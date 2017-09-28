#!/usr/bin/env python

import argparse
from itertools import islice

def fai_chunk(fai_path, blocksize, decoy=False):
    '''
    Get chromosome region based on blocksize.
    '''
    seq_map = {}
    with open(fai_path) as handle:
        if not decoy:
            head = list(islice(handle, 25))
        else:
            head = list(handle)
        for line in head:
            tmp = line.split("\t")
            seq_map[tmp[0]] = int(tmp[1])
        for seq in seq_map:
            l = seq_map[seq]
            for i in range(1, l, blocksize):
                yield (seq, i, min(i+blocksize-1, l))

def is_nat(x):
    '''
    Checks that a value is a natural number.
    '''
    if int(x) > 0:
        return int(x)
    raise argparse.ArgumentTypeError('%s must be positive, non-zero' % x)

def main():
    parser = argparse.ArgumentParser('Faidx to BED files.')
    # Required flags.
    parser.add_argument('-f', '--reference_faidx_path', required = True, help = 'Reference faidx path. (i.e. GRCh38.d1.vd1.fa.fai)')
    parser.add_argument('-b', '--block_size', type = is_nat, default = 30000000, required = False, help = 'Parallel Block Size.')
    parser.add_argument('-a', '--all', action="store_true", help='If specified, it will include all the decoy sequences in the faidx.')
    args = parser.parse_args()
    faidx = args.reference_faidx_path
    blocksize = args.block_size
    ifuse = args.all
    for block in fai_chunk(faidx, blocksize, decoy=ifuse):
        bed = '{}_{}_{}.bed'.format(block[0], block[1], block[2])
        with open(bed, 'w') as fout:
            fout.write('{}\t{}\t{}\n'.format(block[0], block[1], block[2]))

if __name__ == '__main__':
    main()
