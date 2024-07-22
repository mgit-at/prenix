{ pkgs, lib, ... }: rec {
  # gets drv and all outputs for derivation
  aggregateDrvAndResults = { name, drv ? true, output ? true }: list: pkgs.releaseTools.aggregate {
    inherit name;
    constituents = lib.concatMap (d:
      (if drv then [ d.drvPath ] else []) ++
      (if output then (map (o: d.${o}) d.outputs) else [])
    ) list;
  };

  # gets all: packages.*.*, nixosConfigurations.*.config.system.build.toplevel
  extractFromFlake = { flake, limitSystem ? null, gatherExtraFnc ? null }:
  let
    # TODO: generify getting system so we can re-use for devShell, apps, etc
    # TODO: add prebuildExtra or similar key to expose other things for build
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

  prebuildFlake = { flake, limitSystem ? null, build ? true }: let
    extracted = extractFromFlake { inherit flake limitSystem; };
  in
    aggregateDrvAndResults {
      name = "pre";
      drv = true;
      output = true;
    } extracted;
}
