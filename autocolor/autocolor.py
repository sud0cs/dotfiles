from collections.abc import Iterable
import getpass, os, re
import IMG
from ConfigParser import Parser

class Colors:
    def __init__(self, colors):
        self.BG = colors['bg_color']
        self.ACCENT = colors['accent_color']
        self.FG = colors['text_color']
        self.FG_FOCUS = colors['text_focus']
        self.FG_ACCENT = colors['text_accent']

def main():
    
    USERNAME = getpass.getuser()
    CONF_PATH = f'/home/{USERNAME}/.config/autocolor/cfg.json'
    parser = Parser()
    cfg = parser.parse(CONF_PATH)
    
    CURRENT_WALLPAPER = cfg.WALLPAPER.replace('%username%', USERNAME)

    with open(cfg.AWESOME_THEME.FILE_LOCATION.replace('%username%', USERNAME), 'r') as file:
        data = file.read()
    AWESOME_WALLPAPER = re.search('theme.wallpaper.*= ".*"', data).group()
    AWESOME_WALLPAPER = AWESOME_WALLPAPER[AWESOME_WALLPAPER.find('"')+1:len(AWESOME_WALLPAPER)-1]
    AWESOME_WALLPAPER = AWESOME_WALLPAPER.replace('~', f'/home/{USERNAME}')
    if CURRENT_WALLPAPER == AWESOME_WALLPAPER:
       exit()

    cfg.WALLPAPER = AWESOME_WALLPAPER.replace(USERNAME,'%username%')

    cl = IMG.IMGProcessor()
    colors = cl.get_colors(AWESOME_WALLPAPER, 5, (25,25))
    colors = Colors(colors)

    for i in cfg.getitems():
        if i!='WALLPAPER':
            location = cfg[i].FILE_LOCATION
            if '%username%' in location:
                location = location.replace('%username%', USERNAME)
            if '%firefox_default_profile%' in location:
                for j in os.listdir(location[:location.find('%firefox_default_profile%')]):
                    if 'default-release' in j:
                        location = location.replace('%firefox_default_profile%', j)
            with open(location, 'r') as file:
                data = file.read()
            for j in cfg[i].getitems():
                if j!='FILE_LOCATION':
                    color = getattr(colors, j)
                    regex = cfg[i][j].REGEX
                    if isinstance(regex, str):
                        for r in re.finditer(regex, data):
                            data = data.replace(r.group(), r.group().replace(re.search('#.[0-9A-Fa-f]*',r.group()).group(),color))
                    elif isinstance(regex, list):
                        for _regex in regex:
                            for r in re.finditer(_regex, data):
                                data = data.replace(r.group(), r.group().replace(re.search('#.[0-9A-Fa-f]*',r.group()).group(),color))
            with open(f'{location}', 'w') as file:
                file.write(data)

    cfg.write_to_file(CONF_PATH)
if __name__ == "__main__":
    main()
