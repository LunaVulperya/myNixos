# modules/features/dolphin/dolphin.nix
{ self, ... }: {
  # system-level: Dolphin needs the same trash/mount/polkit plumbing as Thunar.
  # If you're keeping Thunar too, this duplicates thunar.nix's system module —
  # NixOS merges them fine, but you could drop one if you only want one file manager.
  flake.nixosModules.dolphin = { ... }: {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    security.polkit.enable = true;
  };

  flake.homeModules.dolphin = { pkgs, config, lib, ... }:
    let
      c = self.themeNoHash; # your gruvbox base16 palette from theme.nix
    in {
      home.packages = with pkgs.kdePackages; [
        dolphin
        breeze-icons     # icon theme Dolphin expects to find
        kio-extras       # trash://, network://, thumbnails, etc.
        qtstyleplugin-kvantum
      ];

      xdg.configFile."menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      home.activation.rebuildKSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
      '';

      # Qt platform integration so Dolphin (running outside a Plasma session
      # under niri) actually picks up a KDE-style theme instead of raw Qt defaults
     # qt = {
     #   enable = true;
     #  platformTheme.name = "kde";
     #   style.name = "breeze-dark";
     # };

      # Custom KDE color scheme generated from your gruvbox palette,
      # installed where Dolphin/Qt looks for named schemes


      # Tell Dolphin/Qt apps to actually use this scheme

    };
}
