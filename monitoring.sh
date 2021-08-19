#!/bin/sh
echo "#Architecture: " | tr '\n' ' ' > test.txt
uname -a >> test.txt

echo "#CPU physical: " | tr '\n' '\t' >> test.txt
grep "physical id" /proc/cpuinfo | sort | uniq | wc -l >> test.txt

echo "#vCPU: " | tr '\n' '\t' >> test.txt
grep "^processor" /proc/cpuinfo | wc -l >> test.txt

free --mega | awk 'NR == 2 {printf("#Memory Usage: %d/%dMB (%.2f%%)\n", $3, $2, $3/$2*100)}' >> test.txt

top -b -n1 | grep ^%Cpu | awk '{printf("#CPU load: %.2f%%\n"), 100-$8}' >> test.txt

who -b | awk '{printf("#Last boot: %s %s\n", $3, $4)}' >> test.txt

CHECK=`sudo lvscan | grep -m 1 -o "ACTIVE"`
if [ "$CHECK" = "ACTIVE" ] 
then
	echo "#LVM use: yes" >> test.txt
else
	echo "#LVM use: no" >> test.txt
fi

echo "#Connections TCP: " | tr '\n' ' ' >> test.txt
netstat -natu | grep 'ESTABLISHED' | wc -l | tr '\n' ' ' >> test.txt
echo "ESTABLISHED" >> test.txt

echo "#User log: " | tr '\n' ' ' >> test.txt
who | wc -l >> test.txt

MAC=`ip a show enp0s3 | grep -m1 -o ..:..:..:..:..:.. | head -1`
echo "#Network: IP" | tr '\n' ' ' >> test.txt
ip -4 addr show enp0s3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tr '\n' ' '  >> test.txt
printf "(%s)\n" "$MAC" >> test.txt

echo "#Sudo: " | tr '\n' ' ' >> test.txt
sudo journalctl _COMM=sudo | grep COMMAND | wc -l | tr '\n' ' ' >> test.txt
echo "cmd" >> test.txt

wall -n test.txt
