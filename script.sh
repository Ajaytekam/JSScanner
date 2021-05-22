#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
END='\033[0m'

linkf=~/tools/LinkFinder/linkfinder.py

CreateDir() {
    DIRNAME=`date | sed  -e 's/ /_/g' -e 's/:/-/g' -e 's/IST//g' -e 's/UTC//g' -e 's/__/_/g'`
    DIRNAME=`echo JSScanner_result_`$DIRNAME
    mkdir -p $DIRNAME
    echo $DIRNAME 
}

JScan_Func() {
    cd $2
    n1=$(echo $1 | awk -F/ '{print $3}')
    n2=$(echo $1 | awk -F/ '{print $1}' | sed 's/.$//')
    mkdir -p $n1-$n2/js
    timeout 40 python3 $linkf -d -i $1 -o cli > $n1-$n2/linkfinder_raw.txt

    jslinks=$(cat $n1-$n2/linkfinder_raw.txt | grep -oaEi "https?://[^\"\\'> ]+" | grep '\.js' | grep "$n1" | sort -u)

    if [[ ! -z $jslinks ]]
    then
        for js in $jslinks
        do
            filename=$(echo $js | awk -F/ '{print $(NF-0)}' | sed  's/\?/\=\=/g')
            python3 $linkf -i $js -o cli >> $n1-$n2/js/$filename.endpoints
            echo "$js" >> $n1-$n2/jslinks.txt
            #wget $js -P db/$n1-$n2/ -q
            curl -L --connect-timeout 10 --max-time 10 --insecure --silent $js | js-beautify - > $n1-$n2/js/$filename 2> /dev/null
            echo "js/$filename" >> $n1-$n2/index
            echo "js/$filename.endpoints" >> $n1-$n2/index
        done
    fi
    cd ..
    printf "${GREEN}[+]${END} $i ${YELLOW}done${END}.\n"
}

# Main Function Starts from Here 
if [[ $# -eq 0 ]] ; then
    printf '\n Usage: jsscanner domain_name [-f] path-to-urls-file\n\n'
    printf 'domain_name : FQDN with protocol\n'
    printf 'path-to-urls-file : Line saparated FQDN with protocol\n'
    printf '\nExample :\n'
    printf '\tjsscanner https://www.example.com/\n'
    printf '\tjsscanner -f hosts.txt\n'
    exit 0
elif [[ $# -eq 1 ]]; then
    DIRNAME=$(CreateDir)
    printf "${YELLOW}[+]${END} JSScanner started.\n"
    JScan_Func $1 $DIRNAME
elif [[ $# -eq 2 && $(echo $1 | tr '[:upper:]' '[:lower:]') == "-f" ]]; then 
    DIRNAME=$(CreateDir)
    printf "${YELLOW}[+]${END} JSScanner started.\n"
    for i in $(cat $2)
    do
        JScan_Func $i $DIRNAME
    done   
else 
    printf "${YELLOW}[!]${END} Error.. Please check the provided arguments.\n"
    exit
fi

printf "${YELLOW}[+]${END} Script is done.\n"
printf "\n${YELLOW}[+]${END} Results stored in Jsscanner_results.\n"
