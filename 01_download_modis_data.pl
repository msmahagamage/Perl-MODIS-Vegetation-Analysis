#!/usr/bin/perl

# Created by Madusha sammani on April 17, 2023
# The purpose of this code is to download daily MODIS images from April 1, 2022 to August 31, 2023
# If someone need to run this code it is necessary to chenge the path source code file, output data directory and log file 

$outdirec="/data/MyProject/INPUT/";
$host="e4ftl01.cr.usgs.gov";
$dirc="/MOLT/MOD09CMG.006/";
$username = 'USERNAME';
$password = 'PASSWORD!';
$logfile = "/data/MyProject/LOG/http_data.log";

open($log, ">>", $logfile) or die "Can't open $logfile: $!";

$yy=2022;
@md=(30,31,30,31,31);
$m = 4;

foreach $dda(@md){
	chomp($dda);
	$mm=$m;
	if($m<10) {
		$mm="0";
		$mm.=$m;
		}
		for($d=1;$d<=$dda;$d++){
			if($d<10) {
				$dd="0";
				$dd.=$d;
				} else {
					$dd=$d;
					}
   

    	$localdir = join('.', $yy, $mm, $dd);
    	$directory = join('', $dirc, $localdir, "/");
	$fileindex = "index.html";
    	if (-e $fileindex) {
        	unlink $fileindex;
    	}
    	$URL = join('', "https://", $host, $directory);
    	# Get start time
    	$start_time = time();
    	print $log "$URL downloading started at ", scalar(localtime($start_time)), "\n";
    	system("wget --user=$username --password=$password $URL"); ##generate file of index.html
    	open(IN, "<", $fileindex) || die "cannot open file $fileindex: $!";
    	@alld = <IN>;
    	close IN;
    	foreach $line (@alld) {
        	chomp($line);
        	if ($line =~ m/hdf">MOD09CMG/) {
            		$fi1 = (split('>', $line))[2];
            		$fi1 = (split('<', $fi1))[0];
            		$URL = join('', "https://", $host, $directory, $fi1); # exact file
            		system("wget --user=$username --password=$password -P $outdirec $URL"); ##get the hdf file
			}
        
     		}
        	$end_time = time();
        	print $log "$URL downloading ended at ", scalar(localtime($end_time)), "\n";
	
	}
	$m++;
}
