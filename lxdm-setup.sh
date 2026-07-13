#!/bin/bash
set -eE

mkdir -p ./mnt/usr/local/bin
cp ./firstboot-growroot.sh ./mnt/usr/local/bin
chmod +x ./mnt/usr/local/bin/firstboot-growroot.sh

sed -i 's/# autologin=dgod/autologin=setupadmin/' ./mnt/etc/lxdm/lxdm.conf

# ② 自動起動ファイルの配置（XDG Autostart）
mkdir -p ./mnt/etc/xdg/autostart
cat << 'EOF' > ./mnt/etc/xdg/autostart/first-boot-wizard.desktop
[Desktop Entry]
Type=Application
Name=First Boot Wizard
Exec=/usr/local/bin/gui-wizard.sh
Terminal=false
X-GNOME-Autostart-enabled=true
EOF


# ③ ウィザードスクリプトの配置
cat << 'EOF' > ./mnt/usr/local/bin/gui-wizard.sh
#!/bin/bash

NEW_USER=$(zenity --entry --title="Initial Setup" --text="新しい一般ユーザー名を入力してください:" --width=400)
[ -z "$NEW_USER" ] && reboot

while true; do
    PASS1=$(zenity --password --title="Initial Setup" --text="パスワードを設定してください:")
    PASS2=$(zenity --password --title="Initial Setup" --text="もう一度パスワードを入力してください:")
    if [ "$PASS1" = "$PASS2" ] && [ ! -z "$PASS1" ]; then
        break
    fi
    zenity --error --text="パスワードが一致しないか、空欄です。再入力してくださ
い。"
done

sudo useradd -m -s /bin/bash -G wheel,video,users "$NEW_USER"
echo "$NEW_USER:$PASS1" | sudo chpasswd

# /etc/mkinitcpio.confをオリジナルに戻してmkinitcpioを実行
sudo rm -f /etc/xdg/autostart/first-boot-wizard.desktop

# 確実に対象ファイルが存在するかチェック（絶対パス）
if [ -f "/etc/mkinitcpio.conf.org" ]; then
    # オリジナル設定を復元して一時ファイルを削除
    sudo cp /etc/mkinitcpio.conf.org /etc/mkinitcpio.conf
    sudo rm -f /etc/mkinitcpio.conf.org

    # 実機(Orange Pi 5 Plus)環境に合わせた autodetect 有りの爆速 initramfs を再生成
    # ※zenityを別プロセスにせず、出力をそのまま流し込むか、一度ログに吐くと確実です
    (
        echo "# 復元された設定で initramfs を再構築中..."
        echo "# これにより、実機(Orange Pi 5)に最適化された爆速ブートが有効になります。"
        sudo mkinitcpio -P 2>&1
        
        # --- ここから検証用に追加 ---
        echo ""
        echo "# ========================================"
        echo "# 【検証】再構築後の initramfs 内のドライバー一覧"
        echo "# （不要なストレージドライバーが消えていれば最適化成功です）"
        echo "# ========================================"
        # 仕込み時の項目（ahci sd_mod nvme mmc_block ext4）をすべて網羅
        lsinitcpio /boot/initramfs-linux.img | grep -E "ahci|sd_mod|nvme|mmc_block|ext4" 2>&1 || true
        echo "# ========================================"
        # ----------------------------

        echo "# 再構築が完了しました！"
    ) | zenity --text-info \
        --title="システム最適化中 (mkinitcpio)" \
        --width=600 \
        --height=400 \
        --auto-scroll
fi

sudo sed -i 's/autologin=setupadmin/# autologin=dgod/' /etc/lxdm/lxdm.conf
sudo rm /etc/sudoers.d/setupadmin

zenity --info --text="設定が完了しました。システムを再起動します。" --width=300
sudo reboot
EOF

# 実行権限を付与
chmod +x ./mnt/usr/local/bin/gui-wizard.sh

# 3. systemd サービスファイルの作成
cat << EOF4 > ./mnt/etc/systemd/system/firstboot-growroot.service
[Unit]
Description=First Boot Root Partition Resizer
After=local-fs.target
Before=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/firstboot-growroot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF4

# chromium
mkdir -p ./mnt/etc/chromium
echo 'CHROMIUM_FLAGS="--enable-features=AcceleratedVideoDecoder,V4l2VideoDecode --disable-features=UseChromeOSDirectVideoDecoder"' > ./mnt/etc/chromium/default
