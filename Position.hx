package;

import data.Move;

class Position {
	public var byTypeBB:Array<Bitboard> = [];

	private var board:Array<Int> = [];
	private var sideToMove:Int = Types.BLACK;

	public function new() {
		trace('Posision::new');
		InitBB();
	}

	public function InitBB() {
		trace('Posision::InitBB');
		for (i in 0...Types.PIECE_NB) {
			byTypeBB.push(new Bitboard());
		}
	}

	public function PiecesAll():Bitboard {
		return byTypeBB[Types.ALL_PIECES];
	}

	private function changeSideToMove() {
		sideToMove = (sideToMove + 1) % 2;
	}

	private function doMove(move:Move) {
		doMoveFull(move);
	}

	private function doMoveFull(move:Move) {
		var from = move.from;
		var to = move.to;
		var us = sideToMove;
		var pc = board[from];
		var pt = Types.TypeOf_Piece(pc);
		RemovePiece(from, us, pt);
		MovePiece(from, to, us, pt);
		changeSideToMove();
		trace(byTypeBB[Types.ALL_PIECES].toStringBB());
	}

	public function PutPiece(sq:Int, c:Int, pt:Int) {
		trace('Position::PutPiece sq:$sq c:$c pt:$pt');
		board[sq] = Types.Make_Piece(c, pt);
		byTypeBB[Types.ALL_PIECES].SetBit(sq);
		byTypeBB[pt].SetBit(sq);
	}

	public function MovePiece(from:Int, to:Int, c:Int, pt:Int) {
		trace('Position::MovePiece from:$from to:$to c:$c pt:$pt');
		board[to] = Types.Make_Piece(c, pt);
		board[from] = 0;
		byTypeBB[Types.ALL_PIECES].SetBit(to);
		byTypeBB[pt].SetBit(to);
	}

	private function RemovePiece(sq:Int, c:Int, pt:Int) {
		trace('Position::RemovePiece sq:$sq c:$c pt:$pt');
		board[sq] = 0;
		byTypeBB[Types.ALL_PIECES].ClrBit(sq);
		byTypeBB[pt].ClrBit(sq);
	}

	public function setPosition(sfen) {
		var sf:SFEN = new SFEN(sfen);
		var bd = sf.getBoard();
		for (i in 0...81) {
			var pc = bd[i];
			var pt = Types.TypeOf_Piece(pc);
			var c = Types.getPieceColor(pc);
			if (pc == 0) {
				continue;
			}
            PutPiece(i, c, pt);
		}
		trace('Position::setPosition $sfen');
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
