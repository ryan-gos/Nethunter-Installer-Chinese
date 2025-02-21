pkg install ncurses-utils
echo "$(tput setaf 1)'_____        _____     ______________    ________________'$(tput sgr0)"
echo "$(tput setaf 1)'|   |        |   |    |             |    |              |'$(tput sgr0)"
echo "$(tput setaf 1)'|    |       |   |    |_____________|    |___        ___|'$(tput sgr0)"
echo "$(tput setaf 1)'|   | |      |   |    |                     |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|   |  |     |   |    |_____________        |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|   |   |    |   |    |    V1.14    |       |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|   |    |   |   |    |_____________|       |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|   |     |  |   |    |                     |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|   |      | |   |    |_____________        |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|   |       ||   |    |   臭版本号   |       |        |'$(tput sgr0)"
echo "$(tput setaf 1)'|___|        |___|    |_____________|       |________|'$(tput sgr0)"
echo "更新日志:1.集成换源 2.添加上面那个东东 3.在最后衰气的LOGO"



read -p '更换仓库源Y/N,更换含cn的仓库' repo

[ ''${repo}'' == ''y'' -o ''${repo}'' == ''Y'' ] && echo ''使用方向键和回车来选择'' && termux-change-repo

echo "$(tput setaf 1)"同意存储访问权限"$(tput sgr0)"
sleep 5
termux-setup-storage

#!/data/data/com.termux/files/usr/bin/bash -e

VERSION=2024091801
BASE_URL=https://kali.download/nethunter-images/current/rootfs
SHA_URL=https://ryan-gos.us.kg/sha512sum
USERNAME=kali



function unsupported_arch() {
    printf "${red}"
    echo "[*] 不支持的架构\n\n"
    printf "${reset}"
    exit
}

function ask() {
    # http://djm.me/ask
    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question
        printf "${light_cyan}\n[?] "
        read -p "$1 [$prompt] " REPLY

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        printf "${reset}"

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

function get_arch() {
    printf "${blue}[*] 检查设备架构 ..."
    case $(getprop ro.product.cpu.abi) in
        arm64-v8a)
            SYS_ARCH=arm64
            ;;
        armeabi|armeabi-v7a)
            SYS_ARCH=armhf
            ;;
        i386)
            SYS_ARCH=i386
            ;;
        amd64)
            SYS_ARCH=amd64
            ;;
        *)
            unsupported_arch
            ;;
    esac
}

function set_strings() {
    echo \
    && echo "" 
    ####
    if [[ ${SYS_ARCH} == "arm64" ]];
    then
        echo ''1为完整版 2为迷你版 3为极致精简版''
        echo "3版已经过作者测试,除图形化需安装其他版本无其他问题,1,2版自行尝试"
        echo "[1] NetHunter ARM64 (full)"
        echo "[2] NetHunter ARM64 (minimal)"
        echo "[3] NetHunter ARM64 (nano)"
        read -p "输入你想下载的版本(1/2/3): " wimg
        if (( $wimg == "1" ));
        then
            wimg="full"
        elif (( $wimg == "2" ));
        then
            wimg="minimal"
        elif (( $wimg == "3" ));
        then
            wimg="nano"
        else
            wimg="full"
        fi
    elif [[ ${SYS_ARCH} == "armhf" ]];
    then
        echo ''1为完整版 2为迷你版 3为极致精简版''
        echo "[1] NetHunter ARMhf (full)"
        echo "[2] NetHunter ARMhf (minimal)"
        echo "[3] NetHunter ARMhf (nano)"
        read -p "输入你想下载的版本(1/2/3): " wimg
        if [[ "$wimg" == "1" ]]; then
            wimg="full"
        elif [[ "$wimg" == "2" ]]; then
            wimg="minimal"
        elif [[ "$wimg" == "3" ]]; then
            wimg="nano"
        else
            wimg="full"
        fi
    elif [[ ${SYS_ARCH} == "i386" ]];
    then
        echo ''1为完整版 2为迷你版 3为极致精简版''
        echo "[1] NetHunter i386 (full)"
        echo "[2] NetHunter i386 (minimal)"
        echo "[3] NetHunter i386 (nano)"
        read -p "输入你想下载的版本(1/2/3): " wimg
        if [[ "$wimg" == "1" ]]; then
            wimg="full"
        elif [[ "$wimg" == "2" ]]; then
            wimg="minimal"
        elif [[ "$wimg" == "3" ]]; then
            wimg="nano"
        else
            wimg="full"
        fi  
    elif [[ ${SYS_ARCH} == "amd64" ]];
    then
        echo ''1为完整版 2为迷你版 3为极致精简版''
        echo "[1] NetHunter amd64 (full)"
        echo "[2] NetHunter amd64 (minimal)"
        echo "[3] NetHunter amd64 (nano)"
        read -p "输入你想下载的版本(1/2/3): " wimg
        if [[ "$wimg" == "1" ]]; then
            wimg="full"
        elif [[ "$wimg" == "2" ]]; then
            wimg="minimal"
        elif [[ "$wimg" == "3" ]]; then
            wimg="nano"
        else
            wimg="full"
        fi
    fi
    ####


    CHROOT=kali-${SYS_ARCH} # Modified Line
    IMAGE_NAME=kali-nethunter-rootfs-${wimg}-${SYS_ARCH}.tar.xz  # Modified line
    SHA_NAME=kali-nethunter-rootfs-${wimg}-${SYS_ARCH}.tar.xz.txt # Modified Line
}    

