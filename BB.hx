package;

import util.MathUtil;

class BB {
	public static var filesBB:Array<Bitboard>;
	public static var ranksBB:Array<Bitboard>;
	public static var squareDistance:Array<Array<Int>> = [];
	private static var stepAttacksBB:Array<Array<Bitboard>> = []; // [pc][sq] = BB
	public static var squareBB:Array<Bitboard> = [];
	public static var enemyField1:Array<Bitboard> = []; // 敵陣の1段目BB[color]
	public static var enemyField2:Array<Bitboard> = []; // 敵陣の2段目BB[color]
	public static var enemyField3:Array<Bitboard> = []; // 敵陣の3段目BB[color]
	public static var pawnLineBB:Array<Bitboard> = []; // 二歩チェック要。pawnがある列のBitが立つ[color]
	private static var initialized:Bool = false;
	static private var steps:Array<Array<Int>> = [
		// 駒の移動。のビットシフト。飛びの効きは0。
		[0, 0, 0, 0, 0, 0, 0, 0, 0], // 上下左右斜め＋終端の0＝９個
		[-1, 0, 0, 0, 0, 0, 0, 0, 0], // P
		[-1, -2, -3, -4, -5, -6, -7, -8, 0], // L (香だけ特殊。これに飛車の効きでAND)
		[7, -11, 0, 0, 0, 0, 0, 0, 0], // N
		[-1, 8, 10, -10, -8, 0, 0, 0, 0], // S
		[0, 0, 0, 0, 0, 0, 0, 0, 0], // B
		[0, 0, 0, 0, 0, 0, 0, 0, 0], // R
		[-1, 8, 9, 1, -10, -9, 0, 0, 0], // G
		[-1, 8, 9, 1, -10, -9, 10, -8, 0], // K
		[-1, 8, 9, 1, -10, -9, 0, 0, 0], // P+
		[-1, 8, 9, 1, -10, -9, 0, 0, 0], // L+
		[-1, 8, 9, 1, -10, -9, 0, 0, 0], // N+
		[-1, 8, 9, 1, -10, -9, 0, 0, 0], // S+
		[0, 0, 0, 0, 0, 0, 0, 0, 0], // B+
		[0, 0, 0, 0, 0, 0, 0, 0, 0], // R+
	];
	public static var rDeltas:Array<Int> = [Types.DELTA_N, Types.DELTA_E, Types.DELTA_S, Types.DELTA_W]; // R
	public static var bDeltas:Array<Int> = [Types.DELTA_NE, Types.DELTA_SE, Types.DELTA_SW, Types.DELTA_NW]; // B

	public static function SquareDistance(s1:Int, s2:Int):Int {
		return squareDistance[s1][s2];
	}

	public static function FileDistance(s1:Int, s2:Int):Int {
		return MathUtil.abs(Types.File_Of(s1) - Types.File_Of(s2));
	}

	public static function RankDistance(s1:Int, s2:Int):Int {
		return MathUtil.abs(Types.Rank_Of(s1) - Types.Rank_Of(s2));
	}

