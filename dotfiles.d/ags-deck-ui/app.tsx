import app from "ags/gtk4/app"
import { For, createState } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import style from "./style.scss"

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

type Tile = {
  icon: string
  title: string
  subtitle: string
  run?: () => void
  menu?: Menu
}

type Menu = { title: string; tiles: Tile[] }

let win: Astal.Window

// hides the ui while an external program runs and brings it back afterwards
const launch = (argv: string[]) => () => {
  win.visible = false
  execAsync(argv)
    .catch(() => {})
    .finally(() => (win.visible = true))
}

const power: Menu = {
  title: "Power",
  tiles: [
    {
      icon: "↻",
      title: "Reboot",
      subtitle: "Restart the system",
      run: () => execAsync(["systemctl", "reboot"]),
    },
    {
      icon: "⏻",
      title: "Power off",
      subtitle: "Shut the system down",
      run: () => execAsync(["systemctl", "poweroff"]),
    },
  ],
}

const home: Menu = {
  title: "Home",
  tiles: [
    {
      icon: "🎮",
      title: "Steam",
      subtitle: "Big Picture mode",
      run: launch(["steam", "-tenfoot"]),
    },
    {
      icon: "▶",
      title: "Jellyfin",
      subtitle: "Media library",
      run: launch(["jellyfin-desktop"]),
    },
    {
      icon: "▶",
      title: "Jellyfin MPV Shim",
      subtitle: "Cast to this screen",
      run: launch(["jellyfin-mpv-shim"]),
    },
    {
      icon: "▶",
      title: "Tsukimi",
      subtitle: "Jellyfin client",
      run: launch(["tsukimi"]),
    },
    {
      icon: "▶",
      title: "Delfin",
      subtitle: "Jellyfin client",
      run: launch(["delfin"]),
    },
    {
      icon: "▶",
      title: "Fladder",
      subtitle: "Jellyfin client",
      run: launch(["fladder"]),
    },
    {
      icon: "▶",
      title: "Pelagica",
      subtitle: "Jellyfin client",
      run: launch(["pelagica"]),
    },
    {
      icon: "▶",
      title: "Shadfin",
      subtitle: "Jellyfin client",
      run: launch(["shadfin"]),
    },
    {
      icon: ">_",
      title: "Terminal",
      subtitle: "Open a shell",
      run: launch(["alacritty"]),
    },
    {
      icon: "≋",
      title: "Monitor",
      subtitle: "System resources",
      run: launch(["alacritty", "-e", "btop"]),
    },
    {
      icon: "i",
      title: "About",
      subtitle: "System information",
      run: launch(["alacritty", "--hold", "-e", "fastfetch"]),
    },
    { icon: "⏻", title: "Power", subtitle: "Reboot or power off", menu: power },
  ],
}

function Ui() {
  // each level remembers which tile was selected when it was left
  const [stack, setStack] = createState<{ menu: Menu; selected: number }[]>([
    { menu: home, selected: 0 },
  ])

  const current = stack((s) => s[s.length - 1])
  const title = current((c) => c.menu.title)
  // keeps the selected tile in the middle and rotates the others around it
  const tiles = current((c) => {
    const all = c.menu.tiles
    const count = all.length
    if (count <= 3) {
      return all.map((tile, i) => ({ tile, offset: i - c.selected }))
    }
    const reach = count >= 5 ? 2 : 1
    const out = []
    for (let offset = -reach; offset <= reach; offset++) {
      out.push({ tile: all[(c.selected + offset + count) % count], offset })
    }
    return out
  })

  const select = (delta: number) => {
    const s = stack.get()
    const top = s[s.length - 1]
    const count = top.menu.tiles.length
    const next = (top.selected + delta + count) % count
    setStack([...s.slice(0, -1), { ...top, selected: next }])
  }

  const activate = () => {
    const top = stack.get()[stack.get().length - 1]
    const tile = top.menu.tiles[top.selected]
    if (tile.menu) setStack([...stack.get(), { menu: tile.menu, selected: 0 }])
    else tile.run?.()
  }

  const back = () => {
    if (stack.get().length > 1) setStack(stack.get().slice(0, -1))
  }

  function onKey(_: Gtk.EventControllerKey, keyval: number) {
    switch (keyval) {
      case Gdk.KEY_Left:
      case Gdk.KEY_Up:
        select(-1)
        return true
      case Gdk.KEY_Right:
      case Gdk.KEY_Down:
        select(1)
        return true
      case Gdk.KEY_Return:
      case Gdk.KEY_KP_Enter:
        activate()
        return true
      case Gdk.KEY_Escape:
        back()
        return true
    }
    return false
  }

  return (
    <window
      $={(ref) => (win = ref)}
      visible
      name="ui"
      namespace="ui"
      application={app}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
    >
      <Gtk.EventControllerKey onKeyPressed={onKey} />
      <box orientation={Gtk.Orientation.VERTICAL} vexpand hexpand>
        <label class="title" label={title} halign={Gtk.Align.START} />
        <box
          class="tiles"
          vexpand
          hexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
          spacing={48}
        >
          <For each={tiles}>
            {({ tile, offset }) => (
              <box
                class={offset === 0 ? "tile selected" : "tile"}
                orientation={Gtk.Orientation.VERTICAL}
                valign={Gtk.Align.CENTER}
              >
                <label class="icon" label={tile.icon} vexpand />
                <label class="name" label={tile.title} />
                <label class="subtitle" label={tile.subtitle} />
              </box>
            )}
          </For>
        </box>
        <label
          class="hint"
          label="←↑↓→ navigate    Enter select    Esc back"
          halign={Gtk.Align.CENTER}
        />
      </box>
    </window>
  )
}

app.start({
  css: style,
  gtkTheme: "Adwaita",
  main: Ui,
})
