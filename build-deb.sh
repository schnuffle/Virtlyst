#/bin/bash
# keep in mint 
# LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/x86_64-linux-gnu:/usr/local/lib/cutelyst2-plugins
# has to be set

docker build -t virtlyst .
mkdir ./tmp
mkdir -p virtlyst-deb/usr/local/var/virtlyst
docker run --name virtlysttmp -d --rm virtlyst
docker cp virtlysttmp:/usr/local ./tmp
docker stop virtlysttmp

cp -a ./tmp/local/lib virtlyst-deb/usr/local/
cp -a ./tmp/local/bin virtlyst-deb/usr/local/
cp -a ./tmp/local/man virtlyst-deb/usr/local/
cp -a ./tmp/local/share virtlyst-deb/usr/local/
cp -a ./tmp/local/src/Virtlyst/root virtlyst-deb/usr/local/var/virtlyst/
cp -a ./tmp/local/src/Virtlyst/src/libVirtlyst.so  virtlyst-deb/usr/local/lib/

dpkg --build virtlyst-deb
