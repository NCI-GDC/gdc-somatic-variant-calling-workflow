#!/usr/bin/env python
'''Internal multithreading samtools mpileup calling'''

import os
import argparse
import subprocess
import string
from functools import partial
from multiprocessing.dummy import Pool, Lock

def is_nat(x):
    '''Checks that a value is a natural number.'''
    if int(x) > 0:
        return int(x)
    raise argparse.ArgumentTypeError('%s must be positive, non-zero' % x)

def do_pool_commands(cmd, lock = Lock(), shell_var=True):
    '''run pool commands'''
    try:
        output = subprocess.Popen(cmd, shell=shell_var, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output_stdout, output_stderr = output.communicate()
        with lock:
            print('running: {}'.format(cmd))
            print output_stdout
            print output_stderr
    except Exception:
        print("command failed {}".format(cmd))
    return output.wait()

def multi_commands(cmds, thread_count, shell_var=True):
    '''run commands on number of threads'''
    pool = Pool(int(thread_count))
    output = pool.map(partial(do_pool_commands, shell_var=shell_var), cmds)
    return output

def get_region(intervals):
    '''get region from intervals'''
    interval_list = []
    with open(intervals, 'r') as fh:
        line = fh.readlines()
        for bed in line:
            blocks = bed.rstrip().rsplit('\t')
            intv = '{}:{}-{}'.format(blocks[0], int(blocks[1])+1, blocks[2])
            interval_list.append(intv)
    return interval_list

def cmd_template(ref, min_mq, region, normal, tumor):
    '''cmd template'''
    template = string.Template("samtools mpileup -f ${REF} -q ${MIN_MQ} -B -r ${REGION} ${NORMAL} ${TUMOR} > ${OUTPUT}.mpileup")
    for interval in region:
        cmd = template.substitute(
            dict(
                REF=ref,
                MIN_MQ=min_mq,
                REGION=interval,
                NORMAL=normal,
                TUMOR=tumor,
                OUTPUT=interval.replace(':', '-')
            )
        )
        yield cmd

def main():
    '''main'''
    parser = argparse.ArgumentParser('Internal multithreading samtools mpileup calling.')
    # Required flags.
    parser.add_argument('-f', '--reference_path', required=True, help='Reference path.')
    parser.add_argument('-r', '--interval_bed_path', required=True, help='Interval bed file.')
    parser.add_argument('-t', '--tumor_bam', required=True, help='Tumor bam file.')
    parser.add_argument('-n', '--normal_bam', required=True, help='Normal bam file.')
    parser.add_argument('-c', '--thread_count', type=is_nat, required=True, help='Number of thread.')
    parser.add_argument('-m', '--min_mq', type=is_nat, required=True, help='min MQ.')
    args = parser.parse_args()
    ref = args.reference_path
    interval = args.interval_bed_path
    tumor = args.tumor_bam
    normal = args.normal_bam
    threads = args.thread_count
    min_mq = args.min_mq
    mpileup_cmds = list(cmd_template(ref, min_mq, get_region(interval), normal, tumor))
    outputs = multi_commands(mpileup_cmds, threads)
    if any(x != 0 for x in outputs):
        print('Failed multi_mpileup')
    else:
        print('Completed multi_mpileup')

if __name__ == '__main__':
    main()
