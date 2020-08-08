1. 读取所preferencebundle-->PSSpecifier
2. 按字符顺序sort
3. 把tweak 插入到第2组
4. 设定固定size的icon


libprefs.xm
prefs.h
用于适配Choicy

Choicy调用了旧版preferenceloader里的[PSSpecifier preferenceLoaderBundle]