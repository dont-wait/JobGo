{
  description = "Flutter Full Stack";

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
            android_sdk.accept_license = true; # Chấp nhận bản quyền Android
          };
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ "34.0.0" ];
          platformVersions = [ "34" ];
          abiVersions = [ "x86_64" ];
          includeEmulator = true;
          includeSystemImages = true;
          systemImageTypes = [ "google_apis_playstore" ];
        };

        androidSdk = androidComposition.androidsdk;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            jdk17
            androidSdk
            pkg-config
            ninja
            cmake
            gtk3
            clang
            gcc
            glib
            fontconfig
            libGL
            libX11
            libXext
            libXinerama
            libXcursor
            sysprof
            libXrender
            libXrandr
            libXi
            pcre2
          ];

          shellHook = ''
  export CC="${pkgs.clang}/bin/clang"
  export CXX="${pkgs.clang}/bin/clang++"
  export JAVA_HOME="${pkgs.jdk17.home}"
  export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export LD_LIBRARY_PATH="${pkgs.fontconfig.lib}/lib:${pkgs.libGL}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.glibc}/lib:$LD_LIBRARY_PATH"
  export PKG_CONFIG_PATH="${pkgs.sysprof}/lib/pkgconfig:$PKG_CONFIG_PATH"
  export PATH="${pkgs.ninja}/bin:${pkgs.cmake}/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
  echo "⚡ Android SDK License accepted. Môi trường đã sẵn sàng!"
'';        };
      }
    );
}

