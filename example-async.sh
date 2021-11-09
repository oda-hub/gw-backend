nb2service nb/spectrogram.ipynb &
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

while true; do
    response=$(curl http://127.0.0.1:9191$get_path?_async_request=yes)
    state=$(echo $response | jq '.workflow_status')
    echo -e "\033[31m$state\033[0m"
    sleep 1
done

sleep 100

cleanup