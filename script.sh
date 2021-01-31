#!/bin/bash

ip='127.0.0.1'

function pause(){
  echo -n '[i] Utilitza el espai per continuar...' ; read -s -d ' '
}


function crear_files(){

  echo -e '\n[!] creant el virus EICAR i el guardem a eicar.com ...'
  sleep 1
  echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > eicar.com
  echo -e '\n[!] creant un fitxer de prova i el guardem com a ok.txt...'
  echo 'no soc un virus' |  tee ok.txt
  echo -e '\n[!] creant un fitxer per les credencials de smb...'
  echo -e 'username = alumne\npassword = 1234' | tee .smbcred
  sleep 2 
}

function smb_check(){
  echo ${ip}
  echo -e '\n[?] Mostrant directoris compartits...'
  smbclient -L \\${ip} -A .smbcred 
  sleep 2

  echo -e '\n[?] Mostrant contingut del directori alumne...'
  smbclient  \\\\${ip}\\alumne -A .smbcred -c 'recurse ON;dir *'
  sleep 2 

  echo -e '\n[*] Introduint virus EICAR i finalment el mostrem...'
  smbclient  \\\\${ip}\\alumne -A .smbcred -c 'recurse OFF;cd uploads; put eicar.com; dir'
  sleep 2

  echo -e '\n[*] Introduint fitxer normal i finalment el mostrem...'
  smbclient  \\\\${ip}\\alumne -A .smbcred -c 'recurse OFF;cd uploads; put ok.txt; dir'
  sleep 2

  echo -e '\n[?] Mostrant contingut i comprovem si el antivirus ha actuat...'
  watch -x smbclient  \\\\${ip}\\alumne -A .smbcred -c 'recurse ON;dir *'
  sleep 2

  echo -e '\n[?] Eliminem els fitxer per evitar problemas amb el següent check...'
  smbclient  \\\\${ip}\\alumne -A .smbcred -c 'recurse OFF;cd desktop; rm ok.txt'
  sleep 2
}

function ftp_check(){
  echo -e "\n[i] Per poder fer la conexió per ftp et mostraré les dades que has d'introduir i finalment faré la comprovació..."

  echo -e '\n\t[i] usuari: alumne'
  echo -e '\t[i] passwd: 1234'
  echo -e '\t[i] comandes:'
  echo -e 'pass'
  echo -e 'cd uploads'
  echo -e 'put eicar.com'
  echo -e 'put ok.txt'
  echo -e 'quit'
  
  ftp ${ip} 21
  
  echo -e "[?] Fem la comprovació del que ha passat..."
  sleep 2
  watch -x curl --list-only "ftp://127.0.0.1/desktop/" --user "alumne:1234"
}

function main(){
  crear_files
  smb_check
  pause
  ftp_check
  echo -e "[*] Veure els fitxers eliminats" 
  firefox http://${ip}
}

main
