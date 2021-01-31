# Antivirus
mkdir -p data/{quarantine,ok,nok,uploads}


## Antivirus config
```yml
version: '2'

services:

  docker-av:
    image: rordi/docker-antivirus
    container_name: docker-av
    # uncomment and set the email address to receive email alerts when viruses are detected
    #command:
    # - /usr/local/install_alerts.sh email@example.net
    volumes:
      - ./data/uploads:/data/av/queue
      - ./data/ok:/data/av/ok
      - ./data/nok:/data/av/nok
      - ./data/quarantine:/data/av/quarantine
    networks:
      - avnetwork
networks:
  avnetwork:


```

## creación virus
```
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > eicar.com
echo 'no soc un virus' > ok.txt
```

## SMB

```
docker run -it -p 139:139 -p 445:445 -v "$PWD/data/uploads:/alumne/uploads" -v "$PWD/data/ok:/alumne/desktop" -d dperson/samba -p \
            -u "alumne;badpass" \
            -u "profe;badpass" \
            -s "public;/share" \
            -s "users;/srv;no;no;no;alumne,profe" \
            -s "alumne;/alumne;yes;no;no;alumne;;;private" \
            -s "profe;/profe;yes;no;no;profe" 
```
```
echo -e 'username = alumne\npassword = badpass' > .smbcred


smbclient -L \\localhost -A .smbcred


smbclient  \\\\localhost\\alumne -A .smbcred -c 'recurse OFF;dir desktop; dir uploads'

smbclient  \\\\localhost\\alumne -A .smbcred -c 'recurse OFF;cd uploads; put eicar.com; dir'

smbclient  \\\\localhost\\alumne -A .smbcred -c 'recurse OFF;cd uploads; put ok.txt; dir'

watch -x smbclient  \\\\localhost\\alumne -A .smbcred -c 'recurse ON;dir *'
```

## FTP 

```bash
docker run -d -v $PWD/data/uploads:/home/vsftpd/uploads  \
		-v $PWD/data/ok:/home/vsftpd/desktop \
                -p 20:20 -p 21:21 -p 47400-47470:47400-47470 \
                -e FTP_USER=alumne \
                -e FTP_PASS=1234 \
                -e PASV_ADDRESS=0.0.0.0 \
                --name ftp \
                --restart=always bogem/ftp

ftp 127.0.0.1 21
alumne
1234
pass 
cd uploads
put ok.txt
put eicar.com
quit


watch -x curl --list-only "ftp://127.0.0.1/desktop/" --user "alumne:1234"
```
