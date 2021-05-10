#/bin/bash

<<!
 **********************************************************
 * Author        : WuZhenYu
 * Filename      : service.sh
 * Description   : java 进程启动、停止、重启脚本
 * *******************************************************
!
workdir=$(cd $(dirname $0); pwd)

getJarName(){

    for name in `ls $workdir`
    do
        if [[ "$name" =~ \.jar$ ]];then
            echo $name
            return $?
        fi
    done    
}

stop() {
    local jarName=$1
    kill `cat $workdir/$2`
    rm -rf $workdir/$2
    echo "=== stop $1"

    sleep 5
    hadlerStop $jarName
}

hadlerStop() {
    local jarName=$1
    local pid=`ps -ef | grep -w "$jarName" | grep -v "grep" | awk '{print $2}'`
    if [ "$pid" == "" ]; then
        echo "=== $jarName process not exists or stop success"
    else
        askStop $jarName $pid
    fi
}

askStop() {
    local jarName=$1
    local pid=$2
    read -p "$jarName process is a work in progress! \
        [1]: keep waiting \
        [2]: kill now
        " answer
    case $answer in
        "1")  
            echo "keep waiting......"
            sleep 5
            hadlerStop $jarName
        ;;
        "2")
            echo "=== $jarName process pid is:$pid"
            echo "=== begin kill $jarName process, pid is:$pid"
            kill -9 $pid
        ;;
        *)
            echo "error choice"
            askStop $jarName $pid
        ;;
    esac
}

start() {
    local jarName=$1
    local pidfile=$2
    nohup java -Xmn128M -Xms128M -jar $workdir/$jarName >/dev/null 2>&1 & 
    echo $! > $workdir/$pidfile
    echo "=== start $jarName"
}

restart() {
    stop $1 $2
    sleep 2
    start $1 $2
}

main(){
    jarName=$(getJarName)
    echo $jarName
    pidfile="$jarName.pid"
    echo $pidfile
    case "$1" in
        start)
            start $jarName $pidfile
            ;;
        stop)
            stop $jarName $pidfile
            ;;
        restart)
            restart $jarName $pidfile
            ;;
        *)
            restart $jarName $pidfile
            ;;
    esac
}

main $1

exit 0