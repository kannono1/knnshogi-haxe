package;

import Types.PC;
import Types.PT;

class MoveList {
	public static inline var CAPTURES:Int = 0;
	public static inline var QUIETS:Int = 1;
	public static inline var QUIET_CHECKS:Int = 2;
	public static inline var EVASIONS:Int = 3;
	public static inline var NON_EVASIONS:Int = 4;
	public static inline var LEGAL:Int = 5;

	public var mlist:Array<MoveExt> = [];
	public var curIndex:Int = 0;
	public var moveCount:Int = 0;

	public function new() {
		for (i in 0...Types.MAX_MOVES) {
			mlist[i] = new MoveExt();
		}
	}

	public function Reset() {
		curIndex = 0;
		moveCount = 0;
	}

	public function SerializeBR(from:Int, b:Bitboard, us:Int) {
		if (BB.squareBB[from].newAND(BB.enemyField3[us]).IsNonZero()) { // 移動元が敵陣だったら必ず成る
			b.NORM27();
			while (b.IsNonZero()) {
				mlist[moveCount].move = Types.Make_Move_Promote(from, b.PopLSB());
				moveCount++;
			}
			return;
		}
		var pb:Bitboard = b.newAND(BB.enemyField3[us]);
		var nb:Bitboard = b.newAND(BB.enemyField3[us].newNOT());
		var to:Int;
		pb.NORM27();
		while (pb.IsNonZero()) { // 移動先が敵陣だったら必ず成る
			to = pb.PopLSB();
			mlist[moveCount].move = Types.Make_Move_Promote(from, to);
			moveCount++;
		}
		nb.NORM27();
		while (nb.IsNonZero()) {
			to = nb.PopLSB();
			mlist[moveCount].move = Types.Make_Move(from, to);
			moveCount++;
		}
	}

	public function SerializeS(from:Int, b:Bitboard, us:Int) {
		var pb1:Bitboard = new Bitboard();
		var to:Int;
		if (BB.squareBB[from].newAND(BB.enemyField3[us]).IsNonZero()) { // 移動元が敵陣だったら成る手も生成する
			pb1.Copy(b);
			pb1.NORM27();
			while (pb1.IsNonZero()) {
				to = pb1.PopLSB();
				mlist[moveCount].move = Types.Make_Move_Promote(from, to);
				moveCount++;
			}
		}
		var pb2:Bitboard = b.newAND(BB.enemyField3[us]); // 移動先が敵陣だったら成る手も生成する
		pb2.AND(pb1.newNOT()); // 移動元の分を引く
		pb2.NORM27();
		while (pb2.IsNonZero()) {
			to = pb2.PopLSB();
			mlist[moveCount].move = Types.Make_Move_Promote(from, to);
			moveCount++;
		}
		b.NORM27();
		while (b.IsNonZero()) { // 銀は常に成らない手を生成する
			to = b.PopLSB();
			mlist[moveCount].move = Types.Make_Move(from, to);
			moveCount++;
		}
	}

	public function SerializeN(from:Int, b:Bitboard, us:Int) {
		var pb:Bitboard = b.newAND(BB.enemyField3[us]).NORM27(); // 移動先が敵陣だったら成る手も生成する
		var nb:Bitboard = b.newAND(BB.enemyField2[us].newNOT()).NORM27(); // 移動先が敵陣1,2段目以外は不成の手を生成する
		var to:Int;
		while (pb.IsNonZero()) {
			to = pb.PopLSB();
			mlist[moveCount].move = Types.Make_Move_Promote(from, to);
			moveCount++;
		}
		while (nb.IsNonZero()) {
			to = nb.PopLSB();
			mlist[moveCount].move = Types.Make_Move(from, to);
			moveCount++;
		}
	}

	public function SerializeL(from:Int, b:Bitboard, us:Int) {
		var pb:Bitboard = b.newAND(BB.enemyField3[us]).NORM27(); // 移動先が敵陣だったら成る手も生成する
		var nb:Bitboard = b.newAND(BB.enemyField2[us].newNOT()).NORM27(); // 移動先が敵陣2段目以外は不成の手を生成する
		var to:Int;
		while (pb.IsNonZero()) {
			to = pb.PopLSB();
			mlist[moveCount].move = Types.Make_Move_Promote(from, to);
			moveCount++;
		}
		while (nb.IsNonZero()) {
			to = nb.PopLSB();
			mlist[moveCount].move = Types.Make_Move(from, to);
			moveCount++;
		}
	}

	public function SerializePawns(b:Bitboard, delta:Int, us:Int) {
		var pb:Bitboard = b.newAND(BB.enemyField3[us]).NORM27(); // 27bitでノーマライズしないと余ったbitで重複にMoveが登録される。。
		var nb:Bitboard = b.newAND(BB.enemyField3[us].newNOT()).NORM27();
		var to:Int = 0;
		while (pb.IsNonZero()) {
			to = pb.PopLSB();
			mlist[moveCount].move = Types.Make_Move_Promote(to - delta, to);
			moveCount++;
		}
		while (nb.IsNonZero()) {
			to = nb.PopLSB();
			mlist[moveCount].move = Types.Make_Move(to - delta, to);
			moveCount++;
		}
	}

