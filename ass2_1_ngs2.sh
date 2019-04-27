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
picard_path=$CONDA_PREFIX/share/picard-2.19.2-0
java -Xmx2g -jar $picard_path/picard.jar BuildBamIndex VALIDATION_STRINGENCY=LENIENT INPUT=split.bam

java -Xmx2g -jar $picard_path/picard.jar CreateSequenceDictionary R=/media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa O=./chr22_with_ERCC92.dict

samtools faidx /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa

# Download known varinats

wget ftp://ftp.ensembl.org/pub/grch37/current/variation/vcf/homo_sapiens/homo_sapiens-chr22.vcf.gz -O chr22.vcf.gz
gunzip chr22.vcf.gz

#grep "^#" chr22.vcf > fam_chr22.vcf
#grep "^22" chr22.vcf | sed 's/^22/22 dna_sm:chromosome chromosome:GRCh38:22:1:50818468:1 REF
/' >> fam_chr22.vcf
#gatk IndexFeatureFile -F fam_chr22.vcf

# base recalibration:
#gatk --java-options "-Xmx2G" BaseRecalibrator -R /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa -I split.bam --known-sites fam_chr22.vcf -O split.report

#BQSR
#gatk --java-options "-Xmx2G" ApplyBQSR -R /media/ngs-01/My_Passport/ngs2workspace/ngs2_ass/chr22/chr22_with_ERCC92.fa -I split.bam -bqsr split.report -O split.bqsr.bam --add-output-sam-program-record --emit-original-quals