	static public function Init() {
		trace('Init::BB');
		if (initialized) {
			return;
		}
		filesBB = [];
		ranksBB = [];
		for (i in 0...9) {
			filesBB.push(new Bitboard(0x1FF, 0, 0));
			filesBB[i].ShiftL(9 * i);
			ranksBB.push(new Bitboard(0x40201, 0x40201, 0x40201));
			ranksBB[i].ShiftL(i);
		}
		enemyField1[Types.WHITE] = ranksBB[8].newCOPY();
		enemyField1[Types.BLACK] = ranksBB[0].newCOPY();
		enemyField2[Types.WHITE] = ranksBB[8].newOR(ranksBB[7]);
		enemyField2[Types.BLACK] = ranksBB[0].newOR(ranksBB[1]);
		enemyField3[Types.WHITE] = enemyField2[Types.WHITE].newOR(ranksBB[6]);
		enemyField3[Types.BLACK] = enemyField2[Types.BLACK].newOR(ranksBB[2]);
		pawnLineBB[Types.BLACK] = new Bitboard();
		pawnLineBB[Types.WHITE] = new Bitboard();
		for (sq in Types.SQ_A1...Types.SQ_NB) {
			squareBB[sq] = new Bitboard();
			squareBB[sq].SetBit(sq);
		}
		for (s1 in Types.SQ_A1...Types.SQ_NB) {
			squareDistance[s1] = [];
			for (s2 in Types.SQ_A1...Types.SQ_NB) {
				squareDistance[s1][s2] = MathUtil.max(FileDistance(s1, s2), RankDistance(s1, s2));
				// if( s1 != s2 ) {
				// 	distanceRingsBB[s1][ squareDistance[s1][s2] - 1 ].OR( squareBB[s2] );
				// }
			}
		}
		for (pt in Types.NO_PIECE...Types.PIECE_NB) {
			stepAttacksBB[pt] = [];
			for (s1 in Types.SQ_A1...Types.SQ_NB) {
				stepAttacksBB[pt][s1] = new Bitboard();
			}
		}
		var c = Types.BLACK; // JSだとLoopを分割しないとスルーされるかも
		for (pt in Types.PAWN...Types.DRAGON) {
			for (s in Types.SQ_A1...Types.SQ_NB) {
				for (k in 0...9) { // 9=eps[0].length
					if (steps[pt][k] == 0) {
						continue;
					}
					var to:Int = s;
					if (c == Types.BLACK) {
						to += steps[pt][k];
					} else {
						to -= steps[pt][k];
					}
					if (Types.Is_SqOK(to) == false) {
						continue;
					}
					if (SquareDistance(s, to) >= 3 && Types.RawTypeOf(pt) != Types.LANCE) {
						continue; // 3=駒の隣接チェック(香の時は行わない)
					}
					// trace('BB.Init, c:$c, pt:$pt, s:$s, pc:${Types.Make_Piece(c, pt) } ');
					stepAttacksBB[Types.Make_Piece(c, pt)][s].OR(squareBB[to]);
				}
			}
		}
		var c = Types.WHITE;
		for (pt in Types.PAWN...Types.DRAGON) {
			for (s in Types.SQ_A1...Types.SQ_NB) {
				for (k in 0...9) { // 9=eps[0].length
					if (steps[pt][k] == 0) {
						continue;
					}
					var to:Int = s;
					if (c == Types.BLACK) {
						to += steps[pt][k];
					} else {
						to -= steps[pt][k];
					}
					if (Types.Is_SqOK(to) == false) {
						continue;
					}
					if (SquareDistance(s, to) >= 3 && Types.RawTypeOf(pt) != Types.LANCE) {
						continue; // 3=駒の隣接チェック(香の時は行わない)
					}
					stepAttacksBB[Types.Make_Piece(c, pt)][s].OR(squareBB[to]);
				}
			}
		}
		initialized = true;
	}

	public static function getStepAttacksBB(pc:Int, sq:Int):Bitboard {
		return stepAttacksBB[pc][sq];
	}

	public static function AttacksBB(sq:Int, occ:Bitboard, pt:Int):Bitboard {
		switch (pt) {
			case Types.ROOK:
				return SlidingAttack(rDeltas, sq, occ);
			case Types.DRAGON:
				return SlidingGoldenAttack(rDeltas, sq, occ);
			case Types.HORSE:
				return SlidingGoldenAttack(bDeltas, sq, occ);
			case Types.BISHOP:
				return SlidingAttack(bDeltas, sq, occ);
			case Types.LANCE:
				return SlidingAttack(rDeltas, sq, occ);
			default:
				return new Bitboard();
		}
	}

	public static function SlidingAttack(deltas:Array<Int>, sq:Int, occ:Bitboard):Bitboard {
		var attack:Bitboard = new Bitboard();
		for (i in 0...4) { // 4方向
			if (deltas[i] == 0) {
				return attack;
			}
			var s:Int = sq + deltas[i];
			while (Types.Is_SqOK(s) && SquareDistance(s, s - deltas[i]) == 1) { // 範囲内
				attack.OR(squareBB[s]);
				if (occ.newAND(squareBB[s]).IsNonZero()) { // 当たり判定
					break;
				}
				s += deltas[i];
			}
		}
		return attack;
	}

	public static function SlidingGoldenAttack(deltas:Array<Int>, sq:Int, occ:Bitboard):Bitboard {
		var attack:Bitboard = stepAttacksBB[Types.KING][sq].newCOPY();
		for (i in 0...4) {
			if (deltas[i] == 0) {
				return attack;
			}
			var s:Int = sq + deltas[i];
			while (Types.Is_SqOK(s) && SquareDistance(s, s - deltas[i]) == 1) {
				attack.OR(squareBB[s]);
				if (occ.newAND(squareBB[s]).IsNonZero()) {
					break;
				}
				s += deltas[i];
			}
		}
		return attack;
	}

	public static function ShiftBB(b:Bitboard, deltta:Int):Bitboard {
		if (deltta == Types.DELTA_N) {
			return b.newShiftR(1);
		}
		if (deltta == Types.DELTA_S) {
			return b.newShiftL(1);
		}
		if (deltta == Types.DELTA_NE) {
			return (b.newAND(filesBB[8].newNOT())).newShiftL(10);
		}
		if (deltta == Types.DELTA_SE) {
			return (b.newAND(filesBB[8].newNOT())).newShiftR(8);
		}
		if (deltta == Types.DELTA_NW) {
			return (b.newAND(filesBB[0].newNOT())).newShiftL(8);
		}
		if (deltta == Types.DELTA_SW) {
			return (b.newAND(filesBB[0].newNOT())).newShiftR(10);
		}
		var zero:Bitboard = new Bitboard();
		return zero;
	}
}
