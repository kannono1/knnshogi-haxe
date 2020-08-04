package;

import Types.Move;
import Types.PC;
import Types.PR;
import Types.PT;

@:allow()
class Position {
	public static var psq:Array<Array<Array<Int>>> = []; // [color][pt][sq] = v
	public static var pieceValue:Array<Int> = [
		Types.VALUE_ZERO, Types.PawnValue, Types.LanceValue, Types.KnightValue, Types.SilverValue, Types.BishopValue, Types.RookValue, Types.GoldValue,
		Types.KingValue, Types.ProPawnValue, Types.ProLanceValue, Types.ProKnightValue, Types.ProSilverValue, Types.HorseValue, Types.DragonValue
	];

	public var board:Array<Int> = [];
	public var sideToMove:Int = Types.BLACK;
	public var hand:Array<Array<Int>> = [];
	public var byTypeBB:Array<Bitboard> = [];
	public var byColorBB:Array<Bitboard> = [];
	public var index:Array<Int> = []; // [sq]=pieceCount[c][pt]
	public var pieceCount:Array<Array<Int>> = []; // [c][pt]=count
	public var pieceList:Array<Array<Array<Int>>> = []; // [c][pt][index]=sq
	public var materialValue:Int = 0;// 駒割

	private var st:StateInfo;// undoのときに使用する

	public function new() {
		InitBB();
	}

	public static function Init() {
		psq[Types.BLACK] = [];
		psq[Types.WHITE] = [];
		for (pt in Types.NO_PIECE_TYPE...Types.PIECE_TYPE_NB) {
			psq[Types.BLACK][pt] = [];
			psq[Types.WHITE][pt] = [];
			var v:Int = pieceValue[pt];
			for (s in Types.SQ_A1...Types.SQ_NB) {
				var sFlip:Int = Types.FlipSquare(s);
				psq[Types.BLACK][pt][s]     =  (v + PSQTable.psqT[pt][s]);
				psq[Types.WHITE][pt][sFlip] = -(v + PSQTable.psqT[pt][s]);
			}
		}
	}

	public function InitBB() {
		byTypeBB = [];
		for (i in 0...Types.PIECE_NB) {
			byTypeBB.push(new Bitboard());
		}
		byColorBB = [];
		for (i in 0...Types.COLOR_NB) {
			byColorBB.push(new Bitboard());
			pieceCount[i] = [];
			pieceList[i] = [];
			for (j in 0...Types.PIECE_TYPE_NB) {
				pieceCount[i][j] = 0;
				pieceList[i][j] = [];
			}
		}
		st = new StateInfo();
	}

	public function AttacksFromPawn(sq:Int, c:Int):Bitboard {
		return BB.stepAttacksBB[Types.Make_Piece(c, Types.PAWN)][sq];
	}

	// sqに移動できる駒のBBを返す
	public function AttackersToSq(sq:Int):Bitboard {
		return AttackersTo(sq, byTypeBB[Types.ALL_PIECES]);
	}

	// 王手をかけている駒のBBを返す
	public function Checkers():Bitboard {
		return st.checkersBB;
	}

	public function KingSquare(c:Int):Int {
		return pieceList[c][Types.KING][0];
	}

