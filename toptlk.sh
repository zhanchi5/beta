#!/bin/bash
#------------------------------------------------------------------------------
# Test timeout time
#------------------------------------------------------------------------------
if [ -z $2 ]
then
    t="30"
else
    t="$2"
fi
#------------------------------------------------------------------------------
# Test packs count
#------------------------------------------------------------------------------
if [ -z $3 ]
then
    p="500"
else
    p="$3"
fi
#------------------------------------------------------------------------------
# Test filename var
#------------------------------------------------------------------------------
if [ -z $1 ]
then
    BASEDIR=`dirname $0`
    DIRPATH=`cd $BASEDIR; pwd`
    f=$DIRPATH/data/print_toptlk
else
    f="$1"
    printf "<table border=\"1\"><tr><td>COLLECTING</td></tr></table>\n" > $f
    exit 0
fi
#------------------------------------------------------------------------------
# Print top talkers
#------------------------------------------------------------------------------
buffer=$(printf "<table border=\"1\">\n<tr>
<td>#</td>
<td>packets</td>
<td><center>IP_SRC -&gt; IP_DST</center></td>
</tr>";
sudo timeout $t tcpdump -tnn not broadcast | awk -F "[. ]"                    \
'{print $2"."$3"."$4"."$5" -&gt; "$8"."$9"."$10"."$11}' |                     \
sort | uniq -c | sort -r | awk '$1 > 1' | awk -F " "                          \
'{ print "<tr><td>"NR"</td><td>"$1"</td><td>"$2" -&gt; "$4"</td></tr>" }';
printf "\n</table>\n";)
#------------------------------------------------------------------------------
chars=`echo $buffer | wc -c`
if (( $chars < 120 ))
then
	printf "<table border=\"1\"><tr><td>NOTHING</td></tr></table>\n" > $f
else
	echo "$buffer" > $f
fi
#------------------------------------------------------------------------------