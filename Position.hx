package;

@:allow()
class Position {
	public var board:Array<Int> = [];
	public var sideToMove:Int = Types.BLACK;
	public var hand:Array<Array<Int>> = [];
	public var byTypeBB:Array<Bitboard> = [];
	public var byColorBB:Array<Bitboard> = [];

	public function new() {
		trace('Posision::new');
		InitBB();
	}

	public function InitBB() {
		trace('Posision::InitBB');
		byTypeBB = [];
		for (i in 0...Types.PIECE_NB) {
			byTypeBB.push(new Bitboard());
		}
		byColorBB = [];
		for (i in 0...Types.COLOR_NB) {
			byColorBB.push(new Bitboard());
		}
	}

	public function PiecesAll():Bitboard {
		return byTypeBB[Types.ALL_PIECES];
	}

	public function PiecesColourType(c:Int, pt:Int):Bitboard {
		return byColorBB[c].newAND(byTypeBB[pt]);
	}

	public function PieceOn(sq:Int):Int {
		return board[sq];
	}

	private function changeSideToMove() {
		sideToMove = (sideToMove + 1) % 2;
	}

	private function doMove(move:Int) {
		doMoveFull(move);
	}

	private function doMoveFull(move:Int) {
        trace('Position::doMove ${Types.Move_To_String(move)}');
		var from = Types.Move_FromSq(move);
		var to = Types.Move_ToSq(move);
		var us = sideToMove;
		var them:Int = Types.OppColour(us);
		var pc = board[from];
		var pt = Types.TypeOf_Piece(pc);
		var captured:Int = Types.TypeOf_Piece(PieceOn(to));
		var capturedRaw:Int = Types.RawTypeOf(captured);
		trace('catured: $captured capturedRaw: $capturedRaw');
		if (captured != 0) {
			var capsq:Int = to;
			AddHand(us, capturedRaw);
			RemovePiece(capsq, them, captured);
		}
		RemovePiece(from, us, pt);
		MovePiece(from, to, us, pt);
		changeSideToMove();
	}

	public function PutPiece(sq:Int, c:Int, pt:Int) {
		trace('Position::PutPiece sq:$sq c:$c pt:$pt');
		board[sq] = Types.Make_Piece(c, pt);
		byColorBB[c].SetBit(sq);
		byTypeBB[Types.ALL_PIECES].SetBit(sq);
		byTypeBB[pt].SetBit(sq);
	}

	public function MovePiece(from:Int, to:Int, c:Int, pt:Int) {
		trace('Position::MovePiece from:$from to:$to c:$c pt:$pt');
		board[to] = Types.Make_Piece(c, pt);
		board[from] = 0;
		byColorBB[c].SetBit(to);
		byTypeBB[Types.ALL_PIECES].SetBit(to);
		byTypeBB[pt].SetBit(to);
	}

	private function RemovePiece(sq:Int, c:Int, pt:Int) {
		trace('Position::RemovePiece sq:$sq c:$c pt:$pt');
		board[sq] = 0;
		byColorBB[c].ClrBit(sq);
		byTypeBB[Types.ALL_PIECES].ClrBit(sq);
		byTypeBB[pt].ClrBit(sq);
	}

	public function HandExists(c:Int, pr:Int):Bool {
		return hand[c][pr] > 0;
	}

	public function AddHand(c:Int, pr:Int, n:Int = 1) {
		hand[c][pr] += n;
	}

	public function SubHand(c:Int, pr:Int, n:Int = 1) {
		hand[c][pr] -= n;
	}

	public function HandCount(c:Int, pr:Int):Int {
		return hand[c][pr];
	}

	public function setPosition(sfen) {
		var sf:SFEN = new SFEN(sfen);
		sideToMove = sf.SideToMove();
		board = sf.getBoard();
		for (i in 0...81) {
			var pc = board[i];
			var pt = Types.TypeOf_Piece(pc);
			var c = Types.getPieceColor(pc);
			if (pc == 0) {
				continue;
			}
			PutPiece(i, c, pt);
		}
		trace('Position::setPosition $sfen');
		hand = sf.getHand();
		var moves = sf.getMoves();
		for (i in 0...moves.length) {
			doMove(moves[i]);
		}
		trace(board);
	}

	public function SideToMove():Int {
		return sideToMove;
	}

	public function printBoard() {
		var s = '';
		for (r in 0...9) {
			s += '\n';
			var f = 8;
			while (f >= 0) {
				var sq = Types.Square(f, r);
				s += '  ${board[sq]}'.substr(-3);
				f--;
			}
		}
		trace(s);
	}
}
