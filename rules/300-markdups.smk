rule markdups_merge_ubam:
    output: bam = temp("inter/300-markdups/merged/{read_group}.bam"),
    input:
        aligned = "inter/200-fq2bam/{read_group}.bam",
        unmapped = "inter/100-fq2ubam/{read_group}.bam",
        genome = "inter/050-ref/Homo_sapiens_assembly38.fasta",
        bwa_version = "inter/200-fq2bam/{read_group}-bwa.version",
        bwa_command = "inter/200-fq2bam/{read_group}-bwa.command",
        _genome_indices = "inter/050-ref/Homo_sapiens_assembly38.dict",
    log: stderr = "logs/300-markdups/merged/{read_group}.stderr",
    resources: mem_mb = 16_000,
    conda: "envs/gatk.yaml"
    shell: """
        gatk --java-options "-Xms{resources.mem_mb}M" MergeBamAlignment \
            --VALIDATION_STRINGENCY SILENT \
            --EXPECTED_ORIENTATIONS FR \
            --ATTRIBUTES_TO_RETAIN X0 \
            --ALIGNED_BAM {input.aligned} \
            --UNMAPPED_BAM {input.unmapped} \
            --REFERENCE_SEQUENCE {input.genome} \
            --OUTPUT {output.bam} \
            --PAIRED_RUN true \
            --SORT_ORDER "unsorted" \
            --IS_BISULFITE_SEQUENCE false \
            --ALIGNED_READS_ONLY false \
            --CLIP_ADAPTERS false \
            --MAX_RECORDS_IN_RAM 2000000 \
            --ADD_MATE_CIGAR true \
            --MAX_INSERTIONS_OR_DELETIONS -1 \
            --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
            --PROGRAM_RECORD_ID "bwamem" \
            --PROGRAM_GROUP_NAME "bwamem" \
            --PROGRAM_GROUP_VERSION "$(cat {input.bwa_version})" \
            --PROGRAM_GROUP_COMMAND_LINE "$(cat {input.bwa_command})" \
            --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
            --ALIGNER_PROPER_PAIR_FLAGS true \
            --UNMAP_CONTAMINANT_READS true 2> {log.stderr}"""

rule markdups_sort:
    output:
        bam = temp("inter/300-markdups/sorted/{read_group}.bam"),
        bai = temp("inter/300-markdups/sorted/{read_group}.bai"),
    input:
        merged = "inter/300-markdups/merged/{read_group}.bam",
        genome = "inter/050-ref/Homo_sapiens_assembly38.fasta",
        _genome_indices = "inter/050-ref/Homo_sapiens_assembly38.dict",
    log: stderr = "logs/300-markdups/sorted/{read_group}.stderr",
    resources: mem_mb = 16_000,
    conda: "envs/gatk.yaml"
    shell: """
        gatk --java-options "-Xms{resources.mem_mb}M" SortSam \
                --INPUT {input.merged} \
                --OUTPUT /dev/stdout \
                --SORT_ORDER "coordinate" \
                --CREATE_INDEX false \
                --CREATE_MD5_FILE false 2>> {log.stderr} |
            gatk --java-options "-Xms{resources.mem_mb}M" SetNmMdAndUqTags \
                --INPUT /dev/stdin \
                --OUTPUT {output.bam} \
                --CREATE_INDEX true \
                --CREATE_MD5_FILE false \
                --REFERENCE_SEQUENCE {input.genome} 2>> {log.stderr}"""

rule markdups_mark:
    output:
        bam = temp("inter/300-markdups/marked/{sample_name}.bam"),
        bai = temp("inter/300-markdups/marked/{sample_name}.bai"),
        metrics = "inter/300-markdups/marked/{sample_name}.txt",
    input:
        bams = lambda wc: [ f"inter/300-markdups/sorted/{read_group}.bam" \
            for read_group in get_read_groups_for_sample_name(wc.sample_name) ],
        _bais = lambda wc: [ f"inter/300-markdups/sorted/{read_group}.bai" \
            for read_group in get_read_groups_for_sample_name(wc.sample_name) ],
    log: stderr = "logs/300-markdups/marked/{sample_name}.stderr",
    resources: mem_mb = 16_000,
    params:
        inputs = lambda _, input: [ f"--INPUT {bam}" for bam in input.bams ],
    conda: "envs/gatk.yaml"
    # I couldn't get --CREATE_INDEX true to create an index.
    shell: """
        gatk --java-options "-Xms{resources.mem_mb}M" MarkDuplicates \
            {params.inputs} \
            --OUTPUT {output.bam} \
            --METRICS_FILE {output.metrics} \
            --VALIDATION_STRINGENCY SILENT \
            --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
            --ASSUME_SORT_ORDER "queryname" 2> {log.stderr}
        samtools index {output.bam} {output.bai}"""

# Adapted from https://github.com/gatk-workflows/gatk4-data-processing (c44603c)
#
# BSD 3-Clause License
#
# Copyright (c) 2017, Broad Institute
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
