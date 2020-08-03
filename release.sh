#!/bin/bash

# Current Version: 1.1.6

## How to get and use?
# git clone "https://github.com/hezhijie0327/Trackerslist.git" && chmod 0777 ./Trackerslist/release.sh && bash ./Trackerslist/release.sh

## Function
# Get Data
function GetData() {
    dead_domain=(
        "https://raw.githubusercontent.com/hezhijie0327/DHDb/master/dhdb_dead.txt"
    )
    trackerlist_combine=(
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
    trackerlist_http=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_http.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_https.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/http.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_http.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_https.txt"
    )
    trackerlist_udp=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_udp.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_udp.txt"
    )
    trackerlist_ws=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_ws.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ws.txt"
    )
    rm -rf ./*.txt ./Temp && mkdir ./Temp && cd ./Temp
    for dead_domain_task in "${!dead_domain[@]}"; do
        curl -s --connect-timeout 15 "${dead_domain[$dead_domain_task]}" >> ./dead_domain.tmp
    done
    for trackerlist_combine_task in "${!trackerlist_combine[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_combine[$trackerlist_combine_task]}" >> ./trackerlist_combine.tmp
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
    trackerlist_data=($(cat ./trackerlist_*.tmp | grep -v "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\#\|\[\|\]\|announcehttp\|announcehttps\|announceudp\|announcews\|announcewss" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|ws\:\/\/\|wss\:\/\/" | tr -d -c "[:alnum:]\-\.\/\:\n" | tr "A-Z" "a-z" | awk '{ match( $0, /.*\:+[0-9]+\/+announce/ ); print substr( $0, RSTART, RLENGTH ) }' | sed '/^$/d' | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    for trackerlist_data_task in "${!trackerlist_data[@]}"; do
        if [ "$(echo ${trackerlist_data[$trackerlist_data_task]} | sed 's/http\:\/\///g;s/https\:\/\///g;s/udp\:\/\///g;s/ws\:\/\///g;s/wss\:\/\///g;s/\:.*//g')" != "$(cat ./dead_domain.tmp | grep ${trackerlist_data[$trackerlist_data_task]})" ]; then
            echo "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_combine.txt
            echo "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_tracker.txt
            if [ "$((${trackerlist_data_task} + 1))" == "${#trackerlist_data[@]}" ]; then
                echo -n "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_combine_aria2.txt
                echo -n "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_tracker_aria2.txt
            else
                echo -n "${trackerlist_data[$trackerlist_data_task]}," >> ../trackerslist_combine_aria2.txt
                echo -n "${trackerlist_data[$trackerlist_data_task]}," >> ../trackerslist_tracker_aria2.txt
            fi
        else
            echo "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_combine.txt
            echo "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_exclude.txt
            if [ "$((${trackerlist_data_task} + 1))" == "${#trackerlist_data[@]}" ]; then
                echo -n "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_combine_aria2.txt
                echo -n "${trackerlist_data[$trackerlist_data_task]}" >> ../trackerslist_exclude_aria2.txt
            else
                echo -n "${trackerlist_data[$trackerlist_data_task]}," >> ../trackerslist_combine_aria2.txt
                echo -n "${trackerlist_data[$trackerlist_data_task]}," >> ../trackerslist_exclude_aria2.txt
            fi
        fi
    done
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
