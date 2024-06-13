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

rule not_human:
    input:
        sequences = "../ingest/results/sequences.fasta",
        metadata = "results/metadata.tsv",
        exclude = "defaults/dropped_strains.txt"
    output:
        sample_strains = "results/sample_strains_not_human.txt"
    params:
        query = config["subsampling"]["not_human"],
        subsample_max_sequences = config["subsampling"]["not_human_max"],
        min_length = config["filter"]["min_length"]  
    shell:
        """
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --exclude {input.exclude} \
            --query {params.query:q} \
            --subsample-max-sequences {params.subsample_max_sequences:q} \
            --min-length {params.min_length:q} \
            --output-strains {output.sample_strains:q} \
        """

rule human:
    input:
        sequences = "../ingest/results/sequences.fasta",
        metadata = "results/metadata.tsv",
        exclude = "defaults/dropped_strains.txt"
    output:
        sample_strains = "results/sample_strains_human.txt"
    params:
        group_by = config["subsampling"]["human_group"],
        query = config["subsampling"]["human"],
        subsample_max_sequences = config["subsampling"]["sequences_per_group"],
        min_length = config["filter"]["min_length"]        
    shell:
        """
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --exclude {input.exclude} \
            --query {params.query:q} \
            --group-by {params.group_by:q} \
            --sequences-per-group {params.subsample_max_sequences:q} \
            --min-length {params.min_length:q} \
            --output-strains {output.sample_strains:q} \
        """

rule combine_intermediate_samples:
    input:
        sequences = "../ingest/results/sequences.fasta",
        metadata = "results/metadata.tsv",
        include_not_human = "results/sample_strains_not_human.txt",
        include_human = "results/sample_strains_human.txt"
    output:
        sequences = "results/subsampled_sequences.fasta",
        metadata = "results/subsampled_metadata.tsv"     
    shell:
        """
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --exclude-all \
            --include {input.include_human:q} {input.include_not_human:q} \
            --output-sequences {output.sequences:q} \
            --output-metadata {output.metadata:q} \
        """

rule align:
    input:
        sequences = "results/subsampled_sequences.fasta",
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