package;

import haxe.ds.Vector;
import Types.PC;
import Types.PieceNumber;
import Types.PR;
import Types.PT;

enum abstract BonaPiece(Int) from Int to Int {
	// f = friend(≒先手)の意味。e = enemy(≒後手)の意味
	// 未初期化の時の値
	var BONA_PIECE_NOT_INIT = -1;
	// 無効な駒。駒落ちのときなどは、不要な駒をここに移動させる。
	var BONA_PIECE_ZERO = 0;
	// --- 手駒
	var f_hand_pawn = 1;//0//0+1
	var e_hand_pawn = 20;//f_hand_pawn + 19,//19+1
	var f_hand_lance = 39;//e_hand_pawn + 19,//38+1
	var e_hand_lance = 44;//f_hand_lance + 5,//43+1
	var f_hand_knight = 49;//e_hand_lance + 5,//48+1
	var e_hand_knight = 54;//f_hand_knight + 5,//53+1
	var f_hand_silver = 59;//e_hand_knight + 5,//58+1
	var e_hand_silver = 64;//f_hand_silver + 5,//63+1
	var f_hand_gold = 69;//e_hand_silver + 5,//68+1
	var e_hand_gold = 74;//f_hand_gold + 5,//73+1
	var f_hand_bishop = 79;//e_hand_gold + 5,//78+1
	var e_hand_bishop = 82;//f_hand_bishop + 3,//81+1
	var f_hand_rook = 85;//e_hand_bishop + 3,//84+1
	var e_hand_rook = 88;//f_hand_rook + 3,//87+1
	var fe_hand_end = 90;//e_hand_rook + 3,//90
	// --- 盤上の駒
	var f_pawn = fe_hand_end;
	var e_pawn = f_pawn + 81;
	var f_lance = e_pawn + 81;
	var e_lance = f_lance + 81;
	var f_knight = e_lance + 81;
	var e_knight = f_knight + 81;
	var f_silver = e_knight + 81;
	var e_silver = f_silver + 81;
	var f_gold = e_silver + 81;
	var e_gold = f_gold + 81;
	var f_bishop = e_gold + 81;
	var e_bishop = f_bishop + 81;
	var f_horse = e_bishop + 81;
	var e_horse = f_horse + 81;
	var f_rook = e_horse + 81;
	var e_rook = f_rook + 81;
	var f_dragon = e_rook + 81;
	var e_dragon = f_dragon + 81;
	var fe_old_end = e_dragon + 81;
	var fe_end = fe_old_end;
	// fe_end がKPP配列などのPの値の終端と考えられる。
	// 例) kpp[SQ_NB][fe_end][fe_end];
	// 王も一意な駒番号を付与。これは2駒関係をするときに王に一意な番号が必要なための拡張
	var f_king = fe_end;
	var e_king = f_king + Types.SQ_NB;
	var fe_end2 = e_king + Types.SQ_NB; // 玉も含めた末尾の番号。
	// 末尾は評価関数の性質によって異なるので、BONA_PIECE_NBを定義するわけにはいかない。

}

class ExtBonaPiece{
	public var fb:BonaPiece; // from black
	public var fw:BonaPiece; // from white
	public function new(b:BonaPiece, w:BonaPiece) {
		fb = b;
		fw = w;
	}
}

