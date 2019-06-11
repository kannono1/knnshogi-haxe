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
		var s1 = BB.ShiftBB(pawnsNotOn7, up);
		var b1 = BB.ShiftBB(pawnsNotOn7, up).newAND(emptySquares); // Shift upで歩を進め、空白マスでフィルタ
		SerializePawns(b1, up, us);
	}

	public function GenerateAll(pos:Position, us:Int, target:Bitboard) {
		trace('MoveList::GenerateAll c: $us');
		generatePawnMoves(pos, us, target);
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
