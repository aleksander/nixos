# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, pkgs, inputs, ... }: {
  flake.nixosModules.laptopConfiguration = { pkgs, lib, ... }: {
  imports = [ # Include the results of the hardware scan.
    #./hardware-configuration.nix
    self.nixosModules.myMachineHardware
    self.nixosModules.niri
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  #nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  hardware.bluetooth.enable = true;
  #services.blueman.enable = true;

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #boot.tmp.useTmpfs = true;
  #boot.tmp.tmpfsSize = "8G";

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16*1024; # 16 GB
  }];

  networking.hostName = "laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;

  # Enable the COSMIC login manager
  #services.displayManager.cosmic-greeter.enable = true;
  # Enable the COSMIC desktop environment
  #services.desktopManager.cosmic.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us,ru";
    #variant = "";
    #xkb.options = "terminate:ctrl_alt_bksp,grp:caps_toggle";
  };

/*
  programs = {
    dconf = {
      profiles = {
        user = {
          databases = [
            {
              # Disallow changing the input settings in Control Center since unlike with NixOS options,
              # there is no merging between databases and user-db would just replace this.
              lockAll = true;
              settings = {
                "org/gnome/desktop/wm/keybindings" = {
                  switch-input-source = [ "CapsLock" ];
                  #switch-input-source-backward = [ "<Shift><Alt>Tab" ];
                };

                "org/gnome/desktop/input-sources" = {
                  sources = [
                    (lib.gvariant.mkTuple [
                      "xkb"
                      "us"
                    ])
                    (lib.gvariant.mkTuple [
                      "xkb"
                      "ru"
                    ])
                  ];
                };
              };
            }
          ];
        };
      };
    };
  };
*/

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  #hardware.pulseaudio.enable = true;

  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.soos = {
    isNormalUser = true;
    description = "soos";
    extraGroups = [ "networkmanager" "wheel" "dialout" "input" ];
    packages = with pkgs; [
    #  thunderbird
      telegram-desktop
    ];
    shell = pkgs.fish;
    #TODO: use one of *Password* options to declaratively set password 
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "soos";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox = {
    enable = true;
    languagePacks = [ "ru" "en-US" ];

    policies = {
      # Extensions
      ExtensionSettings = let
        moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
      in {
        #"*".installation_mode = "blocked";
  
  	#TODO: add translation extension

        #TODO: config custom server at vaw.salvian.ru
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url       = moz "bitwarden";
          installation_mode = "force_installed";
          #updates_disabled  = true;
        };

	"uBlock0@raymondhill.net" = {
          install_url       = moz "ublock-origin";
          installation_mode = "force_installed";
          #updates_disabled  = true;
        };
      };
  
      /* ---- PREFERENCES ---- */
      # Check about:config for options.
      Preferences = {
      	# start from previously opened tabs
        "browser.startup.page" = 3;
      };
    };

#    profiles.default.search = {
#	    force           = true;
#	    default         = "DuckDuckGo";
#	    privateDefault  = "DuckDuckGo";
#
#	    engines = {
#		    "Nix Packages" = {
#			    urls = [
#			    {
#				    template = "https://search.nixos.org/packages";
#				    params = [
#				    { name = "channel"; value = "unstable"; }
#				    { name = "query";   value = "{searchTerms}"; }
#				    ];
#			    }
#			    ];
#			    icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
#			    definedAliases = [ "@np" ];
#		    };
#
#		    "Nix Options" = {
#			    urls = [
#			    {
#				    template = "https://search.nixos.org/options";
#				    params = [
#				    { name = "channel"; value = "unstable"; }
#				    { name = "query";   value = "{searchTerms}"; }
#				    ];
#			    }
#			    ];
#			    icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
#			    definedAliases = [ "@no" ];
#		    };
#
#		    "NixOS Wiki" = {
#			    urls = [
#			    {
#				    template = "https://wiki.nixos.org/w/index.php";
#				    params = [
#				    { name = "search"; value = "{searchTerms}"; }
#				    ];
#			    }
#			    ];
#			    icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
#			    definedAliases = [ "@nw" ];
#		    };
#	    };
#    };
  };

  programs.fish.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    neovim
    mpv
    qbittorrent
    git
    fish
    #TODO: setup laptop vpn config at vip.salvian.ru (user-configuration.nix? hardware-configuration.nix?)
    #v2rayn
    v2raya
    #v2ray-geoip
    xray
    tree
    file
    gnumake
    gcc
    ripgrep
    clang
    clang-tools
    #cinnamon-menus
    #cinnamon-session
    #cinnamon-desktop
    #cinnamon-screensaver
    #cinnamon-translations
    #cinnamon-control-center
    #cinnamon-settings-daemon
    #nemo
    #nemo-preview
    google-chrome
    wireguard-tools
    alacritty
    fuzzel		# \
    #waybar		# | for raw niri
    xwayland-satellite	# |
    #brightnessctl	# /
    imv			# image viewer
    noctalia-qs
    noctalia-shell
    amnezia-vpn
    nh
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome		# font for waybar (maybe we can use nerd-fonts.jetbrains-mono?)
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  #programs.neovim.enable = true;
  #FIXME: doesn't work without 'enable=true', but then we have to declaratively configure .config/nvim
  programs.neovim.vimAlias = true;

  programs.niri.enable = true;

  programs.amnezia-vpn.enable = true;

  # List services that you want to enable:
  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ 5201 ];
  #networking.firewall.allowedUDPPorts = [ 5201 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Automatic updating
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # Automatic cleanup
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";
  nix.settings.auto-optimise-store = true;
  };

}
