{
  description = "Helper to pre-evaulate and pre-build nix(os) derivations";

  inputs = {};

  outputs = { self }: {
    lib = rec {
      main = nixpkgs: import ./default.nix nixpkgs;
      prebuildForSystem = flake: system: let
        fncs = main {
          lib = flake.inputs.nixpkgs.lib;
          pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
        };
      in
        fncs.prebuildFlake { inherit flake; limitSystem = system; };
    };
  };
}
