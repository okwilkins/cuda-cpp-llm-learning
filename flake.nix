{
  description = "C++ & CUDA Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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

        clangdWrapped = pkgs.writeShellScriptBin "clangd" ''
          exec ${pkgs.llvmPackages.clang-unwrapped}/bin/clangd \
            --query-driver=${pkgs.gcc}/bin/g++ \
            "$@"
        '';

        genClangdConfig = pkgs.writeShellScriptBin "gen-clangd-config" ''
          CUDA_ARCH_RAW=$(nvidia-smi --query-gpu=compute_cap | sed -n '2p' | tr -d '.' 2>/dev/null)

          if [ -z "$CUDA_ARCH_RAW" ]; then
            echo "ERROR: nvidia-smi failed to return a compute capability." >&2
            exit 1
          fi

          cat > .clangd <<EOF
          CompileFlags:
            Add:
              - -std=c++23
              - -Wall
              - -Wextra
              - -Wsign-conversion
              - -Wshadow
              - -Wpedantic
              - --driver-mode=g++

          ---
          If:
            PathMatch: .*\.cuh?

          CompileFlags:
            Add:
              - "-xcuda"
              - "--cuda-path=${pkgs.cudatoolkit}"
              - "--cuda-gpu-arch=sm_$CUDA_ARCH_RAW"
            Remove:
              - "-Xcompiler*"
              - "-Xfatbin*"
              - "-gencode*"
              - "--generate-code*"
              - "-ccbin*"
              - "--compiler-options*"
              - "-forward-unknown-to-host-compiler"
              - "-rdc=*"
          EOF
        '';

        tools = [
          pkgs.gcc

          # Build Systems
          pkgs.cmake
          pkgs.ninja
          pkgs.gnumake

          pkgs.cudatoolkit

          # Dev tools
          pkgs.gdb
          clangdWrapped
          pkgs.valgrind
          genClangdConfig
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = tools;
          shellHook = ''
            # Clangd variables
            export GCC_DIR="${pkgs.gcc.cc}"
            export GCC_VER="${pkgs.gcc.version}"

            export CPATH="$GCC_DIR/include/c++/$GCC_VER:$GCC_DIR/include/c++/$GCC_VER/${pkgs.stdenv.hostPlatform.config}:${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include:$CPATH"
            export CPLUS_INCLUDE_PATH="$GCC_DIR/include/c++/$GCC_VER:$GCC_DIR/include/c++/$GCC_VER/${pkgs.stdenv.hostPlatform.config}:${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include:$CPLUS_INCLUDE_PATH"

              # NVCC variables
              export LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH

              gen-clangd-config

          '';
        };

        packages.tools = pkgs.buildEnv {
          name = "cuda-tools";
          paths = tools;
        };

        defaultPackage = self.packages.${system}.tools;
      }
    );
}
