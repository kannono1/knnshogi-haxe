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
    public function toString(){
        return 'from: $from to: $to'
        // + Util.fileToString( Util.sqToFile(this.from) )
        // + Util.sqToRow(this.from)
        // + Util.fileToString( Util.sqToFile(this.to) )
        // + Util.sqToRow(this.to)
        ;
    }
}