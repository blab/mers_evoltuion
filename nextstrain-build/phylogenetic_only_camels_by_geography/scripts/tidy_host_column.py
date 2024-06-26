"""
This script adds a new column onto metadata.tsv called 'host' 
and changes the current 'host' column to 'host_scientific'. 
The new 'host' column contains the sequence's non-scientific name.
"""
import pandas as pd 
import argparse

def tidy_host_column(metadata, output_file):
    """
    This function takes the scientific name and changes it to the 
    non-scientific name and adds it to a new column called 'host'. 
    It also renames the accession column to 'strain' to temporarily 
    fix the duplicate strain issue.
    """
    df = pd.read_table(metadata)
    df = df.rename(columns={"host":"host_scientific","accession":"strain", "strain":"strain_name"})
    df['host'] = df['host_scientific']
    for index, value in df['host'].items():
        if value == 'Homo sapiens':
            df.at[index, 'host'] = 'Human' 
        elif value == 'Camelus dromedarius' or value == 'Camelus' or value == 'Camelus bactrianus':
            df.at[index, 'host'] = 'Camel'
        elif value == 'Lama glama':
            df.at[index, 'host'] = 'Llama'
        else:
            df.at[index, 'host'] = 'Bat'
    df.to_csv(output_file, sep='\t')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument("--metadata",
        help="Path to metadata.")
    parser.add_argument("--output-file",
        help="Path to output file.")

    args = parser.parse_args()

    tidy_host_column(args.metadata, args.output_file)
    


