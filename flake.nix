{
  description = "Mycelium Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            dart
            cocoapods
          ];

          shellHook = ''
            export PATH="/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
            export ANDROID_HOME="$HOME/Library/Android/sdk"
            unset CC CXX LD AR AS RANLIB STRIP SDKROOT
            echo "Welcome to the Mycelium development environment!"
            echo "Flutter and Dart are now available in your PATH."
          '';
        };
      });
}
