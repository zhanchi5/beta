#!/bin/bash
#--------------------------------------------------------------------
# Test filename var
#--------------------------------------------------------------------
if [ -z $1 ]
then
    BASEDIR=`dirname $0`
    DIRPATH=`cd $BASEDIR; pwd`
    f=$DIRPATH/data/print_diskst
else
    f="$1"
fi
#--------------------------------------------------------------------
f1="/tmp/disksinfo1"
f2="/tmp/disksinfo2"
#--------------------------------------------------------------------
df -a -h  | grep -v -E '( /run| /dev| /sys| /proc| /var)' > $f1
df -ai -h | grep -v -E '( /run| /dev| /sys| /proc| /var)' > $f2
#--------------------------------------------------------------------
# Disks info, free space, free inodes
#--------------------------------------------------------------------
buffer=$(printf "<table border=\"1\">\n";
cat $f1 | awk -v FILE=$f2 -v LIM1=10 -v LIM2=20                     \
'{ getline line < FILE;
   split(line, i);
   split($0, j);
   { if (j[5] != "Use%")
     { if (j[5] > LIM1)
       { if (j[5] > LIM2)
         j[5]="<span style=\"color: red\">"j[5]"</span>";
       else j[5]="<span style=\"color: yellow\">"j[5]"</span>"; }
     else j[5]="<span style=\"color: green\">"j[5]"</span>"; } }
   { if (i[5] != "IUse%")
     { if (i[5] > LIM1)
       { if (i[5] > LIM2)
         i[5]="<span style=\"color: red\">"i[5]"</span>";
       else i[5]="<span style=\"color: yellow\">"i[5]"</span>"; }
     else i[5]="<span style=\"color: green\">"i[5]"</span>"; } }
   print "<tr><td>"j[1]"</td><td>"k[2]"</td><td>"j[3]"</td><td>" \
                   j[4]"</td><td>"k[5]"</td><td>"i[2]"</td><td>" \
                   i[3]"</td><td>"s[4]"</td><td>"i[5]"</td><td>" \
                   i[6]"</td></tr>";
}';
printf "\n</table>\n";) 
echo "$buffer" > $f
#--------------------------------------------------------------------
