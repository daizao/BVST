## **BVST**
	BVST(Batch Virtual Screening Tool)  is a Perl-based pipline developed for high-throughput molecular docking and ranking of protein–molecule interactions.
### Please pay attention to the following issues before calculation
	1.Please make sure that the ligand file name is not too long.
	2.Prepare yourself's protein pdbqt and Grid box file 
	3.Please pay attention to the placement rules of folders.
	4.Please put all the lig files (mol2 or sdf formula) in the same doc, and named lig_file. 
	5.Before you run this program, you should copy your data in a safe path.
	6.Make sure OpenBabel,R,Perl is installed.
	7.The Linux version of Vina is compiled in the Centos 7 system. If you encounter an error in Vina on Linux, please recompile.

### OpenBabel Website : [OpenBabel](https://openbabel.org/)
### OpenBabel install in Linux
```Bash
sudo dnf install openbabel -y
```
or
```bash
sudo apt install openbabel -y
```

### Vina compilation reference : [Vina recompile](https://www.dzbioinformatics.com/2020/09/05/autodock-vina-%e6%ba%90%e7%a0%81%e7%bc%96%e8%af%91%e5%ae%89%e8%a3%85/)

### R Website: [R](https://www.r-project.org/)
### R script dependencies
```R
install.packages(c("ggplot2","tidyverse"))
```

### Usage
```Perl
perl /path/to/BVST/bin/run.pl --help
        Usage:
                perl run.pl [options]
        options:
        --path = Enter the folder path where the files is located
        --out_prefix = Output path of the results    default: out
        -h = prints this message
```
### Sample
```Perl
perl /path/to/BVST/bin/run.pl --path /path/to/files #the default out_prefix is out under the /path/to/files
```
or
```Perl
perl /path/to/BVST/bin/run.pl --path /path/to/files --out_prefix /path/to/output 
```

### In the output files, plot.pdf and final_sort_energy.txt were obtained
### the final_sort_energy.txt was like this:
	Mol_old_name    Molname Target  Energy
	Quercetin der   Quercetin_der   ESR1    -8.3
	ZINC105741014   ZINC105741014   MAPK14  -7.9
