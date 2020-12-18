#!/bin/bash

if ! [ -x "$(command -v vegeta)" ]; then
  echo 'Error: vegeta is not installed.' >&2
  exit 1
fi

singleTestDuration=3s
rate=2000
sleepAfterTestGroup=2s
numberOfSingleTestRepetitions=3

runSingleVegetaTest() {
  path=$1
  echo "GET http://localhost:8080/gingerbread/${path}" | vegeta attack -timeout=5s -duration=${singleTestDuration} -rate ${rate} | vegeta report | egrep "^Requests|^Latencies|^Success"
  sleep ${sleepAfterTestGroup}
}

runVegeta() {
  path=$1

  for i in $(seq 1 $numberOfSingleTestRepetitions); do
    runSingleVegetaTest ${path}
  done
}

runSingleVegetaTestWithPort() {
  path=$1
  port=$2

  echo "GET http://localhost:${port}/gingerbread/${path}" | vegeta attack -timeout=5s -duration=${singleTestDuration} -rate ${rate} | vegeta report | egrep "^Requests|^Latencies|^Success"
  sleep ${sleepAfterTestGroup}
}

runVegetaWithPort() {
  path=$1
  port=$2

  for i in $(seq 1 $numberOfSingleTestRepetitions); do
    runSingleVegetaTestWithPort ${path} ${port}
  done
}

#for path in blockingRestTemplate suspendingPureCoroutines suspendingFuelCoroutines webfluxPureReactive webfluxReactiveCoroutines; do
#  echo ${path}
#  #runVegeta ${path} ${rateForNonBlocking} | sort -r | cut -c 42- | sed 's/ms//g; s/s//g; s/%//g; s/,//g'
#  runVegeta ${path} ${rateForNonBlocking} > /tmp/result_${path}.txt
#done

#for path in quarkus_gingerbread; do
#  echo ${path}
#  #runVegeta ${path} ${rateForNonBlocking} | sort -r | cut -c 42- | sed 's/ms//g; s/s//g; s/%//g; s/,//g'
#  runVegeta ${path} ${rateForNonBlocking} > /tmp/result_${path}.txt
#done


#runVegetaWithPort blockingRestTemplate 8080 > /tmp/result_blockingRestTemplate.txt
#runVegetaWithPort suspendingPureCoroutines 8080 > /tmp/result_suspendingPureCoroutines.txt
#runVegetaWithPort suspendingFuelCoroutines 8080 > /tmp/result_suspendingFuelCoroutines.txt
#runVegetaWithPort webfluxPureReactive 8080 > /tmp/result_webfluxPureReactive.txt
#runVegetaWithPort webfluxReactiveCoroutines 8080 > /tmp/result_webfluxReactiveCoroutines.txt
runVegetaWithPort quarkus_gingerbread 8083 > /tmp/result_quarkus_gingerbread.txt

# runblockingRestTemplate
