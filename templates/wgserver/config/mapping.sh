
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

peersmapping=(
    # servers
    "aaon|p2"
    "popi|p3"
    # pcs
    "lpro|p20"
    "lg15|p21"
    "mbm1|p22"
    "idea|p23"
    "fair|p24"
    "hpkw|p25"
    "hpjb|p26"
    # phones & tablets
    "iphone-8s-quang|p40"
    "ipad-air-quang|p41"
    "ipad-a16-quang|p42"
    "thomson-quang|p43"
    "ipad-9-max|p44"
    "iphone-14-pro-max-hoa|p45"
)

get_peer_value() {
    local key="$1"
    for entry in "${peersmapping[@]}"; do
        peernb="${entry%%|*}"
        name="${entry#*|}"
        if [[ "$peernb" == "$key" ]]; then
            echo "$name"
            return 0
        fi
    done
    echo "Key not found"
    return 1
}

# Usage: get_peer_value "aaon"
if [[ -n "$1" ]]; then
    peernb=$(get_peer_value "$1")
    cat $SCRIPT_DIR/../data/peer_$peernb/peer_$peernb.conf
fi
