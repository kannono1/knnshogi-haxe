package;

import Types.PieceNumber;
import Types.PR;

enum abstract BonaPiece(Int) to Int {
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

class EvalList {
	public var piece_no_list_hand:Array<PieceNumber> = [];
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
		// var now = st;
		// var prev = st->previous;
		return 0;
	}

	public static function DoEvaluate(pos:Position, doTrace:Bool):Int {
		var score:Int = calc_diff_kpp(pos) + pos.state().materialValue;
		return (pos.SideToMove() == Types.BLACK)? score : -1 * score;
	}
}
