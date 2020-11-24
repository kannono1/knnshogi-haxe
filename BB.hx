package;

import Types.Direct;
import Types.SquareWithWall;
import util.MathUtil;
import Types.PT;

class BB {
	public static var ZERO_BB = new Bitboard();
	public static var filesBB:Array<Bitboard>;
	public static var ranksBB:Array<Bitboard>;
	public static var squareDistance:Array<Array<Int>> = [];
	public static var stepAttacksBB:Array<Array<Bitboard>> = []; // [pc][sq] = BB	// 盤上の駒を考慮しない利き
	public static var betweenBB:Array<Array<Bitboard>> = []; // [sq1][sq2] // 1と2の地点をつなぐ直線の効き
	public static var lineBB:Array<Array<Bitboard>> = []; // [sq1][sq2] // 1と2の地点を通る直線の効き
	public static var squareBB:Array<Bitboard> = [];
	public static var enemyField1:Array<Bitboard> = []; // 敵陣の1段目BB[color]
	public static var enemyField2:Array<Bitboard> = []; // 敵陣の2段目BB[color]
	public static var enemyField3:Array<Bitboard> = []; // 敵陣の3段目BB[color]
	public static var pawnLineBB:Array<Bitboard> = []; // 二歩チェック要。pawnがある列のBitが立つ[color]
	public static var pseudoAttacks:Array<Array<Bitboard>> = []; // [pt][sq] 飛車と角の利き.自駒のSQは含まない 擬似合法手。合法手もどき。)と呼ぶ。ちなみにpseudoの頭文字のpは読まない(黙字)で、「すーだ」に近い発音をする。
	public static var pseudoQueenAttacks:Array<Bitboard> = []; // [sq]
	private static var RookStepEffectBB:Array<Bitboard> = [];// [sq] 駒を無視した飛車の効き、自駒のSQを含む
	private static var BishopStepEffectBB:Array<Bitboard> = [];// [sq] 駒を無視した飛車の効き、自駒のSQを含む
	private static var LanceStepEffectBB:Array<Array<Bitboard>> = [[]];// [c][sq] 駒を無視した香車の効き、自駒のSQを含む
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
	public static var fDeltas:Array<Int> = [Types.DELTA_N,  Types.DELTA_S, 0, 0]; // 上下
	public static var nDeltas:Array<Int> = [Types.DELTA_N,  0, 0, 0]; // 上
	public static var sDeltas:Array<Int> = [Types.DELTA_S,  0, 0, 0]; // 下

	public static function SquareDistance(s1:Int, s2:Int):Int {
		return squareDistance[s1][s2];
	}

	public static function FileDistance(s1:Int, s2:Int):Int {
		return MathUtil.abs(Types.file_of(s1) - Types.file_of(s2));
	}

