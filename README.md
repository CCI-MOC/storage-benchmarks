# Storage Benchmarks
These benchmarks are designed to measure the performance of storage
on the MOC and NERC, specifically related to AI applications.

# Experiments
- FIO
- MLPerf storage
- End to End

## FIO
The benchmarking tool selected for this evaluation is FIO.
We will follow [John Strunk's FIO evaluation framework](https://github.com/JohnStrunk/fs-performance-container/blob/master/entry.sh).
The specific client machine used for running the experiments is not critical, as long as we can distinguish between network and storage latency.
The same experiment data file is used without cleaning, through all the benchmarking explained below.

The evaluation will include five key benchmarks:
- **Streaming**: 100% sequential writes, followed by 100% sequential reads, using 32 I/O threads. This test measures the maximum write/read bandwidth (in MB/s) we can achieve, with approximately 300GB of data written over about 30 minutes.
- **Maximal Latency**: 100% random writes, followed by 100% random reads, using a single I/O thread. This test measures the maximum write/read latency we can expect, lasting about 30 minutes.
- **Minimal Latency**: 100% sequential writes, followed by 100% sequential reads, using a single I/O thread. This test focuses on the minimal write/read latency, providing insights primarily into network latency. Client-side caching should be disabled. The test runs for around 30 minutes, and the sequential throughput should also be measured or calculated.
- **Max I/O Random Throughput**: 100% random writes, followed by 100% random reads, using 32 I/O threads. This test assesses the maximum write/read throughput we can expect, with a duration of approximately 30 minutes.
- **Small WSS Streaming Reads**: 100% sequential reads over a small working-set with 32 I/O threads. This test is an attempt to separate the effects of the network between the client and storage from the overheads of the storage back end (i.e., disk). The workload generator is configured to bypass the client cache, ensuring the reads are sent to the storage system even though the WSS is small. Given the small WSS, the expectation is that it will fit in the storage system’s cache, leading to network overheads being the dominant contributor to performance.

The results can be found in the [results/](results) folder.

## MLPerf Storage

MLPerf Storage benchmarks the performance for training workloads.
This is achieved by generating a dataset and simulating the process of training over the generated dataset.
It does not make use of GPUs, and the time which the GPU would have spent on training over each sample of the dataset has been replaced with a sleep command.
Processing time on actual hardware (A100 and H100) has been measured in order to calculate the correct sleep time amount for each sample.
Training is run over 5 epochs and does not perform checkpointing.

The main metric for the MLPerf Storage experiment is `Accelerator Utilization`.
This is measured as the fraction of time that the GPU would spend processing compared to the overall duration of the experiment, as defined by the formula `AU = Accelerator Total Time / Total Duration = Accelerator Total Time / (Accelerator Total Time + Storage Load Time)`.

By default, MLPerf Storage defines an accelerator utilization score below 90% as a fail.

In our setup of the experiment the dataset is loaded from a Persistent Volume Claim that is hosted on the NESE ceph cluster.
The training workload is unet3d, 1 simulated GPU, and 1000 (~140GB) and 3500 (~500GB) samples of dataset.
Each sample ranges in size from around 80MB to 200MB.
Kubernetes job and PVC definition can be found in the [k8s/](k8s) folder.

The results can be found in the [results/](results) folder.

| Simulated GPU | Samples | Storage Type       | AU (%) | MB/s   |
|---------------|---------|--------------------|--------|--------|
| A100          | 3500    | NESE Ceph PVC      | 10.81  | 165.35 |
| H100          | 3500    | NESE Ceph PVC      | 5.58   | 168.05 |
| A100          | 1000    | Local EmptyDir PVC | 24.51  | 729.10 |
|               |         | Weka PVC           |        |        |
|               |         | Weka PVC           |        |        |

The below results have not been run on the NERC and are provided purely for reference.

| Simulated GPU | Samples | Storage Type         | AU (%) | MB/s    |
|---------------|---------|----------------------|--------|---------|
| A100          | 1200    | Macbook Pro 14" NVMe | 99.16  | 1495.76 |

Other results that have been contributed from organizations can be found on the [MLPerf Storage website](https://mlcommons.org/benchmarks/storage/). 

## Actual Inference Workload
