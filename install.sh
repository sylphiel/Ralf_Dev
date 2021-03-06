#!/bin/bash   
# GSshop package install manager   
# Made by Jiook Yang
# goody80762@gmail.com & ralf.yang@gsshop.com


echo " ======================================================================================== "
echo "  Please insert directory name for you want (ex /data )"
echo "  Directory will be created as you type it "
echo "  I recommend you a directory name is /data. Due to I made already so many packages based "
echo "  on that directory. If you have own package already, you just ignor this message :) "
echo " ======================================================================================== "
read ZinstBaseRootO
# -> ex) /data



if [[ $ZinstBaseRootO = "" ]]
	then
	echo " === Empty data has been inserted! ==="
	echo " ===  Processor has been stopped   ==="
	exit 0;
fi

ZinstBaseRoot=`echo "$ZinstBaseRootO" | sed -e 's/\//\\\\\//g'`

export ZinstDir="$ZinstBaseRootO"


echo " ======================================================================================== "
echo "  Do you want to make a Distribute server for packages download? [y / n ]" 
echo "  * Notice: Apache web server will be start in this server automaticlly *"
echo " ======================================================================================== "
read Dist_IC

if [[ $Dist_IC = y ]]
	then
	mkdir -p $ZinstBaseRootO/dist/checker
	chown nobody.nobody $ZinstBaseRootO/dist
	echo " ======================================================================================= "
	echo "  File directory for the Distritution is $ZinstBaseRootO/dist  "
	echo " ======================================================================================= "

fi

echo " ======================================================================================== "
echo "  Please insert your Domain name of the Distribution server ex)package.dist.blahblah.com"
echo " ======================================================================================== "
read Dist_server
# -> ex) package.dist.gsshop.com

if [[ $Dist_server = "" ]]
	then
	echo " === Empty data has been inserted! ==="
	echo " === You can't use the package distributer  === "
fi

echo " ======================================================================================= "
echo "  Please insert your IP address of the Distribution server"
echo " ======================================================================================= "
read Dist_server_IP

# -> ex) 192.168.10.141

if [[ $Dist_server_IP = "" ]]
	then
		echo " === Empty data has been inserted! ==="
		echo " === You can't use the package distributer  === "
fi

echo " ======================="
echo " | Go ahead ? [y or n] |"
echo " ======================="
read Ggo

if [[ $Ggo != "y" ]]
	then
	echo " ===  Processor has been stopped   ==="
	exit 0;
fi

sed -i "s/RootDirectorY/$ZinstBaseRoot/g" ./zinst
sed -i "s/DISTsERVERsET/$Dist_server/g" ./zinst
sed -i "s/DISTsERVERIp/$Dist_server_IP/g" ./zinst

mkdir -p $ZinstBaseRootO/zinst
mkdir -p $ZinstBaseRootO/z
mkdir -p $ZinstBaseRootO/vault/Source/bin
echo "set -o emacs" >> /etc/profile

cp ./zinst $ZinstBaseRootO/vault/Source/bin/zinst
ln -sf $ZinstBaseRootO/vault/Source/bin/zinst /usr/bin/zinst

if [[ $Dist_IC = y ]]
    then
	mv ./zinst $ZinstBaseRootO/dist/zinst
	cp ./*.zinst $ZinstBaseRootO/vault/Source/
	mv ./*.zinst $ZinstBaseRootO/dist/
	cd $ZinstBaseRootO/vault/Source/

	zinst i server_default_setting*.zinst 
	zinst i httpd_lynx*.zinst 
	zinst i gsshop_httpd_server*.zinst 
	zinst i gsshop_httpd_conf_pkgdist*.zinst -set gsshop_httpd_conf_pkgdist.ServerName=$Dist_server
	zinst set gsshop_httpd_conf_pkgdist.DocumentRoot=$ZinstBaseRootO/dist
	zinst start httpd
	echo " ======================================================================================= "
	echo "  Apache web server has been installed "
	echo "  You can push the packages to $ZinstBaseRootO/dist for the package distribute "
	echo " ======================================================================================= "
fi


echo " =============================== "
echo " ===== Job finished!! :) ======= "
echo " =============================== "

