{
  description = "Raylib testing";

  inputs = {
    rootFlake.url = "github:okwilkins/cuda-cpp-llm-learning";
    nixpkgs.follows = "rootFlake/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rootFlake,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        raylib-src = pkgs.fetchFromGitHub {
          owner = "raysan5";
          repo = "raylib";
          rev = "6.0";
          hash = "sha256-8+6MDTMc7Spix4ndAUzp51Q5iWcl7pQmyXuV2RutnOk=";
        };
      in
      {
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            rootFlake.devShells.${system}.default
          ];
          packages = [ raylib-src ];

          shellHook = ''
            ${rootFlake.devShells.${system}.default.shellHook or ""}

            mkdir -p include/raylib
            ln -sfn "${raylib-src}/src/"* include/raylib/

            mkdir -p build
            meson setup build --reconfigure

            ln -sf build/compile_commands.json compile_commands.json
          '';
        };
      }
    );
}
