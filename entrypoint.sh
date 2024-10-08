#!/usr/bin/env sh
mkdir /tmp/results

./benchmark.sh datagen \
    --hosts localhost \
    --workload unet3d \
    --accelerator-type a100 \
    --num-parallel 1 \
    --results-dir /tmp/results \
    --param dataset.num_files_train=1200 \
    --param dataset.data_folder=unet3d_data

./benchmark.sh run \
    --hosts localhost \
    --workload unet3d \
    --accelerator-type a100 \
    --num-accelerators 1 \
    --results-dir /tmp/results \
    --param dataset.num_files_train=1200 \
    --param dataset.data_folder=unet3d_data

cat /tmp/results/per_epoch_stats.json
cat /tmp/results/summary.json
