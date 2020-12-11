#! /usr/bin/bash


FILE1="TTP/test_new_dup_dna_1.fq"
FILE2="TTP/test_new_dup_dna_2.fq"
PUT="TTP/REZULTAT"
INDEX="$PUT/BOWTIE/INDEX"

if [ ${FILE1%_*} == ${FILE2%_*} ]
then 
   FILE="$(basename ${FILE1%_*})" 
   echo $FILE
else
    echo -e "Imena fajlova nisu konzistentna.\n"
    exit
fi

sleep 1

OUT1="$PUT/FASTP/${FILE}_trim1.fq"
OUT2="$PUT/FASTP/${FILE}_trim2.fq"
echo $OUT1

fastp  --html "$PUT/FASTP/fastp.html" --json "$PUT/FASTP/fastp.json" -i $FILE1 -I $FILE2 -o $OUT1 -O $OUT2


if ! [ -e "$INDEX" ]
then 
    echo -e "Sada cemo napraviti index fajl.\n"
    sleep 2
    mkdir $INDEX
    bowtie2-build TTP/REF/test.fa $INDEX/moj_index

else
    echo -e "Index fajl vec postoji.\n"
fi

sleep 2 

if ! [ -e "$PUT/BOWTIE/$FILE.bam" ]
then 
    echo -e "Sada cemo napraviti BAM fajl.\n"
    sleep 2 
    (bowtie2 -x $INDEX/moj_index -1 $OUT1 -2 $OUT2 |samtools view -bS - > "TTP/REZULTAT/BOWTIE/$FILE.bam") 2>"TTP/REZULTAT/BOWTIE/file.log"
    
else
    echo -e "$FILE.bam fajl vec postoji\n"
fi

sleep 2 


cd TTP/REZULTAT
multiqc .

