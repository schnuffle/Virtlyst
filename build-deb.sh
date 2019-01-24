#/bin/bash
docker build -t virtlyst .
mkdir ./tmp
mkdir -p virtlyst-deb/usr/local/var/virtlyst
docker run --name virtlysttmp --rm virtlyst
docker cp virtlysttmp:/usr/local ./tmp
docker stop virtlysttmp

cp -a ./tmp/lib virtlyst-deb/usr/local/
cp -a ./tmp/bin virtlyst-deb/usr/local/
cp -a ./tmp/man virtlyst-deb/usr/local/
cp -a ./tmp/share virtlyst-deb/usr/local/
cp -a ./tmp/src/Virtlyst/root virtlyst-deb/usr/local/var/virtlist
#cp -a ~/src/Virtlyst/usr/local/src/Virtlyst/config.ini ../../etc/
cp -a ./tmp/src/libVirtlyst.so  virtlyst-deb/usr/local/lib/

