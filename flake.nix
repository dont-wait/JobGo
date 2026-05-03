{
  description = "Flutter 3.13.x";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            buildToolsVersion
            "28.0.3"
          ];
          platformVersions = [
            "34"
            "28"
          ];
          abiVersions = [ "x86_64" ]; # đổi sang x86_64 cho emulator nhanh hơn
          includeEmulator = true; # <-- emulator binary
          includeSystemImages = true; # <-- system image cho AVD
          systemImageTypes = [ "google_apis_playstore" ];
          includeSources = false;
          includeNDK = false;
          cmdLineToolsVersion = "8.0"; # <-- avdmanager, sdkmanager nằm ở đây
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            buildInputs = [
              flutter
              androidSdk # The customized SDK that we've made above
              jdk17
            ];
          };
      }
    );
}
