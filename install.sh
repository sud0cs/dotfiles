#!/bin/bash
git clone https://github.com/allusive-dev/compfy compfy_git
if [ -x "$(command -v apt-get)" ];
then
  sudo apt-get install python3 python3-pip python3-venv kitty neovim neofetch rofi firefox fish lsd bat flameshot wget libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev build-essential unzip cmake libxinerama-dev libxcb-xinerama0-dev libpulse-dev libcxxopts-dev -y
  git clone https://github.com/cdemoulins/pamixer.git
  cd pamixer
  meson setup build
  meson install -C build
  cd ..
  rm -rf pamixer
elif [ -x "$(command -v pacman)" ];
then
  sudo pacman -S python3 python-pip kitty rofi fish lsd bat neovim neofetch firefox pamixer flameshot wget unzip meson ninja cmake libev uthash libconfig --noconfirm
elif [ -x "$(command -v dnf)" ];
then
  sudo dnf install python3 python-pip kitty rofi fish neovim lsd bat neofetch firefox pamixer flameshot wget unzip dbus-devel gcc libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson pcre2-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake -y
fi
firefox &
sleep 5
killall firefox
sudo chsh -s $(which fish) $(whoami)
wget https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
mkdir ~/jdtls
tar -xf jdt-language-server-latest.tar.gz -C ~/jdtls
rm -rf jdt-language-server-latest.tar.gz
wget https://github.com/zigtools/zls/releases/download/0.11.0/zls-x86-linux.tar.gz
mkdir zls
tar -xf zls-x86-linux.tar.gz -C zls
sudo mv zls/bin/zls /bin/zls
rm -rf zls zls*
cd compfy_git
meson setup . build
ninja -C build install
cd ..
rm -rf compfy_git
mkdir -p ~/.local/share/fonts
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip"
unzip -o Meslo.zip -d ~/.local/share/fonts/
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Arimo.zip"
unzip -o Arimo.zip -d ~/.local/share/fonts/
rm -rf Arimo.zip
rm -rf Meslo.zip
cp -r awesome ~/.config/
cp -r kitty ~/.config/
cp -r rofi ~/.config/
cp -r autocolor ~/.config/
cp -r .wallpapers ~
cp -r firefox/homepage ~
cp -r firefox/chrome ~/.mozilla/firefox/*.default-release/
cp -r compfy ~/.config/
cp -r nvim ~/.config/
cp -r fish ~/.config/
cp -r neofetch ~/.config/
cd ~/.config/autocolor
python3 -m venv venv
source venv/bin/activate
pip3 install opencv-python scikit-learn
