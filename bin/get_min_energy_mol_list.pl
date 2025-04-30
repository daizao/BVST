#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use File::Basename;
use File::Spec;

my $usage=<<USAGE;
Usage:
	perl $0 --path /path/to/files/ --out_prefix output_files_dir
USAGE
if(@ARGV==0){print $usage}

my $path="";
my $out_prefix="";

GetOptions(
	'path=s' => \$path,
	'out_prefix:s' => \$out_prefix,
	'help|h' => \&HELP_MESSAGE,
);

if(($path ne "") && ($out_prefix ne "")){
	my $dir=$path;
	opendir(DIR,$dir) || die "no this dir";
	my @first_file=readdir(DIR);
	close(DIR);

	my @doc;	# store the gene doc;
	my $out_dir = basename($out_prefix);

	for my $i (0..$#first_file){
		if($first_file[$i] =~ /\.+$/){next};
		next if($first_file[$i] =~ /git$/);
		next if ($first_file[$i] eq $out_dir);
		my $gene_doc = File::Spec -> catdir($dir,$first_file[$i]);
#		print $gene_doc;
		if (-d ($gene_doc)){
			push(@doc,$first_file[$i]);
		}
	}
#	print @doc;
	my @lig_name;
	my $total_temp = File::Spec -> catfile($out_prefix,"total_temp.txt");
	open(WF,">$total_temp") || die $!;
	print WF "Molname\t"."Target\t"."Energy\n";
	for my $i (0..$#doc){
		my $lig_path=$dir."/".$doc[$i]."/lig_file";
		opendir(DIR,$lig_path) || die "do not have the lig_path";
		@lig_name=readdir(DIR);
		close(DIR);
		for my $j (0..$#lig_name){
			if($lig_name[$j] =~ /\.+$/){next};
			if($lig_name[$j] =~/ /){next};
			next if ($lig_name[$j] =~ /^old/);
			my $old_lig_name = $lig_name[$j];
			$lig_name[$j] =~ /(.*?).pdbqt/;
	#		print $1."\n";
			my $log_path=$dir."/".$doc[$i]."/".$1."/".$1."_log.txt";
			my $temp=$1;
	#		print $log_path."\n";
			open(RF,$log_path) || die "no lig_log path";
			while(my $line=<RF>){
				chomp($line);
				if($line =~ /\s+1\s/){ #get the minnum energy data;
					my @arr=split(/\s+/,$line);
					print WF $temp."\t".$doc[$i]."\t".$arr[2]."\n";
					}
			}
			close(RF);
		}
	}
	close(WF);

	my $final_total_energy = File::Spec -> catfile($out_prefix,"final_total_energy.txt");
	open(WF,">$final_total_energy") || die $!;

	my %hash_energy;
	my @list;
	my $hang=0;

	open(RF,$total_temp) || die "do not have $total_temp";
	while(my $line=<RF>){
		chomp($line);
		if($.==1){
			my @head=split(/\t/,$line);
			print WF $head[0]."\t".$head[1]."\t".$head[2]."\n";
			next;
			}
		my @arr=split(/\t/,$line);
	#	$hash_energy{$arr[2]}="$arr[0]\t$arr[1]";
		for my $i (0..$#arr){
			$list[$hang][$i]=$arr[$i];
			}
		$hang=$hang+1;
	}
	close(RF);

	@list=sort{$a -> [2] <=>$b -> [2]} @list;

	for my $i (0..$#list){
		for my $j (0..$#{$list[$i]}){
			print WF $list[$i][$j]."\t";
		}
		print WF "\n";
	}

	#for my $key (sort {$a <=> $b}keys %hash_energy){
	#		print WF $key."\t".$hash_energy{$key}."\n";
	#	}
	#close(WF);

	my %lig_name_hash;
	my $dict_lig_name = File::Spec -> catfile($out_prefix,"dict_lig_name.txt");
	open(RF,$dict_lig_name) || die "do not have dit_lig_name file";
	while(my $line=<RF>){
		chomp ($line);
		my @arr=split(/\t/,$line);
		$lig_name_hash{$arr[1]}=$arr[0];
	}
	close(RF);

	my $final_sort_energy = File::Spec -> catfile($out_prefix,"final_sort_energy.txt");
	open(RF,$final_total_energy) || die "no final_total_energy.txt";
	open(WF,">$final_sort_energy") || die $!;
	while(my $line=<RF>){
		chomp($line);
		if($.==1){print WF "Mol_old_name\t".$line."\n";next};
		my @arr=split(/\t/,$line);
		if(exists $lig_name_hash{$arr[0]}){
			print WF $lig_name_hash{$arr[0]}."\t".join("\t",@arr)."\n";
		}	
	}
	close(RF);
	close(WF);

	unlink "$total_temp";
	unlink "$dict_lig_name";
	unlink "$final_total_energy";
}

sub HELP_MESSAGE{
	my $help_message=<<USAGE;
	Usage:
		perl run.pl [options] <input/output>
	options:
	--path = Enter the folder path where the files is located
	--out_prefix = Output path of the results
	-h = prints this message
USAGE
	
	print $help_message;
}