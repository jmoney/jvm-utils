#!/bin/sh
#
# Program: Print GC times <gctime>
#
# Purpose:
#   This script analyzes GC logs to see how much time is spent
#   performing garbage collection.
#
# Notes:
#   This script requires that the JVM was started with the "-XX:+PrintGCApplicationStoppedTime"
#   and "-XX:+PrintGCApplicationConcurrentTime" options.
#
# Example:
#   $ gctime gc.log
#   Total execution time               : 66.30secs
#   Time application ran               : 55.47secs
#   Time application was stopped       : 10.84secs
#   % of time application ran          : 83.65%
#   % of time application was stopped  : 16.35%

if [ ! -f "${1}" ] ; then
    echo "Usage: $0 <GC Log>"
    exit 1
fi

# NOTE: you'd really only use STARTLAG when you have ONLY gc.log.0 and you just started looking
STARTLAG=0
if [ "x${2}" = "x" ]; then
    STARTLAG=$2
fi


# 2014-09-06T14:17:02.136-0500: 10816.645: Application time: 9.1890410 seconds
# 2014-09-03T00:33:33.183-0500: 4804.262: Total time for which application threads were stopped: 0.2268070 seconds


awk -v start=$STARTLAG 'BEGIN{max=-1; min=100000000.0; sum=0; knt=0; first=0; last=-1; num=0; appstop=0; apprun=0}
     /Application time/     { runtime = $2; if (runtime > start) apprun += $(NF-1); if (first == 0) first=$(NF-5); last=$(NF-5) }
     /threads were stopped/ { runtime = $2; num=$(NF-1);  if (runtime > start) appstop += num; if (num > max && runtime > start) max=num; if (num < min && runtime > start) min=num; if (runtime > start) sum+=num; if (runtime > start) knt += 1}
     END {
          total = apprun + appstop
          printf("Total execution time               : %.2f secs\n", total)
          printf("Time appication ran                : %.2f secs\n", apprun)
          printf("Time application was stopped       : %0.2f secs\n", appstop)
          printf("%% of time application ran          : %.2f%%\n", apprun / total * 100)
          printf("%% of time application was stopped  : %.2f%%\n", appstop / total * 100)
          printf("Minimum stop                       : %.4f secs\n", min)
          printf("Maximum stop                       : %.4f secs\n", max)
          printf("Average stop                       : %.4f secs\n", sum/knt)
          printf("Logs begin                         : %s\n", first)
          printf("Logs end                           : %s\n", last)
     }' ${1}
