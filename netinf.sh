#!/bin/bash
#----------------------------------------------------------------------
# Test filename var
#----------------------------------------------------------------------
if [ -z $1 ]
then
	BASEDIR=`dirname $0`
	DIRPATH=`cd $BASEDIR; pwd`
	f=$DIRPATH/data/print_netinf
    c=$DIRPATH/data/curr_netinf
    l=$DIRPATH/data/last_netinf
    cp $c $l
else
    f="$1"
    (sudo cat /proc/net/dev | head -n 1 | sed 's/Inter-|/IF /g' | sed -e 's/|/_ _ _ _ _ _ _ /g'; \
	 sudo cat /proc/net/dev | tail -n +2 | sed -e 's/face/\_/g' | sed -e 's/|/ /g')              \
	 | column -t | sed -e 's/_/ /g' > $f
	exit 0
fi
#--------------------------------------------------------------------------------------------------
# Print net info
#--------------------------------------------------------------------------------------------------
(sudo cat /proc/net/dev | head -n 1 | sed 's/Inter-|/IF /g' | sed -e 's/|/_ _ _ _ _ _ _ /g'; \
 sudo cat /proc/net/dev | tail -n +2 | sed -e 's/face/\_/g' | sed -e 's/|/ /g')              \
 | column -t | sed -e 's/_/ /g' > $c
#--------------------------------------------------------------------------------------------------
buffer=$(printf "<table border=\"1\">\n";
cat $c | awk -v FILE=$l \
'{ split($0, k)
   getline line < FILE;
   print "<tr>";
   { if (NR == 1)
     { print "<td rowspan=\"2\">"k[1]"</td><td colspan=\"8\">"k[2]"</td><td colspan=\"8\">"k[3]"</td>"; }
   else
     { if (NR == 2) { for (i = 1; i <= 16; i++) print "<td>"k[i]"</td>"; }
       else {
       	split(line, s);
       	print "<td>"k[1]"</td>";
       	for (i = 2; i <= 17; i++) print "<td>"(k[i]-s[i])"</td>";
       }
     }
   }
   print "</tr>";
 }';
printf "\n</table>\n";)
echo "$buffer" > $f
#--------------------------------------------------------------------------------------------------