#!/usr/bin/env python

import argparse

def annotate_filter(raw, post_filter, new):
    filter_pass = '##FILTER=<ID=PASS,Description="Accept as a high confident somatic mutation">'
    filter_reject = '##FILTER=<ID=REJECT,Description="Rejected as an unconfident somatic mutation">'
    filter_loh = '##FILTER=<ID=LOH,Description="Rejected as a loss of heterozygosity">'
    with open(raw, 'rb') as fin:
        line = fin.readlines()
        with open(post_filter, 'rb') as fcom:
            comp = fcom.readlines()
            hc = set(line).intersection(comp)
            with open(new, 'w') as fout:
                for i in line:
                    if i.startswith('##fileformat'):
                        fout.write(i)
                        fout.write('{}\n'.format(filter_pass))
                        fout.write('{}\n'.format(filter_reject))
                        fout.write('{}\n'.format(filter_loh))
                    elif i.startswith('#'):
                        fout.write(i)
                    elif i in hc:
                        new = i.split('\t')
                        new[6] = 'PASS'
                        fout.write('\t'.join(new))
                    elif i.split(':')[-2] == '3':
                        new = i.split('\t')
                        new[6] = 'LOH'
                        fout.write('\t'.join(new))
                    else:
                        new = i.split('\t')
                        new[6] = 'REJECT'
                        fout.write('\t'.join(new))

def main():
    parser = argparse.ArgumentParser('Annotate somaticsniper post filteration results back to raw outputs.')
    # Required flags.
    parser.add_argument('-r', '--raw_vcf', required = True, help = 'Raw vcf from somaticsniper calling.')
    parser.add_argument('-p', '--post_filter_file', required = True, help = 'Post highconfidence filter file.')
    parser.add_argument('-n', '--new_vcf', required = True, help = 'New file name.')
    args = parser.parse_args()
    raw = args.raw_vcf
    hc = args.post_filter_file
    new = args.new_vcf
    annotate_filter(raw, hc, new)

if __name__ == '__main__':
    main()
