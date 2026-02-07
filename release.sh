#!/bin/bash

## How to get and use?
# git clone "https://github.com/hezhijie0327/Trackerslist.git" && bash ./Trackerslist/release.sh

## Function
# Get Data
function GetData() {
    trackerlist_combine=(
        "https://gitee.com/harvey520/www.yaozuopan.top/raw/master/blacklist.txt"
        "https://newtrackon.com/api/all"
        "https://newtrackon.com/api/live"
        "https://newtrackon.com/api/stable"
        "https://raw.githubusercontent.com/1265578519/OpenTracker/master/tracker.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_bad.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_best.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/all.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/best.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/blacklist.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/other.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/blacklist.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt"
    )
    trackerlist_custom=(
        "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/main/data/data_http.txt"
        "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/main/data/data_udp.txt"
        "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/main/data/data_ws.txt"
    )
    trackerlist_http=(
        "https://newtrackon.com/api/http"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_http.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_https.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/http.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_http.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_https.txt"
    )
    trackerlist_udp=(
        "https://newtrackon.com/api/udp"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_udp.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_udp.txt"
    )
    trackerlist_ws=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_ws.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ws.txt"
    )
    rm -rf ./trackerslist_* ./Temp && mkdir ./Temp ./Temp/data && cd ./Temp
    for trackerlist_combine_task in "${!trackerlist_combine[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_combine[$trackerlist_combine_task]}" >> ./trackerlist_combine.tmp
    done
    for trackerlist_custom_task in "${!trackerlist_custom[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_custom[$trackerlist_custom_task]}" >> ./trackerlist_custom.tmp
    done
    for trackerlist_http_task in "${!trackerlist_http[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_http[$trackerlist_http_task]}" >> ./trackerlist_http.tmp
    done
    for trackerlist_udp_task in "${!trackerlist_udp[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_udp[$trackerlist_udp_task]}" >> ./trackerlist_udp.tmp
    done
    for trackerlist_ws_task in "${!trackerlist_ws[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_ws[$trackerlist_ws_task]}" >> ./trackerlist_ws.tmp
    done
}
# Analyse Data
function AnalyseData() {
    trackerlist_verified=($(cat ./trackerlist_*.tmp | tr -cd "[:alnum:]-./:_\n" | tr "A-Z" "a-z" | sed "s/\.php$//g" | grep -E "^(http|https|udp|ws|wss):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3}):[0-9]{1,5}/announce$" | sort | uniq | awk "{ print $2 }"))
    trackerlist_unverified_udp=($(cat ./trackerlist_*.tmp | tr -cd "[:alnum:]-./:_\n" | tr "A-Z" "a-z" | sed "s/\.php$//g" | grep -vE "^(udp):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3}):[0-9]{1,5}/announce$" | grep -E "^(udp):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})/announce$" | sed "s/\/announce$/\:6969\/announce/g" | sort | uniq | awk "{ print $2 }"))
    trackerlist_unverified_nossl=($(cat ./trackerlist_*.tmp | tr -cd "[:alnum:]-./:_\n" | tr "A-Z" "a-z" | sed "s/\.php$//g" | grep -vE "^(http|udp|ws):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3}):[0-9]{1,5}/announce$" | grep -E "^(http|udp|ws):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})/announce$" | sed "s/\/announce$/\:80\/announce/g" | sort | uniq | awk "{ print $2 }"))
    trackerlist_unverified_ssl=($(cat ./trackerlist_*.tmp | tr -cd "[:alnum:]-./:_\n" | tr "A-Z" "a-z" | sed "s/\.php$//g" | grep -vE "^(https|wss):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3}):[0-9]{1,5}/announce$" | grep -E "^(https|wss):[\/]{2}(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})/announce$" | sed "s/\/announce$/\:443\/announce/g" | sort | uniq | awk "{ print $2 }"))
    trackerlist_data=($(echo ${trackerlist_verified[*]} ${trackerlist_unverified_udp[*]} ${trackerlist_unverified_nossl[*]} ${trackerlist_unverified_ssl[*]} | tr " " "\n" | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    for trackerlist_data_task in "${!trackerlist_data[@]}"; do
        DOMAIN=$(echo ${trackerlist_data[$trackerlist_data_task]} | sed 's/http\:\/\///g;s/https\:\/\///g;s/udp\:\/\///g;s/ws\:\/\///g;s/wss\:\/\///g;s/\:.*//g')
        PORT=$(echo ${trackerlist_data[$trackerlist_data_task]} | sed 's/.*\://g;s/\/.*//g')
        PROTOCOL=$(echo ${trackerlist_data[$trackerlist_data_task]} | cut -d ':' -f 1)
        if [ "${PORT}" == "80" ] || [ "${PORT}" == "8080" ]; then
            if [ "${PROTOCOL}" == "https" ] || [ "${PROTOCOL}" == "udp" ]; then
                PROTOCOL="http"
            elif [ "${PROTOCOL}" == "wss" ]; then
                PROTOCOL="ws"
            fi
        elif [ "${PORT}" == "443" ] || [ "${PORT}" == "8443" ]; then
            if [ "${PROTOCOL}" == "http" ] || [ "${PROTOCOL}" == "udp" ]; then
                PROTOCOL="https"
            elif [ "${PROTOCOL}" == "ws" ]; then
                PROTOCOL="wss"
            fi
        elif [ "${PORT}" == "6969" ]; then
            if [ "${PROTOCOL}" == "https" ]; then
                PROTOCOL="http"
            elif [ "${PROTOCOL}" == "wss" ]; then
                PROTOCOL="ws"
            fi
        fi
        if [ "$(dig +short A ${DOMAIN} | tail -n 1 | grep -E '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$')" != "" ]; then
            TCP_V4=$(nmap ${DOMAIN} -p ${PORT} | grep 'Host is up')
            UDP_V4="" && if [ "${PROTOCOL}" == "udp" ] || [ "${PORT}" == "6969" ]; then
                UDP_V4=$(nmap -sU ${DOMAIN} -p ${PORT} | grep 'Host is up')
            fi
        else
            if [ "$(dig +short AAAA ${DOMAIN} | tail -n 1 | grep -E '^(([0-9a-f]{1,4}:){7,7}[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,7}:|([0-9a-f]{1,4}:){1,6}:[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}|([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}|([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}|([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}|[0-9a-f]{1,4}:((:[0-9a-f]{1,4}){1,6})|:((:[0-9a-f]{1,4}){1,7}|:)|fe80:(:[0-9a-f]{0,4}){0,4}%[0-9a-z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-f]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$')" != "" ]; then
                TCP_V6=$(nmap -6 ${DOMAIN} -p ${PORT} | grep 'Host is up')
                UDP_V6="" && if [ "${PROTOCOL}" == "udp" ] || [ "${PORT}" == "6969" ]; then
                    UDP_V6=$(nmap -6 -sU ${DOMAIN} -p ${PORT} | grep 'Host is up')
                fi
            else
                echo "${PROTOCOL}://${DOMAIN}:${PORT}/announce" >> "./trackerslist_exclude.tmp"
            fi
        fi
        if [ "${TCP_V4}" != "" ] || [ "${TCP_V6}" != "" ] || [ "${UDP_V4}" != "" ] || [ "${UDP_V6}" != "" ]; then
            if [ "${PROTOCOL}" == "udp" ] && [ "${UDP_V4}" == "" ] && [ "${UDP_V6}" == "" ]; then
                echo "${PROTOCOL}://${DOMAIN}:${PORT}/announce" >> "./trackerslist_exclude.tmp"
            else
                if [ "${PROTOCOL}" != "udp" ] && [ "${PORT}" == "6969" ]; then
                    if [ "${UDP_V4}" != "" ] || [ "${UDP_V6}" != "" ]; then
                        echo "udp://${DOMAIN}:${PORT}/announce" >> "./trackerslist_tracker.tmp"
                    fi
                fi && echo "${PROTOCOL}://${DOMAIN}:${PORT}/announce" >> "./trackerslist_tracker.tmp"
            fi
        else
            echo "${PROTOCOL}://${DOMAIN}:${PORT}/announce" >> "./trackerslist_exclude.tmp"
        fi
    done
    cat "./trackerslist_exclude.tmp" | sort | uniq > "../trackerslist_exclude.txt" && cat "../trackerslist_exclude.txt" | awk NF | sed ":a;N;s/\n/,/g;ta" > "../trackerslist_exclude_aria2.txt"
    cat "./trackerslist_tracker.tmp" | sort | uniq > "../trackerslist_tracker.txt" && cat "../trackerslist_tracker.txt" | awk NF | sed ":a;N;s/\n/,/g;ta" > "../trackerslist_tracker_aria2.txt"
    cat "./trackerslist_exclude.tmp" "./trackerslist_tracker.tmp" | sort | uniq > "../trackerslist_combine.txt" && cat "../trackerslist_combine.txt" | awk NF | sed ":a;N;s/\n/,/g;ta" > "../trackerslist_combine_aria2.txt"
    cd .. && rm -rf ./Temp
    exit 0
}

## Process
# Call GetData
GetData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
