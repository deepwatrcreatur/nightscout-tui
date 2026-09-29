{
  description = "High-resolution Unicode terminal monitor for Nightscout CGM telemetry";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nightscout-tui = pkgs.runCommand "nightscout-tui" {
          nativeBuildInputs = [ pkgs.makeWrapper ];
        } ''
          mkdir -p $out/bin
          cp ${./bin/nightscout-tui} $out/bin/nightscout-tui
          chmod +x $out/bin/nightscout-tui
          wrapProgram $out/bin/nightscout-tui \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.python3 ]}
        '';
      in
      {
        packages = {
          default = nightscout-tui;
          nightscout-tui = nightscout-tui;
        };

        apps = {
          default = {
            type = "app";
            program = "${nightscout-tui}/bin/nightscout-tui";
          };
          nightscout-tui = {
            type = "app";
            program = "${nightscout-tui}/bin/nightscout-tui";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.python3
          ];
        };
      }
    ) // {
      nixosModules = {
        default = import ./modules/nixos.nix;
        nightscout-tui = import ./modules/nixos.nix;
      };

      homeManagerModules = {
        default = import ./modules/home-manager.nix;
        nightscout-tui = import ./modules/home-manager.nix;
      };
    };
}
