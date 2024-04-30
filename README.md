# Plotting scripts for Sterzinger and Igel (2024)
Python notebooks for [Sterzinger and Igel (2024)](https://doi.org/10.5194/acp-24-3529-2024)

First, set up the Conda environment

```
conda env create -f environment.yml
```

and activate with 

```
conda activate sterzinger-igel-2023-data
```

OR use pip

```
pip install pandas numpy matplotlib tqdm xarray pyrams pint-xarray
```

Next, get the data needed to run the scripts

```
./get_all_data.sh
```

Finally, run each of the notebooks. Plots will be saved to [./plots](./plots)
