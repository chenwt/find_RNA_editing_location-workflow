#!usr/bin/perl -w
#-------------------------�˳���֪snpλ��
$string =$ARGV[0];

$dir="$string/diff_point";#����1��result_qual_chrY.txt��
$dir1="/home/storage/lung/snp137_sort_in_chr";#����2����֪snpλ��
$dir2="$string/filter_snp";#�����result_snp_chrY.txt��
opendir (DIR,$dir) or die "Can't open the dictionary!";
@dir=readdir DIR;
foreach $file (@dir){
	if($file=~/^result_chr/){
		print "$file\n";
		@name1=split/_/,$file;
		$file_out="result_snp_$name1[1]_$name1[2]";
	   open OUT,">$dir2/$file_out";
	  
	   $a=0;
	   @site="";
	   $file1="snp137_$name1[1]\.txt";
	   #print "$file1\n";
	   open IN1,"$dir1/$file1";
	   while($rd=<IN1>){
	 	 	$a++;
	  		chomp $rd;
			@rds = split('\t+',$rd);
	  		$site[$a]=$rds[1];
	 	 }
	  
	   $temp=1;
	   open IN,"$dir/$file";
	   while($rd=<IN>){
	  		$flag=0;	#��ʶ����������֪snpλ�㣬��Ϊ1
	  		chomp $rd;
	  		@rd=split/\t+/,$rd;
	  		for($i=$temp;$i<=$a;$i++){
	  			if($rd[1]==$site[$i]){
	  				$flag=1;
	  				$temp=$i;
	  				last;
	  			}elsif($rd[1]>$site[$i]){
	  				next;
	  			}else{
	  				$temp=$i;
	  				last;
	  			}
	 	 	}
	  		if($flag==0){
	 	 		print OUT "$rd\n";
	  		}
		 }
	}
}
