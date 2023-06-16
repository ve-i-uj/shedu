set +e

docker pull $@ 2>/dev/null 1>/dev/null
if [ $? -eq 1 ]; then
    echo "false"
    exit 0
fi

echo "true"
exit 0
