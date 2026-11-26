{ ... }: {
  flake.modules.home-manager.git = {
    home.file.".gitconfig.default".text = ''
      [user]
        email = "11753516+pedro-pereira-dev@users.noreply.github.com"
        signingkey = "B1B18907C404F134"
    '';
    home.file.".gitconfig.mercedes".text = ''
      [user]
        email = "pedro.pereira@mercedes-benz.com"
        signingkey = "23440B98CDDDA9F3"
    '';
    programs.git = {
      enable = true;
      settings = {
        commit.gpgsign = true;
        push = {
          autoSetupRemote = true;
          default = "current";
        };
        url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
        user.name = "Pedro Pereira";
      };
      includes = [
        { path = "~/.gitconfig.default"; }
        {
          condition = "gitdir:~/workspace/work/";
          path = "~/.gitconfig.mercedes";
        }
      ];
    };
  };
}
