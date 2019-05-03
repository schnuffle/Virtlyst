#/bin/bash

# Check the distro we're building on and set the deps acordingly
valid_distros=( "Linuxmint" "Ubuntu" "Debian" )
mint_versions=( "18.0" "18.1" "19.0" "19.1" )
ubuntu_versions=( "16.04" "18.04" )
debian_versions=( "8" "9" )

distro_name=$(lsb_release -is)
distro_version=$(lsb_release -rs)


ubuntu_deps="Depends: libgrantlee-templates5 (>= 5.1.0-2), libpcre3, libicu60, libicu60, libdouble-conversion1,libc6, libglib2.0-0, libgcc1, libqt5core5a, zlib1g, libstdc++6"
debian_deps="Depends: libgrantlee-templates5, libqt5core5a, libqt5network5, libqt5sql5, libqt5xml5, libvirt0"

echo "Distro: $distro_name"
echo "Version: $distro_version"

case $distro_name in
	LinuxMint|Ubuntu)
		sed -i "s/^Depends:.*/$ubuntu_deps/g" virtlyst-deb/DEBIAN/control
		;;
	Debian)
		sed  -i "s/^Depends:.*/$debian_deps/g" virtlyst-deb/DEBIAN/control
		;;
	*)
		echo "Distro is not supported"
		exit 0
		;;
esac
# 
exit 0

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
