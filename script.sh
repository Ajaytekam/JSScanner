#!/bin/bash

RED='\033[0;31m'
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
    printf '\n Usage: jsscanner domain_name [-f] path-to-urls-file [-d] output_directory\n\n'
    printf 'domain_name : FQDN with protocol\n'
    printf 'path-to-urls-file : Line saparated FQDN with protocol\n'
    printf 'output_directory  : User supplied output directory' 
    printf '\nExample :\n'
    printf '\tjsscanner https://www.example.com/\n'
    printf '\tjsscanner https://www.example.com/ -d ./out\n'
    printf '\tjsscanner -f hosts.txt\n'
    printf '\tjsscanner -f hosts.txt -d ./out\n\n'
    exit 0
elif [[ $# -eq 1 ]]; then
    DIRNAME=$(CreateDir)
    printf "${YELLOW}[+]${END} JSScanner started.\n"
    JScan_Func $1 $DIRNAME
elif [[ $# -gt 1 ]]; then 
    if [[ $(echo $1 | tr '[:upper:]' '[:lower:]') == "-f" ]] ; then 
        INPUTFILE=$2
        if [[ $(echo $3 | tr '[:upper:]' '[:lower:]') == "-d" ]];then
            if [[ "$4" != "" ]] ; then
                OUTPUTDIR=$4
                mkdir -p $OUTPUTDIR
                printf "${YELLOW}[+]${END} JSScanner started.\n"
                for i in $(cat $INPUTFILE)
                do
                    JScan_Func $i $OUTPUTDIR
                done   
            else
                printf "${RED}[!]${END} Error Dir name supplied\n"  
                exit 1
            fi
        else
            DIRNAME=$(CreateDir)
            printf "${YELLOW}[+]${END} JSScanner started.\n"
            for i in $(cat $2)
            do
                JScan_Func $i $DIRNAME
            done   
        fi
    elif [[ $(echo $2 | tr '[:upper:]' '[:lower:]') == "-d" ]]; then
        DOMAIN_NAME=$1
        if [[ "$3" != "" ]];then
            OUTPUTDIR=$3
            mkdir -p $OUTPUTDIR
            JScan_Func $DOMAIN_NAME $OUTPUTDIR
        else
            printf "${RED}[!]${END} Error : Output Dir not supplied\n"
            exit 1
        fi
    else
       printf "${RED}[!]${END} Error: Wrong arguments supplied\n"
    fi
else 
    printf "${RED}[!]${END} Error.. Please check the provided arguments.\n"
    exit
fi

printf "${YELLOW}[+]${END} Script is done.\n"
printf "\n${YELLOW}[+]${END} Results stored in Jsscanner_results.\n"
