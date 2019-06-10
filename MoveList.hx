package;

class MoveList {
	public function new() {
		trace('MoveList::new');
	}

	public function generatePawnMoves(pos:Position, us:Int, target:Bitboard) {
		trace('MoveList::GeneratePawnMoves c: $us');
		var up:Int = Types.DELTA_S;
		var emptySquares:Bitboard = target;
		// var pawnsOn7:SF_Bitboard    = pos.PiecesColourType( us, SF_Types.PAWN ).newAND( tRank8BB );
		// var pawnsNotOn7:SF_Bitboard = pos.PiecesColourType( us, SF_Types.PAWN ).newAND( tRank8BB.newNOT() );// 最上段に達していない歩
		// var b1 = BB.ShiftBB( pawnsNotOn7, up ).newAND( emptySquares );// Shift upで歩を進め、空白マスでフィルタ
		// SerializePawns( b1, up, us );
	}

	public function GenerateAll(pos:Position, us:Int, target:Bitboard) {
		trace('MoveList::GenerateAll c: $us');
		generatePawnMoves(pos, us, target);
	}

	public function Generate(pos:Position) {
		var us:Int = pos.SideToMove();
		var pc:Int;
		trace('MoveList::Generate c: $us');
        var target:Bitboard = new Bitboard();
        // var target:Bitboard = pos.PiecesAll().newNOT();
		GenerateAll(pos, us, target);
	}
}
