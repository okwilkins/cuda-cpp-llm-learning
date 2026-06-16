{
  description = "LLM inference engine";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        download-model = pkgs.writeShellApplication {
          name = "download-model";
          runtimeInputs = [ pkgs.python3Packages.huggingface-hub ];
          text = ''
            mkdir -p models/Qwen3.5-0.8B
            exec hf download \
              Qwen/Qwen3.5-0.8B \
              --revision 2fc06364715b967f1860aea9cf38778875588b17 \
              --local-dir models/Qwen3.5-0.8B \
              "$@"
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            python314
            uv
            ruff
            ty
            download-model

            cudaPackages.cudatoolkit
            cudaPackages.cuda_cudart
          ];
          shellHook = ''
            export CUDA_HOME="${pkgs.cudaPackages.cudatoolkit}"
            export LD_LIBRARY_PATH=/run/opengl-driver/lib:${pkgs.libglvnd}/lib:${
              pkgs.lib.makeLibraryPath [
                pkgs.cudatoolkit
                pkgs.cudaPackages.cuda_cudart
                pkgs.stdenv.cc.cc.lib
              ]
            }:$LD_LIBRARY_PATH
          '';
        };
      }
    );
}
