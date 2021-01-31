#!/bin/bash

function start(){
  mkdir -p data/{quarantine,ok,nok,uploads}
  docker-compose up -d
  sleep 1
  docker run -it -p 139:139 -p 445:445 -v "$PWD/data/uploads:/alumne/uploads" -v "$PWD/data/ok:/alumne/desktop" -d dperson/samba -p \
            -u "alumne;1234" \
            -u "profe;badpass" \
            -s "public;/share" \
            -s "users;/srv;no;no;no;alumne,profe" \
            -s "alumne;/alumne;yes;no;no;alumne;;;private" \
            -s "profe;/profe;yes;no;no;profe"   
  sleep 1
  docker run -d -v $PWD/data/uploads:/home/vsftpd/uploads  \
		            -v $PWD/data/ok:/home/vsftpd/desktop \
                -p 20:20 -p 21:21 -p 47400-47470:47400-47470 \
                -e FTP_USER=alumne \
                -e FTP_PASS=1234 \
                -e PASV_ADDRESS=0.0.0.0 \
                --name ftp \
                --restart=always bogem/ftp  
  sudo chmod 777 -R data
}
function _stop(){
  docker-compose down
  id=$(docker ps | awk '{print $1}' | xargs)
  docker stop ${id}
  docker rm ${id}
  sudo rm -r data
}

function main(){
  if [[ $1 == 'start' ]]; then 
    start
  elif [[ $1 == 'stop' ]]; then
    _stop
  else
    echo "error"
  fi 
}
main $1
