{
  description = "Remix template project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, devenv, ... }@inputs: {
    packages = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (system:
      let pkgs = import nixpkgs { inherit system; }; in {
        default = pkgs.buildNpmPackage {
          name = "remix-template-project";
          src = self;
          npmDepsHash = "sha256-GZr3yhmJbxpdQLe7Cly1NrJ+G7mLWTX6nc6FHKeZpGw=";
        };
      }
    );

    devShells = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (system:
      let pkgs = import nixpkgs { inherit system; }; in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              pre-commit.hooks = {
                actionlint.enable = true;
                markdownlint.enable = true;
                shellcheck.enable = true;
                nixpkgs-fmt.enable = true;
                statix.enable = true;
                deadnix.enable = true;
              };
              packages = [
                pkgs.nixpkgs-fmt
              ];
            }
            {
              pre-commit.hooks = {
                eslint.enable = true;
                prettier.enable = true;
              };
              packages = [
                pkgs.nodejs
              ];
            }
          ];
        };
      }
    );
  };
}
