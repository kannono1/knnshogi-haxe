package;

import Types.Move;
import haxe.ds.Vector;

class DebugInfo{
    public static inline var targetNode:Int = 9573;
    public static var moves:Vector<Move> = new Vector<Move>(99);
    public static var colors:Vector<Int> = new Vector<Int>(99);
    public static var inChecks:Vector<Bool> = new Vector<Bool>(99);
    public static var nodes:Vector<Int> = new Vector<Int>(99);// Depthごとのnodes番号
    public static var qmoves:Vector<Move> = new Vector<Move>(99);
    public static var qcolors:Vector<Int> = new Vector<Int>(99);
    public static var inQChecks:Vector<Bool> = new Vector<Bool>(99);
    public static var qnodes:Vector<Int> = new Vector<Int>(99);// Depthごとのnodes番号
    public static var depth:Int = 0;
    public static var qdepth:Int = 0;
    public static var startDepth:Int = 0;
    public static var lastMove:Move;
    public static var lastQMove:Move;

    public function new(){}

    public static function print() {
        trace('DebugInfo::print >>>');
        for(i in 0...Types.MAX_PLY){
            trace('moves depth:${i} c:${colors[i]} n:${nodes[i]} ${Types.Move_To_StringLong(moves[i])} inCheck:${inChecks[i]}');
        }
        for(i in 0...10){
            trace('qmoves depth:${i} c:${qcolors[i]} n:${qnodes[i]} ${Types.Move_To_StringLong(qmoves[i])} inCheck:${inQChecks[i]}');
        }
        trace('DebugInfo::print <<<');
    }
}