	public function SerializeDrop(pt:PT, b:Bitboard) {
		var to:Int;
		b.NORM27();
		while (b.IsNonZero()) {
			to = b.PopLSB();
			mlist[moveCount].move = Types.Make_Move_Drop(Types.RawTypeOf(pt), to);
			moveCount++;
		}
	}

	public function Serialize(from:Int, b:Bitboard) { // 成らない移動
		b.NORM27();
		while (b.IsNonZero()) {
			mlist[moveCount].move = Types.Make_Move(from, b.PopLSB());
			moveCount++;
		}
	}

	public function GenerateMoves(pos:Position, us:Int, target:Bitboard, pt:PT) {
		var pl:Bitboard = pos.PiecesColourType(us, pt).NORM27();
		var from:Int = 0;
		var pc:PC = Types.Make_Piece(us, pt);
		while (pl.IsNonZero()) {
			from = pl.PopLSB();
			var b:Bitboard = pos.AttacksFromPTypeSQ(from, pc).newAND(target); // fromにいるpcの移動可能範囲
			if (pt == Types.BISHOP || pt == Types.ROOK) {
				SerializeBR(from, b, us);
			} else if (pt == Types.SILVER) {
				SerializeS(from, b, us);
			} else if (pt == Types.KNIGHT) {
				SerializeN(from, b, us);
			} else if (pt == Types.LANCE) {
				SerializeL(from, b, us);
			} else {
				Serialize(from, b);
			}
		}
	}

	private function GenerateKingMoves(pos:Position, us:Int, target:Bitboard) {
		// if(
		// 	genType == QUIET_CHECKS
		// 	|| genType == EVASIONS
		// ) { // K
		// 	return;
		// }
		// var from:Int = pos.KingSquare( us );
		// var b:Bitboard = pos.AttacksFromPTypeSQ( from, Types.KING ).newAND( target );
		// Serialize( from, b );
		GenerateMoves(pos, us, target, Types.KING);
	}

	public function generatePawnMoves(pos:Position, us:Int, target:Bitboard) {
		var up:Int = Types.DELTA_S;
		var tRank8BB:Bitboard = BB.ranksBB[8]; // 最奥の行
		if (us == Types.BLACK) {
			up = Types.DELTA_N;
			tRank8BB = BB.ranksBB[0];
		}
		var emptySquares:Bitboard = target;
		// var pawnsOn7:SF_Bitboard    = pos.PiecesColourType( us, SF_Types.PAWN ).newAND( tRank8BB );
		var pawnsNotOn7:Bitboard = pos.PiecesColourType(us, Types.PAWN).newAND(tRank8BB.newNOT()); // 最上段に達していない歩
		var b1 = BB.ShiftBB(pawnsNotOn7, up).newAND(emptySquares); // Shift upで歩を進め、空白マスでフィルタ
		SerializePawns(b1, up, us);
	}

	public function GenerateDopMoves(pos:Position, us:Int, target:Bitboard, pt:PT) {
		if (!pos.HandExists(us, Types.RawTypeOf(pt))) {
			return; // 持ち駒チェエク
		}
		var target2:Bitboard = target.newAND(pos.PiecesAll().newNOT()); // 空いてるところ
		switch (pt) {
			case Types.PAWN:
				target2.AND(BB.enemyField1[us].newNOT()); // 1段目には打てない
				target2.AND(BB.pawnLineBB[us].newNOT()); // 二歩チェック
			case Types.LANCE:
				target2.AND(BB.enemyField1[us].newNOT()); // 1段目には打てない
			case Types.KNIGHT:
				target2.AND(BB.enemyField2[us].newNOT()); // 2段目には打てない
			default: // 空いてるところならOK
		}
		SerializeDrop(pt, target2);
	}

	public function GenerateAllDopMoves(pos:Position, us:Int, target:Bitboard) {
		GenerateDopMoves(pos, us, target, Types.PAWN);
		GenerateDopMoves(pos, us, target, Types.LANCE);
		GenerateDopMoves(pos, us, target, Types.KNIGHT);
		GenerateDopMoves(pos, us, target, Types.SILVER);
		GenerateDopMoves(pos, us, target, Types.BISHOP);
		GenerateDopMoves(pos, us, target, Types.ROOK);
		GenerateDopMoves(pos, us, target, Types.GOLD);
	}

