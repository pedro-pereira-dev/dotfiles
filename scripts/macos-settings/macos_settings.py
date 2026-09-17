#!/usr/bin/env python3
"""Shared snapshot, comparison, filtering, and desired-state helpers."""

from __future__ import annotations

import base64
import datetime as dt
import fnmatch
import json
import os
from pathlib import Path
import tempfile
from typing import Any, Iterable


HERE = Path(__file__).resolve().parent
REPOSITORY = HERE.parents[1]
SNAPSHOTS = HERE / "snapshots"
FILTERS = HERE / "filters.json"
DESIRED = REPOSITORY / ".chezmoidata" / "macos-settings.yaml"
MISSING = object()
TAG = "__macos_settings_type__"


def encode_plist(value: Any) -> Any:
    if isinstance(value, bytes):
        return {TAG: "bytes", "base64": base64.b64encode(value).decode("ascii")}
    if isinstance(value, dt.datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=dt.timezone.utc)
        value = value.astimezone(dt.timezone.utc)
        return {TAG: "datetime", "value": value.isoformat().replace("+00:00", "Z")}
    if isinstance(value, dict):
        return {str(key): encode_plist(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [encode_plist(item) for item in value]
    if value is None or isinstance(value, (bool, int, float, str)):
        return value
    raise TypeError(f"unsupported plist value: {type(value).__name__}")


def atomic_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode & 0o777 if path.exists() else 0o644
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    except BaseException:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass
        raise


def resolve_snapshots(refs: list[str]) -> tuple[Path, Path]:
    if len(refs) not in (0, 2):
        raise ValueError("provide either no snapshot references or exactly two")
    if not refs:
        snapshots = sorted(SNAPSHOTS.glob("*.json"))
        if len(snapshots) < 2:
            raise ValueError("at least two snapshots are required")
        return snapshots[-2], snapshots[-1]
    return resolve_snapshot(refs[0]), resolve_snapshot(refs[1])


def resolve_snapshot(ref: str) -> Path:
    supplied = Path(ref).expanduser()
    candidates = [supplied]
    if not supplied.is_absolute():
        candidates.append(SNAPSHOTS / supplied)
    if supplied.suffix != ".json":
        candidates.extend(path.with_suffix(".json") for path in list(candidates))
    for candidate in candidates:
        if candidate.is_file():
            return candidate.resolve()
    raise ValueError(f"snapshot not found: {ref}")


def load_snapshot(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        scopes = data["scopes"]
        if not isinstance(scopes, dict):
            raise TypeError
        return data
    except (OSError, json.JSONDecodeError, KeyError, TypeError) as error:
        raise ValueError(f"invalid snapshot {path}: {error}") from error


def value_type(value: Any) -> str:
    if value is MISSING:
        return "missing"
    if isinstance(value, dict) and value.get(TAG) in ("bytes", "datetime"):
        return value[TAG]
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int):
        return "int"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict):
        return "dictionary"
    return type(value).__name__


def changes(old: dict[str, Any], new: dict[str, Any]) -> list[dict[str, Any]]:
    result = []
    old_scopes = old.get("scopes", {})
    new_scopes = new.get("scopes", {})
    for scope in sorted(set(old_scopes) | set(new_scopes)):
        old_domains = old_scopes.get(scope, {})
        new_domains = new_scopes.get(scope, {})
        for domain in sorted(set(old_domains) | set(new_domains)):
            old_values = old_domains.get(domain, {})
            new_values = new_domains.get(domain, {})
            for key in sorted(set(old_values) | set(new_values)):
                before = old_values.get(key, MISSING)
                after = new_values.get(key, MISSING)
                if before != after:
                    result.append({
                        "scope": scope,
                        "domain": domain,
                        "key": key,
                        "old": before,
                        "new": after,
                    })
    return result


def load_filters() -> dict[str, Any]:
    try:
        data = json.loads(FILTERS.read_text(encoding="utf-8"))
        if not isinstance(data.get("keyGlobs", []), list):
            raise TypeError("keyGlobs must be a list")
        if not isinstance(data.get("types", []), list):
            raise TypeError("types must be a list")
        if not isinstance(data.get("settings", []), list):
            raise TypeError("settings must be a list")
        return data
    except (OSError, json.JSONDecodeError, TypeError) as error:
        raise ValueError(f"invalid filters file {FILTERS}: {error}") from error


def contains_filtered_type(value: Any, filtered: set[str]) -> bool:
    if isinstance(value, dict):
        if value.get(TAG) in filtered:
            return True
        return any(contains_filtered_type(item, filtered) for item in value.values())
    if isinstance(value, list):
        return any(contains_filtered_type(item, filtered) for item in value)
    return False


def is_filtered(change: dict[str, Any], filters: dict[str, Any]) -> bool:
    key = change["key"].casefold()
    if any(fnmatch.fnmatchcase(key, pattern.casefold()) for pattern in filters.get("keyGlobs", [])):
        return True
    filtered_types = set(filters.get("types", []))
    if any(
        value is not MISSING and contains_filtered_type(value, filtered_types)
        for value in (change["old"], change["new"])
    ):
        return True
    identity = {name: change[name] for name in ("scope", "domain", "key")}
    return identity in filters.get("settings", [])


def filtered_changes(
    old: dict[str, Any], new: dict[str, Any], filters: dict[str, Any] | None
) -> list[dict[str, Any]]:
    result = changes(old, new)
    return result if filters is None else [item for item in result if not is_filtered(item, filters)]


def change_kind(change: dict[str, Any]) -> str:
    if change["old"] is MISSING:
        return "added"
    if change["new"] is MISSING:
        return "removed"
    return "changed"


def render_change(change: dict[str, Any]) -> str:
    before, after = change["old"], change["new"]
    lines = [
        f"{change_kind(change)}: {change['scope']} / {change['domain']} / {change['key']}",
        f"type: {value_type(before)} -> {value_type(after)}",
    ]
    if before is not MISSING:
        lines.append("old: " + json.dumps(before, ensure_ascii=False, indent=2, sort_keys=True))
    if after is not MISSING:
        lines.append("new: " + json.dumps(after, ensure_ascii=False, indent=2, sort_keys=True))
    return "\n".join(lines)


def supported_value(value: Any) -> bool:
    if value is None or isinstance(value, dict):
        return False
    if isinstance(value, (bool, int, float, str)):
        return True
    if isinstance(value, list):
        return all(isinstance(item, (bool, int, float, str)) and item is not None for item in value)
    return False


def load_desired() -> list[dict[str, Any]]:
    if not DESIRED.exists():
        return []
    lines = DESIRED.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "macosSettings:":
        raise ValueError(f"unsupported desired-state format in {DESIRED}")
    records: list[dict[str, Any]] = []
    for number, line in enumerate(lines[1:], 2):
        if not line.strip():
            continue
        if not line.startswith("  - "):
            raise ValueError(f"unsupported desired-state format at {DESIRED}:{number}")
        try:
            record = json.loads(
                line[4:],
                object_pairs_hook=_unique_object,
                parse_constant=lambda value: (_ for _ in ()).throw(ValueError(value)),
            )
        except (json.JSONDecodeError, ValueError) as error:
            raise ValueError(f"invalid JSON object at {DESIRED}:{number}") from error
        _validate_desired(record, number)
        records.append(record)
    return records


def _unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result = {}
    for name, value in pairs:
        if name in result:
            raise ValueError(f"duplicate field: {name}")
        result[name] = value
    return result


def _validate_desired(record: Any, number: int | None = None) -> None:
    location = f" at {DESIRED}:{number}" if number is not None else ""
    if not isinstance(record, dict):
        raise ValueError(f"desired-state record must be an object{location}")
    fields = set(record)
    if fields not in ({"scope", "domain", "key", "value"}, {"scope", "domain", "key", "delete"}):
        raise ValueError(f"invalid desired-state fields{location}")
    if record["scope"] not in ("defaults", "current-host"):
        raise ValueError(f"invalid desired-state scope{location}")
    if any(not isinstance(record[name], str) or not record[name] for name in ("domain", "key")):
        raise ValueError(f"invalid desired-state domain or key{location}")
    if "delete" in record and record["delete"] is not True:
        raise ValueError(f"desired-state delete must be true{location}")
    if "value" in record and not _supported_json_value(record["value"]):
        raise ValueError(f"unsupported desired-state value{location}")


def _supported_json_value(value: Any) -> bool:
    if isinstance(value, float):
        return value == value and value not in (float("inf"), float("-inf"))
    if isinstance(value, (bool, int, str)):
        return True
    if isinstance(value, list):
        return all(_supported_json_value(item) and not isinstance(item, list) for item in value)
    return False


def write_desired(records: Iterable[dict[str, Any]]) -> None:
    records = list(records)
    for record in records:
        _validate_desired(record)
    ordered = sorted(records, key=lambda item: (item["scope"], item["domain"], item["key"]))
    lines = ["macosSettings:"]
    for record in ordered:
        output = {name: record[name] for name in ("scope", "domain", "key")}
        output["delete" if "delete" in record else "value"] = record.get("delete", record.get("value"))
        lines.append("  - " + json.dumps(
            output, ensure_ascii=False, separators=(", ", ": ")
        ))
    atomic_text(DESIRED, "\n".join(lines) + "\n")


def identity(item: dict[str, Any]) -> tuple[str, str, str]:
    return item["scope"], item["domain"], item["key"]
