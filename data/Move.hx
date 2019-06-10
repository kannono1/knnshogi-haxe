package data;

class Move {
    public var from = 0;
    public var to = 0;

    public function new(){
    }
    static public function generateMove(from:Int, to:Int):Move {
        var m = new Move();
        m.from = from;
        m.to = to;
        return m;
    }
    static public function generateMoveFromString(ft:String):Move {
        trace('gene s: $ft');
        var m = new Move();
        var f:Int = Std.parseInt(ft.substr(0, 1)) -1;
        var r:Int = ft.charCodeAt(1) -97;
        m.from = Types.Square(f, r);
        trace('gene1 f: $f, r: $r from: ${m.from}');
        f = Std.parseInt(ft.substr(2, 1)) -1;
        r = ft.charCodeAt(3) -97;
        m.to = Types.Square(f, r);
        trace('gene2 f: $f, r: $r to: ${m.to}');
        return m;
    }
    public function toString():String {
        return ''
        + Types.FileString_Of(from)
        + Types.RankString_Of(from)
        + Types.FileString_Of(to)
        + Types.RankString_Of(to)
        ;
    }
}