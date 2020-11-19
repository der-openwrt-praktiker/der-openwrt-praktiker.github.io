#!/bin/bash

# purpose: benchmark local DNS server for performance

for value in {1..10000}
do
  nslookup www.google.de localhost >/dev/null
done

exit 0
