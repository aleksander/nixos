{ inputs, ... }: {
  flake.nixosModules.yazi = { pkgs, ... }: {
    nixpkgs.overlays = [ inputs.yazi.overlays.default ];
    environment.systemPackages = [ pkgs.yazi ];
  };
}
