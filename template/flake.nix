{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    core-flake = {
      url = "github:purplenoodlesoop/core-flake/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    reify = {
      url = "github:purplenoodlesoop/reify/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , core-flake
    , reify
    }:
    let
      core = core-flake.lib;
      name = throw "Undefined name";
      systemSpecific = { pkgs, toolchains }:
        let
          toolchain = toolchains.dart;
          dartDevEnv = core.toolchain.devEnv toolchain;
        in
        {
          shells.default = dartDevEnv;
          apps.watch = reify.build.watch {
            inherit pkgs; bin = "bin/site";
          };
        };
    in
    core.mkFlake {
      inherit name systemSpecific;
    };
}
