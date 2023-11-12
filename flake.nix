{
  description = "Wireproxy Mod build service";

  inputs = {
    upstream.url = "github:tywtyw2002/nix-repo/master";
  };

  outputs = { upstream, ... }:
    let
      nixpkgs = upstream.inputs.nixpkgs;
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = allSystems: f: nixpkgs.lib.genAttrs allSystems (system: f system);
      forAllSystems = forEachSystem allSystems;
    in
    {
      packages = forAllSystems (
        cSystem:
        with nixpkgs.lib; let
            systemType = lists.last (splitString "-" cSystem);
            crossSystems = (filter (sys: (sys != cSystem) && (strings.hasSuffix systemType sys)) allSystems);
        in
        builtins.listToAttrs
          (nixpkgs.lib.forEach crossSystems
            (
              system:
              let
                crossPkgs = import nixpkgs {
                  localSystem = cSystem;
                  crossSystem = system;
                };
              in
              {
                name = "wireproxy-cross-${system}";
                value = crossPkgs.callPackage ./package.nix { };
              }
            ))
        // (
          let
            pkgs = import nixpkgs { system = cSystem; };
          in
          {
            wireproxy = pkgs.callPackage ./package.nix { };
            wireproxy-musl = pkgs.callPackage ./package-musl.nix { };
          }
        )
      );
    };
}
