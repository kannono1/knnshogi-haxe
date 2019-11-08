package;

import Types.PR;

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

	public static function material(pos:Position):Int {
		var v:Int = 0;
		for (sq in 0...Types.SQ_NB) {
			v += pieceValue[pos.PieceOn(sq)];
		}
		for(c in 0...Types.COLOR_NB){
			for(pr in Types.PAWN...Types.PIECE_HAND_NB){
				v += (c == Types.BLACK ? 1 : -1) * pos.HandCount(c, new PR(pr)) * pieceValue[pr];
				// v += pos.HandCount(c, new PR(pr)) * pieceValue[pr];
			}
		}
		return v;
	}

	public static function DoEvaluate(pos:Position, doTrace:Bool):Int {
		trace('Evaluate::DoEvaluate v=${pos.state().materialValue} c=${pos.SideToMove()} c2=${pos.sideToMove} -v=${-pos.state().materialValue}');
		return (pos.SideToMove() == Types.BLACK)? pos.state().materialValue : -1 * pos.state().materialValue;
	}
}
