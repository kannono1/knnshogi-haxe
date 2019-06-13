package;

class MoveList {
	public var mlist:Array<MoveExt> = [];
	public var curIndex:Int = 0;
	public var moveCount:Int = 0;

	public function new() {
		trace('MoveList::new');
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

	public function Serialize(from:Int, b:Bitboard) { // 成らない移動
		b.NORM27();
		while (b.IsNonZero()) {
			mlist[moveCount].move = Types.Make_Move(from, b.PopLSB());
			moveCount++;
		}
	}

	public function GenerateMoves(pos:Position, us:Int, target:Bitboard, pt:Int) {
		var pl:Bitboard = pos.PiecesColourType(us, pt).NORM27();
		trace('GenerateMoves us:$us', pl.toStringBB());
		var from:Int; // = pl[0];
		var pc:Int = Types.Make_Piece(us, pt);
		var occ = pos.PiecesAll();
		trace('GenerateMoves pt:$pt pc:$pc occ', occ.toStringBB());
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

	public function generatePawnMoves(pos:Position, us:Int, target:Bitboard) {
		trace('MoveList::GeneratePawnMoves c: $us');
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

	public function GenerateAll(pos:Position, us:Int, target:Bitboard) {
		trace('MoveList::GenerateAll c: $us');
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
	}

	public function Generate(pos:Position) {
		var us:Int = pos.SideToMove();
		var pc:Int;
		trace('MoveList::Generate c: $us');
		var target:Bitboard = pos.PiecesAll().newNOT();
		trace(target.toStringBB());
		GenerateAll(pos, us, target);
	}
}
