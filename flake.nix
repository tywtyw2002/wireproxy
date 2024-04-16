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
          sSys = lib.splitString "-" system;
          osType = lib.lists.last sSys;
          archType = builtins.elemAt sSys 0;
          goCrossOverride = mod:
            if (archType != "x86_64")
            then null
            else
              mod.overrideAttrs (old:
                old
                // {
                  GOOS = osType;
                  GOARCH = "arm64";
                });
          allPackages = {
            wireproxy = pkgs.callPackage ./package.nix { };
            # cross pkgs need in host system.
            wireproxy-cross-aarch64 = goCrossOverride (pkgs.callPackage ./package.nix { });
          };
        in
        {
          packages = filterAttrs (n: v: v != null) allPackages;
        };
    };
}
