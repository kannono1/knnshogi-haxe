package;

import haxe.ds.Vector;
import Evaluate.BonaPiece;
import Evaluate.EvalList;
import LongEffect.ByteBoard;
import LongEffect.WordBoard;
import LongEffect.LongEffect;
import Types.PieceNumber;
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
	public var hand:Array<Array<Int>> = []; // [color][count]
	public var byTypeBB:Array<Bitboard> = []; // 駒種類ごとのBB
	public var byColorBB:Array<Bitboard> = []; // 先後のBB
	public var index:Array<Int> = []; // [sq]=pieceCount[c][pt]
	public var pieceCount:Array<Array<Int>> = []; // [c][pt]=count
	public var pieceList:Array<Array<Array<Int>>> = []; // [c][pt][index]=sq
	public var materialValue:Int = 0; // 駒割
	public var board_effect:Vector<ByteBoard> = new Vector<ByteBoard>(Types.COLOR_NB); // 各升の利きの数
	public var long_effect:WordBoard = new WordBoard(); // 長い利き(これは先後共用)

	private var st:StateInfo; // undoのときに使用する
	private var evalList:EvalList = new EvalList();
	private var nodes:Int = 0; // count of domove

	public function new() {
		LongEffect.init(this);
		InitBB();
	}

	public function eval_list():EvalList {
		return evalList;
	}

	
	public function ADD_BOARD_EFFECT(c, to, e1) {
		board_effect[c].e[to] += e1;
	}

	public static function Init() {
		psq[Types.BLACK] = [];
		psq[Types.WHITE] = [];
		for (pt in Types.NO_PIECE_TYPE...Types.PIECE_TYPE_NB) {
			psq[Types.BLACK][pt] = [];
			psq[Types.WHITE][pt] = [];
			var v:Int = pieceValue[pt];
			for (s in Types.SQ_11...Types.SQ_NB) {
				var sFlip:Int = Types.FlipSquare(s);
				psq[Types.BLACK][pt][s] = (v + PSQTable.psqT[pt][s]);
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

	public function pawn_effect(sq:Int, c:Int):Bitboard {
		return BB.stepAttacksBB[Types.Make_Piece(c, Types.PAWN)][sq];
	}

	// sqに移動できる駒のBBを返す
	public function AttackersToSq(sq:Int):Bitboard {
		return AttackersTo(sq, byTypeBB[Types.ALL_PIECES]);
	}

	public function Nodes():Int
		return nodes;

	// 王手をかけている駒のBBを返す
	public function Checkers():Bitboard {
		return st.checkersBB;
	}

	public function in_check():Bool {
		return Checkers().IsNonZero();
	}

	// c側の玉に対してpinしている駒(その駒をc側の玉との直線上から動かしたときにc側の玉に王手となる)
	public function blockers_for_king(c:Int):Bitboard {
		return st.blockersForKing[c];
	}

	public function king_square(c:Int):Int {
		return pieceList[c][Types.KING][0];
	}

	public function legal(m:Move):Bool {
		if (Types.is_drop(m)) {
			return true;
		}
		var us:Int = sideToMove;
		var from:Int = Types.move_from(m);
		// 王の自殺手チェック
		if (Types.TypeOf_Piece(piece_on(from)) == Types.KING) {
			if (!AttackersToSq(Types.move_to(m)).newAND(PiecesColour(Types.OppColour(us))).IsZero()) {
				return false;
			}
		}
		// 自玉への開き王手のチェック
		// blockers_for_king()は、pinされている駒(自駒・敵駒)を表現するが、fromにある駒は自駒であることは
		// わかっているのでこれで良い。
		return !(blockers_for_king(us).isSet(from)) /** 移動する駒がブロッカー **/
			|| Types.aligned(from, Types.to_sq(m), king_square(us)); // 移動先が王の直線上か
	}

	public function pieces():Bitboard {
		return PiecesAll();
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

	public function piece_on(sq:Int):PC {
		return new PC(board[sq]);
	}

	private function piecesType(pt:PT):Bitboard {
		return byTypeBB[pt];
	}

	private function between_bb(from:Int, to:Int):Bitboard {
		return BB.betweenBB[from][to];
	}

	// c側の手駒ptの最後の1枚のBonaPiece番号を返す
	private function bona_piece_of(c:Int, pt:PT):BonaPiece {
		var ct:Int = hand[c][pt];
		return evalList.kpp_hand_index[c][pt].fb + ct - 1;
	}

	// c側の手駒ptの(最後の1枚の)PieceNumberを返す。
	private function piece_no_of_hand(c:Int, pt:PT):PieceNumber {
		return evalList.piece_no_of_hand(bona_piece_of(c, pt));
	}

	// 盤上のsqの升にある駒のPieceNumberを返す。
	private function piece_no_of(sq:Int):PieceNumber {
		return evalList.piece_no_of_board(sq);
	}

	public function PiecesTypes(pt1:PT, pt2:PT):Bitboard {
		return byTypeBB[pt1].newOR(byTypeBB[pt2]);
	}

	private function changeSideToMove() {
		sideToMove = (sideToMove + 1) % 2;
	}

	private function set_check_info(si:StateInfo) {
		// 王手を遮断する駒の情報
		si.blockersForKing[Types.WHITE] = slider_blockers(Types.BLACK, king_square(Types.WHITE), si.pinners[Types.WHITE]);
		si.blockersForKing[Types.BLACK] = slider_blockers(Types.WHITE, king_square(Types.BLACK), si.pinners[Types.BLACK]);
	}

	// return: blockers(飛び駒と玉の間にある駒（敵味方両方）)を返す。ついでにpinnersも更新する。
	// c : 敵
	// s : king square
	private function slider_blockers(c:Int, s:Int, pinners:Bitboard):Bitboard {
		var us = Types.OppColour(c);
		var blockers = new Bitboard();
		var rook_dragons:Bitboard = piecesType(Types.ROOK).newOR(piecesType(Types.DRAGON)).newAND(BB.rookStepEffect(s)); // 飛車・龍
		var bishop_horses:Bitboard = piecesType(Types.BISHOP).newOR(piecesType(Types.HORSE)).newAND(BB.bishopStepEffect(s)); // 角・馬
		var lances:Bitboard = piecesType(Types.LANCE).newAND(BB.lanceStepEffect(us, s)); // 香に関しては攻撃駒が先手なら、玉より下側をサーチして、そこにある先手の香を探す。
		var snipers:Bitboard = rook_dragons.newOR(bishop_horses).newOR(lances).newAND(PiecesColour(c)); // 王に効きを持つ飛び駒
		while (snipers.IsNonZero()) {
			var sniperSq:Int = snipers.PopLSB(); // スナイパーのsq
			var b:Bitboard = between_bb(s, sniperSq).newAND(PiecesAll()); // occupancy // snipperと玉との間にある駒のBitboard
			if (b.IsNonZero() && !b.more_than_one()) { // snipperと玉との間にある駒が1個であるなら。
				blockers.OR(b); // blockersに追加
				if (b.newAND(PiecesColour(us)).IsNonZero()) {
					pinners.SetBit(b.LSB()); // sniperと玉に挟まれた駒が玉と同じ色の駒であるなら、pinnerに追加。
				}
			}
		}
		return blockers;
	}

	public function countNode() {
		nodes++;
	}

	public function do_move(move:Move, newSt:StateInfo) {
		doMoveFull(move, newSt);
	}

	private function doMoveFull(move:Move, newSt:StateInfo) {
		var from = Types.move_from(move);
		var to = Types.move_to(move);
		var us = sideToMove;
		var them:Int = Types.OppColour(us);
		var pc:PC = MovedPieceAfter(move);
		var pr:PR = Types.RawTypeOf(pc);
		var pt = Types.TypeOf_Piece(pc);
		var moved_after_pc:PC = (Types.Move_Type(move) == Types.MOVE_PROMO)?new PC(pc+Types.PIECE_PROMOTE):pc;
		var materialDiff:Int = 0;
		countNode();
		newSt.Copy(st);
		newSt.previous = st;
		st = newSt;
		if (Types.is_drop(move)) {
			st.dirtyPiece.dirty_num = 1;
			PutPiece(to, us, pt);
			var piece_no:PieceNumber = piece_no_of(pr);
			evalList.put_piece(piece_no, to, pc);
			SubHand(us, pr);
			materialDiff = 0; // 駒打ちなので駒割りの変動なし。
			st.checkersBB = AttackersToSq(king_square(them)).newAND(PiecesColour(us)); // 相手玉への王手駒
			// 駒打ちによる利きの更新処理
			LongEffect.update_by_dropping_piece(this, to, pc);
			changeSideToMove();
			return;
		}
		var capturedPC:PC = piece_on(to);
		var captured:PT = Types.TypeOf_Piece(capturedPC);
		var capturedRaw:PR = Types.RawTypeOf(captured);
		if (captured != 0) {
			// 移動先で駒を捕獲するときの利きの更新
			LongEffect.update_by_capturing_piece(this, from, to, pc, moved_after_pc, capturedPC);
			var capsq:Int = to;
			var piece_no:PieceNumber = piece_no_of(to);
			evalList.put_piece_hand(piece_no, us, new PT(pr), HandCount(us, pr));
			AddHand(us, capturedRaw);
			RemovePiece(capsq, them, captured);
		}
		else{
			// 移動先で駒を捕獲しないときの利きの更新
			LongEffect.update_by_no_capturing_piece(this, from, to, pc, moved_after_pc);
		}
		var piece_no2:PieceNumber = piece_no_of(from);
		RemovePiece(from, us, pt);
		MovePiece(from, to, us, pt);
		evalList.put_piece(piece_no2, to, pc);
		if (Types.Move_Type(move) == Types.MOVE_PROMO) {
			RemovePiece(to, us, pt);
			PutPiece(to, us, new PT(pt + Types.PIECE_PROMOTE));
			materialDiff = Evaluate.proDiffPieceValue[pt];
		}
		st.capturedType = captured;
		materialDiff += Evaluate.capturePieceValue[captured];
		st.materialValue = st.previous.materialValue + (us == Types.BLACK ? materialDiff : -materialDiff);
		st.checkersBB = AttackersToSq(king_square(them)).newAND(PiecesColour(us)); // 相手玉への王手駒
		changeSideToMove();
		set_check_info(st);
	}

	public function undo_move(move:Move) {
		changeSideToMove(); // sideToMove =Types.OppColour(sideToMove);
		var us:Int = sideToMove;
		var them:Int = Types.OppColour(us);
		var to:Int = Types.move_to(move);
		var pc:PC = MovedPieceAfter(move);
		var pr:PR = Types.RawTypeOf(pc);
		var pt:PT = Types.TypeOf_Piece(piece_on(to));
		var moved_after_pc:PC = (Types.Move_Type(move) == Types.MOVE_PROMO)?new PC(pc+Types.PIECE_PROMOTE):pc;
		if (Types.is_drop(move)) {
			AddHand(us, pr);
			RemovePiece(to, us, pt);
			// 駒打ちのundoによる利きの復元
			LongEffect.rewind_by_dropping_piece(this, to, moved_after_pc);
		} else {
			var from:Int = Types.move_from(move);
			var captured:PT = st.capturedType;
			var to_pc:PC = Types.Make_Piece(them, captured);
			var capturedRaw:PR = Types.RawTypeOf(captured);
			if (Types.Move_Type(move) == Types.MOVE_PROMO) {
				var promotion:PT = pt;
				pt = new PT(pt - Types.PIECE_PROMOTE);
				RemovePiece(to, us, promotion);
				PutPiece(from, us, pt);
			} else {
				RemovePiece(to, us, pt);
				PutPiece(from, us, pt);
			}
			if (captured != 0) {
				var capsq:Int = to;
				SubHand(us, capturedRaw);
				PutPiece(capsq, them, captured);
				// 移動先で駒を捕獲するときの利きの更新
				LongEffect.rewind_by_capturing_piece(this, from, to, pc, moved_after_pc, to_pc);
			}
			else{
				// 移動先で駒を捕獲しないときの利きの更新
				LongEffect.rewind_by_no_capturing_piece(this, from, to, pc, moved_after_pc);
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
		index[sq] = pieceCount[c][pt]++;
		pieceList[c][pt][index[sq]] = sq;
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].OR(BB.filesBB[Types.file_of(sq)]);
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
			BB.pawnLineBB[c].OR(BB.filesBB[Types.file_of(to)]);
		}
	}

	private function RemovePiece(sq:Int, c:Int, pt:PT) {
		board[sq] = 0;
		byColorBB[c].ClrBit(sq);
		byTypeBB[Types.ALL_PIECES].ClrBit(sq);
		byTypeBB[pt].ClrBit(sq);
		pieceCount[c][Types.ALL_PIECES]--;
		if (pieceCount[c][pt] > 0) {
			pieceCount[c][pt]--;
		}
		var lastSquare:Int = pieceList[c][pt][pieceCount[c][pt]];
		index[lastSquare] = index[sq];
		pieceList[c][pt][index[lastSquare]] = lastSquare;
		pieceList[c][pt][pieceCount[c][pt]] = Types.SQ_NONE;
		if (pt == Types.PAWN) { // 二歩用BB更新
			BB.pawnLineBB[c].AND(BB.filesBB[Types.file_of(sq)].newNOT());
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
		#if debug
		try {
		#end
			var attBB:Bitboard = pawn_effect(s, Types.BLACK).newAND(PiecesColourType(Types.WHITE, Types.PAWN));
			attBB.OR(pawn_effect(s, Types.WHITE).newAND(PiecesColourType(Types.BLACK, Types.PAWN)));
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
			attBB.OR(AttacksFromPTypeSQ(s, Types.B_KING).newAND(piecesType(Types.KING)));
			return attBB;
		#if debug
		} catch (e) {
			trace('ERR ${e}');
			DebugInfo.print();
			return null;
		}
		#end
	}

	public function MovedPieceAfter(m:Move):PC {
		if (Types.is_drop(m)) {
			return new PC((m >>> 7) & 0x7F);
		} else { // この瞬間はPromoteは気にしなくて良い
			return piece_on(Types.move_from(m));
		}
	}

	public function setPosition(sfen:String) {
		// PieceListを更新する上で、どの駒がどこにあるかを設定しなければならないが、
		// それぞれの駒をどこまで使ったかのカウンター
		var piece_no_count:Array<PieceNumber> = [
			  PIECE_NUMBER_ZERO,   PIECE_NUMBER_PAWN, PIECE_NUMBER_LANCE, PIECE_NUMBER_KNIGHT,
			PIECE_NUMBER_SILVER, PIECE_NUMBER_BISHOP,  PIECE_NUMBER_ROOK,   PIECE_NUMBER_GOLD
		];
		InitBB();
		Clear();
		var sf:SFEN = new SFEN(sfen);
		sideToMove = sf.SideToMove();
		board = sf.getBoard();
		for (sq in 0...81) {
			var pc = piece_on(sq);
			var pt = Types.TypeOf_Piece(pc);
			var c = Types.getPieceColor(pc);
			if (pc == 0) {
				continue;
			}
			PutPiece(sq, c, pt);
			var piece_no:PieceNumber = (pc == Types.B_KING) ? PIECE_NUMBER_BKING : /** 先手玉 **/ (pc == Types.W_KING) ? PIECE_NUMBER_WKING : /** 後手玉 **/ piece_no_count[Types.raw_type_of(pc)]++; // それ以外

			evalList.put_piece(piece_no, sq, pc); // sqの升にpcの駒を配置する // on sfen
		}
		hand = sf.getHand();
		for (c in 0...Types.COLOR_NB) {
			for (rpc in 0...Types.PIECE_HAND_NB) {
				for (i in 0...hand[c][rpc]) {
					var piece_no:PieceNumber = piece_no_count[rpc]++;
					evalList.put_piece_hand(piece_no, c, new PT(rpc), i);
				}
			}
		}
		// st.materialValue = Evaluate.material(this);
		var moves = sf.getMoves();
		for (i in 0...moves.length) {
			do_move(moves[i], new StateInfo());
		}
		st.checkersBB = AttackersToSq(king_square(sideToMove)).newAND(PiecesColour(Types.OppColour(sideToMove)));
		LongEffect.calc_effect(this);
	}

	public function side_to_move():Int {
		return sideToMove;
	}

	public function SideToMove():Int {
		return sideToMove;
	}

	public function state():StateInfo {
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
		nodes = 0;
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

	public function printBoard(msg:String = "") {
		var s = '+++ printBoard +++ : ${msg}';
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

	public function printHand() {
		trace(hand);
	}

	public function printPieceNo() {
		evalList.printPieceNo();
	}

}
