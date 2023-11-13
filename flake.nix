{
  description = "Wireproxy Mod build service";

  inputs = {
    upstream.url = "github:tywtyw2002/nix-repo/master";
    nixpkgs.follows = "upstream/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      perSystem =
        { config
        , self'
        , pkgs
        , lib
        , system
        , ...
        }:
        let
          inherit (lib.attrsets) filterAttrs;
          onlySystems = s: avaliableSystems: modules:
            if (builtins.elem s avaliableSystems)
            then modules
            else null;
          mkCrossPackages = crossArch: modulePath:
            let
              localType = lib.lists.last (lib.splitString "-" system);
              crossSystem = "${crossArch}-${localType}";
              crossPkgs = import inputs.nixpkgs {
                localSystem = system;
                crossSystem = crossSystem;
              };
            in
            if (system != crossSystem)
            then crossPkgs.callPackage modulePath { }
            else null;
          allPackages = {
            wireproxy = pkgs.callPackage ./package.nix { };
            wireproxy-musl = onlySystems system [ "x86_64-linux" "aarch64-linux" ] (pkgs.callPackage ./package-musl.nix { });
            wireproxy-cross-aarch64 = mkCrossPackages "aarch64" ./package.nix;
          };
        in
        {
          packages = filterAttrs (n: v: v != null) allPackages;
        };
    };
}
