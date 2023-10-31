from PIL import Image
import getpass
import re
import math

class palette:
    colors = {}
    color = [0,0,0]
    def __init__(self, img: str):
        self.img_name = img
        self.img = Image.open(self.img_name).convert('RGBA')
        self.color = [0,0,0]
        for i in self.img.getdata():
            #try:
             #   self.colors[i]+=1
            #except:
             #   self.colors[i] = 1
            if i[3] != 0:
                for j in range(len(self.color)):
                    self.color[j] = self.color[j] + i[j]
        for i in range(len(self.color)):
            self.color[i] = math.floor(self.color[i]/len(self.img.getdata()))
        #self.colors = sorted(self.colors.items(), reverse=True, key=lambda x: x[1])
    def getMainColor(self):
        #return self.colors[0][0]
        return self.color

def get_luminance(tpl : tuple):
    r,g,b = tpl
    return math.sqrt( 0.299*r**2 + 0.587*g**2 + 0.114*b**2 )

def color_to_hex(tpl : tuple):
    rgb = list(tpl)
    for i in range(len(rgb)):
        rgb[i] = str(hex(rgb[i])).replace('0x','')
        if len(rgb[i]) == 1:
            rgb[i] = "0"+rgb[i]
    return f'#{rgb[0]}{rgb[1]}{rgb[2]}'
def main():

    USERNAME = getpass.getuser()
    AWESOME_CONFIG_FILE = f'/home/{USERNAME}/.config/awesome/rc.lua'
    AWESOME_THEME_FILE = f'/home/{USERNAME}/.config/awesome/default/theme.lua'
    KITTY_THEME_FILE = f'/home/{USERNAME}/.config/kitty/current-theme.conf'
    ROFI_THEME_FILE = f'/home/{USERNAME}/.config/rofi/theme.rasi'
    FIREFOX_UI_THEME_FILE = f'/home/{USERNAME}/.mozilla/firefox/85b8jlk4.default-release/chrome/userChrome.css'
    FIREFOX_HOME_THEME_FILE = f'/home/{USERNAME}/homepage/style.css'

    with open(AWESOME_THEME_FILE, 'r') as file:
        data = file.read()
    IMAGE = re.search('theme.wallpaper.*= ".*"', data).group()
    IMAGE = IMAGE[IMAGE.find('"')+1:len(IMAGE)-1]
    IMAGE.replace('~', f'/home/{USERNAME}')
    main_color = palette(IMAGE).getMainColor()
    main_color_luminance = get_luminance(main_color)
    main_color = list(main_color)
    color_boost = max(main_color)
    color_dim = min(main_color)
    print(main_color)
    print(main_color_luminance)
    luminance_diff = 128-main_color_luminance
    if luminance_diff<0:
        luminance_diff = luminance_diff*-1
    luminance_boost = math.floor(luminance_diff*0.3)
    accent_color = [0,0,0]

    kitty_color = [0,0,0]
    #luminance_boost = math.floor(main_color_luminance)
    if main_color_luminance > 128:
        text_color = (26,26,26)
        text_focus = (10,10,10)
        for i in range(len(main_color)):
            kitty_color[i] = math.floor(main_color[i]*0.8)
            accent_color[i] = 225 - main_color[i]
            if main_color[i] == color_dim:
                accent_color[i] += - (accent_color[i] - color_dim)
            accent_color[i] = main_color[i] - math.floor(accent_color[i]*0.2)
            accent_color[i] = math.floor(accent_color[i]*0.8)
            print(main_color[i], accent_color[i])
            if main_color[i] == color_boost:
                main_color[i]+=math.floor(luminance_boost*1.1)
            else:
                main_color[i]+=luminance_boost
            if main_color[i]>255:
                main_color[i] = 255
    else:
        text_color = (206,212,223)
        text_focus = (255,255,255)
        kitty_color = main_color
        for i in range(len(main_color)):
            accent_color[i] = main_color[i]
            kitty_color[i] = math.floor(main_color[i]*0.8)
            if accent_color[i] == color_boost:
                accent_color[i] += accent_color[i] - color_dim
            accent_color[i] = accent_color[i] + math.floor(accent_color[i]*0.2)
            print(main_color[i], accent_color[i])
            if main_color[i] == color_boost:
                main_color[i]+=math.floor(luminance_boost*.9)*-1
            else:
                main_color[i]+=luminance_boost*-1
            if main_color[i]<0:
                main_color[i] = 0

    main_color = color_to_hex(tuple(main_color))
    accent_color = color_to_hex(tuple(accent_color))
    kitty_color = color_to_hex(tuple(kitty_color))
    text_color = color_to_hex(text_color)
    text_focus = color_to_hex(text_focus)
    print(kitty_color)


    fg = re.search('theme.fg_normal.*= ".*"', data).group()
    fg_focus = re.search('theme.fg_focus.*= ".*"', data).group()
    bg = re.search('theme.bg_normal.*= ".*"', data).group()
    data = data.replace(fg, f'theme.fg_normal = "{text_color}"')
    data = data.replace(fg_focus, f'theme.fg_focus = "{text_focus}"')
    data = data.replace(bg, f'theme.bg_normal = "{main_color}"')
    with open(AWESOME_THEME_FILE, 'w') as file:
        file.write(data)

    #with open(AWESOME_CONFIG_FILE, 'r') as file:
    #    data = file.read()
    #bg = re.search('local bg_color = ".*"', data).group()
    #data = data.replace(bg, f'local bg_color = "{main_color}"')

   # with open(AWESOME_CONFIG_FILE, 'w') as file:
   #     file.write(data)
    
    with open(KITTY_THEME_FILE, 'r') as file:
        data = file.read()
    fg_kitty = re.search('foreground.*#.*', data).group()
    bg_kitty = re.search('background.*#.*', data).group()
    data = data.replace(fg_kitty, f'foreground {text_color}')
    print(kitty_color)
    data = data.replace(bg_kitty, f'background {kitty_color}')
    with open(KITTY_THEME_FILE, 'w') as file:
        file.write(data)


    with open(ROFI_THEME_FILE, 'r') as file:
        data = file.read()

    rofi_bg = re.search('bg:.*#.*;', data).group()
    rofi_fg = re.search('fg:.*#.*;', data).group()
    rofi_accent = re.search('accent:.*#.*;', data).group()

    data = data.replace(rofi_bg, f'bg: {main_color};')
    data = data.replace(rofi_fg, f'fg: {text_color};')
    data = data.replace(rofi_accent, f'accent: {accent_color};')

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
