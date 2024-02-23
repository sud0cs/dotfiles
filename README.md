# Dotfiles

🎨 Change colors automatically based on the wallpaper!

👨‍💻 Actively mantained

🚩 Feel free to report any issue or features you want implemented


![preview](./resources/preview.png "Preview")

## TODO
- Finish quick menu
- Fix some rc.lua stuff
- Install script
## Installation
### Dependencies
In order to use this dotfiles you will need to install the following dependencies:
- `awesomewm`
- `MesloLGS Nerd Font` and `Arimo Nerd Font`. You can find all Nerd Fonts [here](https://www.nerdfonts.com/)
- `python3` and `python-pip`
- `kitty`
- `rofi`
- `firefox`
- [`compfy`](https://github.com/allusive-dev/compfy)
- [`pamixer`](https://github.com/cdemoulins/pamixer)
- `flameshot`

<b>Assuming AwesomeWM is already installed</b>

### Arch, Debian, Fedora and derivates

```bash
git clone https://github.com/sud0cs/dotfiles
cd dotfiles
./install.sh
```
### Others

Once all the dependencies have been installed, clone the repository

```bash
git clone https://github.com/sud0cs/dotfiles
```
Now lets copy the files to their corresponding location. <b> Remember to backup your config before!</b>

```bash
cp -r dotfiles/awesome ~/.config/
cp -r dotfiles/kitty ~/.config/
cp -r dotfiles/rofi ~/.config/
cp -r dotfiles/autocolor ~/.config/
cp -r dotfiles/.wallpapers ~
cp -r dotfiles/firefox/homepage ~
cp -r dotfiles/firefox/chrome ~/.mozilla/firefox/*.default-release/
cp -r dotfiles/compfy/compfy.conf ~/.config/
```

We need to create a virtual environment to run the python code:

```bash
cd ~/.config/autocolor && \
python3 -m venv venv && \
source venv/bin/activate && \
pip install opencv-python scikit-learn
```

To set up the firefox first go to about:config, search `toolkit.legacyUserProfileCustomizations.stylesheets` and double-click it until its value is <b>true</b>. Then go to about:preferences#home and set the startup page to the custom URL `file:///home/{yourusername}/homepage/index.html`

## Keybindings
List of keybindings which differ from the default.
|keybinding|description|
|---|---|
|`mod`+`Space`|run rofi|
|`mod`+`Escape`|show/hide quick menu|
|`mod`+`Shift`+`q`|close window|
|`mod`+`Tab`|select next workspace|
|`mod`+`Shift`+`Tab`|select previous workspace|
|`mod`+`shift`+`s`|take screenshot with flameshot|
