#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
function git_sparse_clone() {
  branch="$1" rurl="$2" localdir="$3" && shift 3
  #git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
  git clone -b $branch --single-branch --no-tags --depth 1 --filter=blob:none --no-checkout $rurl $localdir
  cd $localdir
  #git sparse-checkout init --cone
  #git sparse-checkout set $@
  git checkout $branch -- $@
  mv -n $@ ../
  cd ..
  rm -rf $localdir
  }
#####自定义设置#####
#1. 修改默认IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate

#2. web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#3.固件版本号添加个人标识和日期
#sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='FICHEN(\$\(TZ=UTC-8 date +%Y-%m-%d\))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings

#4.编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d-%H%M")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#5.更换lede源码中自带argon主题和design主题
rm -rf feeds/luci/themes/luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-design && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-theme-design && mv -n luci-theme-design feeds/luci/themes/luci-theme-design
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-design-config && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-design-config && mv -n luci-theme-design feeds/luci/applications/luci-app-design-config

#7.修改主机名
#sed -i "s/hostname='OpenWrt'/hostname='phicomm-N1'/g" package/base-files/files/bin/config_generate

# 晶晨宝盒
#sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/breakings/OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|http.*/library|https://github.com/breakings/OpenWrt/opt/kernel|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|s9xxx_lede|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakings/OpenWrt/releases/tag/kernel_stable|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakings/OpenWrt/releases/tag/kernel_stable|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

#####修改应用位置######
# luci-app-openvpn
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/controller/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/model/cbi/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/view/openvpn/pageswitch.htm

#luci-app-frpc
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frpc/luasrc/controller/frp.lua
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frpc/luasrc/model/cbi/frp/basic.lua
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frpc/luasrc/model/cbi/frp/config.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-frpc/luasrc/view/frp/frp_status.htm

#luci-app-frps
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frps/luasrc/controller/frps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-frps/luasrc/view/frps/frps_status.htm

#nps（修改nps源为yisier）
rm -rf feeds/packages/net/nps
cp -rf $GITHUB_WORKSPACE/backup/nps feeds/packages/net
#sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/yisier\/nps\/tar.gz\/v$(PKG_VERSION)?/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.26.18/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=29da044262071a1fa53ce7169c6427ee4f12fc0ada60ef7fb52fabfd165afe91/g' feeds/packages/net/nps/Makefile
#luci-app-nps（修改nps显示位置）
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-nps/luasrc/controller/nps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-nps/luasrc/view/nps/nps_status.htm
#luci-app-nps（修改nps服务器允许域名）
sed -i 's/^server.datatype = "ipaddr"/--server.datatype = "ipaddr"/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's/必须是 IPv4 地址/IPv4 地址或域名/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po

#####design主题导航栏设置######
#sed -i 's/shadowsocksr/openclash/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/luci/themes/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/ssr.png/openclash.png/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm

#取消编译libnetwork，防止出现冲突：
# * check_data_file_clashes: Package libnetwork wants to install file /workdir/openwrt/build_dir/target-aarch64_generic_musl/root-armvirt/usr/bin/docker-proxy
#         But that file is already provided by package  * dockerd 
# * opkg_install_cmd: Cannot install package libnetwork.
sed -i 's|CONFIG_PACKAGE_libnetwork=y|# CONFIG_PACKAGE_libnetwork is not set|g' .config


#luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-serverchan
#cp -af feeds/fichenx/luci-app-serverchan feeds/luci/applications/luci-app-serverchan
git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush feeds/luci/applications/luci-app-serverchan

#luci-app-bypass
#git_sparse_clone master "https://github.com/kiddin9/openwrt-packages" "kiddin9" luci-app-bypass && mv -n luci-app-bypass package/luci-app-bypass
git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-bypass && mv -n luci-app-bypass package/luci-app-bypass

#luci-app-npc
git_sparse_clone master "https://github.com/Hyy2001X/AutoBuild-Packages" "Hyy2001X" luci-app-npc && mv -n luci-app-npc package/luci-app-npc

#使用官方最新samba4
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=4.19.4/g' feeds/packages/net/samba4/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=4026d93b866db198c8ca1685b0f5d52793f65c6e63cb364163af661fdff0968c/g' feeds/packages/net/samba4/Makefile
rm -rf feeds/packages/net/samba4
rm -rf feeds/packages/lang/perl
git_sparse_clone master https://github.com/openwrt/packages temp net/samba4 && mv -n samba4 feeds/packages/net/samba4
git_sparse_clone master https://github.com/openwrt/packages temp lang/perl && mv -n perl feeds/packages/lang/perl

#更换msd_lite为最新版（immortalwrt源）
rm -rf feeds/packages/net/msd_lite
git_sparse_clone master https://github.com/immortalwrt/packages immortalwrt net/msd_lite && mv -n msd_lite feeds/packages/net/msd_lite

#修改默认主题
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/fichenx/luci-theme-opentomcat/files/30_luci-theme-opentomcat
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' package/luci-theme-opentomcat/files/30_luci-theme-opentomcat
sed -i 's|luci-theme-bootstrap|luci-theme-design|g' feeds/luci/collections/luci/Makefile

#还原golang版本为1.20
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/coolsnowwolf/packages/trunk/lang/golang feeds/packages/lang/golang

# 替换自带watchcat为https://github.com/gngpp/luci-app-watchcat-plus
rm -rf feeds/packages/utils/watchcat
git_sparse_clone master "https://github.com/openwrt/packages" "temp" utils/watchcat && mv -n watchcat feeds/packages/utils/watchcat
git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-watchcat-plus && mv -n luci-app-watchcat-plus package/luci-app-watchcat-plus

#删除lede自带uwsgi
rm -rf feeds/packages/net/uwsgi
git_sparse_clone openwrt-23.05 "https://github.com/openwrt/packages" "22packages" net/uwsgi && mv -n uwsgi feeds/packages/net/uwsgi

#更换miniupnpd为最新版（immortalwrt源）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/miniupnpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_sparse_clone master https://github.com/immortalwrt/packages immortalwrt net/miniupnpd && mv -n miniupnpd feeds/packages/net/miniupnpd

#替换luci-app-socat为https://github.com/chenmozhijin/luci-app-socat
rm -rf feeds/luci/applications/luci-app-socat
git_sparse_clone main "https://github.com/chenmozhijin/luci-app-socat" "temp" luci-app-socat && mv -n luci-app-socat package/luci-app-socat

#禁用nginx，启用uhttpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/nginx disable' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/nginx stop' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/uhttpd enable' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/uhttpd start' package/lean/default-settings/files/zzz-default-settings
