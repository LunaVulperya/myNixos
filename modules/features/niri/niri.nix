{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  flake.wrappersModules.niri = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
    };
    options.fileManager = lib.mkOption {
      type = lib.types.str;
      default = "dolphin";
    };
    options.browser = lib.mkOption {
      type = lib.types.str;
      default = "firefox";
    };
    config = {
      settings = let
        noctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.myNoctalia;
      in {
        prefer-no-csd = {};


        input = {
          focus-follows-mouse = {};

          keyboard = {
            xkb = {
              layout = "br";
              variant = "nodeadkeys";
              options = "caps:escape";
            };
            repeat-rate = 40;
            repeat-delay = 250;
          };

          touchpad = {
            natural-scroll = {};
            tap = {};
          };

          mouse = {
            accel-profile = "flat";
          };
        };

        binds = {
          # --- App launchers (end4-style) ---
          "Mod+Return".spawn = config.terminal;
          "Mod+E".spawn = config.fileManager;
          "Mod+W".spawn = config.browser;

          # --- Window management ---
          "Mod+Q".close-window = {};
          "Mod+F".maximize-column = {};
          "Mod+G".fullscreen-window = {};
          "Mod+Shift+F".toggle-window-floating = {};
          "Mod+C".center-column = {};

          "Mod+H".focus-column-left = {};
          "Mod+L".focus-column-right = {};
          "Mod+K".focus-window-up = {};
          "Mod+J".focus-window-down = {};

          "Mod+Left".focus-column-left = {};
          "Mod+Right".focus-column-right = {};
          "Mod+Up".focus-window-up = {};
          "Mod+Down".focus-window-down = {};

          "Mod+Shift+H".move-column-left = {};
          "Mod+Shift+L".move-column-right = {};
          "Mod+Shift+K".move-window-up = {};
          "Mod+Shift+J".move-window-down = {};

          # --- Workspaces ---
          "Mod+1".focus-workspace = "w0";
          "Mod+2".focus-workspace = "w1";
          "Mod+3".focus-workspace = "w2";
          "Mod+4".focus-workspace = "w3";
          "Mod+5".focus-workspace = "w4";
          "Mod+6".focus-workspace = "w5";
          "Mod+7".focus-workspace = "w6";
          "Mod+8".focus-workspace = "w7";
          "Mod+9".focus-workspace = "w8";
          "Mod+0".focus-workspace = "w9";

          "Mod+Shift+1".move-column-to-workspace = "w0";
          "Mod+Shift+2".move-column-to-workspace = "w1";
          "Mod+Shift+3".move-column-to-workspace = "w2";
          "Mod+Shift+4".move-column-to-workspace = "w3";
          "Mod+Shift+5".move-column-to-workspace = "w4";
          "Mod+Shift+6".move-column-to-workspace = "w5";
          "Mod+Shift+7".move-column-to-workspace = "w6";
          "Mod+Shift+8".move-column-to-workspace = "w7";
          "Mod+Shift+9".move-column-to-workspace = "w8";
          "Mod+Shift+0".move-column-to-workspace = "w9";

          # --- Quickshell/noctalia UI (end4-style panel toggles) ---
          #"Mod+S".spawn-sh = "${noctaliaExe} ipc call launcher toggle";
          "Mod+Tab".toggle-overview = {};
          "Mod+Slash".show-hotkey-overlay = {};

          # verify these panel names against your actual noctalia settings —
          # they mirror the working bluetooth/wifi pattern below but are unconfirmed
          "Mod+S".spawn-sh = "${noctaliaExe} msg panel-toggle launcher";
          "Mod+A".spawn-sh = "${noctaliaExe} msg panel-toggle control-center";  # wifi, bluetooth, notifications all live here now
          "Ctrl+Alt+Delete".spawn-sh = "${noctaliaExe} msg panel-toggle session";

          # --- Clipboard history (end4: Super+V) ---
          "Mod+V".spawn-sh = "${lib.getExe config.pkgs.cliphist} list | ${lib.getExe config.pkgs.fuzzel} --dmenu | ${lib.getExe config.pkgs.cliphist} decode | ${config.pkgs.wl-clipboard}/bin/wl-copy";

          # moved from Mod+V — mic mute toggle now lives here
          "Mod+Shift+V".spawn-sh = "${noctaliaExe} msg mic-mute";

          # --- Media & hardware keys ---
          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86AudioPlay".spawn-sh = "${lib.getExe config.pkgs.playerctl} play-pause";
          "XF86AudioNext".spawn-sh = "${lib.getExe config.pkgs.playerctl} next";
          "XF86AudioPrev".spawn-sh = "${lib.getExe config.pkgs.playerctl} previous";

          "XF86MonBrightnessUp".spawn-sh = "${lib.getExe config.pkgs.brightnessctl} set +5%";
          "XF86MonBrightnessDown".spawn-sh = "${lib.getExe config.pkgs.brightnessctl} set 5%-";

          # --- Column/window resizing ---
          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";

          "Mod+WheelScrollDown".focus-column-left = {};
          "Mod+WheelScrollUp".focus-column-right = {};
          "Mod+Ctrl+WheelScrollDown".focus-workspace-down = {};
          "Mod+Ctrl+WheelScrollUp".focus-workspace-up = {};

          # --- Screenshots / screen recording (end4-style) ---
          "Print".spawn-sh = "${lib.getExe config.pkgs.grim} - | ${config.pkgs.wl-clipboard}/bin/wl-copy";

          "Mod+Ctrl+S".spawn-sh = ''${lib.getExe config.pkgs.grim} -l 0 - | ${config.pkgs.wl-clipboard}/bin/wl-copy'';

          "Mod+Shift+E".spawn-sh = ''${config.pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe config.pkgs.swappy} -f -'';

          "Mod+Shift+S".spawn-sh = lib.getExe (config.pkgs.writeShellApplication {
            name = "screenshot";
            text = ''
              ${lib.getExe config.pkgs.grim} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" - \
              | ${config.pkgs.wl-clipboard}/bin/wl-copy
            '';
          });

          "Mod+Shift+C".spawn-sh = "${lib.getExe config.pkgs.hyprpicker} -a";

          # requires wf-recorder in your packages
          "Mod+Shift+R".spawn-sh = lib.getExe (config.pkgs.writeShellApplication {
            name = "screenrecord";
            text = ''
              ${lib.getExe config.pkgs.wf-recorder} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" -f "$HOME/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4"
            '';
          });

          # --- Lock screen ---
          "Mod+Escape".spawn-sh = "${lib.getExe config.pkgs.swaylock} -f";
          #"Mod+Shift+B".spawn-sh = "${noctaliaExe} ipc call bluetooth togglePanel";
          #"Mod+Shift+W".spawn-sh = "${noctaliaExe} ipc call wifi togglePanel";
        };

        layout = {
          gaps = 5;

          focus-ring = {
            width = 2;
            active-color = "#${self.themeNoHash.base09}";
          };
        };

        window-rules = [
          {
            draw-border-with-background = false;
            geometry-corner-radius = 12;
            clip-to-geometry = true;
          }
        ];

        workspaces = let
          settings = {layout.gaps = 5;};
        in {
          "w0" = settings;
          "w1" = settings;
          "w2" = settings;
          "w3" = settings;
          "w4" = settings;
          "w5" = settings;
          "w6" = settings;
          "w7" = settings;
          "w8" = settings;
          "w9" = settings;
        };

        xwayland-satellite.path =
          lib.getExe config.pkgs.xwayland-satellite;

        spawn-at-startup =
          [ noctaliaExe ];
      };
    };
  };

  perSystem = {pkgs, ...}: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
    };
  };
}
