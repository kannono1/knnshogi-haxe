# knnshogi-haxe

knnshogi-haxeは[やねうらおう](https://github.com/yaneurao/YaneuraOu)と[StockfishAS3](http://www.chessgym.net/res_sf.php)を参考にHaxeで実装されたブラウザ上で動作するハム将棋くらいの棋力を目指すプロジェクトです。


# 
- Haxe 4.1.4
- VSCode

# Build
```
./vscode/tasks.json

Shift - Cmd - B
> all

close
Ctrl - `


> Engine.js
> Main.js
```

# Dev Server
```
python3 -m http.server 8088
```

# Test
```
haxe -js Test.js -main Test -D js-es=6
node Test.js
```

http://localhost:8088/

https://kannono1.github.io/knnshogi-haxe/
