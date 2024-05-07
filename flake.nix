{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    core-flake = {
      url = "git+ssh://git@github.com/purplenoodlesoop/core-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , core-flake
    }:
    let
      core = core-flake.lib;
      name = "reify";
      systemSpecific = { pkgs, toolchains }: {
        devEnv = core.toolchain.devEnv toolchains.dart;
      };
    in
    core.mkFlake {
      inherit name systemSpecific;
    };
}
