#修改默认IP
sed -i 's/192.168.1.1/192.168.2.66/g' package/base-files/files/bin/config_generate
#修改root登录默认密码
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF./$1$MLDxUctt$LSHuSsYcZ4gqkiAYAPCF80/g' package/lean/default-settings/files/zzz-default-settings

#添加额外仓库
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

#更新feed，删除部分不兼容插件
./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang



#稀疏克隆
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

#添加自定义插件
#监控插件
rm -rf feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
#在线用户
rm rm -rf feeds/luci/applications/luci-app-onliner
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh
#关机
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
#安装插件
./scripts/feeds install -a 

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 取消主题默认设置
#find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 修改 Makefile，使其适应luci的标准化，例如中文语言的翻译
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}

#自定义修改插件配置
#samba4，修改菜单显示位置为nas
sed -i 's|"admin/services/samba4"|"admin/nas/samba4"|g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
#调整ttyd到system菜单
sed -i 's|"admin/services/ttyd/ttyd"|"admin/system/ttyd/ttyd"|g; s|"admin/services/ttyd/config"|"admin/system/ttyd/config"|g; s|"admin/services/ttyd"|"admin/system/ttyd"|g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
#修改NetData为实时监控
sed -i 's/_("NetData")/_("实时监控")/' package/luci-app-netdata/luasrc/controller/netdata.lua
#修改Online User为在线用户
sed -i 's/_("Online User")/_("在线用户")/' package/luci-app-onliner/luasrc/controller/onliner.lua
#修改poweroff中文显示
sed -i 's/_("PowerOff")/_("关机")/' package/luci-app-poweroff/luasrc/controller/poweroff.lua