class EvalList {
	private var kpp_board_index = [
	    new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO),
	    new ExtBonaPiece(f_pawn, e_pawn),
	    new ExtBonaPiece(f_lance, e_lance),
	    new ExtBonaPiece(f_knight, e_knight),
	    new ExtBonaPiece(f_silver, e_silver),
	    new ExtBonaPiece(f_bishop, e_bishop),
	    new ExtBonaPiece(f_rook, e_rook),
	    new ExtBonaPiece(f_gold, e_gold),
	    new ExtBonaPiece(f_king, e_king),
	    new ExtBonaPiece(f_gold, e_gold), // 成歩
	    new ExtBonaPiece(f_gold, e_gold), // 成香
	    new ExtBonaPiece(f_gold, e_gold), // 成桂
	    new ExtBonaPiece(f_gold, e_gold), // 成銀
	    new ExtBonaPiece(f_horse, e_horse), // 馬
	    new ExtBonaPiece(f_dragon, e_dragon), // 龍
	    new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO), // 金の成りはない
	    // 後手から見た場合。fとeが入れ替わる。
	    new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO),
	    new ExtBonaPiece(e_pawn, f_pawn),
	    new ExtBonaPiece(e_lance, f_lance),
	    new ExtBonaPiece(e_knight, f_knight),
	    new ExtBonaPiece(e_silver, f_silver),
	    new ExtBonaPiece(e_bishop, f_bishop),
	    new ExtBonaPiece(e_rook, f_rook),
	    new ExtBonaPiece(e_gold, f_gold),
	    new ExtBonaPiece(e_king, f_king),
	    new ExtBonaPiece(e_gold, f_gold), // 成歩
	    new ExtBonaPiece(e_gold, f_gold), // 成香
	    new ExtBonaPiece(e_gold, f_gold), // 成桂
	    new ExtBonaPiece(e_gold, f_gold), // 成銀
	    new ExtBonaPiece(e_horse, f_horse), // 馬
	    new ExtBonaPiece(e_dragon, f_dragon), // 龍
	    new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO)// 金の成りはない
	  ];

	  public var kpp_hand_index = [
	    [
	      new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO ),
	      new ExtBonaPiece(f_hand_pawn, e_hand_pawn ),
	      new ExtBonaPiece(f_hand_lance, e_hand_lance ),
	      new ExtBonaPiece(f_hand_knight, e_hand_knight ),
	      new ExtBonaPiece(f_hand_silver, e_hand_silver ),
	      new ExtBonaPiece(f_hand_bishop, e_hand_bishop ),
	      new ExtBonaPiece(f_hand_rook, e_hand_rook ),
	      new ExtBonaPiece(f_hand_gold, e_hand_gold ),
	    ],
	    [
	      new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO ),
	      new ExtBonaPiece(e_hand_pawn, f_hand_pawn ),
	      new ExtBonaPiece(e_hand_lance, f_hand_lance ),
	      new ExtBonaPiece(e_hand_knight, f_hand_knight ),
	      new ExtBonaPiece(e_hand_silver, f_hand_silver ),
	      new ExtBonaPiece(e_hand_bishop, f_hand_bishop ),
	      new ExtBonaPiece(e_hand_rook, f_hand_rook ),
	      new ExtBonaPiece(e_hand_gold, f_hand_gold ),
	    ],
	  ];

	private static inline var MAX_LENGTH:Int = 40; // 駒リストの長さ
	private var pieceListFb = new Vector<BonaPiece>(MAX_LENGTH);
	private var pieceListFw = new Vector<BonaPiece>(MAX_LENGTH);
	// 盤上の駒に対して、その駒番号(PieceNumber)を保持している配列
	// 玉がSQ_NBに移動しているとき用に+1まで保持しておくが、
	// SQ_NBの玉を移動させないので、この値を使うことはないはず。
	public var piece_no_list_board = new Vector<PieceNumber>(Types.SQ_NB_PLUS1);
	public var piece_no_list_hand:Array<PieceNumber> = [];

	public function new() { }

	// 盤上のsqの升にpiece_noのpcの駒を配置する
	public function put_piece(piece_no:PieceNumber , sq:Int, pc:PC) {
		set_piece_on_board(piece_no, kpp_board_index[pc].fb + sq, kpp_board_index[pc].fw + Types.Inv(sq), sq);
	}

	// c側の手駒ptのi+1枚目の駒のPieceNumberを設定する。(1枚目の駒のPieceNumberを設定したいならi==0にして呼び出すの意味)
	public function put_piece_hand(piece_no:PieceNumber , c:Int, pt:PT, i:Int) {
		set_piece_on_hand(piece_no, kpp_hand_index[c][pt].fb + i, kpp_hand_index[c][pt].fw + i);
	}

	// あるBonaPieceに対応するPieceNumberを返す。
	public function piece_no_of_hand(bp:BonaPiece):PieceNumber { return piece_no_list_hand[bp]; }

	// 盤上のある升sqに対応するPieceNumberを返す。
	public function piece_no_of_board(sq:Int):PieceNumber { return piece_no_list_board[sq]; }

	public function printPieceNo() {
		trace('EvalList::print');
		var str = "--- print PieceNo ---";
		for(i in 0...Types.SQ_NB){
			if(i%9 == 0){
				str += "\n";
			}
			var s = piece_no_list_board[ Types.bbToSquare[i] ];
			if(Math.isNaN(s)){
				str += " - ";
			}
			else{
				str += ' ${piece_no_list_board[ Types.bbToSquare[i] ]} '.substr(-3);
			}
		}
		trace('${str}');
		trace('piece_no_list_hand: ${piece_no_list_hand}');
	}

	// 盤上sqにあるpiece_noの駒のBonaPieceがfb,fwであることを設定する。
	private function set_piece_on_board(piece_no:PieceNumber , fb:BonaPiece  , fw:BonaPiece , sq:Int) {
		pieceListFb[piece_no] = fb;
		pieceListFw[piece_no] = fw;
		piece_no_list_board[sq] = piece_no;
	}

	// 手駒であるpiece_noの駒のBonaPieceがfb,fwであることを設定する。
	private function set_piece_on_hand(piece_no:PieceNumber , fb:BonaPiece , fw:BonaPiece ) {
		pieceListFb[piece_no] = fb;
		pieceListFw[piece_no] = fw;
		piece_no_list_hand[fb] = piece_no;
	}
}

