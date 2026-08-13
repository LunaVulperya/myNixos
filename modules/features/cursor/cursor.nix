# modules/features/cursor/cursor.nix
{ ... }: {
  flake.homeModules.cursor = { config, ... }: {
    # Symlinks your unpacked cursor folder into ~/.local/share/icons
    xdg.dataFile."icons/MyCursorTheme".source = ./MyCursorTheme;

    home.pointerCursor = {
      name = "kuro_cursor";
      size = 32;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
