#!/usr/bin/perl -w
use strict;
use warnings;
use File::Copy;
use Getopt::Long;
use File::Basename;
use File::Spec;

my $usage=<<USAGE;
Usage:
	perl $0 --rep_box_path /path/to/rep.pdbqt and grid.gpf  --lig_path /path/to/lig_file --vina_path /path/to/vina program --out_prefix output_files_dir
	# input pathway without the file name
	# put all the lig.pdbqt in the lig_file
	# include the path of vina.exe
USAGE
if(@ARGV==0){die $usage};

my $rep_box_path="";
my $lig_path="";
my $vina_path="";
my $out_prefix="";


GetOptions(
	'rep_box_path=s' => \$rep_box_path,
	'lig_path:s' => \$lig_path,
	'vina_path:s' => \$vina_path,
	'out_prefix:s' => \$out_prefix,
	'help|h' => \&HELP_MESSAGE,
);


if(($rep_box_path ne "") && ($lig_path ne "") && ($vina_path ne "") && ($out_prefix ne "")){

	my $input_dir=$rep_box_path;
	my $input_lig_dir=$lig_path;
	my $vina=$vina_path; # the program of vina;

	my $rep; # Store the pathway to rep.pdbqt;
	my $grid; # Store the patheay to grid.gpf;
	my @file; # Store the files in the directory;
	my @lig_file;	# Store the files in the lig dirctory;


	opendir(DIR,$input_dir) || die "can not open the rep directory";
	#print $input_dir;
	@file=readdir(DIR);
	close(DIR);
	for my $i (0..$#file){
	#	print $file[$i];
		if($file[$i] =~ /\.+$/){next};
		if($file[$i] =~ /.pdbqt$/){$rep=File::Spec-> catfile($input_dir,$file[$i])};
		if($file[$i] =~ /.gpf$/){$grid=File::Spec-> catfile($input_dir,$file[$i])};
		}

	#my @ligfile_with_path;
	opendir(DIR,$input_lig_dir) || die "can not open the lig directory";
	@lig_file=readdir(DIR);
	close(DIR);

	my @temp_lig;
	for my $i (0..$#lig_file){
		next if ($lig_file[$i] =~ /^old/);
		push(@temp_lig,$lig_file[$i]);
	}

	my $dict_lig;
	$dict_lig = File::Spec -> catfile($out_prefix,"dict_lig_name.txt");
	for my $i (0..$#temp_lig){
		open(WF,">>$dict_lig") || die $!;
		if($temp_lig[$i] =~ /\.+$/){next};
		$temp_lig[$i] =~ /(.*?).pdbqt$/;
		print WF $1."\t";
		$temp_lig[$i] =~ s/ /_/g;
		$temp_lig[$i] =~ s/\(//g;
		$temp_lig[$i] =~ s/\)//g;
		$temp_lig[$i] =~ s/\[//g;
		$temp_lig[$i] =~ s/\]//g;
		$temp_lig[$i] =~ s/\'//g;
		$temp_lig[$i] =~ s/\,/-/g;
		$temp_lig[$i] =~ /(.*?).pdbqt$/;
		print WF $1."\n";
		close(WF);
	}

	for my $i (0..$#lig_file){
		if($lig_file[$i] =~ /\.+$/){next};
		next if ($lig_file[$i] =~ /^old/);
	#	print $lig_file[$i]."\n";
		my $oldname=$lig_file[$i];
		$lig_file[$i] =~ s/ /_/g;
		$lig_file[$i] =~ s/\(//g;
		$lig_file[$i] =~ s/\)//g;
		$lig_file[$i] =~ s/\[//g;
		$lig_file[$i] =~ s/\]//g;
		$lig_file[$i] =~ s/\'//g;
		$lig_file[$i] =~ s/\,/-/g;
	#	my $temp=$input_lig_dir."\\".$lig_file[$i];
	#	push(@ligfile_with_path,$temp);
		if($oldname ne $lig_file[$i]){
			move("$input_lig_dir/$oldname","$input_lig_dir/$lig_file[$i]") || die "can not move lig file ";
			}
	}

	for my $i (0..$#lig_file){
		if($lig_file[$i] =~ /\.+$/){next};
		next if ($lig_file[$i] =~ /^old/);
		$lig_file[$i] =~ s/ /_/g;
		$lig_file[$i]=~/(.*?).pdbqt$/;
		my $new_temp = File::Spec -> catdir($input_dir,$1);
		if(!(-d $new_temp)){
				mkdir ($new_temp);
			}
		if (!(-e $new_temp."/".$1."_config.txt")){
		print $grid."\n";
		print $new_temp."/".$1."_config.txt\n";
		
		my $spacing;
		open(RF,$grid) || die "do not have grid.gpf file";
		while(my $line = <RF>){
			chomp($line);
			if($line =~ /^spacing/){
				my @temp_spacing = split(/\ /,$line);
				$spacing = $temp_spacing[1];
			}
		}
		close(RF);
				
		open(RF,$grid) || die "do not have grid.gpf file";
		open(WF,">>".$new_temp."/".$1."_config.txt") || die "can not write config.txt";
		my @npts;
		my @gridcenter;
		print WF "receptor = ".$rep."\n";
		print WF "ligand = ".$input_lig_dir."/".$lig_file[$i]."\n";
		while(my $line=<RF>){
			if($line =~ /^gridcenter/){
				@gridcenter=split(/\ /,$line);
				print WF "center_x = ".$gridcenter[1]."\n";
				print WF "center_y = ".$gridcenter[2]."\n";
				print WF "center_z = ".$gridcenter[3]."\n";
			}
			if($line =~ /^npts/){
				@npts=split(/\ /,$line);
				print WF "size_x = ".$npts[1] * $spacing."\n";
				print WF "size_y = ".$npts[2] * $spacing."\n";
				print WF "size_z = ".$npts[3] * $spacing."\n";
			}
			}
			print WF "energy_range = 5\n";
			print WF "num_modes = 20\n";
			close(RF);
			close(WF);
		}
	#	print `$vina --help`;
		my $conf_file=$new_temp."/".$1."_config.txt";
		my $log_file=$new_temp."/".$1."_log.txt";
		my $out_file=$new_temp."/"."output_".$lig_file[$i];
	#	print "$vina --config $conf_file --log $log_file --out $out_file\n";
		print `$vina --config $conf_file --log $log_file --out $out_file`."\n";
		}
}

sub HELP_MESSAGE{
	my $help_message=<<USAGE;
	Usage:
		perl vina_analysis.pl [options] <input/output>
	options:
	--rep_box_path = Pathways to receptors and boxes
	--lig_path = Ligand Path
	--vina_path = the program of vina
	-h = prints this message
USAGE
	
	print $help_message;
}

