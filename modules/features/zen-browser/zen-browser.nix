{ inputs, ... }: {
  flake.homeModules.zen-browser = { pkgs, ... }: {
    # use the flake's real Home Manager module (not just the bare package)
    # so it also wires up xdg-mime / default-browser associations for us.
    imports = [ inputs.zen-browser.homeModules.beta ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };
  };
}
