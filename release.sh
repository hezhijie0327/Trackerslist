#!/bin/bash

# Current Version: 1.0.3

## How to get and use?
# git clone "https://github.com/hezhijie0327/Trackerslist.git" && chmod 0777 ./Trackerslist/release.sh && bash ./Trackerslist/release.sh

## Function
# Get Data
function GetData() {
    exclude_list_unchecked=(
        "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_bad.txt"
        "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/blacklist.txt"
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/blacklist.txt"
    )
    full_list_unchecked=(
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
    rm -rf *.txt ./Temp && mkdir ./Temp && cd ./Temp
    for exclude_list_unchecked_task in "${!exclude_list_unchecked[@]}"; do
        echo "Downloading exclude list ($((${exclude_list_unchecked_task} + 1)) / ${#exclude_list_unchecked[@]})"
        curl -s --connect-timeout 15 "${exclude_list_unchecked[$exclude_list_unchecked_task]}" >> ./exclude_list_unchecked.tmp
        sleep 2.4s
    done
    for full_list_unchecked_task in "${!full_list_unchecked[@]}"; do
        echo "Downloading full list ($((${full_list_unchecked_task} + 1)) / ${#full_list_unchecked[@]})"
        curl -s --connect-timeout 15 "${full_list_unchecked[$full_list_unchecked_task]}" >> ./full_list_unchecked.tmp
        sleep 2.4s
    done
}
# Check Data
function CheckData() {
    exclude_list_checked=($(cat ./exclude_list_unchecked.tmp | sed "s/[[:space:]]//g;s/\#.*//g" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|wss\:\/\/" | grep -v "\,\|\_\|\[\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\]" | awk '{ match( $0, /.*\:+[0-9]+\/+announce+/ ); print substr( $0, RSTART, RLENGTH ) }' | tr "A-Z" "a-z" | sort | uniq | awk "{ print $2 }"))
    full_list_checked=($(cat ./full_list_unchecked.tmp | sed "s/[[:space:]]//g;s/\#.*//g" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|wss\:\/\/" | grep -v "\,\|\_\|\[\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\]" | awk '{ match( $0, /.*\:+[0-9]+\/+announce+/ ); print substr( $0, RSTART, RLENGTH ) }' | tr "A-Z" "a-z" | sort | uniq | awk "{ print $2 }"))
    tracker_list_checked=($(awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./exclude_list_unchecked.tmp ./full_list_unchecked.tmp | sed "s/[[:space:]]//g;s/\#.*//g" | grep "http\:\/\/\|https\:\/\/\|udp\:\/\/\|wss\:\/\/" | grep -v "\,\|\_\|\[\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|\]" | awk '{ match( $0, /.*\:+[0-9]+\/+announce+/ ); print substr( $0, RSTART, RLENGTH ) }' | tr "A-Z" "a-z" | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    for exclude_list_checked_task in "${!exclude_list_checked[@]}"; do
        echo "${exclude_list_checked[$exclude_list_checked_task]}" >> ../list_exclude.txt
        if [ "$((${exclude_list_checked_task} + 1))" == "${#exclude_list_checked[@]}" ]; then
            echo -n "${exclude_list_checked[$exclude_list_checked_task]}" >> ../list_exclude_aria2.txt
        else
            echo -n "${exclude_list_checked[$exclude_list_checked_task]}," >> ../list_exclude_aria2.txt
        fi
    done
    for full_list_checked_task in "${!full_list_checked[@]}"; do
        echo "${full_list_checked[$full_list_checked_task]}" >> ../list_full.txt
        if [ "$((${full_list_checked_task} + 1))" == "${#full_list_checked[@]}" ]; then
            echo -n "${full_list_checked[$full_list_checked_task]}" >> ../list_full_aria2.txt
        else
            echo -n "${full_list_checked[$full_list_checked_task]}," >> ../list_full_aria2.txt
        fi
    done
    for tracker_list_checked_task in "${!tracker_list_checked[@]}"; do
        echo "${tracker_list_checked[$tracker_list_checked_task]}" >> ../list_tracker.txt
        if [ "$((${tracker_list_checked_task} + 1))" == "${#tracker_list_checked[@]}" ]; then
            echo -n "${tracker_list_checked[$tracker_list_checked_task]}" >> ../list_tracker_aria2.txt
        else
            echo -n "${tracker_list_checked[$tracker_list_checked_task]}," >> ../list_tracker_aria2.txt
        fi
    done
    cd .. && rm -rf ./Temp
    exit 0
}

## Process
# Call GetData
GetData
# Call CheckData
CheckData
# Call OutputData
OutputData
