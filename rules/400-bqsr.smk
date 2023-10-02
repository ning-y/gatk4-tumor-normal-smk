rule bqsr_generate_model:
    output: report = "inter/400-bqsr/{sample_name}.recal_data.csv",
    input:
        sorted = "inter/300-markdups/marked/{sample_name}.bam",
        genome = "inter/050-ref/Homo_sapiens_assembly38.fasta",
        known_sites = [ f"inter/050-ref/{db}" \
            for db in config["bqsr_db"].split(",") ],
        _genome_indices = [ f"inter/050-ref/Homo_sapiens_assembly38.{ext}" \
            for ext in ["dict", "fasta.fai"] ],
        _known_sites_indices = [ f"inter/050-ref/{db_idx}" \
            for db_idx in config["bqsr_db_idx"].split(",") ],
    log: stderr = "logs/400-bqsr/{sample_name}.recal_data.stderr",
    resources: mem_mb = 16_000,
    params: known_sites = lambda _, input: [ \
        f"--known-sites {vcf}" for vcf in input.known_sites ]
    conda: "envs/gatk.yaml"
    shell: """
        gatk --java-options "-Xms{resources.mem_mb}M" BaseRecalibrator \
            --reference {input.genome} \
            --input {input.sorted} \
            --use-original-qualities \
            --output {output.report} \
            {params.known_sites} 2> {log.stderr}"""

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
