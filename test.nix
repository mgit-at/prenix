let
  nixpkgs = import <nixpkgs> {};
  fncs = import ./. nixpkgs;
  flake = builtins.getFlake "github:mgit-at/nixos-common/master";
in
  fncs.prebuildFlake { inherit flake; limitSystem = "x86_64-linux"; }
