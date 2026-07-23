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
          overlays = [
            (final: prev: {
              flutter = 
                let
                  patchedUnwrapped = prev.flutter.unwrapped.overrideAttrs (old: {
                    postPatch = (old.postPatch or "") + ''
                      substituteInPlace packages/flutter_tools/bin/macos_assemble.sh \
                        --replace-fail 'xcode_backend_dart="$(dirname "''${BASH_SOURCE[0]}")/xcode_backend.dart"' 'xcode_backend_dart="$(dirname "''${BASH_SOURCE[0]}")/xcode_backend.dart"
export PATH="${prev.writeShellScriptBin "lipo" ''
#!/bin/sh
for arg in "$@"; do
  if [[ "$arg" == *FlutterMacOS.framework* ]]; then
    chmod -R u+w "$(dirname "$arg")" 2>/dev/null || true
  fi
done
exec /usr/bin/lipo "$@"
''}/bin:$PATH"'
                    '';
                  });
                in prev.flutter.wrapFlutter (patchedUnwrapped.overrideAttrs (old: {
                  passthru = old.passthru // {
                    sdk = patchedUnwrapped;
                  };
                }));
            })
          ];
        };
      in
      let
        lipo-wrapper = pkgs.writeShellScriptBin "lipo" ''
          #!/bin/sh
          for arg in "$@"; do
            if [[ "$arg" == *FlutterMacOS.framework* ]]; then
              chmod -R u+w "$(dirname "$arg")" 2>/dev/null || true
            fi
          done
          exec /usr/bin/lipo "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            dart
            cocoapods
            lipo-wrapper
          ];

          shellHook = ''
            export PATH="${lipo-wrapper}/bin:$PATH"
            export ANDROID_HOME="$HOME/Library/Android/sdk"
            unset CC CXX LD AR AS RANLIB STRIP SDKROOT

            echo "Welcome to the Mycelium development environment!"
            echo "Flutter and Dart are now available in your PATH."
          '';
        };
      });
}
