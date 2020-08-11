#!/bin/bash
ID=$(curl -sX GET "https://api.balena-cloud.com/v5/device?\$filter=uuid%20eq%20'$BALENA_DEVICE_UUID'" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" | \
jq ".d | .[0] | .id")


MEMORY=$(sysbench --test=memory --memory-total-size=2G run | grep "total time:" | sed 's/[^0-9.]*//g')
CPU=$(sysbench --test=cpu --cpu-max-prime=5000 run | grep "total time:" | sed 's/[^0-9.]*//g')
THREADS=$(sysbench --test=threads run | grep "total time:" | sed 's/[^0-9.]*//g')

sysbench --test=fileio --file-test-mode=rndrw prepare
FILEIO=$(sysbench --test=fileio --file-test-mode=rndrw run | grep "total time:" | sed 's/[^0-9.]*//g')



curl -sX POST \
"https://api.balena-cloud.com/v5/device_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "{ \"device\": \"$ID\", \"tag_key\": \"Memory\", \"value\": \"$MEMORY\" }" > /dev/null

curl -sX POST \
"https://api.balena-cloud.com/v5/device_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "{ \"device\": \"$ID\", \"tag_key\": \"CPU\", \"value\": \"$CPU\" }" > /dev/null

curl -sX POST \
"https://api.balena-cloud.com/v5/device_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "{ \"device\": \"$ID\", \"tag_key\": \"Threads\", \"value\": \"$THREADS\" }" > /dev/null

curl -sX POST \
"https://api.balena-cloud.com/v5/device_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "{ \"device\": \"$ID\", \"tag_key\": \"FileIO\", \"value\": \"$FILEIO\" }" > /dev/null

balena-idle