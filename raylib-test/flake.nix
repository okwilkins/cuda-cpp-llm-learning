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

        asio-src = pkgs.fetchFromGitHub {
          owner = "chriskohlhoff";
          repo = "asio";
          rev = "asio-1-38-0";
          hash = "sha256-pkSu8XMibmRPMoS3v5hO34oJb077bYc9KWELj3t8D6M=";
        };
      in
      {
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            rootFlake.devShells.${system}.default
          ];
          nativeBuildInputs = [
            pkgs.pkg-config
            raylib-src
            asio-src
          ];
          buildInputs = [
            pkgs.libGL
            pkgs.glfw

            # Wayland dependencies
            pkgs.wayland.dev
            pkgs.wayland
            pkgs.libxkbcommon.dev
            pkgs.libxkbcommon

            # X11 dependencies
            pkgs.xorg.libX11.dev
            pkgs.xorg.libXrandr.dev
            pkgs.xorg.libXi.dev
            pkgs.xorg.libXcursor.dev
            pkgs.xorg.libXinerama.dev
            pkgs.libglvnd.dev
          ];
          shellHook = ''
            ${rootFlake.devShells.${system}.default.shellHook or ""}

            mkdir -p extern/raylib extern/asio

            ln -sfn "${raylib-src}/src/"* extern/raylib
            ln -sfn "${asio-src}/asio"* extern/asio/include
            ln -sfn "${asio-src}/include"* extern/asio

            mkdir -p build
            meson setup build --reconfigure

            ln -sf build/compile_commands.json compile_commands.json

            export PKG_CONFIG_PATH="${pkgs.glfw}/lib/pkgconfig:$PKG_CONFIG_PATH"
          '';
        };
      }
    );
}
