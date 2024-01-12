import getpass
import re, os, json
import IMG
def main():
    with open('cfg.json', 'a+') as cfg_file:
        try:
            cfg = json.loads(cfg_file.read())
            CURRENT_WALLPAPER = cfg['wallpaper']
        except:
            CURRENT_WALLPAPER = ''
    USERNAME = getpass.getuser()
    AWESOME_CONFIG_FILE = f'/home/{USERNAME}/.config/awesome/rc.lua'
    AWESOME_THEME_FILE = f'/home/{USERNAME}/.config/awesome/default/theme.lua'
    KITTY_THEME_FILE = f'/home/{USERNAME}/.config/kitty/current-theme.conf'
    ROFI_THEME_FILE = f'/home/{USERNAME}/.config/rofi/theme.rasi'
    FIREFOX_UI_THEME_FILE = f'/home/{USERNAME}/.mozilla/firefox/'
    FIREFOX_HOME_THEME_FILE = f'/home/{USERNAME}/homepage/style.css'

    for i in os.listdir(FIREFOX_UI_THEME_FILE):
        if 'default-release' in i:
            FIREFOX_UI_THEME_FILE+=f'{i}/chrome/userChrome.css'
            break

    with open(AWESOME_THEME_FILE, 'r') as file:
        data = file.read()
    IMAGE = re.search('theme.wallpaper.*= ".*"', data).group()
    IMAGE = IMAGE[IMAGE.find('"')+1:len(IMAGE)-1]
    IMAGE = IMAGE.replace('~', f'/home/{USERNAME}')
    if CURRENT_WALLPAPER == IMAGE:
        exit()
    else:
        with open('cfg.json','w') as cfg_file:
            cfg_file.write(json.dumps({'wallpaper':IMAGE}))
        cl = IMG.IMGProcessor()
    colors = cl.get_colors(IMAGE, 5, (20,20))
    main_color = colors['bg_color']
    accent_color = colors['accent_color']
    text_color = colors['text_color']
    text_focus = colors['text_focus']
    text_accent = colors['text_accent']

    fg = re.search('theme.fg_normal.*= ".*"', data).group()
    fg_focus = re.search('theme.fg_focus.*= ".*"', data).group()
    bg = re.search('theme.bg_normal.*= ".*"', data).group()
    data = data.replace(fg, f'theme.fg_normal = "{text_color}"')
    data = data.replace(fg_focus, f'theme.fg_focus = "{text_focus}"')
    data = data.replace(bg, f'theme.bg_normal = "{main_color}"')
    with open(AWESOME_THEME_FILE, 'w') as file:
        file.write(data)

    with open(AWESOME_CONFIG_FILE, 'r') as file:
        data = file.read()
    bg = re.search('local bg_color = ".*"', data).group()
    data = data.replace(bg, f'local bg_color = "{main_color}"')

    with open(AWESOME_CONFIG_FILE, 'w') as file:
        file.write(data)
    
    with open(KITTY_THEME_FILE, 'r') as file:
        data = file.read()
    fg_kitty = re.search('foreground.*#.*', data).group()
    bg_kitty = re.search('background.*#.*', data).group()
    data = data.replace(fg_kitty, f'foreground {text_color}')
    data = data.replace(bg_kitty, f'background {main_color}')
    with open(KITTY_THEME_FILE, 'w') as file:
        file.write(data)


    with open(ROFI_THEME_FILE, 'r') as file:
        data = file.read()

    rofi_bg = re.search('bg:.*#.*;', data).group()
    rofi_fg = re.search('fg:.*#.*;', data).group()
    rofi_accent = re.search('accent:.*#.*;', data).group()
    rofi_fg_focus = re.search('fg-focus:.*#.*;', data).group()

    data = data.replace(rofi_bg, f'bg: {main_color};')
    data = data.replace(rofi_fg, f'fg: {text_color};')
    data = data.replace(rofi_accent, f'accent: {accent_color};')
    data = data.replace(rofi_fg_focus, f'fg-focus: {text_accent};')

    with open(ROFI_THEME_FILE, 'w') as file:
        file.write(data)

    with open(FIREFOX_UI_THEME_FILE, 'r') as file:
        data = file.read()

    firefox_bg = re.search('--bg:.*#.*;', data).group()
    firefox_accent = re.search('--accent:.*#.*;', data).group()
    firefox_font_color = re.search('--font-color:.*#.*;', data).group()

    data = data.replace(firefox_bg, f'--bg: {main_color};')
    data = data.replace(firefox_accent, f'--accent: {accent_color};')
    data = data.replace(firefox_font_color, f'--font-color: {text_color};')

    with open(FIREFOX_UI_THEME_FILE, 'w') as file:
        file.write(data)

    with open(FIREFOX_HOME_THEME_FILE, 'r') as file:
        data = file.read()

    home_bg = re.search('--bg:.*#.*;', data).group()
    home_accent = re.search('--accent:.*#.*;', data).group()
    home_font_color = re.search('--font-color:.*#.*;', data).group()

    data = data.replace(home_bg, f'--bg: {main_color};')
    data = data.replace(home_accent, f'--accent: {accent_color};')
    data = data.replace(home_font_color, f'--font-color: {text_color};')

    with open(FIREFOX_HOME_THEME_FILE, 'w') as file:
        file.write(data)
if __name__ == "__main__":
    main()
