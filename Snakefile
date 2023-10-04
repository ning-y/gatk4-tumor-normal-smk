import pandas as pd

include: "rules/010-lookup.smk"
include: "rules/050-ref.smk"
include: "rules/100-fq2ubam.smk"
include: "rules/200-fq2bam.smk"
include: "rules/300-markdups.smk"
include: "rules/400-bqsr.smk"

rule dev:
    input: "inter/400-bqsr/BC042.bam",
