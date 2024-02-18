#!/bin/bash
if [ -x "$(command -v apt-get)" ];
then
  sudo apt-get install python3 python3-pip kitty rofi firefox flameshot wget libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev unzip
  git clone https://github.com/allusive-dev/compfy
  cd compfy
  meson setup . build
  ninja -C build install
  cd ..
  rm -rf compfy
  git clone https://github.com/cdemoulins/pamixer.git
  cd pamixer
  meson setup build
  meson install -C build
  cd ..
  rm -rf pamixer
  mkdir -p ~/.local/share/fonts
  wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip"
  unzip -q Meslo.zip -d ~/.local/share/fonts/
  wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Arimo.zip"
  unzip -q Arimo.zip -d ~/.local/share/fonts/
  rm -rf Arimo.zip
  rm -rf Meslo.zip
elif [ -x "$(command -v pacman)" ];
then
  sudo pacman -S python3 python-pip kitty rofi firefox pamixer flameshot
elif [ -x "$(command -v dnf)" ];
then
  echo "dnf"
fi
cp -r dotfiles/awesome ~/.config/ && \
cp -r dotfiles/kitty ~/.config/ && \
cp -r dotfiles/rofi ~/.config/ && \
cp -r dotfiles/autocolor ~/.config/ && \
cp -r dotfiles/.wallpapers ~
cp -r dotfiles/firefox/homepage ~ && \
cp -r dotfiles/firefox/chrome ~/.mozilla/firefox/*.default-release/ && \
sudo cp -r dotfiles/picom/picom.conf /etc/xdg/
cd ~/.config/autocolor && \
python3 -m venv venv && \
source venv/bin/activate && \
pip3 install opencv-python scikit-learn
