"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

REQUIRED INPUTS:

    metadata            = data/metadata.tsv
    prepared_sequences  = results/prepared_sequences.fasta
    tree                = results/tree.nwk

OUTPUTS:

    node_data = results/*.json

    There are no required outputs for this part of the workflow as it depends
    on which annotations are created. All outputs are expected to be node data
    JSON files that can be fed into `augur export`.

    See Nextstrain's data format docs for more details on node data JSONs:
    https://docs.nextstrain.org/page/reference/data-formats.html

This part of the workflow usually includes the following steps:

    - augur traits
    - augur ancestral
    - augur translate
    - augur clades

See Augur's usage docs for these commands for more details.

Custom node data files can also be produced by build-specific scripts in addition
to the ones produced by Augur commands.
"""
rule ancestral:
    input:
        tree = "results/tree.nwk",
        alignment = "results/aligned.fasta"
    output:
        node_data = "results/nt_muts.json",
    log:
        "logs/ancestral.txt"
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output-node-data {output.node_data} \
        2>{log}
        """

rule translate:
    input:
        tree = "results/tree.nwk",
        node_data = "results/nt_muts.json",
        reference = "defaults/mers_genemap.gff"
    output:
        node_data = "results/aa_muts.json"
    log:
        "logs/translate.txt"
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output-node-data {output.node_data} \
        2>{log}
        """

rule traits:
    input:
        tree = "results/tree.nwk",
        metadata = "data/metadata.tsv"
    output:
        node_data = "results/traits.json",
    params:
        columns = config["traits"]["columns"],
    shell:
        """
        augur traits \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --output {output.node_data} \
            --columns {params.columns} \
            --confidence \
        """