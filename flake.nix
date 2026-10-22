{
  description = "GitHub Action to install chiplab-cli";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05-small";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "";
    };
  };

  outputs = inputs @ {
    flake-parts,
    make-shell,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        make-shell.flakeModules.default
        ./nix/actionlint.nix
        ./nix/alejandra.nix
        ./nix/deadnix.nix
        ./nix/editorconfig.nix
        ./nix/jj-fix.nix
        ./nix/mdslw.nix
        ./nix/yamllint.nix
      ];

      _module.args.root = ./.;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
}
