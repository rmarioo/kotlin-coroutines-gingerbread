#!/bin/bash

if ! [ -x "$(command -v vegeta)" ]; then
  echo 'Error: vegeta is not installed.' >&2
  exit 1
fi

singleTestDuration=60s
rate=2000
sleepAfterTestGroup=30s
numberOfSingleTestRepetitions=2

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

  echo "running http://localhost:${port}/gingerbread/${path}"
  echo "GET http://localhost:${port}/gingerbread/${path}" | vegeta attack -timeout=5s -duration=${singleTestDuration} -rate ${rate} | vegeta report | egrep "^Requests|^Latencies|^Success"
  echo "completed http://localhost:${port}/gingerbread/${path} sleep for ${sleepAfterTestGroup}"
  echo "sleeping  for ${sleepAfterTestGroup}"
  sleep ${sleepAfterTestGroup}
  echo "awake"
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



#for rate in 2000; do
#  for path in quarkus_gingerbread webfluxPureReactive; do
#
#    defaultPortTouse=8080
#    quarkusPortTouse=8083
#    if [ ${path} = "quarkus_gingerbread" ]; then
#     portTouse=${quarkusPortTouse}
#    else
#     portTouse=${defaultPortTouse}
#    fi
#
#    echo "run VegetaWithPort ${path} ${portTouse}";
#    runVegetaWithPort ${path} ${portTouse}      > /tmp/result_${path}_rate_${rate}.txt
#  done
#done

#echo "running blockingRestTemplate"; runVegetaWithPort blockingRestTemplate 8080      > /tmp/result_blockingRestTemplate_rate_${rate}.txt
#echo "running suspendingPureCoroutines"; runVegetaWithPort suspendingPureCoroutines 8080  > /tmp/result_suspendingPureCoroutines_rate_${rate}.txt
#echo "running suspendingFuelCoroutines"; runVegetaWithPort suspendingFuelCoroutines 8080  > /tmp/result_suspendingFuelCoroutines_rate_${rate}.txt
#echo "running webfluxReactiveCoroutines"; runVegetaWithPort webfluxReactiveCoroutines 8080 > /tmp/result_webfluxReactiveCoroutines_rate_${rate}.txt
echo "running webfluxPureReactive"; runVegetaWithPort webfluxPureReactive 8080       > /tmp/result_webfluxPureReactive_rate_${rate}.txt
echo "running quarkus_gingerbread"; runVegetaWithPort quarkus_gingerbread 8083       > /tmp/result_quarkus_gingerbread_rate_${rate}.txt

# runblockingRestTemplate