	public static function RankDistance(s1:Int, s2:Int):Int {
		return MathUtil.abs(Types.rank_of(s1) - Types.rank_of(s2));
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
		// 1) SquareWithWallテーブルの初期化。
		for(sq in Types.SQ_11...Types.SQ_NB_PLUS1) {
			Types.sqww_table[sq] = SquareWithWall.SQWW_11 + Types.file_of(sq) * SquareWithWall.SQWW_L + Types.rank_of(sq) * SquareWithWall.SQWW_D;
		}
		// 2) direct_tableの初期化
		for (sq1 in Types.SQ_11...Types.SQ_NB) {
			Types.direc_table[sq1] = [];
			for(dir in Direct.DIRECT_ZERO...Direct.DIRECT_NB){// 0-7
				// dirの方角に壁にぶつかる(盤外)まで延長していく。このとき、sq1から見てsq2のDirectionsは (1 << dir)である。
				var delta:SquareWithWall = Types.DirectToDeltaWW(dir);
				var sq2 = Std.int(Types.to_sqww(sq1)) + Std.int(delta);
				while( Types.is_ok(sq2) ) {
					Types.direc_table[sq1][Types.sqww_to_sq(sq2)] = Types.to_directions(dir);
					sq2 += delta;
				}
			}
		}
		for (sq in Types.SQ_11...Types.SQ_NB) {
			squareBB[sq] = new Bitboard();
			squareBB[sq].SetBit(sq);
		}
		for (s1 in Types.SQ_11...Types.SQ_NB) {
			squareDistance[s1] = [];
			for (s2 in Types.SQ_11...Types.SQ_NB) {
				squareDistance[s1][s2] = MathUtil.max(FileDistance(s1, s2), RankDistance(s1, s2));
			}
		}
		var pt:PT = new PT(0);
		for (p in Types.NO_PIECE...Types.PIECE_NB) {
			pt = new PT(p);
			stepAttacksBB[pt] = [];
			for (s1 in Types.SQ_11...Types.SQ_NB) {
				stepAttacksBB[pt][s1] = new Bitboard();
			}
		}
		var s:Int = 0;
		for (pt in Types.NO_PIECE_TYPE...Types.PIECE_TYPE_NB) {
			pseudoAttacks[pt] = [];
		}
		for (s in Types.SQ_11...Types.SQ_NB) {
			var a = AttacksBB(s, new Bitboard(), Types.BISHOP);
			pseudoAttacks[Types.BISHOP][s] = AttacksBB(s, new Bitboard(), Types.BISHOP);
			pseudoAttacks[Types.ROOK][s] = AttacksBB(s, new Bitboard(), Types.ROOK);
			pseudoAttacks[Types.HORSE][s] = AttacksBB(s, new Bitboard(), Types.HORSE);
			pseudoAttacks[Types.DRAGON][s] = AttacksBB(s, new Bitboard(), Types.DRAGON);
			RookStepEffectBB[s] = pseudoAttacks[Types.ROOK][s].newOR(squareBB[s]);
			BishopStepEffectBB[s] = pseudoAttacks[Types.BISHOP][s].newOR(squareBB[s]);
			pseudoQueenAttacks[s] = new Bitboard(); // 飛び駒の効きの判定に使用
			pseudoQueenAttacks[s].OR(pseudoAttacks[Types.BISHOP][s]);
			pseudoQueenAttacks[s].OR(pseudoAttacks[Types.ROOK][s]);
		}
		for (s1 in Types.SQ_11...Types.SQ_NB) {
			betweenBB[s1] = [];
			lineBB[s1] = [];
			for (s2 in Types.SQ_11...Types.SQ_NB) {
				betweenBB[s1][s2] = new Bitboard();
				lineBB[s1][s2] = new Bitboard();
				if (pseudoQueenAttacks[s1].newAND(squareBB[s2]).IsNonZero()) {// Queenのライン上にある
					var deltta:Int = Std.int((s2 - s1) / SquareDistance(s1, s2));
					s = s1 + deltta;
					while (s != s2) {
						betweenBB[s1][s2].OR(squareBB[s]);
						s += deltta;
					}
					pt = Types.ROOK;
					if (pseudoAttacks[Types.BISHOP][s1].newAND(squareBB[s2]).IsNonZero()) {
						pt = Types.BISHOP;
					}
					lineBB[s1][s2].Copy(pseudoAttacks[pt][s1]);
					lineBB[s1][s2].AND(pseudoAttacks[pt][s2]);
					lineBB[s1][s2].OR(squareBB[s1]);
					lineBB[s1][s2].OR(squareBB[s2]);
				}
			}
		}
		var c = Types.BLACK; // JSだとLoopが多いとスルーされるかもなので先後でループを分割してみた
		for (p in Types.PAWN...Types.DRAGON) {
			pt = new PT(p);
			for (s in Types.SQ_11...Types.SQ_NB) {
				for (k in 0...9) { // 9=eps[0].length
					if (steps[pt][k] == 0) {
						continue;
					}
					var to:Int = s + steps[pt][k];
					if (Types.Is_SqOK(to) == false) {
						continue;
					}
					if (SquareDistance(s, to) >= 3 && new PT(Types.RawTypeOf(pt)) != Types.LANCE) {
						continue; // 3=駒の隣接チェック(香の時は行わない)
					}
					// trace('BB.Init, c:$c, pt:$pt, s:$s, pc:${Types.Make_Piece(c, pt) } ');
					stepAttacksBB[Types.Make_Piece(c, pt)][s].OR(squareBB[to]);
				}
			}
		}
		var c = Types.WHITE;
		for (p in Types.PAWN...Types.DRAGON) {
			pt = new PT(p);
			for (s in Types.SQ_11...Types.SQ_NB) {
				for (k in 0...9) { // 9=eps[0].length
					if (steps[pt][k] == 0) {
						continue;
					}
					var to:Int = s - steps[pt][k];
					if (Types.Is_SqOK(to) == false) {
						continue;
					}
					if (SquareDistance(s, to) >= 3 && new PT(Types.RawTypeOf(pt)) != Types.LANCE) {
						continue; // 3=駒の隣接チェック(香の時は行わない)
					}
					stepAttacksBB[Types.Make_Piece(c, pt)][s].OR(squareBB[to]);
				}
			}
		}
		for(c in Types.BLACK...Types.COLOR_NB){
			LanceStepEffectBB[c] = [];
			for(s in Types.SQ_11...Types.SQ_NB){
				LanceStepEffectBB[c][s] = stepAttacksBB[Types.Make_Piece(c, Types.LANCE)][s].newOR(squareBB[s]).newAND(RookStepEffectBB[s]);
			}
		}
		initialized = true;
	}