function prepare_fs() {
    unset KEEP_CHROOT
    if [ -d ${CHROOT} ]; then
        if ask "检测到下载过的根文件系统，要删掉再重新创建吗?" "N"; then
            rm -rf ${CHROOT}
        else
            KEEP_CHROOT=1
        fi
    fi
} 

function cleanup() {
    if [ -f ${IMAGE_NAME} ]; then
        if ask "删掉以前的根文件系统吗?" "N"; then
	    if [ -f ${IMAGE_NAME} ]; then
                rm -f ${IMAGE_NAME}
	    fi
	    if [ -f ${SHA_NAME} ]; then
                rm -f ${SHA_NAME}
	    fi
        fi
    fi
} 

function check_dependencies() {
    printf "${blue}\n[*] 检查包的依赖关系...${reset}\n"
    ## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
    ##apt update -y &> /dev/null
    apt-get update -y &> /dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &> /dev/null

    for i in proot tar axel ncurses-utils; do
        if [ -e $PREFIX/bin/$i ]; then
            echo "  $i is OK"
        else
            printf "下载中 ${i}...\n"
            apt install -y $i || {
                printf "${red}下载失败.\n Exiting.\n${reset}"
	        exit
            }
        fi
    done
    apt upgrade -y
}


function get_url() {
    ROOTFS_URL="${BASE_URL}/${IMAGE_NAME}"
}

function get_rootfs() {
    unset KEEP_IMAGE
    if [ -f ${IMAGE_NAME} ]; then
        if ask "检测到存在的镜像文件，要删掉再重新下载吗?" "N"; then
            rm -f ${IMAGE_NAME}
        else
            printf "${yellow}[!] 使用已存在的根文件系统存档${reset}\n"
            KEEP_IMAGE=1
            return
        fi
    fi
    printf "${blue}[*] 正在下载根文件系统...${reset}\n\n"
    get_url
    wget ${EXTRA_ARGS} --continue "${ROOTFS_URL}"
}

function get_sha() {
    if [ -z $KEEP_IMAGE ]; then
        printf "\n${blue}[*] 正在获取SHA值 ... ${reset}\n\n"
        get_url
        if [ -f ${SHA_NAME} ]; then
            rm -f ${SHA_NAME}
        fi
        wget ${EXTRA_ARGS} --continue "${SHA_URL}/${SHA_NAME}"
    fi
}

function verify_sha() {
    if [ -z $KEEP_IMAGE ]; then
        printf "\n${blue}[*] 正在验证根文件系统的完整度...${reset}\n\n"
        sha512sum -c $SHA_NAME || {
            printf "${red} 根文件系统下载被终止，请重新跑一次这个下载器或者手动下载文件\n${reset}"
            exit 1
        }
    fi
}

function extract_rootfs() {
    if [ -z $KEEP_CHROOT ]; then
        printf "\n${blue}[*] 解压根文件系统中(此过程需要一点时间，很多小伙伴卡在这里，趁现在干点事情吧)... ${reset}\n\n"
        proot --link2symlink tar -xf $IMAGE_NAME 2> /dev/null || :
    else        
        printf "${yellow}[!] 使用已存在的根文件系统目录${reset}\n"
    fi
}


