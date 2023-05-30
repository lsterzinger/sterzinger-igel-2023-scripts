#!/bin/bash
echo "Getting mosaic data"
cd mosaic_data
./get_files.sh

echo "Getting model data"
cd ../model_data
./get_model_data.sh

cd ..
