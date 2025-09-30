#!/usr/bin/perl

# created by Madusha Sammani
# Last modified May 7, 2023

# Purpose of this code is to calculate the maximum NDVI and EVI2 images for each three days
# When you run this code you have to change the input derectory and output derectories.

# Relative path for input for NDVI is MyProject-->Output-->NDVI
# Relative path for input for EVI2 is MyProject-->Output-->EVI2
# Relative path for output for NDVI is MyProject-->Output-->Maximum_3D_NDVI
# Relative path for output for EVI2 is MyProject-->Output-->Maximum_3D_EVI2


# Set output directory paths
$output_directory_NDVI="/data/MyProject/Output/Maximum_3D_NDVI/";
$output_directory_EV12="/data/MyProject/Output/Maximum_3D_EVI2/";

# Set input directory paths
$input_directory_NDVI="/data/MyProject/Output/NDVI/";
$input_directory_EV12="/data/MyProject/Output/EVI2/";

# Declare constant variables
$yyyy=2022;
$endday=241;
$fill_value= -28672;
$num_rows = 3600;
$num_cols = 7200;
$start_date=91;
$nbytes=2*$num_cols;


for (my $date = $start_date; $date <= $endday; $date += 1) {
	
	# First day and third day
	my $day1 = sprintf("%03d", $date);
    	my $day3 = sprintf("%03d", $date + 2); 
	
	#Output file path for NDVI
	$output_file_ndvi = join('', $output_directory_NDVI, "MOD09CMG.A", $yyyy,  $day1, "_", $day3, "_NDVI.bin");
	open data_out_ndvi, "> $output_file_ndvi" or die "Error opening file $output_file_ndvi: $!\n";
	binmode data_out_ndvi;
	
	#Output file path for EV12
	$output_file_ev12 = join('', $output_directory_EV12, "MOD09CMG.A", $yyyy, $day1, "_", $day3, "_EVI2.bin");
	open data_out_ev12, "> $output_file_ev12" or die "Error opening file $output_file_ev12: $!\n";
	binmode data_out_ev12;
	
	#Declare Variables for save the file path
	my @file_names_NDVI = ();
	my @file_names_EV12 = ();
	
	#Store input filepaths to array
	for ($day = $date; $day <= $date+2; $day += 1) {
		
		push(@file_names_NDVI, join('', $input_directory_NDVI, "MOD09CMG.A", $yyyy, sprintf("%03d", $day), "_NDVI.bin"));
		push(@file_names_EV12, join('', $input_directory_EV12, "MOD09CMG.A", $yyyy, sprintf("%03d", $day), "_EVI2.bin"));

	}

	# Set the maximum value
	open day_ndvi1, '<', $file_names_NDVI[0] or die "Error opening file $file_names_NDVI[0]: $!\n";
	binmode day_ndvi1;
		
	open day_ev121, '<', $file_names_EV12[0] or die "Error opening file $file_names_EV12[0]: $!\n";
	binmode day_ev121;

	# Run the loop through nedxt two images	
	while (read day_ndvi1, $NDVI_d1, $nbytes) {
		@max_ndvi = unpack("s*", $NDVI_d1);
		
		read (day_ev121, $EV12_d1, $nbytes);
		@max_ev12 = unpack("s*", $EV12_d1);
			
		for ($i = 1; $i < scalar @file_names_NDVI; $i += 1) {
				open day_ndvi, '<', $file_names_NDVI[$i] or die "Error opening file $file_names_NDVI[$i]: $!\n";
				binmode day_ndvi;
				
				open day_ev12, '<', $file_names_EV12[$i] or die "Error opening file $file_names_EV12[$i]: $!\n";
				binmode day_ev12;
				
				read (day_ndvi, $NDVI, $nbytes);
				@NDVI_day = unpack("s*", $NDVI);
				
				$iii=0;
				foreach $z(@NDVI_day){
					if ($z != $fill_value && $z > $max_ndvi[$iii]) {
						$max_ndvi[$iii] = $z;
						$iii++;
					}
				}
				
				read (day_ev12, $EV12, $nbytes);
				@EV12_day = unpack("s*", $EV12);
				
				$iiii=0;
				foreach $m(@EV12_day){
					if ($m != $fill_value && $m > $max_ev12[$iiii]) {
						$max_ev12[$iiii] = $m;
						$iiii++;
					}
				}
				close $day_ndvi;
				close $day_ev12;
			}
			
			print data_out_ndvi pack("s*", @max_ndvi);
			print data_out_ev12 pack("s*", @max_ev12);
		}
	close data_out_ndvi;
	close data_out_ev12;
		
}
