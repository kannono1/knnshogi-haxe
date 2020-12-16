import haxe.ds.Vector;
import util.MathUtil;

class Zobrist {
	public static var zero:Bitboard64 = new Bitboard64(0, 0);
	public static var side:Bitboard64 = new Bitboard64(1, 0);
	public static var psq:Vector<Vector<Bitboard64>> = new Vector<Vector<Bitboard64>>(Types.SQ_NB); // [sq][pc]
	public static var hand:Vector<Vector<Bitboard64>> = new Vector<Vector<Bitboard64>>(Types.COLOR_NB); // [c][pr=8]
	public static var depth:Vector<Bitboard64> = new Vector<Bitboard64>(Types.MAX_PLY);

	public function new() {}

	public static function Init():Void {
		trace('Zobrist::Init');
		var rk:RKiss = new RKiss();
		for (sq in 0...Types.SQ_NB) {
			psq[sq] = new Vector<Bitboard64>(Types.PIECE_NB);
			psq[sq][Types.NO_PIECE] = new Bitboard64(0, 0); // pc==NO_PIECEのときは0
			for (pc in Types.B_PAWN...Types.PIECE_NB) {
				psq[sq][pc] = rk.Rand64();
			}
		}
		for (c in Types.BLACK...Types.COLOR_NB) {
            hand[c] = new Vector<Bitboard64>(Types.PIECE_HAND_NB);
			for (pr in Types.PIECE_ZERO...Types.PIECE_HAND_NB) {
				if (pr > 0) {
					hand[c][pr] = rk.Rand64();
				} else {
					hand[c][pr] = new Bitboard64(0, 0);
				}
			}
		}
		for (i in 0...Types.MAX_PLY) {
			depth[i] = rk.Rand64();
		}
	}
}
