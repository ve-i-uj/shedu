cd /tmp/kbedump
while true; do
    mergecap -w /tmp/merged.pcap $(ls | grep .pcap)
    sleep 1
done
