#!/bin/bash
# send cpu/network usage information to prometheus
# I use it on digitcal ocean centos6 droplets.

. /etc/sysconfig/prometheus
# import variable promhost which should be something like http://1.2.3.4:9091 . Point the ip/port to the promethues pushgateway.
job=node
instance=$( hostname )

tmpdir=/dev/shm/promethues
[ -d $tmpdir ] || mkdir -p $tmpdir

outfile=$tmpdir/prom-topush.txt
function build_push_data()
{
# cpu  5585090 866 2687228 254859644 475786 4221 727593 244391 0
#     user: normal processes executing in user mode
#    nice: niced processes executing in user mode
#    system: processes executing in kernel mode
#    idle: twiddling thumbs
#    iowait: waiting for I/O to complete
#    irq: servicing interrupts
#    softirq: servicing softirqs
metric=cpu
epoch=$( date +%s )
echo "#TYPE $metric counter" >$outfile
    cat /proc/stat | grep -w cpu | while read name user nice sys idle iowait irq si steal other; do {
         cat - <<EOF
$metric{vendor="digitalocean", type="user"} $user ${epoch}000
$metric{vendor="digitalocean", type="nice"} $nice ${epoch}000
$metric{vendor="digitalocean", type="sys"} $sys ${epoch}000
$metric{vendor="digitalocean", type="idle"} $idle ${epoch}000
$metric{vendor="digitalocean", type="iowait"} $iowait ${epoch}000
$metric{vendor="digitalocean", type="irq"} $irq ${epoch}000
$metric{vendor="digitalocean", type="si"} $si ${epoch}000
$metric{vendor="digitalocean", type="steal"} $steal ${epoch}000
EOF
} done >>$outfile

metric=network
epoch=$( date +%s )
echo "#TYPE $metric counter" >>$outfile
    cat /proc/net/dev | grep -w eth0 | cut -d":" -f2 |  while read bytes packets errs drop fifo frame compressed multicast outbytes outpackets other; do {
         cat - <<EOF
$metric{vendor="digitalocean", type="bytes", direction="in" } $bytes ${epoch}000
$metric{vendor="digitalocean", type="packets", direction="in" } $packets ${epoch}000
$metric{vendor="digitalocean", type="bytes", direction="out" } $outbytes ${epoch}000
$metric{vendor="digitalocean", type="packets", direction="out" } $outpackets ${epoch}000
EOF
} done >>$outfile

#cat /proc/loadavg 
#0.00 0.06 0.12 1/81 22874
metric=loadavg
epoch=$( date +%s )
echo "#TYPE $metric gauge" >>$outfile
    cat /proc/loadavg  |  while read l1min l5min l30min other; do {
         cat - <<EOF
$metric{vendor="digitalocean", type="1min"} $l1min ${epoch}000
$metric{vendor="digitalocean", type="5min"} $l5min ${epoch}000
$metric{vendor="digitalocean", type="30min"} $l30min ${epoch}000
EOF
} done >>$outfile

}

function push_data()
{
  cat $outfile | curl --data-binary @- $promhost/metrics/job/$job/instance/$instance
}

function runOnce()
{ 
   build_push_data
   push_data
}
runOnce

