rule fq2bam:
    output: bam = temp("inter/200-fq2bam/{read_group}.bam"),
    input:
        fastqs = lambda wc: get_fqs_for_read_group(wc.read_group),
        genome = "inter/050-ref/Homo_sapiens_assembly38.fasta",
        _genome_indices = [ \
            f"inter/050-ref/Homo_sapiens_assembly38.fasta.64.{ext}" \
            for ext in ["alt", "amb", "ann", "bwt", "pac", "sa"] ],
    log: stderr = "logs/200-fq2bam/10-aligned/{read_group}.stderr",
    threads: 16
    resources: mem_mb = 16_000,
    # chunk_size sets a consistent chunk size rather than the default
    # threads * 10M bases, ensuring reproducible alignments. See
    # https://github.com/CCDG/Pipeline-Standardization/issues/2.
    # verbose_level goes from 1 to 4 in order of increasing verbosity, but
    # verbose level 4 leaks into stdin.
    params: chunk_size = 100000000, verbose_level = 3,
    # bwa mem -Y uses CIGAR soft clipping rather than hard clipping for
    # supplementary alignments: https://github.com/SciLifeLab/Sarek/issues/770.
    # samtools -1 is fast compression which defaults to BAM output.
    conda: "envs/bwa.yaml"
    shell: """
        bwa mem -t {threads} \
                -K {params.chunk_size} -v {params.verbose_level}  -Y \
                {input.genome} {input.fastqs} \
            2> {log.stderr} | samtools view -1 > {output.bam}"""

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
