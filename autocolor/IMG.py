import cv2
from sklearn.cluster import KMeans
import itertools
import numpy as np
class IMGProcessor():
    TEXT_DARK = '#030119'
    TEXT_DARK_FOCUS = '#141221'
    TEXT_LIGHT = '#eeedf4'
    TEXT_LIGHT_FOCUS = '#d4d2e0'

    def _cluster_img(self, path, clusters = 3, shape=(20,20)):
        img = cv2.imread(path)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, shape)
        img_reshaped = img.reshape(-1,3)
        kmeans = KMeans(n_clusters=clusters, n_init=100)
        kmeans.fit(img_reshaped)
        _, count = np.unique(kmeans.labels_, return_counts=True)
        return (kmeans.cluster_centers_, count)

    def luma(self, rgb):
        return rgb[0]*0.2126+rgb[1]*0.7152+rgb[2]*0.0722

    def rgb2hex(self, rgb):
        _hex = '#'
        for i in rgb:
            n=str(hex(int(i))).replace('0x','')
            _hex += n if len(n) == 2 else f'0{n}' 
        return _hex

    def maxrgbdistance(self, rgb):
        _comb = [i for i in itertools.combinations(rgb, 2)]
        _comb = [sorted(i, reverse=True) for i in _comb]
        distance = int(max([_comb[i][0]-_comb[i][1] for i in range(len(_comb))]))
        return distance

    def get_colors(self, path, clusters = 3, shape = (20,20)):
        colors, count = self._cluster_img(path, clusters, shape)
        luma = np.array([self.luma(i) for i in colors])
        luma_mean = luma.mean()
        bg_color = colors[np.where(count==max(count))[0][0]]
        colors = np.delete(colors, np.where(colors==bg_color)[0][0],0)
        colors = colors.reshape(clusters-1,3)
        print(colors)
        rgbdist = np.array([self.maxrgbdistance(i) for i in colors])
        accent_color = colors[np.where(rgbdist==max(rgbdist))[0][0]]
        text_color = self.TEXT_DARK if self.luma(bg_color)>125 else self.TEXT_LIGHT
        text_focus = self.TEXT_DARK_FOCUS if text_color == self.TEXT_DARK else self.TEXT_LIGHT_FOCUS
        text_accent = self.TEXT_DARK if self.luma(accent_color)>125 else self.TEXT_LIGHT
        colors_dict = {
            'bg_color': self.rgb2hex(bg_color),
            'accent_color': self.rgb2hex(accent_color),
            'text_color': text_color,
            'text_focus': text_focus,
            'text_accent': text_accent
        }
        print(colors_dict)

        return colors_dict
