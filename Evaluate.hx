package;

import haxe.io.BytesData;
import js.lib.ArrayBuffer;
import js.lib.DataView;
// import js.html.XMLHttpRequest;
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
	    new ExtBonaPiece(f_gold, e_gold), // 9 成歩
	    new ExtBonaPiece(f_gold, e_gold), //10 成香
	    new ExtBonaPiece(f_gold, e_gold), //11 成桂
	    new ExtBonaPiece(f_gold, e_gold), //12 成銀
	    new ExtBonaPiece(f_horse, e_horse), //13 馬
	    new ExtBonaPiece(f_dragon, e_dragon), //14 龍
	    new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO), //15 金の成りはない
	    // 後手から見た場合。fとeが入れ替わる。
	    new ExtBonaPiece(BONA_PIECE_ZERO, BONA_PIECE_ZERO),//16
	    new ExtBonaPiece(e_pawn, f_pawn),//17
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

	public function new() {
		for(i in 0...length()){
			pieceListFb[i] = 0;
			pieceListFw[i] = 0;
		}
	}

	// 評価関数(FV38型)で用いる駒番号のリスト
	public function piece_list_fb() { return pieceListFb; }
	public function piece_list_fw() { return pieceListFw; }

	public function length():Int {
		return PIECE_NUMBER_KING; // 駒リストの長さ // 38固定
	}

	// 盤上のsqの升にpiece_noのpcの駒を配置する
	public function put_piece(piece_no:PieceNumber , sq:Int, pc:PC) {
		set_piece_on_board(
			piece_no
			, kpp_board_index[pc].fb + sq
			, kpp_board_index[pc].fw + Types.Inv(sq)
			, sq);
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
	private static inline var FV_SCALE:Int = 32;
	// 評価関数パラメーター
	private static var kk:Vector<Vector<Vector<Int>>>;  //EvalValueKK.kk; //[[[]]];//[SQ_NB][SQ_NB][2];
	private static var kkp:Vector<Vector<Vector<Vector<Int>>>>;//[SQ_NB][SQ_NB][fe_end][2];
	// private static var kpp:Vector<Vector<Vector<Int>>>;//[SQ_NB][fe_end][fe_end];

	public static function Init() {
		trace('Evaluate::Init ${fe_end}');
		kk = new Vector(Types.SQ_NB);
		for (i in 0...Types.SQ_NB){
			kk[i] = new Vector(Types.SQ_NB);
			for (j in 0...Types.SQ_NB){
				kk[i][j] = new Vector(2);
				kk[i][j][0] = 0;
				kk[i][j][1] = 0;
			}
		} 
		kkp = new Vector(Types.SQ_NB);
		for (i in 0...Types.SQ_NB){
			kkp[i] = new Vector(Types.SQ_NB);
			for (j in 0...Types.SQ_NB){
				kkp[i][j] = new Vector(fe_end);
				for (m in 0...fe_end){
					kkp[i][j][m] = new Vector(2);
					kkp[i][j][m][0] = 0;
					kkp[i][j][m][1] = 0;
				}
			}
		} 
		// kpp = new Vector(Types.SQ_NB);
		// for (i in 0...Types.SQ_NB){
		// 	kpp[i] = new Vector(fe_end);
		// 	for (j in 0...fe_end){
		// 		kpp[i][j] = new Vector(fe_end);
		// 		for (k in 0...fe_end){
		// 			kpp[i][j][k] = 0;
		// 		}
		// 	}
		// } 
		load_eval();
	}

	private static function load_eval(){
		load_eval_impl();
	}
	private static function load_eval_impl(){
		// load_eval_kk();
		// load_eval_kkp();
		// load_eval_kpp();
	}
	// private static function load_eval_kk(){
	// 	var filename = 'bin/KK_synthesized.bin';
	// 	var request:XMLHttpRequest = new XMLHttpRequest();
	// 	request.open('GET', filename, true);
	// 	request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER; //'arraybuffer';
	// 	request.onload = function (e) {
	// 		trace('kk read start');
	// 		var arrayBuffer:ArrayBuffer = request.response; 	
	// 		if (arrayBuffer == null || arrayBuffer.byteLength < 1000) {
	// 			trace('kk buffer is null');
	// 			return;
	// 		}
	// 		var dataview:DataView = new DataView(arrayBuffer);
	// 		var bytesData = new BytesData(dataview.byteLength);
	// 		final byteSize = 4;
	// 		var p:Int = 0;
	// 		for (i in 0...Types.SQ_NB){
	// 			for (j in 0...Types.SQ_NB){
	// 				for(k in 0...2){
	// 					kk[i][j][k] = dataview.getInt32(p*byteSize, true);// 4byte, littleEdian
	// 					p++;
	// 				}
	// 			}
	// 		} 
	// 		trace('kk read end');
	// 	};		
	// 	request.send(null);
	// }
	// private static function load_eval_kkp(){
	// 	var filename = 'bin/KKP_synthesized.bin';
	// 	var request:XMLHttpRequest = new XMLHttpRequest();
	// 	request.open('GET', filename, true);
	// 	request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER; //'arraybuffer';
	// 	request.onload = function (e) {
	// 		trace('kkp read start ${filename}');
	// 		var arrayBuffer:ArrayBuffer = request.response; 	
	// 		if (arrayBuffer == null || arrayBuffer.byteLength < 1000) {
	// 			trace('kkp buffer is null');
	// 			return;
	// 		}
	// 		var dataview:DataView = new DataView(arrayBuffer);
	// 		var bytesData = new BytesData(dataview.byteLength);
	// 		final byteSize = 4;
	// 		var p:Int = 0;
	// 		for (i in 0...Types.SQ_NB){
	// 			for (j in 0...Types.SQ_NB){
	// 				for (m in 0...fe_end){
	// 					for(k in 0...2){
	// 						kkp[i][j][m][k] = dataview.getInt32(p*byteSize, true);// 4byte, littleEdian
	// 						p++;
	// 					}
	// 				}
	// 			}
	// 		} 
	// 		trace('kkp read end p = ${p}');//20M
	// 	};		
	// 	request.send(null);
	// }
	// private static function load_eval_kpp(){
	// 	var filename = 'bin/KPP_synthesized.bin';
	// 	var request:XMLHttpRequest = new XMLHttpRequest();
	// 	request.open('GET', filename, true);
	// 	request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
	// 	request.onload = function (e) {
	// 		trace('kpp read start');
	// 		var arrayBuffer:ArrayBuffer = request.response; 	
	// 		if (arrayBuffer == null || arrayBuffer.byteLength < 1000) {
	// 			trace('kpp buffer is null');
	// 			return;
	// 		}
	// 		var dataview:DataView = new DataView(arrayBuffer);
	// 		var bytesData = new BytesData(dataview.byteLength);
	// 		final byteSize = 2;
	// 		var p:Int = 0;
	// 		for (i in 0...Types.SQ_NB){
	// 			for (j in 0...fe_end){
	// 				for(k in 0...fe_end){
	// 					kpp[i][j][k] = dataview.getInt16(p*byteSize, true);// 2byte, littleEdian
	// 					p++;
	// 				}
	// 			}
	// 		} 
	// 		trace('kpp read end p = ${p}');//
	// 	};		
	// 	request.send(null);
	// }

	// 評価関数。全計算。(駒割りは差分)
	// 返し値は持たず、計算結果としてpos.state()->sumに値を代入する。
	private static function compute_eval_impl(pos:Position) {
		var sq_bk:Int = pos.king_square(Types.BLACK);
		var sq_wk:Int = pos.king_square(Types.WHITE);
		// var ppkppb:Vector<Vector<Int>> = kpp[sq_bk];// bkの位置のKPP配列
		// var ppkppw:Vector<Vector<Int>> = kpp[Types.Inv(sq_wk)];// wkの位置のKPP配列
		var pos_ = pos;
		var length:Int = pos_.eval_list().length();//// 駒リストの長さ // 38固定
		var list_fb = pos_.eval_list().piece_list_fb();// 先手のBonaPiece配列
		var list_fw = pos_.eval_list().piece_list_fw();// 後手のBonaPiece配列
		var k0:BonaPiece, k1:BonaPiece, l0:BonaPiece, l1:BonaPiece;
		var sum:EvalSum = new EvalSum(); // 評価値を管理するクラス
		sum.p[0][0] = /*sum.p[0][1] =*/ sum.p[1][0] = /*sum.p[1][1] =*/ 0; // sum.p[0](BKPP)とsum.p[1](WKPP)をゼロクリア
		// KK T
		sum.p[2][0] = kk[sq_bk][sq_wk][0];
		sum.p[2][1] = kk[sq_bk][sq_wk][1];// sum.p[2] = kk[sq_bk][sq_wk];
		for (i in  0...length) {
			k0 = list_fb[i];// 先手のBonaPieceを取得
			k1 = list_fw[i];// 後手のBonaPieceを取得
			// var pkppb:Vector<Int> = ppkppb[k0];// 先手のBPの位置のKPP配列
			// var pkppw:Vector<Int> = ppkppw[k1];// 後手のBPの位置のKPP配列
			// for (j in 0...i) {
			// 	l0 = list_fb[j];
			// 	l1 = list_fw[j];
			// 	// KPP
			// 	sum.p[0][0] += pkppb[l0];
			// 	sum.p[1][0] += pkppw[l1];
			// }
			// KKP T
			sum.p[2][0] += kkp[sq_bk][sq_wk][k0][0];
			sum.p[2][1] += kkp[sq_bk][sq_wk][k1][1];// sum.p[2] += kkp[sq_bk][sq_wk][k0];
		}
		var st = pos.state();
		sum.p[2][0] += st.materialValue * FV_SCALE;
		st.sum = sum;
	}

	// 評価関数。差分計算ではなく全計算する。
	// Position::set()で一度だけ呼び出される。(以降は差分計算)
	// 手番側から見た評価値を返すので注意。(他の評価関数とは設計がこの点において異なる)
	// なので、この関数の最適化は頑張らない。
	public static function compute_eval(pos:Position):Int {
		compute_eval_impl(pos);
		return Std.int(pos.state().sum.sum(pos.side_to_move()) / FV_SCALE);
	}

	private static function  evaluateBody(pos:Position) {
		compute_eval_impl(pos);// Todo 差分計算
	}

	public static function DoEvaluate(pos:Position, doTrace:Bool):Int {
		compute_eval(pos);
		var st = pos.state();
		var sum = st.sum;
		return Std.int(sum.sum(pos.side_to_move()) / FV_SCALE);
	}
}
