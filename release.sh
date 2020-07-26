#!/bin/bash

# Current Version: 1.0.9

## How to get and use?
# git clone "https://github.com/hezhijie0327/Trackerslist.git" && chmod 0777 ./Trackerslist/release.sh && bash ./Trackerslist/release.sh

## Function
# Get Data
function GetData() {
    trackerlist_combine=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_http.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_https.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_ip.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_udp.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_ws.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_bad.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_best.txt"
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_best_ip.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/all.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/best.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/blacklist.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/http.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/other.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/blacklist.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_http.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_https.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ip.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_udp.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ws.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt"
    )
    trackerlist_exclude=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_bad.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/blacklist.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/blacklist.txt"
    )
    rm -rf *.txt ./Temp && mkdir ./Temp && cd ./Temp
    for trackerlist_combine_task in "${!trackerlist_combine[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_combine[$trackerlist_combine_task]}" >> ./trackerlist_combine.tmp
    done
    for trackerlist_exclude_task in "${!trackerlist_exclude[@]}"; do
        curl -s --connect-timeout 15 "${trackerlist_exclude[$trackerlist_exclude_task]}" >> ./trackerlist_exclude.tmp
    done
}
# Analyse Data
function AnalyseData() {
    combine_data=($(cat ./trackerlist_combine.tmp | grep -v "\+\|\,\|\_\|\[\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\]\|announce+\|announcehttp\|announcehttps\|announceudp\|announcewss" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|wss\:\/\/" | tr -d -c "[:alnum:]\-\.\/\:\n" | tr "A-Z" "a-z" | sed "s/[[:space:]]//g;s/\#.*//g" | awk '{ match( $0, /.*\:+[0-9]+\/+announce+/ ); print substr( $0, RSTART, RLENGTH ) }' | sort | uniq | awk "{ print $2 }"))
    exclude_data=($(cat ./trackerlist_exclude.tmp | grep -v "\+\|\,\|\_\|\[\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\]\|announce+\|announcehttp\|announcehttps\|announceudp\|announcewss" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|wss\:\/\/" | tr -d -c "[:alnum:]\-\.\/\:\n" | tr "A-Z" "a-z" | sed "s/[[:space:]]//g;s/\#.*//g" | awk '{ match( $0, /.*\:+[0-9]+\/+announce+/ ); print substr( $0, RSTART, RLENGTH ) }' | sort | uniq | awk "{ print $2 }"))
    tracker_data=($(awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./trackerlist_exclude.tmp ./trackerlist_combine.tmp | grep -v "\+\|\,\|\_\|\[\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\]\|announce+\|announcehttp\|announcehttps\|announceudp\|announcewss" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|wss\:\/\/" | tr -d -c "[:alnum:]\-\.\/\:\n" | tr "A-Z" "a-z" | sed "s/[[:space:]]//g;s/\#.*//g" | awk '{ match( $0, /.*\:+[0-9]+\/+announce+/ ); print substr( $0, RSTART, RLENGTH ) }' | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    for combine_data_task in "${!combine_data[@]}"; do
        echo "${combine_data[$combine_data_task]}" >> ../trackerslist_combine.txt
        if [ "$((${combine_data_task} + 1))" == "${#combine_data[@]}" ]; then
            echo -n "${combine_data[$combine_data_task]}" >> ../trackerslist_combine_aria2.txt
        else
            echo -n "${combine_data[$combine_data_task]}," >> ../trackerslist_combine_aria2.txt
        fi
    done
    for exclude_data_task in "${!exclude_data[@]}"; do
        echo "${exclude_data[$exclude_data_task]}" >> ../trackerslist_exclude.txt
        if [ "$((${exclude_data_task} + 1))" == "${#exclude_data[@]}" ]; then
            echo -n "${exclude_data[$exclude_data_task]}" >> ../trackerslist_exclude_aria2.txt
        else
            echo -n "${exclude_data[$exclude_data_task]}," >> ../trackerslist_exclude_aria2.txt
        fi
    done
    for tracker_data_task in "${!tracker_data[@]}"; do
        echo "${tracker_data[$tracker_data_task]}" >> ../trackerslist_tracker.txt
        if [ "$((${tracker_data_task} + 1))" == "${#tracker_data[@]}" ]; then
            echo -n "${tracker_data[$tracker_data_task]}" >> ../trackerslist_tracker_aria2.txt
        else
            echo -n "${tracker_data[$tracker_data_task]}," >> ../trackerslist_tracker_aria2.txt
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
