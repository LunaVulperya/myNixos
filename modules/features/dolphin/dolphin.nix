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

  flake.homeModules.dolphin = { pkgs, config, ... }:
    let
      c = self.themeNoHash; # your gruvbox base16 palette from theme.nix
    in {
      home.packages = with pkgs.kdePackages; [
        dolphin
        breeze-icons     # icon theme Dolphin expects to find
        kio-extras       # trash://, network://, thumbnails, etc.
        qtstyleplugin-kvantum
      ];

      # Qt platform integration so Dolphin (running outside a Plasma session
      # under niri) actually picks up a KDE-style theme instead of raw Qt defaults
      qt = {
        enable = true;
        platformTheme.name = "kde";
        style.name = "breeze-dark";
      };

      # Custom KDE color scheme generated from your gruvbox palette,
      # installed where Dolphin/Qt looks for named schemes
      xdg.dataFile."color-schemes/Gruvbox.colors".text = ''
        [ColorEffects:Disabled]
        Color=56,56,56
        ColorAmount=0
        ColorEffect=0
        ContrastAmount=0.65
        ContrastEffect=1
        IntensityAmount=0.1
        IntensityEffect=2

        [ColorEffects:Inactive]
        ChangeSelectionColor=true
        Color=112,111,110
        ColorAmount=0.025
        ColorEffect=2
        ContrastAmount=0.1
        ContrastEffect=2
        Enable=false
        IntensityAmount=0
        IntensityEffect=0

        [Colors:Button]
        BackgroundNormal=${c.base01}
        ForegroundNormal=${c.base05}
        DecorationFocus=${c.base09}
        DecorationHover=${c.base0A}

        [Colors:Selection]
        BackgroundNormal=${c.base09}
        ForegroundNormal=${c.base00}

        [Colors:View]
        BackgroundNormal=${c.base00}
        ForegroundNormal=${c.base05}
        ForegroundInactive=${c.base03}
        ForegroundLink=${c.base0D}
        ForegroundVisited=${c.base0E}
        ForegroundNegative=${c.base08}
        ForegroundPositive=${c.base0B}
        ForegroundNeutral=${c.base0A}

        [Colors:Window]
        BackgroundNormal=${c.base01}
        ForegroundNormal=${c.base05}
        ForegroundInactive=${c.base03}

        [Colors:Tooltip]
        BackgroundNormal=${c.base01}
        ForegroundNormal=${c.base06}

        [General]
        ColorScheme=Gruvbox
        Name=Gruvbox
        shadeSortColumn=true

        [KDE]
        contrast=4
      '';

      # Tell Dolphin/Qt apps to actually use this scheme
      xdg.configFile."kdeglobals".text = ''
        [General]
        ColorScheme=Gruvbox

        [Icons]
        Theme=breeze-dark
      '';
    };
}
