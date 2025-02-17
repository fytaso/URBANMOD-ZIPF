# URBANMOD-ZIPF

This repository contains codes and sample data to run the urban land expansion model, URBANMO-ZIPF, that preserves the Zipf's law size distribution of urban clusters. Detailed descriptions of this model can be found in (Huang et al 2019). 

Visualization of global urban land expansion by 2050: https://knhuang.weebly.com/urban-expansion-2050.html.

Other versions of this model can be found in (Seto et al 2012) and (Chen et al 2020). The version in (Seto et al 2012) does not preserve Zipf's law. The version in (Chen et al 2020) preserves Zipf's law and introduces a mechanism of urban shrinking.

## How to run URBANMOD-ZIPF

Run "main.m" in Matlab.

Change the parameters in urbanmod_prob_new() function to run forecasts in different regions, under different scenarios, and for different ensemble sizes. Change csv file "results/urban_land.csv" to set different total areas of urban land for different countries/regions. Change GeoTiff file "data/suitability/suitability_pca2_excluded.tif" and rerun "functions/urban_land_setup.R" in R to use different suitability layers.

This demo only provides setup data for China, India, and United States. To setup for other coutries/regions, run script "functions/urban_land_setup.R" in R.

## Urban land areas in Shared Socioeconomic Pathways (SSPs)

The area of urban land (km\^2) for each country in five Shared Socioeconomic Pathways (SSPs) are stored in "results/urban_land.csv". These areas are calculated based on the panel regression coefficients listed in the Supplementary Table 2 in (Huang et al 2019).

Run "functions/urban_land_quantities.R" in R to perform the calculation.

## Urban land covers in 2015

The urban land covers in 2015 are based on the Global Human Settlement Layer - Settlement Model (GHSL-SMOD; Florczyk et al 2019). Grid cells labeled as "urban center (30)" or "dense urban cluster (23)" are considered urban lands. Both of these two types of grid cells have \>50% impervious surface and \>1,500 people/km\^2 population density. This repository only includes setups for China, India, and United States.

Run script "functions/urban_land_setup.R" in R to crop urban land covers in 2015 for all countries. The cropped rasters are stored in "results/{country_ISO3_code}/urban_2015.tif".

## System requirements

-   Matlab R2021b or above;
-   Matlab Add-On Toolboxes: Mapping; Image Processing; Parallel Computing;
-   R v4.1.0 or above;
-   R libraries required: sf, rgdal, dplyr, raster, fasterize, rstudioapi, rnaturalearth

## References

1.  Huang, Kangning, Xia Li, Xiaoping Liu, Karen C. Seto. "Projecting global urban land expansion and heat island intensification through 2050." Environmental Research Letters 14.11 (2019): 114037.(https://iopscience.iop.org/article/10.1088/1748-9326/ab4b71/meta)
2.  Seto, Karen C., Burak Güneralp, and Lucy R. Hutyra. "Global forecasts of urban expansion to 2030 and direct impacts on biodiversity and carbon pools." Proceedings of the National Academy of Sciences 109.40 (2012): 16083-16088. (https://www.pnas.org/doi/abs/10.1073/pnas.1211658109)
3.  Chen, Guangzhao, Xia Li, Xiaoping Liu, Yimin Chen, Xun Liang, Jiye Leng, Xiaocong Xu, Weilin Liao, Qianlian Wu, and Kangning Huang. "Global projections of future urban land expansion under shared socioeconomic pathways." Nature communications 11, no. 1 (2020): 1-12. (https://www.nature.com/articles/s41467-020-14386-x)
4.  Florczyk A.J., Corbane C., Ehrlich D., Freire S., Kemper T., Maffenini L., Melchiorri M., Pesaresi M., Politis P., Schiavina M., Sabo F., Zanchetta L., GHSL Data Package 2019, EUR 29788 EN, Publications Office of the European Union, Luxembourg, 2019, ISBN 978-92-76-13186-1, <doi:10.2760/290498>, JRC 117104.
