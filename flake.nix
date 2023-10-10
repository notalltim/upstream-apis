{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    protoGenerator = { url = "git+file:///home/tgallion/dev/proto-test"; };
  };
  outputs = { self, nixpkgs, flake-utils, protoGenerator, ... }@inputs:
    let
      meta = protoGenerator.generateMeta {
        name = "upstream";
        dir = ./proto;
        version = "1.0.0";
        protoDeps = [ ];
      };

      derivations = protoGenerator.generateDerivations { inherit meta; };
      overlays = protoGenerator.generateOverlays { metas = [meta];};
    in
    flake-utils.lib.eachDefaultSystem (system: rec
    {
      legacyPackages = import nixpkgs { inherit system; inherit overlays; };
    });
}
