"""
This part of the workflow collects the phylogenetic tree and annotations to
export a Nextstrain dataset.

REQUIRED INPUTS:

    metadata        = data/metadata.tsv
    tree            = results/tree.nwk
    branch_lengths  = results/branch_lengths.json
    node_data       = results/*.json

OUTPUTS:

    auspice_json = auspice/${build_name}.json

    There are optional sidecar JSON files that can be exported as part of the dataset.
    See Nextstrain's data format docs for more details on sidecar files:
    https://docs.nextstrain.org/page/reference/data-formats.html

This part of the workflow usually includes the following steps:

    - augur export v2
    - augur frequencies

See Augur's usage docs for these commands for more details.
"""
rule export:
    input:
        tree = "results/{region}/tree.nwk",
        metadata = "results/{region}/metadata.tsv",
        colors = "defaults/colors.tsv",
        branch_lengths = "results/{region}/branch_lengths.json",
        traits = "results/{region}/traits.json",
        nt_muts = "results/{region}/nt_muts.json",
        aa_muts = "results/{region}/aa_muts.json",
        auspice_config = "defaults/auspice_config.json"
    output:
        auspice_json = "auspice/mers_{region}.json",
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.traits} {input.nt_muts} {input.aa_muts} \
            --auspice-config {input.auspice_config} \
            --output {output.auspice_json} \
            --colors {input.colors}
        """