	public function Legal(m:Move):Bool {
		if (Types.Is_Drop(m)) {
			return true;
		}
		var us:Int = sideToMove;
		var from:Int = Types.Move_FromSq(m);
		if (Types.TypeOf_Piece(PieceOn(from)) == Types.KING) {
			if (AttackersToSq(Types.Move_ToSq(m)).newAND(PiecesColour(Types.OppColour(us))).IsZero()) {
				return true;
			}
			return false;
		}
		return true;
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

	public function PiecesType(pt:PT):Bitboard {
		return byTypeBB[pt];
	}

	public function PiecesTypes(pt1:PT, pt2:PT):Bitboard {
		return byTypeBB[pt1].newOR(byTypeBB[pt2]);
	}

	private function changeSideToMove() {
		sideToMove = (sideToMove + 1) % 2;
	}

	public function doMove(move:Move, newSt:StateInfo) {
		doMoveFull(move, newSt);
	}

	private function doMoveFull(move:Move, newSt:StateInfo) {
		var from = Types.Move_FromSq(move);
		var to = Types.Move_ToSq(move);
		var us = sideToMove;
		var them:Int = Types.OppColour(us);
		var pc:PC = MovedPieceAfter(move);
		var pr:PR = Types.RawTypeOf(pc);
		var pt = Types.TypeOf_Piece(pc);
		var materialDiff:Int = 0;
		newSt.Copy(st);
		newSt.previous = st;
		st = newSt;
		if (Types.Is_Drop(move)) {
			SubHand(us, pr);
			PutPiece(to, us, pt);
			materialDiff = 0; // 駒打ちなので駒割りの変動なし。
			changeSideToMove();
			return;
		}
		var captured:PT = Types.TypeOf_Piece(PieceOn(to));
		var capturedRaw:PR = Types.RawTypeOf(captured);
		if (captured != 0) {
			var capsq:Int = to;
			AddHand(us, capturedRaw);
			RemovePiece(capsq, them, captured);
		}
		RemovePiece(from, us, pt);
		MovePiece(from, to, us, pt);
		if (Types.Move_Type(move) == Types.MOVE_PROMO) {
			RemovePiece(to, us, pt);
			PutPiece(to, us, new PT(pt + Types.PIECE_PROMOTE));
			materialDiff = Evaluate.proDiffPieceValue[pt];
		}
		st.capturedType = captured;
		materialDiff += Evaluate.capturePieceValue[captured];
		st.materialValue = st.previous.materialValue + (us == Types.BLACK ? materialDiff : -materialDiff);
		changeSideToMove();
	}

	public function undoMove(move:Move) {
		changeSideToMove(); // sideToMove =Types.OppColour(sideToMove);
		var us:Int = sideToMove;
		var them:Int = Types.OppColour(us);
		var to:Int = Types.Move_ToSq(move);
		var pc:PC = MovedPieceAfter(move);
		var pr:PR = Types.RawTypeOf(pc);
		var pt:PT = Types.TypeOf_Piece(PieceOn(to));
		if (Types.Is_Drop(move)) {
			AddHand(us, pr);
			RemovePiece(to, us, pt);
		} else {
			var from:Int = Types.Move_FromSq(move);
			var captured:PT = st.capturedType;
			var capturedRaw:PR = Types.RawTypeOf(captured);
			if (Types.Move_Type(move) == Types.MOVE_PROMO) {
				var promotion:PT = pt;
				pt = new PT(pt - Types.PIECE_PROMOTE);
				RemovePiece(to, us, promotion);
				PutPiece(to, us, pt);
			}
			else{
				RemovePiece(to, us, pt);
				PutPiece(from, us, pt);
			}
			if (captured != 0) {
				var capsq:Int = to;
				SubHand(us, capturedRaw);
				PutPiece(capsq, them, captured);
			}
		}
		st = st.previous;
	}

	public function PutPiece(sq:Int, c:Int, pt:PT) {
		board[sq] = Types.Make_Piece(c, pt);
		byColorBB[c].SetBit(sq);
		byTypeBB[Types.ALL_PIECES].SetBit(sq);
		byTypeBB[pt].SetBit(sq);
		pieceCount[c][Types.ALL_PIECES]++;
		trace('pieceCount:${pieceCount} c:${c} pt:${pt}');
		index[sq] = pieceCount[c][pt]++;
		trace('index:${index} sq:${sq} index[sq]:${index[sq]}');
		pieceList[c][pt][index[sq]] = sq;
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.File_Of(sq)]);
		}
	}

	public function MovePiece(from:Int, to:Int, c:Int, pt:PT) {
		board[to] = Types.Make_Piece(c, pt);
		board[from] = 0;
		byColorBB[c].SetBit(to);
		byTypeBB[Types.ALL_PIECES].SetBit(to);
		byTypeBB[pt].SetBit(to);
		index[to] = index[from];
		pieceList[c][pt][index[to]] = to;
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.File_Of(to)]);
		}
	}

	private function RemovePiece(sq:Int, c:Int, pt:PT) {
		board[sq] = 0;
		byColorBB[c].ClrBit(sq);
		byTypeBB[Types.ALL_PIECES].ClrBit(sq);
		byTypeBB[pt].ClrBit(sq);
		pieceCount[c][Types.ALL_PIECES]--;
		pieceCount[c][pt]--;
		var lastSquare:Int = pieceList[c][pt][pieceCount[c][pt]];
		index[lastSquare] = index[sq];
		pieceList[c][pt][index[lastSquare]] = lastSquare;
		pieceList[c][pt][pieceCount[c][pt]] = Types.SQ_NONE;
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

	// sの位置に対して効きを持つ駒のBBを返す(先後両方)
	// s = 調べたいSQ
	// occ 盤上の駒BB
	// Sでの移動範囲 - 相手番での駒種位置
	// 移動が上下対称じゃない場合は両方の登録が必要...
	public function AttackersTo(s:Int, occ:Bitboard):Bitboard {
		var attBB:Bitboard = AttacksFromPawn(s, Types.BLACK).newAND(PiecesColourType(Types.WHITE, Types.PAWN));
		attBB.OR(AttacksFromPawn(s, Types.WHITE).newAND(PiecesColourType(Types.BLACK, Types.PAWN)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_KNIGHT).newAND(PiecesColourType(Types.BLACK, Types.KNIGHT)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_KNIGHT).newAND(PiecesColourType(Types.WHITE, Types.KNIGHT)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_LANCE).newAND(PiecesColourType(Types.BLACK, Types.LANCE)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_LANCE).newAND(PiecesColourType(Types.WHITE, Types.LANCE)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_SILVER).newAND(PiecesColourType(Types.BLACK, Types.SILVER)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_SILVER).newAND(PiecesColourType(Types.WHITE, Types.SILVER)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_GOLD).newAND(PiecesColourType(Types.BLACK, Types.GOLD)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_GOLD).newAND(PiecesColourType(Types.WHITE, Types.GOLD)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_PRO_PAWN).newAND(PiecesColourType(Types.BLACK, Types.PRO_PAWN)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_PRO_PAWN).newAND(PiecesColourType(Types.WHITE, Types.PRO_PAWN)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_PRO_LANCE).newAND(PiecesColourType(Types.BLACK, Types.PRO_LANCE)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_PRO_LANCE).newAND(PiecesColourType(Types.WHITE, Types.PRO_LANCE)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_PRO_KNIGHT).newAND(PiecesColourType(Types.BLACK, Types.PRO_KNIGHT)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_PRO_KNIGHT).newAND(PiecesColourType(Types.WHITE, Types.PRO_KNIGHT)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.W_PRO_SILVER).newAND(PiecesColourType(Types.BLACK, Types.PRO_SILVER)));
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_PRO_SILVER).newAND(PiecesColourType(Types.WHITE, Types.PRO_SILVER)));
		attBB.OR(BB.AttacksBB(s, occ, Types.ROOK).newAND(PiecesTypes(Types.ROOK, Types.DRAGON))); // 縦横の効き (まとめて高速化してる？)
		attBB.OR(BB.AttacksBB(s, occ, Types.BISHOP).newAND(PiecesTypes(Types.BISHOP, Types.HORSE))); // 斜めの効き　
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_KING).newAND(PiecesTypes(Types.DRAGON, Types.HORSE))); // 上下左右
		attBB.OR(AttacksFromPTypeSQ(s, Types.B_KING).newAND(PiecesType(Types.KING)));
		return attBB;
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
		Clear();
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
		hand = sf.getHand();
		st.materialValue = Evaluate.material(this);
		var moves = sf.getMoves();
		for (i in 0...moves.length) {
			doMove(moves[i], new StateInfo());
		}
		st.checkersBB = AttackersToSq(KingSquare(sideToMove)).newAND(PiecesColour(Types.OppColour(sideToMove)));
	}

	public function SideToMove():Int {
		return sideToMove;
	}

	public function state():StateInfo{
		return st;
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

	private function Clear() {
		for (i in 0...Types.SQ_NB) {
			board[i] = 0;
			index[i] = 0;
		}
		for (i in 0...Types.PIECE_TYPE_NB) {
			byTypeBB[i].Clear();
		}
		for (i in 0...Types.COLOR_NB) {
			byColorBB[i].Clear();
			pieceCount[i] = [];
			for (j in 0...Types.PIECE_TYPE_NB) {
				pieceCount[i][j] = 0;
				for (k in 0...16) {
					pieceList[i][j][k] = 0;
				}
			}
		}
		for (i in 0...Types.PIECE_TYPE_NB) {
			for (j in 0...16) {
				pieceList[Types.WHITE][i][j] = Types.SQ_NONE;
				pieceList[Types.BLACK][i][j] = Types.SQ_NONE;
			}
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
