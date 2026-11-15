#!/usr/bin/env python3

## How to get and use?
# git clone "https://github.com/hezhijie0327/Trackerslist.git" && python3 ./Trackerslist/build.py

import re
import socket
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent

TRACKERLIST_COMBINE = (
    "https://gitee.com/harvey520/www.yaozuopan.top/raw/master/blacklist.txt",
    "https://newtrackon.com/api/all",
    "https://newtrackon.com/api/live",
    "https://newtrackon.com/api/stable",
    "https://raw.githubusercontent.com/1265578519/OpenTracker/master/tracker.txt",
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all.txt",
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_bad.txt",
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_best.txt",
    "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/all.txt",
    "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/best.txt",
    "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/blacklist.txt",
    "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/other.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/blacklist.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt",
)
TRACKERLIST_CUSTOM = (
    "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/main/data/data_http.txt",
    "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/main/data/data_udp.txt",
    "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/main/data/data_ws.txt",
)
TRACKERLIST_HTTP = (
    "https://newtrackon.com/api/http",
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_http.txt",
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_https.txt",
    "https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/http.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_http.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_https.txt",
)
TRACKERLIST_UDP = (
    "https://newtrackon.com/api/udp",
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_udp.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_udp.txt",
)
TRACKERLIST_WS = (
    "https://raw.githubusercontent.com/DeSireFire/animeTrackerList/master/AT_all_ws.txt",
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ws.txt",
)

HOST = (
    r"(([a-z])|([a-z]{2})|([a-z][0-9])|([0-9][a-z])|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))"
    r"\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})"
)
VERIFIED_REGEX = re.compile(rf"^(http|https|udp|ws|wss)://{HOST}:[0-9]{{1,5}}/announce$")
UNVERIFIED_UDP_REGEX = re.compile(rf"^udp://{HOST}/announce$")
UNVERIFIED_NOSSL_REGEX = re.compile(rf"^(http|udp|ws)://{HOST}/announce$")
UNVERIFIED_SSL_REGEX = re.compile(rf"^(https|wss)://{HOST}/announce$")

CONNECT_TIMEOUT = 5
VERIFY_WORKERS = 64


## Function
# Download one URL, return decoded text (empty string on failure, like curl -s)
def download(url):
    try:
        request = Request(url, headers={"User-Agent": "curl/8"})
        with urlopen(request, timeout=15) as response:
            return response.read().decode("utf-8", errors="replace")
    except OSError:
        return ""


# Fetch all URLs in parallel and concatenate (raw append, like curl >> file)
def fetch(urls):
    with ThreadPoolExecutor(max_workers=16) as pool:
        return "".join(pool.map(download, urls))


# Get Data
def get_data():
    groups = (TRACKERLIST_COMBINE, TRACKERLIST_CUSTOM, TRACKERLIST_HTTP, TRACKERLIST_UDP, TRACKERLIST_WS)
    with ThreadPoolExecutor(max_workers=5) as pool:
        return "".join(pool.map(fetch, groups))


# Analyse Data
def analyse_data(raw):
    # tr -cd "[:alnum:]-./:_\n" | tr "A-Z" "a-z" | sed "s/\.php$//g"
    cleaned = re.sub(r"[^a-zA-Z0-9\-./:_\n]", "", raw).lower()
    lines = [re.sub(r"\.php$", "", line) for line in cleaned.split("\n")]
    trackers = set()
    for line in lines:
        if VERIFIED_REGEX.fullmatch(line):
            trackers.add(line)
        # Independent checks: a portless udp URL feeds both the udp (:6969)
        # and nossl (:80) pipelines, like the original parallel greps.
        # The substitution is anchored: sed "s/\/announce$/.../"
        if UNVERIFIED_UDP_REGEX.fullmatch(line):
            trackers.add(re.sub(r"/announce$", ":6969/announce", line))
        if UNVERIFIED_NOSSL_REGEX.fullmatch(line):
            trackers.add(re.sub(r"/announce$", ":80/announce", line))
        if UNVERIFIED_SSL_REGEX.fullmatch(line):
            trackers.add(re.sub(r"/announce$", ":443/announce", line))
    return sorted(trackers)


# Resolve A/AAAA records (dig +short A/AAAA)
def resolves(domain, family):
    try:
        return bool(socket.getaddrinfo(domain, None, family))
    except OSError:
        return False


# TCP reachability of the tracker port (replaces nmap host discovery)
def tcp_check(domain, port, family):
    try:
        for af, socktype, proto, _, addr in socket.getaddrinfo(domain, port, family, socket.SOCK_STREAM):
            with socket.socket(af, socktype, proto) as sock:
                sock.settimeout(CONNECT_TIMEOUT)
                if sock.connect_ex(addr) == 0:
                    return True
    except OSError:
        pass
    return False


# UDP reachability via nmap -sU (same probe as the original script)
def udp_check(domain, port, ipv6):
    command = ["nmap", "-sU", "-6" if ipv6 else "-4", domain, "-p", str(port), "--host-timeout", "15s"]
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        return "Host is up" in result.stdout
    except (OSError, subprocess.TimeoutExpired):
        return False


# Normalize the protocol for well-known ports (original OutputData logic)
def normalize_protocol(protocol, port):
    if port in ("80", "8080"):
        if protocol in ("https", "udp"):
            return "http"
        if protocol == "wss":
            return "ws"
    elif port in ("443", "8443"):
        if protocol in ("http", "udp"):
            return "https"
        if protocol == "ws":
            return "wss"
    elif port == "6969":
        if protocol == "https":
            return "http"
        if protocol == "wss":
            return "ws"
    return protocol


# Verify one tracker, return (accepted, excluded) URLs
def verify(tracker):
    protocol, rest = tracker.split("://", 1)
    domain, rest = rest.split(":", 1)
    port = rest.split("/", 1)[0]
    protocol = normalize_protocol(protocol, port)
    url = f"{protocol}://{domain}:{port}/announce"

    ipv4 = resolves(domain, socket.AF_INET)
    ipv6 = not ipv4 and resolves(domain, socket.AF_INET6)
    if not ipv4 and not ipv6:
        return [], [url]

    family = socket.AF_INET if ipv4 else socket.AF_INET6
    tcp_up = tcp_check(domain, int(port), family)
    udp_up = False
    if protocol == "udp" or port == "6969":
        udp_up = udp_check(domain, int(port), ipv6)

    if not tcp_up and not udp_up:
        return [], [url]
    if protocol == "udp" and not udp_up:
        return [], [url]
    accepted = [url]
    if protocol != "udp" and port == "6969" and udp_up:
        accepted.append(f"udp://{domain}:{port}/announce")
    return accepted, []


# Output Data
def output_data(trackers):
    tracker_list, exclude_list = [], []
    with ThreadPoolExecutor(max_workers=VERIFY_WORKERS) as pool:
        for accepted, excluded in pool.map(verify, trackers):
            tracker_list.extend(accepted)
            exclude_list.extend(excluded)
    tracker_set = sorted(set(tracker_list))
    exclude_set = sorted(set(exclude_list))
    combine_set = sorted(set(tracker_list) | set(exclude_list))
    for name, lines in (("tracker", tracker_set), ("exclude", exclude_set), ("combine", combine_set)):
        (ROOT / f"trackerslist_{name}.txt").write_text("\n".join(lines) + "\n" if lines else "")
        (ROOT / f"trackerslist_{name}_aria2.txt").write_text(",".join(lines) + "\n" if lines else "")


## Process
def main():
    output_data(analyse_data(get_data()))


if __name__ == "__main__":
    main()
