#!/bin/bash
if [ ! -d ./.bin ];then
mkdir .bin
fi
APIURL="https://api.mslmc.cn/v4"
Arch_check() {
	if [ $(uname -m) == "x86_64" ] || [ $(uname -m) == "amd64" ]; then
	export Arch=amd64
elif [ $(uname -m) = "aarch64" ] || [ $(uname -m) = "arm64" ]; then
	export Arch=arm64
else
	echo "你的架构不受支持"
	exit
fi
}

Jq_check() {
	echo "正在寻找Json解析器JQ..."
	if [ ! $(command -v jq) ];then
		if [[ ! -f ./.bin/jq ]];then
			echo "未发现JQ,下载中"
			curl -o ./.bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux-${Arch}
			chmod +x ./.bin/jq
			export JQ=./.bin/jq
		else 
			echo "发现用户JQ"
			export JQ=./.bin/jq
		fi
	else
		echo "发现系统JQ"
		export JQ=jq
	fi

}
Arch_check
Jq_check
Java_install() {
if [ ! -d .jdltmp ];then    
mkdir .jdltmp
fi
    echo "本脚本安装的java路径在 当前目录/.bin/javaX/ 下,X代表数字"
	 if [ $Arch == "amd64" ];then
		 Arch="x64"
	 else
		 Arch="aarch64"
	 fi
    echo "请选择需要的Java版本"
    echo
    echo " 1) Java8(适用于mc1.7.2~1.16.5)
 2) Java11
 3) Java17(适用于mc1.17~1.20.4)
 4) Java21(适用于mc1.20.5~1.21.11)
 5) Java25(适用于mc26.1~至今)
 0) 返回
 "
 echo -n "清输入数字: "
 read input
 case $input in
	 1)
		 curl -o ./.jdltmp/java8.tar.gz https://cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-linux_${Arch}.tar.gz
		 tar zxvf ./.jdltmp/java8.tar.gz -C ./.bin/
		 mv ./.bin/zulu8* ./.bin/java8
	;;
	2)
		curl -o ./.jdltmp/java11.tar.gz https://cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-linux_${Arch}.tar.gz
		tar zxvf ./.jdltmp/java11.tar.gz -C ./.bin/
		mv ./.bin/zulu11* ./.bin/java11
	;;
	3)
		curl -o ./.jdltmp/java17.tar.gz https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-linux_${Arch}.tar.gz
		tar zxvf ./.jdltmp/java17.tar.gz -C ./.bin/
		mv ./.bin/zulu17* ./.bin/java17
	;;
	5)
		curl -o ./.jdltmp/java25.tar.gz https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-linux_${Arch}.tar.gz
		tar zxvf ./.jdltmp/java25.tar.gz -C ./.bin/
		mv ./.bin/zulu25* ./.bin/java25
	;;
	4)
		curl -o ./.jdltmp/java21.tar.gz https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-linux_${Arch}.tar.gz
		tar zxvf ./.jdltmp/java21.tar.gz -C ./.bin/
		mv ./.bin/zulu21* ./.bin/java21
	;;
	0|exit|q)
		Menu
esac
Arch_check
}
Mcsdl() {
echo "请选择服务端类型
 
 1) 插件端
 2) (Neo)forge混合端
 3) Fabric混合端
 4) (Neo)forge服务端
 5) Fabric/Quilt服务端
 6) 原版服务端
 7) 基岩版服务端
 8) 代理服务端
 0) 返回 
 "
echo -n "请输入数字: "
input=
read input
case $input in
	1)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.pluginsCore"
	;;
	2)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.pluginsAndModsCore_Forge"
	;;
	3)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.pluginsAndModsCore_Fabric"
	;;
	4)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.modsCore_Forge"
	;;
	5)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.modsCore_Fabric"
	;;
	6)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.vanillaCore"
	;;
	7)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.bedrockCore"
	;;
	8)
		curl -s https://api.mslmc.cn/v4/mirrors | $JQ ".data.proxyCore"
	;;
	9)
		Menu
esac
echo -n "请完整地输入服务端名称(例:paper): "
read server
echo -n "你选择的"
curl -s $APIURL/mirrors/${server} | $JQ ".data.description"
sleep 1
echo "请选择版本:"
curl -s $APIURL/mirrors/${server} | $JQ ".data.versions"
echo -n "请完整地输入版本号(例:1.20.1): "
read version
echo "本脚本下载的服务端位于 当前目录/服务端名称/版本号 文件夹下"
echo "正在创建目录..."
mkdir -p ${server}/${version}
echo "正在获得下载链接..."
Download_url=$(curl -s $APIURL/download/server/${server}/${version}|$JQ ".data.url"|sed ':a;N;$!ba;s/[[:space:]]//g'|sed 's/"//g')
#echo $Download_url
echo "下载中..."
curl --progress-bar -o $server/$version/server.jar $Download_url
echo "基本启动命令为 /path/to/java -jar ./$server/$version/server.jar"
echo "如需使用本脚本安装的java,请把 /path/to/java 换成 ./.bin/javaX/bin/java, X 代表数字"
}
#$JQ
Menu() {
echo "请选择功能"
echo 
echo " 1) 安装任意JavaLTS"
echo " 2) 安装Minecraft服务端"
echo " 0) 退出"
echo
echo -n "请输入数字: "
read putin
case $putin in
	1)
		Java_install
	;;
	0)
		exit
	;;
	2)
		Mcsdl
esac
}
Menu
