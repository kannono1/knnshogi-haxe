# knnshogi-haxe

knnshogi-haxeは[やねうらおう](https://github.com/yaneurao/YaneuraOu)と[StockfishAS3](http://www.chessgym.net/res_sf.php)を参考にHaxeで実装されたブラウザ上で動作するハム将棋くらいの棋力を目指すプロジェクトです。


## Demo
https://kannono1.github.io/knnshogi-haxe/

<a href="https://kannono1.github.io/knnshogi-haxe/"><img width="354" alt="knnshogi" src="https://user-images.githubusercontent.com/1817669/101229006-8ad9c080-36e1-11eb-8262-84e710bef657.png"></a>

##
- Haxe 4.1.4
- VSCode

## Build
```
./vscode/tasks.json

Shift - Cmd - B
> all

close
Ctrl - `


> Engine.js
> Main.js
```

## Dev Server
```
python3 -m http.server 8088

>> http://localhost:8088/
```

## Test
```
haxe -js Test.js -main Test -D js-es=6
node Test.js
```



