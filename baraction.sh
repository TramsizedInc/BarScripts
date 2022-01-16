#!/bin/bash

##############################################
########   ##   ##   ##   ##   ###############
######## #### #### # ## # ## # ###############
######## ###### ##   ##   ##   ###############
######## ###### ## # ## # ## # ###############
########   ##   ## # ##   ## # ###############
##############################################

# Csaba's baraction.sh for spectrwm
# dependencies:
# lm_sensors
# alsa support for audio
# rg for like everithing
# wget for the public ip
# speedtest-cli for internet speeds
# tput
# awk
# internet connection (!)
#   needed for the speedtest for the public ip and for the weather


# baraction.sh
# spectrwm status bar


## Colors ##

# colors were set in the config
# of spectrwm
#
# 0 blue-ish purple-ish color
# 1 purple
# 2 yellow
# 3 red
# 4 strong yellow
# 5 light blue
# 6 green
# 7 very light blue
# 8 black
# 9 white


#### DISK
hdd() {
  hdd="$(df -h | awk 'NR==4{print $3, $5}')"
  echo -e "HDD: $hdd"
}

## RAM
mem() {
  mem=`free | awk '/Mem/ {printf "%dM/%dM\n", $3 / 1024.0, $2 / 1024.0 }'`
  echo -e "$mem"
}

## CPU
cpu() {
  read cpu a b c previdle rest < /proc/stat
  prevtotal=$((a+b+c+previdle))
  sleep 0.5
  read cpu a b c idle rest < /proc/stat
  total=$((a+b+c+idle))
  cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
  echo -e "CPU: $cpu%"
}

## VOLUME
vol() {
    #vol=`amixer get Master | awk -F'[][]' 'END{ print $4":"$2 }' | sed 's/on://g'`
  vol=`pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'`
  echo -e "VOL: $vol%"
}

## CPU_TEMP
ct() {
  ct=`sensors | rg -w Tctl: | awk -F: '{ print $2 }' | sed 's/ //g' | sed 's/+//g'`
  echo -e "CPU: $ct"
}

#### 🌡🌡️🌡

## Local IPv4
ipv4(){
  ip=`ip -o -4  address show  | awk ' NR==2 { gsub(/\/.*/, "", $4); print $4 } '`
  echo -e "IPv4: $ip"
}



## Local IPv6
ipv6(){
  #ip6=`ifconfig -a | awk 'NR==2{ sub(/^[^0-9]*/, "", $2); printf "IPv6=%s\n"; $2; exit }'`
  #ip6=`ifconfig -a | awk 'NR==2{ sub(/^[^0-9]*/, "", $2); printf "%s\n", $2; exit }'`
  ip6=`ip addr show dev enp31s0 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d'`
  echo -e "IPv6: $ip6"
}


## Public IPv4
pub(){
  obs=`ps -e | rg -w obs`
  nobs=`ps -e | rg -w fasz`
  pubip=`wget http://ipecho.net/plain -O - -q ; echo`
    if [ $obs == $nobs ];
      then
        echo -e "Public: $pubip"
    else
      echo -e "PublicIP: Classified"
  fi
}
# you may want to disable it, of you stream
# keep your public ip to yourself
# it makes using the internet
# more secure, if you do so

## Who thefuck
wtf(){ wtf=`whoami`
       if [ $wtf == "csaba" ];
       then
         echo -e "Csaba vagyok"
       elif [ $wtf == root ];
       then
         echo -e "Gyökér!"
       else
         echo -e "$wtf"
  fi
}


## Weather report mother fucker
wtt(){
  wth=`curl wttr.in/Delegyhaza?format="%C+%t\n"`
  echo -e "$wth"
}

###### Time hurting bs ########

