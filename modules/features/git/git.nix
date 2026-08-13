# modules/features/git/git.nix
{ ... }: {
  flake.homeModules.git = { pkgs, config, ... }: {
    programs.git = {
      enable = true;
      userName = "Luna Vulperya";
      userEmail = "lunavulperya@gmail.com";

      signing = {
        signByDefault = true;
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      extraConfig = {
        gpg.format = "ssh";
      };
    };

    services.ssh-agent.enable = true;
  };
}
