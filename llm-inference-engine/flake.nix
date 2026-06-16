{
  description = "LLM inference engine";

  inputs = {
    # rootFlake.url = "github:okwilkins/cuda-cpp-llm-learning";
    # nixpkgs.follows = "rootFlake/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      # rootFlake,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          # inputsFrom = [
          #   rootFlake.devShells.${system}.default
          # ];
          nativeBuildInputs = with pkgs; [
            python314
            uv
            ruff
            ty
          ];
          # shellHook = ''
          #   ${rootFlake.devShells.${system}.default.shellHook or ""}
          # '';
        };
      }
    );
}
