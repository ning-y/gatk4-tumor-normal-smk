from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()

# From GATK's resource bundle:
# https://web.archive.org/web/20231001051022/https://gatk.broadinstitute.org/hc/en-us/articles/360035890811
# Or, listed directly at:
# https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0

DOWNLOAD_REMOTES = {
    "Homo_sapiens_assembly38.fasta":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta"),
    # BWA indices
    "Homo_sapiens_assembly38.fasta.64.alt":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.64.alt"),
    "Homo_sapiens_assembly38.fasta.64.amb":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.64.amb"),
    "Homo_sapiens_assembly38.fasta.64.ann":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.64.ann"),
    "Homo_sapiens_assembly38.fasta.64.bwt":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.64.bwt"),
    "Homo_sapiens_assembly38.fasta.64.pac":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.64.pac"),
    "Homo_sapiens_assembly38.fasta.64.sa":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.64.sa"),
    # samtools index
    "Homo_sapiens_assembly38.fasta.fai":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.fasta.fai"),
    # GATK index
    "Homo_sapiens_assembly38.dict":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.dict"),
    # BQSR databases
    "Homo_sapiens_assembly38.dbsnp138.vcf":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.dbsnp138.vcf"),
    "Mills_and_1000G_gold_standard.indels.hg38.vcf.gz":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"),
    "Homo_sapiens_assembly38.known_indels.vcf.gz":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.known_indels.vcf.gz"),
    # BQSR database indices
    "Homo_sapiens_assembly38.dbsnp138.vcf.idx":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.dbsnp138.vcf.idx"),
    "Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi"),
    "Homo_sapiens_assembly38.known_indels.vcf.gz.tbi":
        HTTP.remote("https://storage.googleapis.com/"
                    "genomics-public-data/resources/broad/hg38/v0/"
                    "Homo_sapiens_assembly38.known_indels.vcf.gz.tbi"),
}

rule ref_download:
    output: downloaded = "inter/050-ref/{filename}",
    input: remote = lambda wc: DOWNLOAD_REMOTES[wc.filename],
    wildcard_constraints:
        filenames = "({})".format("|".join(DOWNLOAD_REMOTES.keys()))
    retries: 2
    shell: "cp {input.remote} {output.downloaded}"
