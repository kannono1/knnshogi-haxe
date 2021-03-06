package;

import Types.Move;
import haxe.ds.Vector;

class DebugInfo{
    public static inline var targetNode:Int = 9573;
    public static var moves:Vector<Move> = new Vector<Move>(99);
    public static var colors:Vector<Int> = new Vector<Int>(99);
    public static var inChecks:Vector<Bool> = new Vector<Bool>(99);
	public static var blockersForKing:Vector<Vector<Bitboard>>;// [depth][color]
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
    public static var traceNode:Bool;

    public function new(){ }

    public static function init() {
        trace('DebugInfo::init');
        blockersForKing = new Vector<Vector<Bitboard>>(Types.MAX_PLY);// [depth][color]
        for(depth in 0...Types.MAX_PLY) {
            blockersForKing[depth] = new Vector<Bitboard>(Types.COLOR_NB);
            for(c in Types.BLACK...Types.COLOR_NB) {
                blockersForKing[depth][c] = new Bitboard();
            }
        }
    }

    public static function print() {
        trace('DebugInfo::print >>>');
        for(i in 0...Types.MAX_PLY){
            trace('moves depth:${i} c:${colors[i]} n:${nodes[i]} ${Types.Move_To_StringLong(moves[i])} inCheck:${inChecks[i]}');
            trace('  blockerForKing white:${blockersForKing[i][Types.WHITE].IsNonZero()} black:${blockersForKing[i][Types.BLACK].IsNonZero()}');
        }
        for(i in 0...10){
            trace('qmoves depth:${i} c:${qcolors[i]} n:${qnodes[i]} ${Types.Move_To_StringLong(qmoves[i])} inCheck:${inQChecks[i]}');
        }
        trace('DebugInfo::print <<<');
    }
}