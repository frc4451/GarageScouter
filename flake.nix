{
  description = "Robotz Garage Scouting App Nix Devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: {
      # For `nix fmt`
      formatter = nixpkgs.legacyPackages.${system}.alejandra;

      devShell = let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [devshell.overlays.default];
        };
      in
        pkgs.devshell.mkShell {
          # Nix is great but most things should go in this toml file so others can easily add things
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];

          env = [
            {
              # Fixes title bar and fat cursor on Wayland
              name = "XDG_DATA_DIRS";
              prefix = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}";
            }
          ];
        };
    });
}
