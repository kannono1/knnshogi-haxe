package;

import Types.Move;
import haxe.ds.Vector;

class DebugInfo{
    public static var moves:Vector<Move> = new Vector<Move>(99);
    public static var qmoves:Vector<Move> = new Vector<Move>(99);
    public static var inChecks:Vector<Bool> = new Vector<Bool>(99);
    public static var inQChecks:Vector<Bool> = new Vector<Bool>(99);
    public static var nodes:Vector<Int> = new Vector<Int>(99);// Depthごとのnodes番号
    public static var depth:Int = 0;
    public static var qdepth:Int = 0;
    public static var lastMove:Move;
    public static var lastQMove:Move;

    public function new(){}
}