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

rule filter:
    input:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv",
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
# rule align:
#     input:
#         sequences = "results/filtered.fasta",
#         reference = "defaults/mers_reference.fasta",
#         genemap = "defaults/genemap.gff"
#     output:
#         alignment = "results/aligned.fasta"
#     shell:
#         """
#         augur align \
#             --sequences {input.sequences} \
#             --reference-sequence {input.reference} \
#             --output {output.alignment} \
#             --fill-gaps \
#             --remove-reference
#         """