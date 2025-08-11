tail --bytes +1 --quiet --follow /tmp/kbedump/dbmgr.pcap | sudo wireshark -k -i -
