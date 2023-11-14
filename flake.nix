{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-proto.url = "github:notalltim/nix-proto";
    nix-proto.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs = { self, nixpkgs, flake-utils, nix-proto, ... }@inputs:
    let
      namespace_meta = nix-proto.generateMeta {
        name = "name";
        dir = ./proto;
        version = "1.0.0";
        protoDeps = [ ];
        namespace = "outer/inner/namespaced";
      };
      meta = nix-proto.generateMeta {
        name = "upstream";
        dir = ./proto;
        version = "1.0.0";
        protoDeps = [ namespace_meta ];
      };
      overlays = nix-proto.generateOverlays { metas = [ meta namespace_meta ]; };
    in
    { inherit overlays; inherit meta; inherit namespace_meta; } // flake-utils.lib.eachDefaultSystem (system: rec
    {
      legacyPackages = import nixpkgs { inherit system; inherit overlays; };
    });
}
