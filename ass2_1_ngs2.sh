gs-01/My_Passport/ngs2workspace/ngs2_ass/chr22
wget http://genomedata.org/rnaseq-tutorial/fasta/GRCh38/chr22_with_ERCC92.fa
gunzip chr22_with_ERCC92.fa.gz

#Mapping to the reference

conda install star
genomeDir=/media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22
mkdir $genomeDir
STAR --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa --runThreadN 1

#Alignment jobs

cd /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass
runDir=/media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/1pass
mkdir $runDir
cd $runDir
cp /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/SRR8797509_1.part_001.fastq.gz /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/1pass/SRR8797509_1.part_001.fastq.gz
cp /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/SRR8797509_2.part_001.fastq.gz /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/1pass/SRR8797509_2.part_001.fastq.gz
gunzip SRR8797509_1.part_001.fastq.gz
gunzip SRR8797509_2.part_001.fastq.gz
STAR --genomeDir $genomeDir --readFilesIn /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/1pass/SRR8797509_1.part_001.fastq /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/1pass/SRR8797509_2.part_001.fastq --runThreadN 1

#Add read groups, sort, mark duplicates, and create index

picard_path=$CONDA_PREFIX/share/picard-2.19.2-0
java -jar $picard_path/picard.jar AddOrReplaceReadGroups I=Aligned.out.sam O=rg_added_sorted.bam SO=coordinate RGID=id RGLB=library RGPL=platform RGPU=machine RGSM=sample
java -jar $picard_path/picard.jar MarkDuplicates I=rg_added_sorted.bam O=dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics
samtools view -H rg_added_sorted.bam
samtools view -H dedupped.bam

# Split'N'Trim and reassign mapping qualities

samtools faidx /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa
java -jar gatk SplitNCigarReads -R /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa -I dedupped.bam -O split.bam

#indexing

