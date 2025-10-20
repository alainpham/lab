docker exec -it  wgserver /app/show-peer $1
cat ./../data/peer_$1/peer_$1.conf

echo CLIENT NAME :
case "$1" in
    # computers
    p2)
        echo "aaon"
        ;;
    # computers
    p20)
        echo "lpro"
        ;;
    p21)
        echo "lg15"
        ;;
    # phones & tablets
    p50)
        echo "iphone 8s quang"
        ;;
    p51)
        echo "ipad a16 quang"
        ;;
    p52)
        echo "iphone 14 pro max hoa"
        ;;
    p53)
        echo "ipad 9 max"
        ;;
    p54)
        echo "ipad air quang"
        ;;
    *)
        # other peers: no-op
        ;;
esac