# modules/features/cursor/cursor.nix
{ ... }: {
  flake.homeModules.cursor = { pkgs, ... }: {
    home.pointerCursor = {
    enable = true;
      name = "kuro_cursor";
      size = 32;
      gtk.enable = true;
      x11.enable = true;

      package = pkgs.runCommand "kuro_cursor" {} ''
        mkdir -p $out/share/icons
        cp -r ${./kuro_cursor} $out/share/icons/kuro_cursor
      '';
    };
  };
}