class DirtyPiece {
	public function new() { }
	// dirtyになった駒番号
	public var pieceNo = new Vector<PieceNumber>(2);
	// dirtyになった個数。
	// null moveだと0ということもありうる。
	// 動く駒と取られる駒とで最大で2つ。
	public var dirty_num:Int = 0;
}

class Evaluate {
	public static var evalRootColour:Int = 0;
	public static var pieceValue:Array<Int> = [
		Types.VALUE_ZERO
		, Types.PawnValue, Types.LanceValue, Types.KnightValue, Types.SilverValue
		, Types.BishopValue
		, Types.RookValue
		, Types.GoldValue
, Types.KingValue
		, Types.ProPawnValue
		, Types.ProLanceValue
		, Types.ProKnightValue
		, Types.ProSilverValue
		, Types.HorseValue
		, Types.DragonValue
		, 0
		, 0
		, -Types.PawnValue
		, -Types.LanceValue
		, -Types.KnightValue
		, -Types.SilverValue
		, -Types.BishopValue
		, -Types.RookValue
		, -Types.GoldValue
		, -Types.KingValue
		, -Types.ProPawnValue
		, -Types.ProLanceValue
		, -Types.ProKnightValue
		, -Types.ProSilverValue
		, -Types.HorseValue
		, -Types.DragonValue
	];
	public static var capturePieceValue:Array<Int> = [
		Types.VALUE_ZERO
		, Types.PawnValue * 2
		, Types.LanceValue * 2
		, Types.KnightValue * 2
		, Types.SilverValue * 2
		, Types.BishopValue * 2
		, Types.RookValue * 2
		, Types.GoldValue * 2
		, Types.KingValue
		, Types.ProPawnValue + Types.PawnValue
		, Types.ProLanceValue + Types.LanceValue
		, Types.ProKnightValue + Types.KnightValue
		, Types.ProSilverValue + Types.SilverValue
		, Types.HorseValue + Types.BishopValue
		, Types.DragonValue + Types.RookValue
		, 0
		, 0
		, Types.PawnValue * 2
		, Types.LanceValue * 2
		, Types.KnightValue * 2
		, Types.SilverValue * 2
		, Types.BishopValue * 2
		, Types.RookValue * 2
		, Types.GoldValue * 2
		, Types.KingValue
		, Types.ProPawnValue + Types.PawnValue
		, Types.ProLanceValue + Types.LanceValue
		, Types.ProKnightValue + Types.KnightValue
		, Types.ProSilverValue + Types.SilverValue
		, Types.HorseValue + Types.BishopValue
		, Types.DragonValue + Types.RookValue
	];
	public static var proDiffPieceValue:Array<Int> = [
		Types.VALUE_ZERO
		, Types.ProPawnValue - Types.PawnValue
		, Types.ProLanceValue - Types.LanceValue
		, Types.ProKnightValue - Types.KnightValue
		, Types.ProSilverValue - Types.SilverValue
		, Types.HorseValue - Types.BishopValue
		, Types.DragonValue - Types.RookValue
		, 0
		, 0
	];

	public static function Init() {}

	// 起動時に呼ばれる。以降は差分計算する。
	public static function material(pos:Position):Int {
		var v:Int = 0;
		for (sq in 0...Types.SQ_NB) {
			v += pieceValue[pos.PieceOn(sq)];
		}
		for(c in 0...Types.COLOR_NB){
			for(pr in Types.PAWN...Types.PIECE_HAND_NB){
				v += (c == Types.BLACK ? 1 : -1) * pos.HandCount(c, new PR(pr)) * pieceValue[pr];
			}
		}
		return v;
	}

	private static function calc_diff_kpp(pos:Position) {
		var st:StateInfo = pos.state();
		var now = st;
		var prev = st.previous;
		var sumKKP:Int = 0;
		var sq_bk0:Int = pos.KingSquare(Types.BLACK);
		var sq_wk1:Int = Types.Inv(pos.KingSquare(Types.WHITE));
		var dp = now.dirtyPiece;
		// var k:Int = dp.dirty_num; // 移動させた駒は最大2つある。その数
		return 0;
	}

	public static function DoEvaluate(pos:Position, doTrace:Bool):Int {
		var score:Int = calc_diff_kpp(pos) + pos.state().materialValue;
		return (pos.SideToMove() == Types.BLACK)? score : -1 * score;
	}
}
