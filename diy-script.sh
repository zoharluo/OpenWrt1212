
# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

rm -rf feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
git_sparse_clone main https://github.com/messense/aliyundrive-webdav openwrt/aliyundrive-webdav
git_sparse_clone main https://github.com/messense/aliyundrive-webdav openwrt/luci-app-aliyundrive-webdav

sed -i 's/192.168.1.1/192.168.2.66/g' package/base-files/files/bin/config_generate
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF./$1$MLDxUctt$LSHuSsYcZ4gqkiAYAPCF80/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

./scripts/feeds update -a && ./scripts/feeds install -a
