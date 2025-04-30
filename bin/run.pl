#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use File::Basename;
use File::Spec;
use FindBin qw($Bin);


my $usage=<<USAGE;
Usage:
	perl $0 --path /path/to/files/ --out_prefix output_files_dir
USAGE
if(@ARGV==0){print $usage;}

#my $bin_path=dirname($0);
my $bin_path=$Bin;
my $software_dir = $bin_path; $software_dir =~ s/bin$//;

require "$bin_path/get_os.pm";

# Get option from command line
my $path="";
my $out_prefix = "out";

GetOptions(
	'path=s' => \$path,
	'out_prefix:s' => \$out_prefix,
	'help|h' => \&HELP_MESSAGE,
);

if((defined ($path) && ($path ne ""))){
	if ($out_prefix eq "out"){
		$out_prefix = File::Spec-> catdir($path,$out_prefix); #object way
	}
	if (-d $out_prefix){
		print "the output dir is exist\n";
	}else{
		mkdir($out_prefix) || die "can not create $out_prefix dir, $!";
		#	print $out_prefix;
	}
	
	# convert drug molecular to pdbqt files
	my $cmdString;
	$cmdString = "perl $bin_path/mol2pdbqt.pl --path $path";
	#print `perl mol2pdbqt.pl $path`;
	system($cmdString) == 0 or die "failed to execute: $cmdString\n";
	
	my @input_files;
	my $vina;
	
	my @all_tools;
	opendir(DIR,$bin_path) || die $!;
	@all_tools = readdir(DIR);
	close(DIR);
	
	
	# Determine the system type
	my $system_class=get_os::which_os();
	#print $system_class;
	
	for my $i (0..$#all_tools){
		if($all_tools[$i] =~ /\.+$/){next};
		next if ($all_tools[$i] =~ /git$/);
	
		if($system_class =~/Win/){
			if($all_tools[$i] =~ /vina.exe$/){
				$vina=File::Spec-> catdir($bin_path,$all_tools[$i]);
			}
		}
		if($system_class =~/linux/){
			if($all_tools[$i] =~ /vina$/){
				$vina=File::Spec-> catdir($bin_path,$all_tools[$i]);
			}
		}
	}
	
	my @gene_doc=();
	opendir(DIR,$path) || die "no this dir";
	@input_files=readdir(DIR);
	close(DIR);
	
	for my $i (0..$#input_files){
		next if ($input_files[$i] =~ /\.+$/);
		next if ($input_files[$i] eq $out_prefix);
		my $dir_test = File::Spec-> catdir($path,$input_files[$i]);
		if (-d $dir_test){
#			print $input_files[$i]."\n";
			push(@gene_doc,$input_files[$i]);
		}
	}

#	print `$vina --help`;
#	print @gene_doc;
	
	for my $i (0..$#gene_doc){
		my $input_1 = File::Spec-> catdir($path,$gene_doc[$i]); #Each gene folder
		my $input_2="";
		opendir(DIR,$input_1) || die "can open $input_1";
		my @temp=readdir(DIR);	#get the file name in the gene doc
		close(DIR);
		for my $j (0..$#temp){
			if($temp[$j] =~ /\.+$/){next};
			my $temp_path = $input_1."/".$temp[$j];
			if(-d $temp_path){
				$input_2 = File::Spec -> catdir($input_1,$temp[$j]); #Ligand folders within each gene folder
			}
		}
		$cmdString = "perl $bin_path/vina_analysis.pl --rep_box_path $input_1 --lig_path $input_2 --vina_path $vina --out_prefix $out_prefix";
		system($cmdString) == 0 or die "failed to execute: $cmdString\n";	
#		print `perl vina_analysis.pl $input_1 $input_2 $vina`;
	}
	$cmdString = "perl $bin_path/get_min_energy_mol_list.pl --path $path --out_prefix $out_prefix";
	system($cmdString) == 0 or die "failed to execute: $cmdString\n";	
#	print `perl get_min_energy_mol_list.pl`

	my $R_input = File::Spec -> catfile($out_prefix,"final_sort_energy.txt");
	my $R_output = File::Spec -> catfile($out_prefix,"plot.pdf");
	$cmdString = "Rscript $bin_path/R_draw_lig.R $R_input $R_output";
	system($cmdString) == 0 or die "failed to execute: $cmdString\n";	

}

sub HELP_MESSAGE{
	my $help_message=<<USAGE;
	Usage:
		perl run.pl [options]
	options:
	--path = Enter the folder path where the files is located
	--out_prefix = Output path of the results    default: out
	-h = prints this message
USAGE
	
	print $help_message;
}