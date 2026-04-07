    peersmapping=(
        # servers
        "p2|aaon"
        "p3|popi"
        # pcs
        "p20|lpro"
        "p21|lg15"
        "p22|mbm1"
        "p23|idea"
        "p24|fair"
        "p25|hpkw"
        # phones & tablets
        "p40|iphone 8s quang"
        "p41|ipad air quang"
        "p42|ipad a16 quang"
        "p43|thomson quang"
        "p44|ipad 9 max"
        "p45|iphone 14 pro max hoa"
    )

    for entry in "${peersmapping[@]}"; do
        peernb="${entry%%|*}"
        name="${entry#*|}"
    echo $peernb "->" $name
    done