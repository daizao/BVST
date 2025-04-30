#!/usr/bin/perl -w

use strict;
use warnings;
use File::Basename;
use Cwd;
use Getopt::Long;
use File::Copy;
use File::Spec;

my $usage=<<USAGE;
Usage:
	perl $0 --path /path/to/files/
USAGE
if(@ARGV==0){print $usage;}

# Get option from command line
my $path="";

GetOptions(
	'path=s' => \$path,
	'help|h' => \&HELP_MESSAGE,
);

if((defined ($path) && ($path ne ""))){
	#my $original_dir=getcwd;
	my $original_dir=$path;

	my @all_file_name;
	opendir(DIR,$original_dir) || die $!;
	@all_file_name=readdir(DIR);
	close(DIR);

	my @gene_name;
	for my $i (0..$#all_file_name){
		next if($all_file_name[$i]=~ /\.+$/);
		next if($all_file_name[$i]=~ /git$/);
		next if($all_file_name[$i]=~ /out$/);
		my $path_tmp = File::Spec-> catdir($original_dir,$all_file_name[$i]);
		if(-d $path_tmp){
	#		print $all_file_name[$i]."\n";
			push(@gene_name,$all_file_name[$i]);
		}
	}


	for my $i (0..$#gene_name){
		my $dir = File::Spec -> catdir($original_dir,$gene_name[$i],"lig_file");
	#	print $dir;
		my @drug_files;
		opendir(DIR,$dir) || die "no this dir";
		@drug_files = readdir(DIR);
		close(DIR);


		my @drug_mol2;
		my @drug_sdf;

		for my $i (0..$#drug_files){
			next if($drug_files[$i]=~ /\.+$/);
			if ($drug_files[$i]=~ /mol2$/){
				push (@drug_mol2,$drug_files[$i]);
		#		print $drug_files[$i]."\n";
			}
			if($drug_files[$i] =~ /sdf$/){
				push (@drug_sdf,$drug_files[$i]);
			}
		}


		if(!(-d "$dir/old_files")){
			mkdir ("$dir/old_files");
		}

		for my $i (0..$#drug_mol2){
			my @arr=split('\.',$drug_mol2[$i]);
			my $cmdString;
			my ($input1,$input2);
			$input1 = File::Spec -> catdir($dir,$drug_mol2[$i]);
			$input2 = File::Spec -> catdir($dir,$arr[0]);
	#		$cmdString="obabel -imol2 $input1 -opdbqt -O $input2.pdbqt -h -ff GAFF --minimize";
	#		print $cmdString."\n";
	#		system() == 0 or die "failed to execute: $cmdString\n"; #can not use space bar
			print `obabel -imol2 "$input1" -opdbqt -O "$input2.pdbqt" -h --ff GAFF --minimize`;
			move("$dir/$drug_mol2[$i]","$dir/old_files");
		}
	#	
		for my $i (0..$#drug_sdf){
			my @arr=split('\.',$drug_sdf[$i]);
			my $cmdString;
			my ($input1,$input2);
			$input1 = File::Spec -> catdir($dir,$drug_sdf[$i]);
			$input2 = File::Spec -> catdir($dir,$arr[0]);
			print `obabel -isdf "$input1" -opdbqt -O "$input2.pdbqt" -h --ff GAFF --minimize`;
			move("$dir/$drug_sdf[$i]","$dir/old_files");
		}
		
	}
}


sub HELP_MESSAGE{
	my $help_message=<<USAGE;
	Usage:
		perl run.pl [options]
	options:
	--path = Enter the folder path where the files is located
	-h = prints this message
USAGE
	
	print $help_message;
}