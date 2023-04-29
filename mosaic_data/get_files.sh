#!/bin/bash

curl -L -o aerosol-data.zip https://doi.pangaea.de/10.1594/PANGAEA.943907?format=zip
curl -L -o met-data.zip https://doi.pangaea.de/10.1594/PANGAEA.952341?format=zip

unzip aerosol-data.zip -d aerosol-data
unzip met-data.zip -d met-data
