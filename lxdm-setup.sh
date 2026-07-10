#!/bin/bash
set -eE

mkdir -p ./mnt/usr/local/bin
cp firstboot-growroot.sh ./mnt/usr/local/bin
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

NEW_USER=$(zenity --entry --title="Initial Setup" --text="新しい一般ユーザー名>>を入力してください:" --width=400)
[ -z "$NEW_USER" ] && reboot

while true; do
    PASS1=$(zenity --password --title="Initial Setup" --text="パスワードを設定>>してください:")
    PASS2=$(zenity --password --title="Initial Setup" --text="もう一度パスワー>>ドを入力してください:")
    if [ "$PASS1" = "$PASS2" ] && [ ! -z "$PASS1" ]; then
        break
    fi
    zenity --error --text="パスワードが一致しないか、空欄です。再入力してくださ
い。"
done

sudo useradd -m -s /bin/bash -G sudo,video,audio "$NEW_USER"
echo "$NEW_USER:$PASS1" | sudo chpasswd

sudo rm -f /etc/xdg/autostart/first-boot-wizard.desktop

sudo sed -i 's/autologin=setupadmin/# autologin=dgod/' /etc/lxdm/lxdm.conf

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
mkdir -p ./mnt/etc/chromium.d/
echo 'export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --enable-features=AcceleratedVideoDecoder,V4l2VideoDecode --disable-features=UseChromeOSDirectVideoDecoder"' > ./mnt/etc/chromium.d/opi5-v4l2
