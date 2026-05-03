{
  description = "Flutter/Dart Development Environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
          abiVersions = [ "x86_64" ]; 
          includeEmulator = true; 
          includeSystemImages = true; 
          systemImageTypes = [ "google_apis_playstore" ];
          includeSources = false;
          includeNDK = false;
          cmdLineToolsVersion = "8.0"; 
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
