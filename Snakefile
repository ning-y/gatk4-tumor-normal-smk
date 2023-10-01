import pandas as pd

include: "rules/010-lookup.smk"
include: "rules/050-ref.smk"
include: "rules/100-fq2ubam.smk"
include: "rules/200-fq2bam.smk"

rule dev:
    input: "inter/200-fq2bam/I0005_L1.bam",
