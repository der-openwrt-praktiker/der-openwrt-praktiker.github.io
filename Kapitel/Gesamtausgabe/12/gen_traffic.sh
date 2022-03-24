#!/bin/bash

# purpose: generate traffic from labsrv through RT-1

while :
do
  iperf3 --client 192.0.2.4 --time $(shuf -i 1-5 -n 1)
  iperf3 --client 192.0.2.4 --time $(shuf -i 1-5 -n 1) --reverse
  echo "sleeping..."
  sleep $(shuf -i 10-30 -n 1)

  iperf3 --client 192.0.2.4 --time $(shuf -i 2-7 -n 1)
  iperf3 --client 192.0.2.4 --time $(shuf -i 2-7 -n 1) --reverse
  echo "sleeping..."
  sleep $(shuf -i 10-30 -n 1)
done
