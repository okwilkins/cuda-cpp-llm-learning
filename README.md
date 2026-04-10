# Learning C++

A project dedicated to learning C++ for applications in AI/ML and lower-level GPU programming.

## Getting Started

To gain access to all required binaries needed run:

```bash
nix shell
```

After running this, in order for the Clangd LSP to run, generate the config with:

```bash
gen-clangd-config
```

This will generate the config in whichever directory the shell currently is in and will get C++ and CUDA running correctly with Clangd.
Preferably, do this in the root directory. Clangd has the ability to search upwards from whichever directory it is running in.

