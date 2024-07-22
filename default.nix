{ pkgs, lib, ... }: rec {
  # gets drv and all outputs for derivation
  aggregateDrvAndResults = name: list: pkgs.releaseTools.aggregate {
    inherit name;
    constituents = lib.concatMap (drv:
      [ drv.drvPath ] ++
      (map (o: drv.${o}) drv.outputs)
    ) list;
  };

  # gets all: packages.*.*, nixosConfigurations.*.config.system.build.toplevel
  extractFromFlake = { flake, limitSystem ? null, extra ? null }:
  let
    # TODO: generify getting system so we can re-use for devShell, apps, etc
    pkgs = if flake ? "packages" then
      (let
        systems =
          if limitSystem != null then (if flake.packages ? limitSystem then [ limitSystem ] else [])
          else builtins.attrNames flake.packages;
      in
        lib.concatMap (system: builtins.attrValues flake.packages.${system}) systems)
    else [];
    configs = if flake ? "nixosConfigurations" then
      map (nixos: nixos.config.system.build.toplevel) (builtins.attrValues flake.nixosConfigurations)
    else [];
  in
    pkgs ++ configs;

  prebuildFlake = { flake, limitSystem ? null }: let
    extracted = extractFromFlake { inherit flake limitSystem; };
  in
    aggregateDrvAndResults "pre" extracted;
}
