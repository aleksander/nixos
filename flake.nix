{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # или stable: "github:nixos/nixpkgs/nixos-25.05"

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    yazi.url = "github:sxyazi/yazi";
    yazi.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    (inputs.import-tree ./modules);

  #outputs = inputs@{ self, nixpkgs, ... }: {
  #  nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
  #    system = "x86_64-linux";
  #    specialArgs = { inherit inputs; };
  #    modules = [ ./configuration.nix ];
  #  };
  #};
}
