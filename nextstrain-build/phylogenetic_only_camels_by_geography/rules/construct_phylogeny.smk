"""
This part of the workflow constructs the phylogenetic tree.

REQUIRED INPUTS:

    metadata            = data/metadata.tsv
    prepared_sequences  = results/prepared_sequences.fasta

OUTPUTS:

    tree            = results/tree.nwk
    branch_lengths  = results/branch_lengths.json

This part of the workflow usually includes the following steps:

    - augur tree
    - augur refine

See Augur's usage docs for these commands for more details.
"""
rule tree:
    input:
        alignment = "results/{region}/aligned.fasta"
    output:
        tree = "results/{region}/tree_raw.nwk"
    shell:
        """
        augur tree \
            --alignment {input.alignment} \
            --output {output.tree}
        """

rule refine:
    input:
        tree = "results/{region}/tree_raw.nwk",
        alignment = "results/{region}/aligned.fasta",
        metadata = "results/{region}/metadata.tsv"
    output:
        tree = "results/{region}/tree.nwk",
        node_data = "results/{region}/branch_lengths.json"
    shell:
        """
        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --timetree \
            --output-tree {output.tree} \
            --output-node-data {output.node_data}
        """
