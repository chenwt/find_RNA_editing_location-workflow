#!usr/bin/perl -w	#perl for Bowtie ֱ����������ļ����ɣ���Ϊ�����һ�б��л�������Ϣ���൱��������֪λ��
use Switch;
my $starttime=time;
$dir=$ARGV[0]."/cluster";#����ľ����ļ�·��
$dir1=$ARGV[0]."/diff_point";				#����Ľ���ļ�·��
$run=$ARGV[1];
opendir (DIR,$dir) or die "Can't open the document!";
@dir= readdir DIR;
foreach $file (@dir){
	if($file =~ /_resort_$run/){#��ȡ�����ļ�
		print "$file\n";
		@name2=split/_/,$file;
		$file_name=$name2[0];#Ⱦɫ����

		open IN,"$dir/$file";
		open OUT,">$dir1/result_$file_name\_$run\.txt";#����ļ�
		while($rd=<IN>){
			chomp $rd;
			@rd=split/\s+/,$rd;
			if($rd[0]=~/^>chr/){#----ÿ������Ŀ�ʼ��־����ȡ��>chr��ͷ����
				@rd1=split/_/,$rd[0];
				@rd2=split/-/,$rd1[1];#�ָ��õ�������ʼ����ֹ����
				@rd3=split/:/,$rd[2];#�����е�����������reads��100
				$base_num=length $rd[3];#�����еĻ�����������
#-----------------------------��ʼ��
				for($i=0;$i<$base_num;$i++){#ÿһ��λ�����Ϣ��ʼ��
					$array0[$i]="";    #��¼�����е�i��λ���Ⱦɫ��
					$array1[$i]=0;		 #��¼�����е�i��λ�������
					$array2[$i]="";	 #��¼�����е�i��λ��ļ�����ͣ��������ϣ�
					$array_A[$i]=0;	 #��¼�����е�i��λ���RNA-Seq���������ּ�����ֵ�Ƶ��
					$array_T[$i]=0;
					$array_C[$i]=0;
					$array_G[$i]=0;
				}
				$tt="";         	#��¼�����ϵļ������
				$count=$rd3[1];	#�����е�����������
#-----------------------------������������Ϣ�����ڴ棬��ÿһ��λ�㸳��ֵ
				for($i=0;$i<$base_num;$i++){
					$array0[$i]=$file_name;#-----------Ⱦɫ��
					$array1[$i]=$rd2[0]+$i;#-----------����
					$array2[$i]=substr($rd[3],$i,1);#--������ͣ�ACGTN
				}
			}else{#-----------------��ȡ�����е�reads
				$count--;#��¼������ʣ����������countΪ0ʱ�������Ѿ����˸�������һ��
				$num=@rd;#���б�Tab���ָ�ĵ�Ԫ����TopHat��һ�ֱȶ���13�У��ڶ��ֱȶ���14��,bowtie��15��(solid)
				if($rd[$#rd] =~ /^CM:i:/){#�ж��Ƿ�Ϊsolid��ʽ
					$num--;
				}
				for($i=0;$i<$base_num;$i++){#����ÿһ�У���������λ�㣬���Ƿ���λ���ڸ�����
					if($array1[$i]>=($rd[$num-10]+length($rd[$num-14]))){#��i��λ�����곬�����еķ�Χ�����i+1��λ��Ҳ������Χ������forѭ��
						last;
					}elsif($array1[$i]<$rd[$num-10]){#��i��λ������С�ڸ��еķ�Χ������������i+1��λ��
						next;
					}else{#��i��λ�������ڸ��з�Χ�ڣ���¼��λ��ļ�����ͣ�ACGTN?
						$pos=$array1[$i]-$rd[$num-10]; #�༭λ��������ȥ���ε���ʼ����,�õ���������ߵĳ���
						$tt=substr($rd[$num-14],$pos,1);#���������ϵ�i���
						switch($tt){
							case ("A") {$array_A[$i]++;last;}#��¼��iλ���ת¼�����ACGT���ж���?
							case ("T") {$array_T[$i]++;last;}
							case ("C") {$array_C[$i]++;last;}
							case ("G") {$array_G[$i]++;last;}
							default {last;}
						}
					}
				}
				if($count==0){#������������һ�У�ͳ�Ƹ���������λ�����Ϣ�������
					for($i=0;$i<$base_num;$i++){
						$sum=$array_A[$i]+$array_T[$i]+$array_C[$i]+$array_G[$i];#��i��λ��ĸ�������
						$flag_0=0;#--------------��¼����������
						$flag_1=0;#--------------��¼������֧����
						$flag_2="";#-------------��¼����������
#---------------------ÿһ��λ��i�����ջ���������ͬ���ֳ������������
						if($array2[$i] eq "A"){#---��������A��˳��TCG
							$temp_count[0]=$array_T[$i];#������
							$temp_count[1]=$array_C[$i];
							$temp_count[2]=$array_G[$i];
							$temp_base[0]="T";			 #���
							$temp_base[1]="C";
							$temp_base[2]="G";
							if($array_A[$i]==$sum){#�޴��䣬�����
								next;
							}else{
								for($j=0;$j<3;$j++){#TCGѭ��
									if($temp_count[$j]!=0){#�Ƿ���A��T��A��C��A��G����
										$flag_0++;					#��¼��������
										$flag_1=$temp_count[$j];#��¼�������
										$flag_2=$temp_base[$j]; #��¼��������
									}
								}
								if($flag_0==1){#---------ֻ�����һ�ִ������͵�λ��
									print OUT "$array0[$i]\t$array1[$i]\t$array2[$i]-$flag_2\tA:$array_A[$i]\t$flag_2:$flag_1\tsum:$sum\n";
								}
							}
						}elsif($array2[$i] eq "T"){#---��������T��˳��ACG
							$temp_count[0]=$array_A[$i];#������
							$temp_count[1]=$array_C[$i];
							$temp_count[2]=$array_G[$i];
							$temp_base[0]="A";					#���
							$temp_base[1]="C";
							$temp_base[2]="G";
							if($array_T[$i]==$sum){#�޴��䣬�����
								next;
							}else{
								for($j=0;$j<3;$j++){#ACGѭ��
									if($temp_count[$j]!=0){
										$flag_0++;
										$flag_1=$temp_count[$j];
										$flag_2=$temp_base[$j];
									}
								}
								if($flag_0==1){#---------��ֻ֤��һ�ִ�������
									print OUT "$array0[$i]\t$array1[$i]\t$array2[$i]-$flag_2\tT:$array_T[$i]\t$flag_2:$flag_1\tsum:$sum\n";
								}
							}
						}elsif($array2[$i] eq "C"){#---��������C��˳��ATG
							$temp_count[0]=$array_A[$i];#������
							$temp_count[1]=$array_T[$i];
							$temp_count[2]=$array_G[$i];
							$temp_base[0]="A";					#���
							$temp_base[1]="T";
							$temp_base[2]="G";
							if($array_C[$i]==$sum){#�޴��䣬�����
								next;
							}else{
								for($j=0;$j<3;$j++){#ATGѭ��
									if($temp_count[$j]!=0){
										$flag_0++;
										$flag_1=$temp_count[$j];
										$flag_2=$temp_base[$j];
									}
								}
								if($flag_0==1){#---------��ֻ֤��һ�ִ�������
									print OUT "$array0[$i]\t$array1[$i]\t$array2[$i]-$flag_2\tC:$array_C[$i]\t$flag_2:$flag_1\tsum:$sum\n";
								}
							}
						}elsif($array2[$i] eq "G"){#---��������G��˳��ATC
							$temp_count[0]=$array_A[$i];#������
							$temp_count[1]=$array_T[$i];
							$temp_count[2]=$array_C[$i];
							$temp_base[0]="A";					#���
							$temp_base[1]="T";
							$temp_base[2]="C";
							if($array_G[$i]==$sum){#�޴��䣬�����
								next;
							}else{
								for($j=0;$j<3;$j++){#ATCѭ��
									if($temp_count[$j]!=0){
										$flag_0++;
										$flag_1=$temp_count[$j];
										$flag_2=$temp_base[$j];
									}
								}
								if($flag_0==1){#---------��ֻ֤��һ�ִ�������
									print OUT "$array0[$i]\t$array1[$i]\t$array2[$i]-$flag_2\tG:$array_G[$i]\t$flag_2:$flag_1\tsum:$sum\n";
								}
							}
						}else{
							next;
						}
					}
				}
			}
		}
	}
}

			

my $duration=time-$starttime;
print "time:$duration";