function create_launcher() {
    NH_LAUNCHER=${PREFIX}/bin/nethunter
    NH_SHORTCUT=${PREFIX}/bin/nh
    cat > $NH_LAUNCHER <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
cd \${HOME}
## termux-exec sets LD_PRELOAD so let's unset it before continuing
unset LD_PRELOAD
## Workaround for Libreoffice, also needs to bind a fake /proc/version
if [ ! -f $CHROOT/root/.version ]; then
    touch $CHROOT/root/.version
fi

## Default user is "kali"
user="$USERNAME"
home="/home/\$user"
start="sudo -u kali /bin/bash"

## NH can be launched as root with the "-r" cmd attribute
## Also check if user kali exists, if not start as root
if grep -q "kali" ${CHROOT}/etc/passwd; then
    KALIUSR="1";
else
    KALIUSR="0";
fi
if [[ \$KALIUSR == "0" || ("\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R")) ]];then
    user="root"
    home="/\$user"
    start="/bin/bash --login"
    if [[ "\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R") ]];then
        shift
    fi
fi

cmdline="proot \\
        --link2symlink \\
        -0 \\
        -r $CHROOT \\
        -b /dev \\
        -b /proc \\
        -b $CHROOT\$home:/dev/shm \\
        -w \$home \\
           /usr/bin/env -i \\
           HOME=\$home \\
           PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin \\
           TERM=\$TERM \\
           LANG=C.UTF-8 \\
           \$start"

cmd="\$@"
if [ "\$#" == "0" ];then
    exec \$cmdline
else
    \$cmdline -c "\$cmd"
fi
EOF

    chmod 700 $NH_LAUNCHER
    if [ -L ${NH_SHORTCUT} ]; then
        rm -f ${NH_SHORTCUT}
    fi
    if [ ! -f ${NH_SHORTCUT} ]; then
        ln -s ${NH_LAUNCHER} ${NH_SHORTCUT} >/dev/null
    fi
   
}

function create_kex_launcher() {
    KEX_LAUNCHER=${CHROOT}/usr/bin/kex
    cat > $KEX_LAUNCHER <<- EOF
#!/bin/bash

function start-kex() {
    if [ ! -f ~/.vnc/passwd ]; then
        passwd-kex
    fi
    USR=\$(whoami)
    if [ \$USR == "root" ]; then
        SCREEN=":2"
    else
        SCREEN=":1"
    fi 
    export MOZ_FAKE_NO_SANDBOX=1; export HOME=\${HOME}; export USER=\${USR}; LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgcc_s.so.1 nohup vncserver \$SCREEN >/dev/null 2>&1 </dev/null
    starting_kex=1
    return 0
}

function stop-kex() {
    vncserver -kill :1 | sed s/"Xtigervnc"/"NetHunter KeX"/
    vncserver -kill :2 | sed s/"Xtigervnc"/"NetHunter KeX"/
    return $?
}

function passwd-kex() {
    vncpasswd
    return $?
}

function status-kex() {
    sessions=\$(vncserver -list | sed s/"TigerVNC"/"NetHunter KeX"/)
    if [[ \$sessions == *"590"* ]]; then
        printf "\n\${sessions}\n"
        printf "\n你可以使用KeX客户端来连接这些任意一个画面.\n\n"
    else
        if [ ! -z \$starting_kex ]; then
            printf '\n启动KeX服务器时出现错误.\n请试试"nethunter kex kill"或者重启你的termux并重试.\n\n'
        fi
    fi
    return 0
}

function kill-kex() {
    pkill Xtigervnc
    return \$?
}

case \$1 in
    start)
        start-kex
        ;;
    stop)
        stop-kex
        ;;
    status)
        status-kex
        ;;
    passwd)
        passwd-kex
        ;;
    kill)
        kill-kex
        ;;
    *)
        stop-kex
        start-kex
        status-kex
        ;;
esac
EOF

    chmod 700 $KEX_LAUNCHER
}

function fix_profile_bash() {
    ## Prevent attempt to create links in read only filesystem
    if [ -f ${CHROOT}/root/.bash_profile ]; then
        sed -i '/if/,/fi/d' "${CHROOT}/root/.bash_profile"
    fi
}

function fix_resolv_conf() {
    ## We don't have systemd so let's use static entries for Quad9 DNS servers
    echo "nameserver 9.9.9.9" > $CHROOT/etc/resolv.conf
    echo "nameserver 149.112.112.112" >> $CHROOT/etc/resolv.conf
}

function fix_sudo() {
    ## fix sudo & su on start
    chmod +s $CHROOT/usr/bin/sudo
    chmod +s $CHROOT/usr/bin/su
	echo "kali    ALL=(ALL:ALL) ALL" > $CHROOT/etc/sudoers.d/kali

    # https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    echo "Set disable_coredump false" > $CHROOT/etc/sudo.conf
}

