"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

REQUIRED INPUTS:

    metadata    = data/metadata.tsv
    sequences   = data/sequences.fasta
    reference   = ../shared/reference.fasta

OUTPUTS:

    prepared_sequences = results/prepared_sequences.fasta

This part of the workflow usually includes the following steps:

    - augur index
    - augur filter
    - augur align
    - augur mask

See Augur's usage docs for these commands for more details.
"""
rule tidy_host_column:
    input:
        metadata = "../ingest/results/metadata.tsv"
    output:
        metadata = "results/metadata.tsv"
    shell:
        """
        python3 scripts/tidy_host_column.py \
            --metadata {input.metadata} \
            --output-file {output.metadata} \
        """

rule filter:
    input:
        sequences = "../ingest/results/sequences.fasta",
        metadata = "results/metadata.tsv",
        exclude = "defaults/dropped_strains.txt"
    output:
        sequences = "results/filtered.fasta"
    params:
        min_length = config["filter"]["min_length"]
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --exclude {input.exclude} \
            --output {output.sequences} \
            --min-length {params.min_length}
        """
rule align:
    input:
        sequences = "results/filtered.fasta",
        reference = "defaults/mers_reference.fasta",
        genemap = "defaults/mers_genemap.gff"
    output:
        alignment = "results/aligned.fasta",
        insertions = "results/insertions.tsv"
    shell:
        """
          nextclade run \
              --input-ref {input.reference} \
              --input-annotation {input.genemap} \
              --output-fasta - \
              --output-tsv {output.insertions} \
              {input.sequences} \
          | seqkit seq -i > {output.alignment} \
        """