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
      lib.build.watch = { pkgs, bin }: with pkgs; writeShellApplication {
        name = "watch";
        runtimeInputs = [
          dart
          nodePackages_latest.live-server
        ];
        text = ''
          (trap 'kill 0' SIGINT; dart \
            --enable-vm-service \
            ${bin}.dart \
            --root=./site \
            --watch \
            --mode=local \
            --path=./site/input \
            --path=./lib & \
          live-server ./site/output & wait)
        '';
      };
    };
}
