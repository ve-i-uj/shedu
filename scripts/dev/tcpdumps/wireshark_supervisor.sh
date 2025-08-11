tail --bytes +1 --quiet --follow /tmp/kbedump/supervisor.pcap | sudo wireshark -k -i -