	public function GenerateAll(pos:Position, us:Int, target:Bitboard, genType:Int) {
		if (genType != CAPTURES) { // CAPTUREの時は打ち手を生成しない。（絶対に敵駒を取れないので）
			GenerateAllDopMoves(pos, us, target);
		}
		generatePawnMoves(pos, us, target);
		GenerateMoves(pos, us, target, Types.LANCE);
		GenerateMoves(pos, us, target, Types.KNIGHT);
		GenerateMoves(pos, us, target, Types.SILVER);
		GenerateMoves(pos, us, target, Types.BISHOP);
		GenerateMoves(pos, us, target, Types.ROOK);
		GenerateMoves(pos, us, target, Types.GOLD);
		GenerateMoves(pos, us, target, Types.PRO_PAWN);
		GenerateMoves(pos, us, target, Types.PRO_LANCE);
		GenerateMoves(pos, us, target, Types.PRO_KNIGHT);
		GenerateMoves(pos, us, target, Types.PRO_SILVER);
		GenerateMoves(pos, us, target, Types.HORSE);
		GenerateMoves(pos, us, target, Types.DRAGON);
		GenerateKingMoves(pos, us, target);
	}

	public function Generate(pos:Position, genType:Int) {
		var us:Int = pos.SideToMove();
		var pt:PT = new PT(0);
		var pc:PC = new PC(0);
		if (genType == NON_EVASIONS) {
			var target:Bitboard = pos.PiecesColour(us).newNOT(); // CAPTURE＋QUIETS
			GenerateAll(pos, us, target, genType);
		}
		if (genType == EVASIONS) { // 3 王の移動先をMovesに入れてから相駒をGenerateする
			var checkersCnt:Int = 0;
			var ksq:Int = pos.king_square(us);
			var checksq:Int = 0; // 王手をかけている駒位置
			var sliderAttacks:Bitboard = new Bitboard(); // 敵駒の効き
			var b = new Bitboard();
			b.Copy(pos.Checkers()); // 王手している駒
			do {
				checkersCnt++;
				checksq = b.PopLSB();
				pc = pos.piece_on(checksq);
				pt = Types.TypeOf_Piece(pc);
				if (pt == Types.BISHOP || pt == Types.ROOK || pt == Types.HORSE || pt == Types.DRAGON || pt == Types.LANCE) { // 飛び駒のとき // ksqとchecksqをつなぐQueenの効き - 王手をかけている駒位置
					sliderAttacks.OR(BB.lineBB[checksq][ksq].newXOR(BB.squareBB[checksq]));
				}
				if (pt == Types.HORSE || pt == Types.DRAGON) {
					sliderAttacks.OR(BB.getStepAttacksBB(Types.B_KING, checksq));
				}
			} while (b.IsNonZero());
			b = new Bitboard();
			b.Copy(pos.AttacksFromPTypeSQ(ksq, Types.B_KING)); // 自王の移動範囲
			b.AND(pos.PiecesColour(us).newNOT()); // 敵の駒
			b.AND(sliderAttacks.newNOT()); // 敵の効きが無い場所
			Serialize(ksq, b);
			if (checkersCnt > 1) { // 両王手であるなら、王の移動のみが回避手となる。ゆえにこれで指し手生成は終了。
				return;
			}
			var target1:Bitboard = BB.betweenBB[checksq][ksq].newCOPY();
			var target2:Bitboard = target1.newOR(BB.squareBB[checksq]);
			generatePawnMoves(pos, us, target2);
			GenerateMoves(pos, us, target2, Types.LANCE);
			GenerateMoves(pos, us, target2, Types.KNIGHT);
			GenerateMoves(pos, us, target2, Types.SILVER);
			GenerateMoves(pos, us, target2, Types.BISHOP);
			GenerateMoves(pos, us, target2, Types.ROOK);
			GenerateMoves(pos, us, target2, Types.GOLD);
			GenerateMoves(pos, us, target2, Types.PRO_PAWN);
			GenerateMoves(pos, us, target2, Types.PRO_LANCE);
			GenerateMoves(pos, us, target2, Types.PRO_KNIGHT);
			GenerateMoves(pos, us, target2, Types.PRO_SILVER);
			GenerateMoves(pos, us, target2, Types.HORSE);
			GenerateMoves(pos, us, target2, Types.DRAGON);
			GenerateAllDopMoves(pos, us, target1);
		}
		if (genType == LEGAL) {
			if (pos.Checkers().IsNonZero()) {
				Generate(pos, EVASIONS);
			} else {
				Generate(pos, NON_EVASIONS);
			}
			var ksq = pos.king_square(pos.SideToMove());
			var i:Int = 0;
			while (i < moveCount) { // Legalの時は王の自殺手をチェックしてカウントをマイナスする。末尾の手で上書きする。
				if ((Types.move_from(mlist[i].move) == ksq) && pos.legal(mlist[i].move) == false) {
					moveCount--;
					mlist[i].move = mlist[moveCount].move;
				} else {
					i++;
				}
			}
		} // Legal
	}
}
