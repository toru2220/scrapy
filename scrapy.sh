#!/bin/bash

#./scrapy.sh 

# jobhash
# giturl
# projectdir
# spidername

workdir=`pwd`
projectdir=`cat /proc/sys/kernel/random/uuid`

conf=${1:-`pwd`}
giturl=${2:-"https://sample.git"}
spidername=${3:-"sample"}
envs=${4:-"{}"}

echo "envs=${envs}"
json=$(echo ${envs} | jq -r 'keys[] as $k | "\($k)=\(.[$k])"')

for e in ${json[@]}; do

    # キーと値を分割する
    arr=(`echo "${e}" | tr -s '=' ' '`)
    
    # キーを大文字に変換して変数定義する 
    
    echo "Set Env:"${arr[0]^^}="${arr[1]}"
    export ${arr[0]^^}="${arr[1]}"
    let i++
done

jobhash=`echo -n "${giturl}${spidername}${envs}" | md5sum | cut -d ' ' -f 1`

if [ -f ${conf}/${jobhash} ]; then
 echo "same spider is processing... skip this job. [${giturl} ${spidername} ${envs}]"
 exit 0
else
 touch ${conf}/${jobhash}
fi

cd ${workdir}

echo git clone ${giturl} ${projectdir}
git clone ${giturl} ${projectdir}

echo start scraping
cd ${workdir}/${projectdir}
scrapy crawl ${spidername}

echo cleanup
rm -rf ${workdir}/${projectdir}

rm -rf ${conf}/${jobhash}
