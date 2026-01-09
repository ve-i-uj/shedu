component_name=$1
tail --bytes +1 --quiet --follow "/tmp/kbedump/$component_name.pcap" | sudo wireshark -k -i -
