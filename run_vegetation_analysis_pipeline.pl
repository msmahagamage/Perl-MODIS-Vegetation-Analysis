#!/usr/bin/perl

# Created by Madusha Sammani
# Last modified this on May 7, 2023
# Before you run this code you need to change the absolute path of  input and output directories of each perl script
# Order of this code: 
	# 1. Download images from April 1 to August 31 in 2022 ( You can change the data range)
	# 2. Calculate the NDVI and EVI2 for cloud free pixels for each downloaded image
	# 3. Calculate the maximim NDVI and EVI2 for each three days
	# 4. Calculate the monthly average for each image

 
# Call download_data.pl script
# Purpose of this code is to download the daily MODIS images
system("01_download_modis_data.pl");

# Call Calculate_NDVI_EV12.pl script
# Purpose of this code is to calulate the NDVI and EVI2 images for cloud free pixels
system("02_calculate_vegetation_indices.pl");

# Call Three_Day_Maximum.pl script
# Purpose of this code is to find the maximum of three day images
system("03_create_3day_composites.pl");

# Call Average_Monthly.pl script
# Purpose of this code is to calculate the monthly average from daily images
system("04_calculate_monthly_averages.pl");
