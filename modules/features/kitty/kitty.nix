{ ... }: {
  flake.homeModules.kitty = { pkgs, ... }: {
    programs.kitty = {
      enable = true;

      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };

      settings = {
        confirm_os_window_close = 0;
        window_padding_width = 8;

        keybindings = {
          "ctrl+c" = "copy_or_interrupt";
          "ctrl+v" = "paste_from_clipboard";
        };

        # transparency + native compositor blur (kitty 0.46+, niri implements
        # ext-background-effect, so this "just works" on your niri setup)
        background_opacity = "0.75";
        dynamic_background_opacity = true;
      };
    };
  };
}
