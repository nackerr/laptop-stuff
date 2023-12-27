export VISUAL=nano
export EDITOR="$VISUAL"
eval "$(/opt/homebrew/bin/brew shellenv)"
export THEOS=~/theos
alias python='python3'
alias checkbashupdate='check_for_updates'
alias updatebash='update_bash_profile'
export BASH_SILENCE_DEPRECATION_WARNING=1

#!/bin/bash

update_bash_profile() {
    curl -s -o ~/.bash_profile https://raw.githubusercontent.com/nackerr/laptop-stuff/main/.bash_profile
    echo "Your .bash_profile has been updated. Please restart your terminal."
}

check_for_updates() {
    local local_version=$(md5 -q ~/.bash_profile)
    local remote_version=$(curl -s https://raw.githubusercontent.com/nackerr/laptop-stuff/main/.bash_profile | md5 -q)

    if [ "$local_version" != "$remote_version" ]; then
        echo "An update is available for your .bash_profile."
        echo "Run 'update_bash_profile' to update."
    else
        echo "Your .bash_profile is up to date."
    fi
}

update_weather_and_ip() {
    while true; do
        # Update weather information
        weather_info=$(curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=0&locCode=US|PA|LEVITTOWN" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p')
        echo "$weather_info" > ~/.cache/weather_info

        # Update public IP information
        ip_info=$(wget -q -O - https://cosmicguard.com/ip/ | tail)
        echo "$ip_info" > ~/.cache/ip_info

        sleep 600 # Update every 10 minutes
    done
}

update_weather_and_ip &

echo '888b    888        d8888  .d8888b.  888    d8P  8888888888 8888888b.  
8888b   888       d88888 d88P  Y88b 888   d8P   888        888   Y88b 
88888b  888      d88P888 888    888 888  d8P    888        888    888 
888Y88b 888     d88P 888 888        888d88K     8888888    888   d88P 
888 Y88b888    d88P  888 888        8888888b    888        8888888P"  
888  Y88888   d88P   888 888    888 888  Y88b   888        888 T88b   
888   Y8888  d8888888888 Y88b  d88P 888   Y88b  888        888  T88b  
888    Y888 d88P     888  "Y8888P"  888    Y88b 8888888888 888   T88b' | lolcat

# Function to get Tunnel IP
get_tunnel_ip() {
    ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | tail -1 || echo "No Tunnel IP"
}

get_lan_ip() {
    ipconfig getifaddr en0 || echo "No LAN IP"
}

memory_usage() {
    page_size=16384  # Page size in bytes

    # Fetching the required values from vm_stat
    pages_active=$(vm_stat | grep 'Pages active' | awk '{print $3}' | sed 's/\.$//')
    pages_wired_down=$(vm_stat | grep 'Pages wired down' | awk '{print $4}' | sed 's/\.$//')
    pages_compressed=$(vm_stat | grep 'Pages occupied by compressor' | awk '{print $5}' | sed 's/\.$//')

    # Calculating total used pages
    total_used_pages=$((pages_active + pages_wired_down + pages_compressed))

    # Converting pages to GB
    used_memory_gb=$(echo "scale=2; $total_used_pages * $page_size / 1024 / 1024 / 1024" | bc)
    echo "$used_memory_gb GB"
}

# Uptime
uptime_formatted=$(uptime | awk -F '(up |, [0-9] users)' '{print $2}')

weather=$(cat ~/.cache/weather_info 2>/dev/null || echo "Weather data not available")
public_ip=$(cat ~/.cache/ip_info 2>/dev/null || echo "Public IP data not available")

echo "$(tput setaf 2)
`date +"%A, %e %B %Y, %r"`
`uname -srmo`$(tput setaf 1)

Uptime.............: ${uptime_formatted}
Memory.............: $(memory_usage)
Running Processes..: $(ps ax | wc -l | tr -d " ")
LAN IP.............: $(get_lan_ip)
Tunnel IP..........: $(get_tunnel_ip)
Public IP..........: $public_ip
Weather............: $weather
$(tput sgr0)"

check_for_updates

PS1="\[\e[1;32m\][\u@\h \W]\[\e[1;34m\] @ \$(date +'%I:%M:%S %p')\[\e[0m\]\n$ "
