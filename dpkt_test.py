#! /usr/bin/env python3
# -*- coding: ASCII -*-
import subprocess
import dpkt
import socket
import sys
import datetime
from operator import itemgetter

f1 = open('print_toptlk.txt','w+r')
f2 = open('temp.txt','w+r')



subprocess.check_call(
    ['RESULT=$(ip r l | grep default | cut -d " " -f 5)&& tcpdump -tnn -c 30 -w packets.pcap -i $RESULT'], shell=True)

f = open('packets.pcap')
pcap = dpkt.pcap.Reader(f)

packets = []
total_buf = 0
for ts, buf in pcap:
    total_buf += len(buf)
    eth = dpkt.ethernet.Ethernet(buf)
    ip = eth.data
    packet = {'IP_Src': socket.inet_ntoa(ip.src), 'IP_Dst': socket.inet_ntoa(
        ip.dst), 'Proto': type(ip.data), 'Size': len(buf)}
    packets.append(packet)
proto_packets = []
for packet in packets:
    if len(proto_packets) != 0:
        flag = 0
        for proto_packet in proto_packets:
            if packet['Proto'] == proto_packet['Proto']:
                flag = 1
                proto_packet['Amount'] += 1
                proto_packet['Size'] += packet['Size']
                break
        if flag == 0:
            buffer = {'Proto': packet['Proto'],
                      'Amount': 1, 'Size': packet['Size']}
            proto_packets.append(buffer)
    else:
        buffer = {'Proto': packet['Proto'],
                  'Amount': 1, 'Size': packet['Size']}
        proto_packets.append(buffer)
ip_packets = []
for packet in packets:
    if len(ip_packets) != 0:
        flag = 0
        for ip_packet in ip_packets:
            if packet['IP_Src'] == ip_packet['IP_Src']:
                flag = 1
                ip_packet['Size'] += packet['Size']
                ip_packet['Amount'] += 1
                break
        if flag == 0:
            buffer = {'IP_Src': packet['IP_Src'],
                      'Size': packet['Size'], 'Amount': 1}
            ip_packets.append(buffer)
    else:
        buffer = {'IP_Src': packet['IP_Src'],
                  'Size': packet['Size'], 'Amount': 1}
        ip_packets.append(buffer)
number_sort = sorted(ip_packets, key=itemgetter('Amount'), reverse=True)
size_sort = sorted(ip_packets, key=itemgetter('Size'), reverse=True)
proto_sort = sorted(proto_packets, key=itemgetter('Size'), reverse=True)
print ("PROCESSING: top talking IP addresses sorted by amount of packets")
#-----------------------------------table No1-------------------- 
f1.write('<table border="1">')
f1.write('<tr>')
f1.write("<th colspan=2>\nThese are the top talking IP addresses sorted by amount of packets:</th>")
f1.write('</tr>')
for packet in number_sort:
    f1.write("<tr>") 
    #print (packet['IP_Src'], "  ", packet['Amount'])   
    f1.write("\n")
    f1.write("<td>	\n" + str(packet['IP_Src']) + "</td>")
    f1.write("		")
    f1.write("<td>	\n" + str(packet['Amount']) + "</td>")
    f1.write("</tr>")

#-------------------------------table No2------------------------
print ("PROCESSING: top talking IP addresses sorted by total bytes size ")
f1.write('<tr>')
f1.write("<th colspan=2>\nThese are the top talking IP addresses sorted by total bytes size :</th>")
f1.write("</tr>")
for packet in size_sort:
    f1.write("<tr>")
    #print (packet['IP_Src'], "  ", packet['Size'])
    f1.write("\n")
    f1.write("<td>	\n" + str(packet['IP_Src']) + "</td>")
    f1.write("	")
    f1.write("<td>	\n" + str(packet['Size']) + "</td>")
    f1.write("</tr>")

#-------------------------------table No3------------------------------
print ("PROCESSING: top used Protocols sorted by percentage of traffic")
f1.write("<tr>")
f1.write("<th colspan=2>These are the top used Protocols sorted by percentage of traffic :</th>")
f1.write("</tr>")
for packet in proto_sort:
    f1.write("<tr>") 
    #print (packet['Proto'], "  ", int((float(packet['Size']) / total_buf) * 100), '%')
    f1.write("\n")
    f1.write("<td>	\n")
    f2.write(str(packet['Proto']))
    f1.write(str(subprocess.check_call(["sudo sed -n 's/[<>]//g' temp.txt"],shell=True)))  
    f1.write("</td>")
    f1.write("	")
    f1.write("<td>	\n"+ str((int((float(packet['Size']) / total_buf)*100))) + "%"+"</td>")
    f1.write("</tr>")
    	
# What is the average packet rate? (packets/second)
# The last time stamp
# print "The packets/second %f " % (packets/(last-first))


# what is the protocol distribution?
# use dictionary

f1.close()
f.close()
sys.exit(0)
