#/bin/bash

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
rm -fR virtlyst-deb/usr/local/lib/x86_64-linux-gnu/pkgconfig
rm -fR virtlyst-deb/usr/local/lib/x86_64-linux-gnu/cmake

chown root:root -R virtlyst-deb/usr

rm -f virtlyst-deb.deb

dpkg --build virtlyst-deb
