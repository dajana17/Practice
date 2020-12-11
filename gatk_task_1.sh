 #!/usr/bin/env bash
FASTA_FILE="test.fa"
FASTQ_1="test_new_dup_dna_1.fq"
FASTQ_2="test_new_dup_dna_2.fq"
BAM_FILE="test.bam"
BAM_FILE_SORTED="test_sorted.bam"
FASTQ_1_TRIMM="test_new_dup_dna_1_trimm.fq"
FASTQ_2_TRIMM="test_new_dup_dna_2_trimm.fq"


if [ ${FASTQ_1%_*} == ${FASTQ_2%_*} ]; then
    echo "names of files are good, continue"
else
    echo "names of files are not the same"
    exit
fi

echo perform fastp analysis
./fastp -i ${FASTQ_1} -I ${FASTQ_2} -o ${FASTQ_1_TRIMM} -O ${FASTQ_2_TRIMM}

if
     [[ ! -e "mkdir.${FASTA_FILE}.GCF.1.bt2" ]] || \
     [[ ! -e "mkdir.${FASTA_FILE}.GCF.2.bt2" ]] || \
     [[ ! -e "mkdir.${FASTA_FILE}.GCF.3.bt2" ]] || \
     [[ ! -e "mkdir.${FASTA_FILE}.GCF.4.bt2" ]] || \
     [[ ! -e "mkdir.${FASTA_FILE}.GCF.rev.1.bt2" ]] \
     || [[ ! -e "mkdir.${FASTA_FILE}.GCF.rev.2.bt2" ]]
then
    bowtie2-build ${FASTA_FILE} mkdir.${FASTA_FILE}.GCF
    echo bowtie2 index files are created


else
    echo bowtie2 index files already created
fi

if
    [[ ! -e ${BAM_FILE} ]]
then

    bowtie2 -p 4 -x mkdir.${FASTA_FILE}.GCF -1 ${FASTQ_1_TRIMM} -2 ${FASTQ_2_TRIMM} > ${BAM_FILE}
    samtools sort ${BAM_FILE} > ${BAM_FILE_SORTED}
    samtools stats  ${BAM_FILE_SORTED} > ${BAM_FILE_SORTED}.txt
    echo Done with Bowtie2_alignment


else
     echo aligned bam file already exist

fi

 echo perform MultiQC analysis
 multiqc .

java -jar picard.jar EstimateLibraryComplexity \
     I=$BAM_FILE_SORTED \
     O=est_lib_complex_metrics.txt
