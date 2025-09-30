#!/usr/bin/perl

# created by Madusha Sammani
# Last modified May 7, 2023

# Purpose of this code is to calculate the monthly average of NDVI and EVI2 images
# When you run this code you have to change the input derectory and output derectories.

# Relative path for input for NDVI is MyProject-->Output-->NDVI
# Relative path for input for EVI2 is MyProject-->Output-->EVI2
# Relative path for output for NDVI is MyProject-->Output-->NDVI_MONTHLY
# Relative path for output for EVI2 is MyProject-->Output-->EVI2_MONTHLY

# Set output directory paths
$output_directory_NDVI="/data/MyProject/Output/NDVI_MONTHLY/";
$output_directory_EV12="/data/MyProject/Output/EVI2_MONTHLY/";

# Set input directory paths
$input_directory_NDVI="/data/MyProject/Output/NDVI/";
$input_directory_EV12="/data/MyProject/Output/EVI2/";

# Set date range
$yyyy=2022;
$endday=243;
$fill_value= -28672;
$num_rows = 3600;
$num_cols = 7200;
@md=(30,31,30,31,31);
$nbytes=2*$num_cols;

$start_date=91;
for (my $m = 0; $m < scalar @md; $m++) {
	$start_date = $start_date;
	my $end_date = $start_date + $md[$m] - 1;

	
	# First day and third day
	my $day1 = sprintf("%03d", $start_date);
    	my $day3 = sprintf("%03d", $end_date); 
	
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
	my @count_ndvi = ();
	my @sum_ndvi = ();
	my @count_ev12 = ();
	my @sum_ev12 = ();
	
	#Store input filepaths to array
	for ($day = $start_date; $day <= $end_date; $day += 1) {
		my $dayn = sprintf("%03d", $day);
		push(@file_names_NDVI, join('', $input_directory_NDVI, "MOD09CMG.A", $yyyy, $dayn, "_NDVI.bin"));
		push(@file_names_EV12, join('', $input_directory_EV12, "MOD09CMG.A", $yyyy, $dayn, "_EVI2.bin"));
	}
	
	# Set the initial sum and count values
	open  day_ndvi1, '<', $file_names_NDVI[0] or die "Error opening file $file_names_NDVI[0]: $!\n";
	binmode day_ndvi1;
		
	open  day_ev121, '<', $file_names_EV12[0] or die "Error opening file $file_names_EV12[0]: $!\n";
	binmode day_ev121;
	
	while (read day_ndvi1, $NDVI_d1, $nbytes) {
		@sum_ndvi = unpack("s*", $NDVI_d1);
		
		read (day_ev121, $EV12_d1, $nbytes);
		@sum_ev12 = unpack("s*", $EV12_d1);
		
		#Declare Variables
		$i=0;
		foreach $x(@sum_ndvi){
			if ($x != $fill_value) {
				$count_ndvi[$i] = 1;
				} else {
					$count_ndvi[$i] = 0;
			}
    		$i++;
		}
			
		$k=0;		
		foreach $y(@sum_ev12){
			if ($y != $fill_value) {
				$count_ev12[$k] = 1;
			} else {
				$count_ev12[$k] = 0;
			}
			$k++;
		}
		
		# Loop through reamaning files
		for ($j = 1; $j < scalar @file_names_NDVI; $j += 1) {
			#Open NDVI image
			open  day_ndvi, '<', $file_names_NDVI[$j] or die "Error opening file $file_names_NDVI[$j]: $!\n";
			binmode day_ndvi;
			
			open  day_ev12, '<', $file_names_EV12[$j] or die "Error opening file $file_names_EV12[$j]: $!\n";
			binmode day_ev12;
			
			read (day_ndvi, $NDVI, $nbytes);
			@NDVI_day = unpack("s*", $NDVI);
			
			$l=0;
			foreach $z(@NDVI_day){
				if ($z != $fill_value) {
					$sum_ndvi[$l] += $z;
					$count_ndvi[$l]++;
					
				}
			$l++;
			}
			close day_ndvi;
			
			read (day_ev12, $EV12, $nbytes);
			@EV12_day = unpack("s*", $EV12);
			
			$m1=0;
			foreach $m(@EV12_day){
				if ($m != $fill_value) {
					$sum_ev12[$m1] += $m;
					$count_ev12[$m1]++;
					
				}
			$m1++;
			}
			
			
			close day_ev12;
		}
		
		$p=0;
		foreach $n(@count_ndvi){
			if ($n > 0) {
				$avg_ndvi[$p] = $sum_ndvi[$p] / $n;
			} else {
				$avg_ndvi[$p] = $fill_value;
			}
			$p++;		
		}
		
		$avg_ndviP = pack("s*", @avg_ndvi);
		print data_out_ndvi $avg_ndviP;
		
		$q=0;	
		foreach $p(@count_ev12){
			if ($p > 0) {
				$avg_ev12[$q] = $sum_ev12[$q] / $p;
			}else {
				$avg_ev12[$q] = $fill_value;
			}
			$q++;		
		}
		$avg_ev12P = pack("s*", @avg_ev12);
		print data_out_ev12  $avg_ev12P;
		
	}
	
	close data_out_ndvi;
	close data_out_ev12;
	$start_date=$end_date+1;
}

