{
  description = "Flutter Full Stack for NixOS - Optimized for Emulator";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            "34.0.0"
            "30.0.3"
          ];
          platformVersions = [
            "34"
            "33"
          ];
          abiVersions = [
            "x86_64"
            "arm64-v8a"
          ];
          includeEmulator = true;
          includeSystemImages = true;
          systemImageTypes = [ "google_apis_playstore" ];
        };
        androidSdk = androidComposition.androidsdk;

        emulatorLibs = with pkgs; [
          pulseaudio
          libpulseaudio
          alsa-lib
          libGL
          libGLU
          mesa
          libX11
          libxcb
          libXext
          libXrender
          libXi
          libXtst
          libXrandr
          libXfixes
          libxkbfile
          xcbutilcursor
          zlib
          stdenv.cc.cc.lib
          nss
          nspr
          dbus
          expat
          systemd
          libpng
          libbsd
          libdrm
          libxkbcommon 
          libxcb
          xcbutil
          xcbutilimage 
          xcbutilkeysyms 
          xcbutilwm 
          xcbutilcursor
          xcbutilrenderutil 
          libSM 
          libICE 
          libxkbcommon 
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              flutter
              dart
              jdk17
              androidSdk
              pkg-config
              ninja
              cmake
              gtk3
              clang
              gcc
              glib
            ]
            ++ emulatorLibs;

          shellHook = ''
                                    export JAVA_HOME="${pkgs.jdk17.home}"
                                    export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
                                    export ANDROID_SDK_ROOT="$ANDROID_HOME"

                                    # Shim cho cmdline-tools
                                    mkdir -p .android-sdk-shim/cmdline-tools/latest
                                    ln -sfT "$ANDROID_HOME/cmdline-tools/bin"              .android-sdk-shim/cmdline-tools/latest/bin
                                    ln -sfT "$ANDROID_HOME/cmdline-tools/lib"              .android-sdk-shim/cmdline-tools/latest/lib
                                    ln -sfT "$ANDROID_HOME/cmdline-tools/source.properties" .android-sdk-shim/cmdline-tools/latest/source.properties

                                    export PATH="$PWD/.android-sdk-shim/cmdline-tools/latest/bin:$PATH"
                                    export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

            export LD_LIBRARY_PATH="\
            $HOME/Downloads/emulator:\
            $HOME/Downloads/emulator/lib64:\
            $HOME/Downloads/emulator/lib64/qt/libs:\
            $HOME/Downloads/emulator/lib64/qt/plugins/platforms:\
            ${pkgs.lib.makeLibraryPath emulatorLibs}:\
            $LD_LIBRARY_PATH"                        export NIX_LD=$(cat "${pkgs.stdenv.cc}/nix-support/dynamic-linker")
                                    export NIX_LD_LIBRARY_PATH="/run/current-system/sw/share/nix-ld/lib"

                                    echo "✅ Flutter dev shell ready!"
                                    echo "   ANDROID_HOME : $ANDROID_HOME"
                                    echo "   LD_LIBRARY_PATH set for emulator"
          '';
        };
      }
    );
}
