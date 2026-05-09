{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb = {
          layout  = "us,ru";
          options = "grp:caps_toggle,compose:ralt,ctrl:nocaps";
        };

        input.touchpad = {
          tap = _:{};
          natural-scroll = _:{};
        };

        hotkey-overlay.skip-at-startup = _:{};

        layout = {
          gaps = 2;
          default-column-width.proportion = 0.5;
        };

        binds = {
          "Mod+Shift+Slash".show-hotkey-overlay = _:{};
          "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          "Mod+B".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call bluetooth toggle";
          "Super+Alt+L".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
          "XF86AudioRaiseVolume".spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0"];
          "XF86AudioLowerVolume".spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
          "XF86AudioMute".spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
          "XF86AudioMicMute".spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
          "XF86AudioPlay".spawn = ["playerctl play-pause"];
          "XF86AudioStop".spawn = ["playerctl stop"];
          "XF86AudioPrev".spawn = ["playerctl previous"];
          "XF86AudioNext".spawn = ["playerctl next"];
          "XF86MonBrightnessUp".spawn = ["brightnessctl" "--class=backlight" "set" "+10%"];
          "XF86MonBrightnessDown".spawn = ["brightnessctl" "--class=backlight" "set" "10%-"];

          "Mod+O".toggle-overview        = _:{};
          "Mod+Q".close-window           = _:{};
      
          "Mod+Left".focus-column-left   = _:{};
          "Mod+Down".focus-window-down   = _:{};
          "Mod+Up".focus-window-up       = _:{};
          "Mod+Right".focus-column-right = _:{};
          "Mod+H".focus-column-left      = _:{};
          "Mod+J".focus-window-down      = _:{};
          "Mod+K".focus-window-up        = _:{};
          "Mod+L".focus-column-right     = _:{};
      
          "Mod+Ctrl+Left".move-column-left   = _:{};
          "Mod+Ctrl+Down".move-window-down   = _:{};
          "Mod+Ctrl+Up".move-window-up       = _:{};
          "Mod+Ctrl+Right".move-column-right = _:{};
          "Mod+Ctrl+H".move-column-left      = _:{};
          "Mod+Ctrl+J".move-window-down      = _:{};
          "Mod+Ctrl+K".move-window-up        = _:{};
          "Mod+Ctrl+L".move-column-right     = _:{};

          "Mod+R".switch-preset-column-width = _:{};
          "Mod+F".maximize-column            = _:{};
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
        };
      };
    };
  };
}
