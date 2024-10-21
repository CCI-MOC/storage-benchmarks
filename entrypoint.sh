#!/usr/bin/env bash

if [ -z "$NUM_SAMPLES" ]; then
    echo "NUM_SAMPLES environment variable must be set."
    exit 1
fi

if [ -z "$ACCELERATOR_TYPE" ]; then
    echo "ACCELERATOR_TYPE environment variable must be set."
    exit 1
fi

mkdir /tmp/results

./benchmark.sh datagen \
    --hosts localhost \
    --workload unet3d \
    --accelerator-type $ACCELERATOR_TYPE \
    --num-parallel 4 \
    --results-dir /tmp/results \
    --param dataset.num_files_train=$NUM_SAMPLES \
    --param dataset.data_folder=unet3d_data

./benchmark.sh run \
    --hosts localhost \
    --workload unet3d \
    --accelerator-type $ACCELERATOR_TYPE \
    --num-accelerators 1 \
    --results-dir /tmp/results \
    --param dataset.num_files_train=$NUM_SAMPLES \
    --param dataset.data_folder=unet3d_data

echo "--------------------------"
echo "/tmp/results/0_output.json"
cat /tmp/results/0_output.json

echo "--------------------------"
echo "/tmp/results/per_epoch_stats.json"
cat /tmp/results/per_epoch_stats.json

echo "--------------------------"
echo "/tmp/results/summary.json"
cat /tmp/results/summary.json
