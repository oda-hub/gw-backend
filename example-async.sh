nb2service spectrogram.ipynb &
service_pid=$?

function cleanup()
{
    kill -9 $service_pid
}

trap cleanup EXIT
trap cleanup SIGINT

sleep 2

curl http://127.0.0.1:9191/

# swagger/openapi
curl http://127.0.0.1:9191/apispec_1.json | jq

get_path=$(curl -s http://127.0.0.1:9191/apispec_1.json | jq -r '.paths | keys[0]')

# rdf
# curl http://127.0.0.1:9191/api/v1.0/rdf

# special parameters, which are not treated as workflow parameters, start with _

# note that this asynchronous interaction does not involve callbacks. 
# But I think dispatcher supports this directly (unless something broke since we did not use this kind of approach)
# this loop should be done by the client, by dispatcher. In fact, it is frontend (or oda_api) that initiates the repeated request.
while true; do
    response=$(curl http://127.0.0.1:9191$get_path?_async_request=yes)
    state=$(echo $response | jq -r '.workflow_status')
    comment=$(echo $response | jq -r '.comment')
    echo -e "\033[31m$state\033[0m $comment"

    if [ "$state" == "done" ]; then
        echo -e "\033[32m$state!\033[0m"
        echo $response | jq 'keys'
        break
    fi

    # this is useful to see service queue (see alse health endpoint for load)
    echo -e "\033[33mjob list: $(curl http://127.0.0.1:9191/async/list)\033[0m"

    sleep 1
done


echo -e "\033[33mexecuted jobs: $(curl http://127.0.0.1:9191/trace/list?json)\033[0m"

cleanup