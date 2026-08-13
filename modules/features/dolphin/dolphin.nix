# modules/features/dolphin/dolphin.nix
{ self, ... }: {
  flake.nixosModules.dolphin = { ... }: {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    security.polkit.enable = true;
  };

  flake.homeModules.dolphin = { pkgs, config, lib, ... }:
    let
      c = self.themeNoHash;

      # Wrap dolphin so KDE platform theming only applies to this process,
      # not the whole niri/Noctalia session.
      dolphin-kde = pkgs.symlinkJoin {
        name = "dolphin-kde-wrapped";
        paths = [ pkgs.kdePackages.dolphin ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/dolphin \
            --set QT_QPA_PLATFORMTHEME kde \
            --set QT_STYLE_OVERRIDE breeze \
            --set QT_QUICK_CONTROLS_STYLE org.kde.desktop
        '';
      };
    in {
      home.packages = with pkgs.kdePackages; [
        dolphin-kde
        breeze          # provides the BreezeDark color scheme file
        breeze-icons
        kio-extras      # trash://, network://, thumbnails, etc.
        knewstuff       # fixes "org.kde.newstuff is not installed" QML error
      ];

      xdg.configFile."menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      home.activation.rebuildKSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
      '';

      # Tell KDE apps (Dolphin included) which color scheme to use
      xdg.configFile."kdeglobals".text = ''
        [General]
        ColorScheme=BreezeDark

        [ColorEffects:Disabled]
        Color=56,56,56
        ColorAmount=0
        ColorEffect=0
        ContrastAmount=0
        ContrastEffect=0
        IntensityAmount=0
        IntensityEffect=0
      '';
    };
}
