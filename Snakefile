import pandas as pd

include: "rules/010-lookup.smk"
include: "rules/050-ref.smk"
include: "rules/100-fq2ubam.smk"
include: "rules/200-fq2bam.smk"
include: "rules/300-markdups.smk"

rule dev:
    input: "inter/300-markdups/merged/I0005_L1.bam",
