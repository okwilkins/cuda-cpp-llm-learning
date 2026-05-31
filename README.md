# Learning C++

A project dedicated to learning C++ for applications in AI/ML and lower-level GPU programming.

## Getting Started

To gain access to all required binaries needed run:

```bash
nix develop --command $SHELL
```

**NOTE**: This will generate a Clangd config in whichever directory the shell currently is in.
This allows C++ and CUDA running correctly with the Clangd LSP.


### Profiling with Nsight

To get the most out of profiling CUDA C++ binaries compile with:

```bash
nvcc -O3 -o main -lineinfo <CUDA FILE>
```

#### Nsight System

In the Nix development shell run:

```bash
nsys profile \
  -t cuda,nvtx,osrt \
  -o profile_report \
  --stats=true \
  main
```

This will generate a report file in the working directory.

If wanting to view the report in the Nsight System UI, run:

```bash
nsys-ui profile_report.nsys-rep
```

#### Nsight Compute

To profile a CUDA binary, sudo is needed. [This is because elevated privileges are needed to profile the GPU](https://developer.nvidia.com/nvidia-development-tools-solutions-err_nvgpuctrperm-permission-issue-performance-counters).
In the Nix development shell run:

```bash
sudo ncu --set full -f -o report ./my_cuda_program
```

To view the report in the terminal:

```bash
ncu --import report.ncu-rep
```

Example output:
```
[674832] main@127.0.0.1
  void matVecMul<float>(T1 *, const T1 *, const T1 *, unsigned int) (1, 1, 1)x(256, 1, 1), Context 1, Stream 7, Device 0, CC 8.9
    Section: GPU Speed Of Light Throughput
    ----------------------- ----------- ------------
    Metric Name             Metric Unit Metric Value
    ----------------------- ----------- ------------
    DRAM Frequency                  Ghz        10.85
    SM Frequency                    Ghz         2.14
    Elapsed Cycles                cycle        4,525
    Memory Throughput                 %         0.90
    DRAM Throughput                   %         0.90
    Duration                         us         2.11
    L1/TEX Cache Throughput           %        38.83
    L2 Cache Throughput               %         0.78
    SM Active Cycles              cycle        30.91
    Compute (SM) Throughput           %         0.01
    ----------------------- ----------- ------------

    OPT   This kernel grid is too small to fill the available resources on this device, resulting in only 0.0 full
          waves across all SMs. Look at Launch Statistics for more details.

    Section: GPU Speed Of Light Roofline Chart
    INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved
          close to 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling
          Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on
          roofline analysis.

...
```

To view the report in the UI, run:

```bash
ncu-ui report.ncu-rep
```