## Download speed
ds(){
  ds=`speedtest-cli --no-upload | rg -w Download | awk -F: '{ print $2 }'`
  echo -e "Download:$ds"
}
# takes a hell of alot time
# like 24 seconds or so, so
# i advise you to just
# get rid of it if you want to do so
# doesn't effect the clock fortunately
# but, the cpu temperature can rise,
# without notice, wich can degrade it

## Upload speed
up(){
  up=`speedtest-cli --no-download | rg -w Upload | awk -F: '{ print $2 }'`
  echo -e "Upload:$up"
}
# the same applies to this
# as for the download script
# takes a lot of time, and
# makes the bar look bad on startup
# if it bothers you, just get rid of it
# still doesn't effect the clock

## Up & Down like a rollercoaster
upd(){
  #speedtest > /home/csaba/testpd.txt
  down=`cat /home/csaba/testpd.txt | rg -w Download | awk -F: '{ print $2 }'`
  up=`cat /home/csaba/testpd.txt | rg -w Upload | awk -F: '{ print $2 }'`
  echo -e "Download:$down | Upload:$up"
}



######### END ##############



###########################################
############### just junk #################

# +@fg=9; $ip
# +@fg=2; $ip6
# +@fg=6;+@fn=1;🌍+@fn=0; $pubip
# +@fg=5; +@fn=1;🌡+@fn=0;$ct
# +@fg=1; +@fn=1;💻+@fn=0; $cpu
# +@fg=2; +@fn=1;💾+@fn=0; $mem
# +@fg=3; +@fn=1;💿+@fn=0; $hdd
# +@fg=4; +@fn=1;🔈+@fn=0; $vol
# +@fg=0; |"

#### 🌍🌍🌍

############# end of junk #################
###########################################

SLEEP_TIME=1
# needed, for looping
# loop is needed, for
# outputting up to date
# values, to the bar

while :; do
#    echo -e "+@fg=7; $(wtf) |+@fg=9; $(ipv4) | +@fg=2;$(ipv6) | +@fg=6;+@fn=1;🌍+@fn=0; $(pub) +@fg=9;| $(ds) | $(up) |+@fg=5; +@fn=1;🌡+@fn=0;$(ct) +@fg=0; | +@fg=1; +@fn=1;💻+@fn=0; $(cpu) +@fg=0; | +@fg=2; +@fn=1;💾+@fn=0; $(mem) +@fg=0; | +@fg=3; +@fn=1;💿+@fn=0; $(hdd) +@fg=0; | +@fg=4; +@fn=1;🔈+@fn=0; $(vol) +@fg=0; |"
    echo -e "+@fg=7;$(wtf) |+@fg=9; $(ipv4) | +@fg=2;$(ipv6) | +@fg=6;+@fn=1;🌍+@fn=0; $(pub) +@fg=9;| $(upd) | $(wtt) |+@fg=5; +@fn=1;🌡+@fn=0;$(ct) +@fg=0; | +@fg=1; +@fn=1;💻+@fn=0; $(cpu) +@fg=0; | +@fg=2; +@fn=1;💾+@fn=0; $(mem) +@fg=0; | +@fg=3; +@fn=1;💿+@fn=0; $(hdd) +@fg=0; | +@fg=4; +@fn=1;🔈+@fn=0; $(vol) +@fg=0; |"
#    echo -e "+@fg=7;$(wtf) |+@fg=9; $(ipv4) | +@fg=2;$(ipv6) | +@fg=6;+@fn=1;🌍+@fn=0; $(pub) +@fg=9;| $(upd) | +@fg=5; +@fn=1;🌡+@fn=0;$(ct) +@fg=0; | +@fg=1; +@fn=1;💻+@fn=0; $(cpu) +@fg=0; | +@fg=2; +@fn=1;💾+@fn=0; $(mem) +@fg=0; | +@fg=3; +@fn=1;💿+@fn=0; $(hdd) +@fg=0; | +@fg=4; +@fn=1;🔈+@fn=0; $(vol) +@fg=0; |"
	sleep $SLEEP_TIME
done
