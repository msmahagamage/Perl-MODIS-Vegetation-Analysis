#!/usr/bin/perl

# created by Madusha Sammani
# Last modified May 7, 2023

# Purpose of this code is to calculate the NDVI and EVI2 images for each hdf file
# When you run this code you have to change the input derectory and output derectories.

# Image Type: 16-bit signed integer
# Fill Value: -28672
# Red Band: Coarse Resolution Surface Reflectance Band 1
# NIR Band: Coarse Resolution Surface Reflectance Band 2
# MODIS Quality Assesment Band: Coarse Resolution State QA (16-bit unsigned integer, Fill Value: 0)

# Relative path for input file is MyProject--> INPUT
# Relative path for output for NDVI is MyProject-->Output-->NDVI
# Relative path for output for EVI2 is MyProject-->Output-->EVI2

# Output path names
$output_directoryNDVI="/data/MyProject/Output/NDVI/"; 
$output_directoryEV12="/data/MyProject/Output/EVI2/";

# Input path name
$input_directory="/data/MahaGamage/MyProject/INPUT/"; 

# Input variables
$fill_value=-28672;
$Scalar_Factor = 10000;
$num_rows = 3600;
$num_cols = 7200;
$nbytes=2*$num_cols;

# Declare the band names
$NIR_Band = "Coarse Resolution Surface Reflectance Band 2";
$RED_Band = "Coarse Resolution Surface Reflectance Band 1";
$QualityAsesment_Band = "Coarse Resolution State QA";

opendir(DIR, $input_directory) or die "Can't open directory: $!";

# Loop through eac file
foreach $filename (readdir(DIR)) {
	
	# Check the file type is hdf
	next unless ($filename =~ /\.hdf$/); # only process HDF files
	
	# Extract the year and date
	my ($year, $day) = $filename =~ /A(\d{4})(\d{3})/; # Get the date and year
	
	# Inputfile path
	$input_file = join('', $input_directory, $filename);

    # Create the file path and name for the NIR and Red Bands
	my $ndvi_file = join('', $output_directoryNDVI, "MOD09CMG.A", $year, $day, "_NDVI.bin"); 
	my $ev12_file = join('', $output_directoryEV12, "MOD09CMG.A", $year, $day, "_EVI2.bin");

	# Extract the bands from image
	my $nir_file = "hdp dumpsds -n \"$NIR_Band\" -d -b \"$input_file\""; # Extract the NIR Band
	my $red_file = "hdp dumpsds -n \"$RED_Band\" -d -b \"$input_file\""; # Extract the Red Band
	my $qa_file = "hdp dumpsds -n \"$QualityAsesment_Band\" -d -b \"$input_file\"";# Extract the QA band
	
	# Open red, NIR, QA files for readingMOD09CMG.
	open (DATAIN_NIR, '-|', $nir_file) or die "Could not execute command: $!";
	binmode DATAIN_NIR;	
	
	open (DATAIN_RED, '-|', $red_file) or die "Could not execute command: $!";
	binmode DATAIN_RED;
	
	open (DATAIN_QA, '-|', $qa_file) or die "Could not execute command: $!";
	binmode DATAIN_QA;

	open(DATAOUT_NDVI, ">$ndvi_file") or die "Error opening file $ndvi_file: $!\n";
	binmode DATAOUT_NDVI;
	
    open(DATAOUT_EVI2, ">$ev12_file") or die "Error opening file $ev12_file: $!\n";
    binmode DATAOUT_EVI2;	
        
	# Run through each column and row
	for($j=0; $j < 2*$num_rows; $j++){
		
		read (DATAIN_NIR, $nir_values, $nbytes);
		@V_NIR = unpack("s*", $nir_values);

		read (DATAIN_RED, $red_values, $nbytes);
		@V_RED = unpack("s*", $red_values);
		
		read (DATAIN_QA, $QA, $nbytes); # Update the QA value for this pixel
		@V_QA = unpack("S*", $QA);
		
		$i=0;
		foreach $QA_V(@V_QA) {
			$binary_string = sprintf("%016b", $QA_V); # Check the cloud
			$last_two_bits = substr($binary_string, -2);
			
			if ($last_two_bits eq "00" && $V_NIR[$i]!=$fill_value && $V_RED[$i]!=$fill_value){
				
				if($V_NIR[$i] + $V_RED[$i] != 0){
					$NDVI[$i] = $Scalar_Factor*($V_NIR[$i] - $V_RED[$i]) / ($V_NIR[$i] + $V_RED[$i]);
				} else {
						$NDVI[$i] = $fill_value;
				}
				
				if($V_NIR[$i] + 2.4 * $V_RED[$i] + $Scalar_Factor != 0) {
					$EVI2[$i] = 2.5 * $Scalar_Factor*($V_NIR[$i] - $V_RED[$i]) / ($V_NIR[$i] + 2.4 * $V_RED[$i] + $Scalar_Factor); 
				} else {
					$EVI2[$i] = $fill_value;
				}
			} else {
				$NDVI[$i] = $fill_value;
				$EVI2[$i] = $fill_value;
			}
			
			$i++;
		}
		
		$NDVI_values = pack("s*", @NDVI);
		print DATAOUT_NDVI $NDVI_values;
		
		$EVI2_values = pack("s*", @EVI2);
		print DATAOUT_EVI2 $EVI2_values;
		
		}
		
		close(DATAIN_NIR);
		close(DATAIN_RED);
		close(DATAIN_QA);
		close(DATAOUT_NDVI);
		close(DATAOUT_EVI2);
}   
close(DIR);