	public static function getStepAttacksBB(pc:Int, sq:Int):Bitboard {
		return stepAttacksBB[pc][sq];
	}

	public static function kingEffect(sq:Int):Bitboard {
		return stepAttacksBB[Types.KING][sq];
	}

	public static function pawnEffect(c:Int, sq:Int):Bitboard {
		return stepAttacksBB[Types.Make_Piece(c, Types.PAWN)][sq];
	}

	public static function knightEffect(c:Int, sq:Int):Bitboard {
		return stepAttacksBB[Types.Make_Piece(c, Types.KNIGHT)][sq];
	}

	public static function silverEffect(c:Int, sq:Int):Bitboard {
		return stepAttacksBB[Types.Make_Piece(c, Types.SILVER)][sq];
	}

	public static function goldEffect(c:Int, sq:Int):Bitboard {
		return stepAttacksBB[Types.Make_Piece(c, Types.GOLD)][sq];
	}

	// 縦横十字の利き 利き長さ=1升分。
	public static function cross00StepEffect(sq:Int):Bitboard  {
		return rookStepEffect(sq).newAND(kingEffect(sq));
	}

	// 斜め十字の利き 利き長さ=1升分。
	public static function cross45StepEffect(sq:Int):Bitboard  {
		return bishopStepEffect(sq).newAND(kingEffect(sq));
	}

	// 飛車の縦の利き(駒を考慮する)
	public static function rookFileEffect(sq:Int, occupied:Bitboard):Bitboard {
		return SlidingAttack(fDeltas, sq, occupied);
	}

	// 香 : occupied bitboardを考慮しながら香の利きを求める
	public static function lanceEffect(c:Int, sq:Int, occupied:Bitboard):Bitboard {
		return (c == Types.BLACK) ? SlidingAttack(nDeltas, sq, occupied) : SlidingAttack(sDeltas, sq, occupied);
	}

	public static function bishopEffect(sq:Int, occupied:Bitboard):Bitboard {
		return SlidingAttack(bDeltas, sq, occupied);
	}

	public static function rookEffect(sq:Int, occupied:Bitboard):Bitboard {
		return SlidingAttack(rDeltas, sq, occupied);
	}

	public static function horseEffect(sq:Int, occupied:Bitboard):Bitboard {
		return SlidingGoldenAttack(bDeltas, sq, occupied);
	}

	public static function dragonEffect(sq:Int, occupied:Bitboard):Bitboard {
		return SlidingGoldenAttack(rDeltas, sq, occupied);
	}

	// StepEffectは盤上の駒を考慮しない
	public static function rookStepEffect(sq:Int):Bitboard {
		return RookStepEffectBB[sq];
	}

	public static function bishopStepEffect(sq:Int):Bitboard {
		return BishopStepEffectBB[sq];
	}

	public static function lanceStepEffect(c:Int, sq:Int):Bitboard {
		return LanceStepEffectBB[c][sq];
	}

	public static function AttacksBB(sq:Int, occ:Bitboard, pt:PT):Bitboard {
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

	public static function ANDsq( b:Bitboard, sq:Int ) : Bitboard {
		return b.newAND( squareBB[sq] );
	}
}
