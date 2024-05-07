{ pkgs }: with pkgs; writeShellApplication {
  name = "develop";
  runtimeInputs = [
    dart
    nodePackages_latest.live-server
  ];
  text = ''
    (trap 'kill 0' SIGINT; dart \
      --enable-vm-service \
      packages/generator/bin/generator.dart \
      --root=./site \
      --watch \
      --mode=local \
      --path=./site/input \
      --path=./lib & \
    live-server ./site/output & wait)
  '';
}
