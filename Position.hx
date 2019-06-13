package;

import Types.Move;

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

	public function PiecesColour(c:Int):Bitboard {
		return byColorBB[c];
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

	private function doMove(move:Move) {
		doMoveFull(move);
	}

	private function doMoveFull(move:Move) {
		trace('Position::doMoveFull ${Types.Move_To_String(move)}');
		var from = Types.Move_FromSq(move);
		var to = Types.Move_ToSq(move);
		var us = sideToMove;
		var them:Int = Types.OppColour(us);
		var pc:Int = MovedPieceAfter(move);
		var pr:Int = Types.RawTypeOf(pc);
		var pt = Types.TypeOf_Piece(pc);
		trace('to: $to from: $from pc: $pc');
		if (Types.Is_Drop(move)) {
			SubHand(us, pr);
			PutPiece(to, us, pr);
			changeSideToMove();
			return;
		}
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
		if (Types.Move_Type(move) == Types.MOVE_PROMO) {
			RemovePiece(to, us, pt);
			PutPiece(to, us, pt + Types.PIECE_PROMOTE);
		}
		changeSideToMove();
	}

	public function PutPiece(sq:Int, c:Int, pt:Int) {
		trace('Position::PutPiece sq:$sq c:$c pt:$pt');
		board[sq] = Types.Make_Piece(c, pt);
		byColorBB[c].SetBit(sq);
		byTypeBB[Types.ALL_PIECES].SetBit(sq);
		byTypeBB[pt].SetBit(sq);
		if (Types.TypeOf_Piece(pt) == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.File_Of(sq)]);
		}
	}

	public function MovePiece(from:Int, to:Int, c:Int, pt:Int) {
		trace('Position::MovePiece from:$from to:$to c:$c pt:$pt');
		board[to] = Types.Make_Piece(c, pt);
		board[from] = 0;
		byColorBB[c].SetBit(to);
		byTypeBB[Types.ALL_PIECES].SetBit(to);
		byTypeBB[pt].SetBit(to);
		if (Types.TypeOf_Piece(pt) == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.File_Of(to)]);
		}
	}

	private function RemovePiece(sq:Int, c:Int, pt:Int) {
		trace('Position::RemovePiece sq:$sq c:$c pt:$pt');
		board[sq] = 0;
		byColorBB[c].ClrBit(sq);
		byTypeBB[Types.ALL_PIECES].ClrBit(sq);
		byTypeBB[pt].ClrBit(sq);
		if (Types.TypeOf_Piece(pt) == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].AND(BB.filesBB[Types.File_Of(sq)].newNOT());
		}
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

	public function MovedPieceAfter(m:Move):Int {
		if (Types.Is_Drop(m)) {
			return (m >>> 7) & 0x7F;
		} else { // この瞬間はPromoteは気にしなくて良い
			return PieceOn(Types.Move_FromSq(m));
		}
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

	public function AttacksFromPTypeSQ(sq:Int, pc:Int):Bitboard {
		var pt:Int = Types.TypeOf_Piece(pc);
		if (pt == Types.BISHOP || pt == Types.ROOK || pt == Types.HORSE || pt == Types.DRAGON) {
			return BB.AttacksBB(sq, PiecesAll(), pt);
		} else if (pt == Types.LANCE) {
			var rb = BB.AttacksBB(sq, PiecesAll(), Types.ROOK);
			var b = BB.getStepAttacksBB(pc, sq).newAND(rb);
			return b;
		} else {
			return BB.getStepAttacksBB(pc, sq); // P N S G K
		}
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
