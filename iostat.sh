#!/bin/bash
#----------------------------------------------------------------------
# Test filename var
#----------------------------------------------------------------------
BASEDIR=`dirname $0`
DIRPATH=`cd $BASEDIR; pwd`
if [ -z $1 ] || [ -z $2 ]
then
	f1=$DIRPATH/data/print_iostat
	f2=$DIRPATH/data/print_cpuinf
	tf=$DIRPATH/data/iostat_output
	iostat -k 29 2 > $tf
else
    f1="$1"
    f2="$2"
    tf=$DIRPATH/data/iostat_output
    fstep="true"
    iostat -k 1 1 > $tf
    cat $tf | tail -n +3 >> $tf
fi
#----------------------------------------------------------------------
lines=`wc -l $tf | cut -d " " -f1`
#----------------------------------------------------------------------
# Disk load (iostat)
#----------------------------------------------------------------------
buffer1=$(printf "<table border=\"1\">\n";
if [ -z $fstep ]; 
then 
	printf "<tr><td colspan=\"6\" style=\"text-align: center;\">
			[!] In 30 sec [!]</td></tr>";
else
	printf "<tr><td colspan=\"6\" style=\"text-align: center;\">
			[!] From start [!]</td></tr>";
fi;
cat $tf | tail -n `expr $lines / 2` | tail -n +5 | head -n -1 | awk   \
'{ split($0, k);
   print "<tr>";
   { for (i = 1; i <= 6; i++) print "<td>"k[i]"</td>"; }
   print "</tr>"; }';
printf "\n</table>\n";)
echo "$buffer1" > $f1
#----------------------------------------------------------------------
# CPU info (cpuinf)
#----------------------------------------------------------------------
buffer2=$(printf "<table border=\"1\">\n";
cat $tf | tail -n `expr $lines / 2` | tail -n +2 | head -n 2 |        \
sed -e 's/avg-cpu: //g' | awk -v LIM1=20 -v LIM2=60                   \
'{ split($0, k);
   print "<tr>";
   { for (i = 1; i <= 6; i++)
     {
     if (i != 2) {
     print "<td>";
     ks = substr(k[i], 0, 1);
     { if (ks != "%") {
       { if (i == 1) k[i] = k[i]+k[i+1]; }
       { if (k[i] > LIM1)
         { if (k[i] > LIM2)
           k[i] = "<span style=\"color: red;\">"k[i]"</span>";
         else k[i] = "<span style=\"color: yellow;\">"k[i]"</span>" }
       else k[i] = "<span style=\"color: green;\">"k[i]"</span>" } }
     print k[i]"</td>";
   } } } }
   print "</tr>"; }';
printf "\n</table>\n";) 
echo "$buffer2" > $f2
#----------------------------------------------------------------------