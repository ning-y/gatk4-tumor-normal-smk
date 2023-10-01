import pandas as pd

include: "rules/010-lookup.smk"
include: "rules/100-fq2ubam.smk"

rule dev:
    input: "inter/100-fq2ubam/I0005_L1.bam",
