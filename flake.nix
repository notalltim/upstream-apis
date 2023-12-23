{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-proto.url = "github:notalltim/nix-proto";
    nix-proto.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, nix-proto, ... }@inputs:
    let
      namespace_meta_drv = nix-proto.mkProtoDerivation {
        name = "name_stuff";
        src = nix-proto.lib.srcFromNamespace { root = ./proto; namespace = "outer/inner/namespaced"; };
        version = "1.0.0";
        protoDeps = [ ];
      };
      meta_drv = { name_stuff }: nix-proto.mkProtoDerivation {
        name = "upstream";
        src = nix-proto.lib.srcFromNamespace { root = ./proto; namespace = "upstream/v1"; };
        version = "1.0.0";
        protoDeps = [ name_stuff ];
      };
      overlays = nix-proto.generateOverlays' { name_stuff = namespace_meta_drv; upstream = meta_drv; };
    in
    { inherit overlays; } // flake-utils.lib.eachDefaultSystem (system: rec
    {
      legacyPackages = import nixpkgs { inherit system; overlays = nix-proto.lib.overlayToList overlays; };
    });
}
