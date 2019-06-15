package;

import Types.Move;
import Types.PC;
import Types.PR;
import Types.PT;

@:allow()
class Position {
	public var board:Array<Int> = [];
	public var sideToMove:Int = Types.BLACK;
	public var hand:Array<Array<Int>> = [];
	public var byTypeBB:Array<Bitboard> = [];
	public var byColorBB:Array<Bitboard> = [];
	private var st:StateInfo;

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
		st = new StateInfo();
	}

	public function PiecesAll():Bitboard {
		return byTypeBB[Types.ALL_PIECES];
	}

	public function PiecesColour(c:Int):Bitboard {
		return byColorBB[c];
	}

	public function PiecesColourType(c:Int, pt:PT):Bitboard {
		return byColorBB[c].newAND(byTypeBB[pt]);
	}

	public function PieceOn(sq:Int):PC {
		return new PC(board[sq]);
	}

	private function changeSideToMove() {
		sideToMove = (sideToMove + 1) % 2;
	}

	public function doMove(move:Move) {
		doMoveFull(move);
	}

	private function doMoveFull(move:Move) {
		trace('Position::doMoveFull ${Types.Move_To_String(move)}');
		var from = Types.Move_FromSq(move);
		var to = Types.Move_ToSq(move);
		var us = sideToMove;
		var them:Int = Types.OppColour(us);
		var pc:PC = MovedPieceAfter(move);
		var pr:PR = Types.RawTypeOf(pc);
		var pt = Types.TypeOf_Piece(pc);
		trace('to: $to from: $from pc: $pc');
		if (Types.Is_Drop(move)) {
			SubHand(us, pr);
			PutPiece(to, us, pt);
			changeSideToMove();
			return;
		}
		var captured:PT = Types.TypeOf_Piece(PieceOn(to));
		var capturedRaw:PR = Types.RawTypeOf(captured);
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
			PutPiece(to, us, new PT(pt + Types.PIECE_PROMOTE) );
		}
		st.capturedType = captured;
		changeSideToMove();
	}

	public function undoMove(move:Move) {
		trace('Position::undoMove');
		changeSideToMove(); //sideToMove =Types.OppColour(sideToMove);
		var us:Int = sideToMove;
		var them:Int = Types.OppColour(us);
		var to:Int = Types.Move_ToSq(move);
		var pc:PC = MovedPieceAfter(move);
		var pr:PR = Types.RawTypeOf(pc);
		var pt:PT = Types.TypeOf_Piece( PieceOn(to) );
		if( Types.Is_Drop(move) ){
			AddHand(us, pr);
			RemovePiece(to, us, pt);
		}
		else{
			var from:Int = Types.Move_FromSq(move);
			var captured:PT = st.capturedType;
			var capturedRaw:PR = Types.RawTypeOf(captured);
			if( Types.Move_Type(move) == Types.MOVE_PROMO ) {
				var promotion:PT = pt;
				pt = new PT(pt - Types.PIECE_PROMOTE);
				RemovePiece( to, us, promotion );
				PutPiece( to, us, pt );
			}
		 	MovePiece( to, from, us, pt ); 
			if( captured != 0 ) {
				var capsq:Int = to;
				SubHand(us, capturedRaw);
				PutPiece( capsq, them, captured ); 
			}
		}
	}

	public function PutPiece(sq:Int, c:Int, pt:PT) {
		trace('Position::PutPiece sq:$sq c:$c pt:$pt');
		board[sq] = Types.Make_Piece(c, pt);
		byColorBB[c].SetBit(sq);
		byTypeBB[Types.ALL_PIECES].SetBit(sq);
		byTypeBB[pt].SetBit(sq);
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.File_Of(sq)]);
		}
	}

	public function MovePiece(from:Int, to:Int, c:Int, pt:PT) {
		trace('Position::MovePiece from:$from to:$to c:$c pt:$pt');
		board[to] = Types.Make_Piece(c, pt);
		board[from] = 0;
		byColorBB[c].SetBit(to);
		byTypeBB[Types.ALL_PIECES].SetBit(to);
		byTypeBB[pt].SetBit(to);
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.File_Of(to)]);
		}
	}

	private function RemovePiece(sq:Int, c:Int, pt:PT) {
		trace('Position::RemovePiece sq:$sq c:$c pt:$pt');
		board[sq] = 0;
		byColorBB[c].ClrBit(sq);
		byTypeBB[Types.ALL_PIECES].ClrBit(sq);
		byTypeBB[pt].ClrBit(sq);
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].AND(BB.filesBB[Types.File_Of(sq)].newNOT());
		}
	}

	public function HandExists(c:Int, pr:PR):Bool {
		return hand[c][pr] > 0;
	}

	public function AddHand(c:Int, pr:PR, n:Int = 1) {
		hand[c][pr] += n;
	}

	public function SubHand(c:Int, pr:PR, n:Int = 1) {
		hand[c][pr] -= n;
	}

	public function HandCount(c:Int, pr:PR):Int {
		return hand[c][pr];
	}

	public function MovedPieceAfter(m:Move):PC {
		if (Types.Is_Drop(m)) {
			return new PC((m >>> 7) & 0x7F);
		} else { // この瞬間はPromoteは気にしなくて良い
			return PieceOn(Types.Move_FromSq(m));
		}
	}

	public function setPosition(sfen) {
		InitBB();
		var sf:SFEN = new SFEN(sfen);
		sideToMove = sf.SideToMove();
		board = sf.getBoard();
		for (i in 0...81) {
			var pc = PieceOn(i);
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

	public function AttacksFromPTypeSQ(sq:Int, pc:PC):Bitboard {
		var pt:PT = Types.TypeOf_Piece(pc);
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
