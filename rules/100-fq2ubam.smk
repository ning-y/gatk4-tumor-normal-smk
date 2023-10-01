# Convert FASTQs to unmapped BAM files, per read group. Read groups represent
# a set of reads from a single run of the sequencer [1]. Adapted from GATK [2].
#
# [1]: https://web.archive.org/web/20231001034910/https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups
# [2]: https://web.archive.org/web/20231001035734/https://gatk.broadinstitute.org/hc/en-us/articles/4403687183515--How-to-Generate-an-unmapped-BAM-from-FASTQ-or-aligned-BAM

rule fq2ubam:
    output: ubam = temp("inter/100-fq2ubam/{read_group}.bam"),
    input: fastqs = lambda wc: get_fqs_for_read_group(wc.read_group),
    log: stderr = "logs/100-fq2ubam/{read_group}.stderr",
    params:
        fastq = lambda _, input: input.fastqs[0],
        fastq2 = lambda _, input: input.fastqs[1],
        sample_name = lambda wc: get_sample_name_for_read_group(wc.read_group),
        library_name = lambda wc: get_library_name_for_read_group(wc.read_group),
        platform_unit = lambda wc: \
            get_platform_unit_for_read_group(wc.read_group),
        platform = lambda wc: get_platform_for_read_group(wc.read_group),
    resources: mem_mb = 16_000,
    conda: "envs/picard.yaml"
    shell: """
        export JAVA_TOOL_OPTIONS="-Xmx{resources.mem_mb}M"
        picard FastqToSam \
            -READ_GROUP_NAME {wildcards.read_group} \
            -SAMPLE_NAME {params.sample_name} \
            -LIBRARY_NAME {params.library_name} \
            -PLATFORM_UNIT {params.platform_unit} \
            -PLATFORM {params.platform} \
            -FASTQ {params.fastq} -FASTQ2 {params.fastq2} \
            -OUTPUT {output.ubam} 2> {log.stderr}"""