function fix_uid() {
    ## Change kali uid and gid to match that of the termux user
    USRID=$(id -u)
    GRPID=$(id -g)
    nh -r usermod -u $USRID kali 2>/dev/null
    nh -r groupmod -g $GRPID kali 2>/dev/null
}

function print_banner() {
    clear
    printf "${blue}##################################################\n"
    printf "${blue}##                                              ##\n"
    printf "${blue}##  88      a8P         db        88        88  ##\n"
    printf "${blue}##  88    .88'         d88b       88        88  ##\n"
    printf "${blue}##  88   88'          d8''8b      88        88  ##\n"
    printf "${blue}##  88 d88           d8'  '8b     88        88  ##\n"
    printf "${blue}##  8888'88.        d8YaaaaY8b    88        88  ##\n"
    printf "${blue}##  88P   Y8b      d8''''''''8b   88        88  ##\n"
    printf "${blue}##  88     '88.   d8'        '8b  88        88  ##\n"
    printf "${blue}##  88       Y8b d8'          '8b 888888888 88  ##\n"
    printf "${blue}##                                              ##\n"
    printf "${blue}####  ############# NetHunter ####################${reset}\n\n"
    echo "$(tput setaf 1)"翻译及"自动化"来自Github · Bilibili:@ryan_gos"$(tput sgr0)"
    
}


##################################
##              Main            ##

# Add some colours
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
light_cyan='\033[1;96m'
reset='\033[0m'

EXTRA_ARGS=""
if [[ ! -z $1 ]]; then
    EXTRA_ARGS=$1
    if [[ $EXTRA_ARGS != "--no-check-certificate" ]]; then
        EXTRA_ARGS=""
    fi
fi

cd $HOME
print_banner
get_arch
set_strings
prepare_fs
check_dependencies
get_rootfs
get_sha
verify_sha
extract_rootfs
create_launcher
cleanup

printf "\n${blue}[*] 正在为Termux配置Nethunter ...\n"
fix_profile_bash
fix_resolv_conf
fix_sudo
create_kex_launcher
fix_uid

print_banner
printf "${green}[=] Termux版Kali Nethunter安装完成!${reset}\n\n"
printf "${green}[+] 想要启动Nethunter, 输入:${reset}\n"
printf "${green}[+] nethunter             # 启动Nethunter CLI${reset}\n"
printf "${green}[+] nethunter kex passwd  # 设置KeX密码${reset}\n"
printf "${green}[+] nethunter kex &       # 启动Nethunter图形化${reset}\n"
printf "${green}[+] nethunter kex stop    # 停止Nethunter图形化${reset}\n"
#printf "${green}[+] nethunter kex <command> # 在Nethunter执行命令${reset}\n"
printf "${green}[+] nethunter -r          # 以root身份运行nethunter${reset}\n"
#printf "${green}[+] nethunter -r kex passwd  # 为Root用户设定图形化密码${reset}\n"
#printf "${green}[+] nethunter kex &       # 以Root身份启动图形化${reset}\n"
#printf "${green}[+] nethunter kex stop    # 关闭Nethunter图形化${reset}\n"
#printf "${green}[+] nethunter -r kex kill # 停止所有Nethunter图形化${reset}\n"
#printf "${green}[+] nethunter -r kex <command> # 以Root身份在Nethunter执行命令${reset}\n"
printf "${green}[+] nh                    # Nethunter的快捷启动方式${reset}\n\n"

echo "$(tput setaf 1)"接下来请输入您的VNC图形化界面密码,过程中密码不会显示,verify为重新输入密码,后面的y/n为是否设定仅浏览图形化界面密码,无需求输n即可"$(tput sgr0)"
sleep 10
echo "如无法设定密码可输入kex passwd来手动设定或下载tigervnc" && sleep 5
nh -r kex passwd
echo "$(tput setaf 2)"作者:@Offensive Security , @ryan_gos"$(tput sgr0)" && sleep 1
echo "$(tput setaf 2)"交流群:364921039  网站:ryan-gos.us.kg,kali.org"$(tput sgr0)" && sleep 1
echo "$(tput setaf 2)"再见!使用'kex &'来启用图形化界面"$(tput sgr0)" && sleep 3
nh -r apt update
nh -r apt install curl
nh -r bash -c "$(curl -L https://ryan-gos.us.kg/download/aptsrc.sh)"
bash -c "$(curl -L ryan-gos.us.kg/download/logo.sh)"
