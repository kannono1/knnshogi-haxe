package;

import util.MathUtil;

// --------------------
//   壁つきの升表現
// --------------------

// This trick is invented by yaneurao in 2016.

// 長い利きを更新するときにある升からある方向に駒にぶつかるまでずっと利きを更新していきたいことがあるが、
// sqの升が盤外であるかどうかを判定する簡単な方法がない。そこで、Squareの表現を拡張して盤外であることを検出
// できるようにする。

// bit 0..7   : Squareと同じ意味
// bit 8      : Squareからのborrow用に1にしておく
// bit 9..13  : いまの升から盤外まで何升右に升があるか(ここがマイナスになるとborrowでbit13が1になる)
// bit 14..18 : いまの升から盤外まで何升上に(略
// bit 19..23 : いまの升から盤外まで何升下に(略
// bit 24..28 : いまの升から盤外まで何升左に(略
enum abstract SquareWithWall(Int) from Int to Int {
	// 相対移動するときの差分値
	var SQWW_R = Types.SQ_R - (1 << 9) + (1 << 24);
	var SQWW_U = Types.SQ_U - (1 << 14) + (1 << 19);
	var SQWW_D = -SQWW_U;
	var SQWW_L = -SQWW_R;
	var SQWW_RU = Std.int(SQWW_R) + Std.int(SQWW_U);
	var SQWW_RD = Std.int(SQWW_R) + Std.int(SQWW_D);
	var SQWW_LU = Std.int(SQWW_L) + Std.int(SQWW_U);
	var SQWW_LD = Std.int(SQWW_L) + Std.int(SQWW_D);

	// SQ_11の地点に対応する値(他の升はこれ相対で事前に求めテーブルに格納)
	var SQWW_11 = Types.SQ_11 | (1 << 8) /* bit8 is 1 */ | (0 << 9) /*右に0升*/ | (0 << 14) /*上に0升*/ | (8 << 19) /*下に8升*/ | (8 << 24) /*左に8升*/;

	// SQWW_RIGHTなどを足して行ったときに盤外に行ったときのborrow bitの集合
	var SQWW_BORROW_MASK = (1 << 13) | (1 << 18) | (1 << 23) | (1 << 28);
}

enum abstract PieceNumber(Int) from Int to Int {
	var PIECE_NUMBER_PAWN; 
	var PIECE_NUMBER_LANCE = 18;
	var PIECE_NUMBER_KNIGHT = 22;
	var PIECE_NUMBER_SILVER = 26;
	var PIECE_NUMBER_GOLD = 30;
	var PIECE_NUMBER_BISHOP = 34;
	var PIECE_NUMBER_ROOK = 36;
	var PIECE_NUMBER_KING = 38;
	var PIECE_NUMBER_BKING = 38;
	var PIECE_NUMBER_WKING = 39; // 先手、後手の玉の番号が必要な場合はこっちを用いる
	var PIECE_NUMBER_ZERO = 0;
	var PIECE_NUMBER_NB = 40;	
}

// 方角を表す。遠方駒の利きや、玉から見た方角を表すのに用いる。 8bit
// bit0..右上、bit1..右、bit2..右下、bit3..上、bit4..下、bit5..左上、bit6..左、bit7..左下
// 同時に複数のbitが1であることがありうる。
enum abstract Directions(Int) from Int to Int {
	var DIRECTIONS_ZERO  = 0;
	var DIRECTIONS_RU = 1;
	var DIRECTIONS_R = 2;
	var DIRECTIONS_RD = 4;
	var DIRECTIONS_U     = 8;
	var DIRECTIONS_D = 16;
	var DIRECTIONS_LU = 32;
	var DIRECTIONS_L = 64;
	var DIRECTIONS_LD = 128;
	var DIRECTIONS_CROSS = DIRECTIONS_U  | DIRECTIONS_D  | DIRECTIONS_R  | DIRECTIONS_L;
	var DIRECTIONS_DIAG  = DIRECTIONS_RU | DIRECTIONS_RD | DIRECTIONS_LU | DIRECTIONS_LD;
}

// Directionsをpopしたもの。複数の方角を同時に表すことはない。
// おまけで桂馬の移動も追加しておく。
enum abstract Direct(Int) from Int to Int {
	var DIRECT_RU;
	var DIRECT_R;
	var DIRECT_RD;
	var DIRECT_U;
	var DIRECT_D;
	var DIRECT_LU;
	var DIRECT_L;
	var DIRECT_LD;
	var DIRECT_NB;
	var DIRECT_ZERO = 0;
	var DIRECT_RUU = 8;
	var DIRECT_LUU;
	var DIRECT_RDD;
	var DIRECT_LDD;
	var DIRECT_NB_PLUS4;
}

abstract Move(Int) to Int {
	inline public function new(i:Int) {
		this = i;
	}
}

abstract PR(Int) to Int {
	inline public function new(i:Int) {
		this = i;
	}
}

abstract PT(Int) to Int {
	inline public function new(i:Int) {
		this = i;
	}
}

abstract PC(Int) to Int {
	inline public function new(i:Int) {
		this = i;
	}
}

class Types {
	static public inline var INT32_MAX:Int = 2147483647;
	static public inline var INT_MAX:Int = 2147483647;
	static public inline var VALUE_NOT_EVALUATED:Int = INT32_MAX;
	static public inline var ONE_PLY:Int = 1;
	static public inline var BLACK:Int = 0;
	static public inline var WHITE:Int = 1;
	static public inline var COLOR_NB:Int = 2;
	public static inline var ALL_PIECES:Int = 0;
	public static inline var PIECE_TYPE_NB:Int = 15;
	public static inline var PIECE_PROMOTE:Int = 8;// 1000
	public static inline var PIECE_WHITE:Int = 16;  // これを先手の駒に加算すると後手の駒になる。
	public static inline var PIECE_HAND_NB:Int = 8;
	public static inline var NO_PIECE_TYPE:PT = new PT(0);
	public static inline var PAWN:PT = new PT(1);
	public static inline var LANCE:PT = new PT(2);
	public static inline var KNIGHT:PT = new PT(3);
	public static inline var SILVER:PT = new PT(4);
	public static inline var BISHOP:PT = new PT(5);
	public static inline var ROOK:PT = new PT(6);
	public static inline var GOLD:PT = new PT(7);
	public static inline var KING:PT = new PT(8);
	public static inline var PRO_PAWN:PT = new PT(9);
	public static inline var PRO_LANCE:PT = new PT(10);
	public static inline var PRO_KNIGHT:PT = new PT(11);
	public static inline var PRO_SILVER:PT = new PT(12);
	public static inline var HORSE:PT = new PT(13);
	public static inline var DRAGON:PT = new PT(14);
	public static inline var NO_PIECE:PC = new PC(0);
	public static inline var B_PAWN:PC = new PC(1);
	public static inline var B_LANCE:PC = new PC(2);
	public static inline var B_KNIGHT:PC = new PC(3);
	public static inline var B_SILVER:PC = new PC(4);
	public static inline var B_BISHOP:PC = new PC(5);
	public static inline var B_ROOK:PC = new PC(6);
	public static inline var B_GOLD:PC = new PC(7);
	public static inline var B_KING:PC = new PC(8);
	public static inline var B_PRO_PAWN:PC = new PC(9);
	public static inline var B_PRO_LANCE:PC = new PC(10);
	public static inline var B_PRO_KNIGHT:PC = new PC(11);
	public static inline var B_PRO_SILVER:PC = new PC(12);
	public static inline var B_HORSE:PC = new PC(13);
	public static inline var B_DRAGON:PC = new PC(14);
	public static inline var W_PAWN:PC = new PC(17);
	public static inline var W_LANCE:PC = new PC(18);
	public static inline var W_KNIGHT:PC = new PC(19);
	public static inline var W_SILVER:PC = new PC(20);
	public static inline var W_BISHOP:PC = new PC(21);
	public static inline var W_ROOK:PC = new PC(22);
	public static inline var W_GOLD:PC = new PC(23);
	public static inline var W_KING:PC = new PC(24);
	public static inline var W_PRO_PAWN:PC = new PC(25);
	public static inline var W_PRO_LANCE:PC = new PC(26);
	public static inline var W_PRO_KNIGHT:PC = new PC(27);
	public static inline var W_PRO_SILVER:PC = new PC(28);
	public static inline var W_HORSE:PC = new PC(29);
	public static inline var W_DRAGON:PC = new PC(30);
	public static inline var PIECE_NB:PC = new PC(31);
	public static inline var SQ_11:Int = 0;
	public static inline var SQ_HB:Int = 80;
	public static inline var SQ_NB:Int = 81;
	public static inline var SQ_NB_PLUS1:Int = SQ_NB + 1; // 玉がいない場合、SQ_NBに移動したものとして扱うため、配列をSQ_NB+1で確保しないといけないときがあるのでこの定数を用いる。
	public static inline var SQ_NONE:Int = 81;
	public static inline var FILE_1:Int = 0;
	public static inline var FILE_2:Int = 1;
	public static inline var FILE_3:Int = 2;
	public static inline var FILE_4:Int = 3;
	public static inline var FILE_5:Int = 4;
	public static inline var FILE_6:Int = 5;
	public static inline var FILE_7:Int = 6;
	public static inline var FILE_8:Int = 7;
	public static inline var FILE_9:Int = 8;
	public static inline var FILE_NB:Int = 9;
	public static inline var RANK_1:Int = 0;
	public static inline var RANK_2:Int = 1;
	public static inline var RANK_3:Int = 2;
	public static inline var RANK_4:Int = 3;
	public static inline var RANK_5:Int = 4;
	public static inline var RANK_6:Int = 5;
	public static inline var RANK_7:Int = 6;
	public static inline var RANK_8:Int = 7;
	public static inline var RANK_9:Int = 8;
	public static inline var RANK_NB:Int = 9;
	public static inline var MAX_MOVES:Int = 600;
	public static inline var MAX_PLY:Int = 6; // 最大探索深度
	public static inline var DELTA_N:Int = -1; // 飛び(上下左右)の方向のシフトビット
	public static inline var DELTA_E:Int = -9;
	public static inline var DELTA_S:Int = 1;
	public static inline var DELTA_W:Int = 9;
	public static inline var DELTA_NN:Int = DELTA_N + DELTA_N; // 飛び(斜め)の方向のシフトビット
	public static inline var DELTA_NE:Int = DELTA_N + DELTA_E;
	public static inline var DELTA_SE:Int = DELTA_S + DELTA_E;
	public static inline var DELTA_SS:Int = DELTA_S + DELTA_S;
	public static inline var DELTA_SW:Int = DELTA_S + DELTA_W;
	public static inline var DELTA_NW:Int = DELTA_N + DELTA_W;
	// 方角に関する定数。StockfishだとNORTH=北=盤面の下を意味するようだが、
	// わかりにくいのでやねうら王ではストレートな命名に変更する。
	public static inline var SQ_D:Int =  1; // 下(Down)
	public static inline var SQ_R:Int = -9; // 右(Right)
	public static inline var SQ_U:Int = -1; // 上(Up)
	public static inline var SQ_L:Int =  9; // 左(Left)
	public static inline var MOVE_NONE:Move = new Move(0);
	public static inline var MOVE_NORMAL:Int = 0;
	public static inline var MOVE_DROP:Int = 1 << 14;
	public static inline var MOVE_PROMO:Int = 1 << 15;
	public static inline var VALUE_ZERO:Int = 0;
	public static inline var VALUE_DRAW:Int = 0;
	public static inline var VALUE_KNOWN_WIN:Int = 15000;
	public static inline var VALUE_MATE:Int = 30000;
	public static inline var VALUE_INFINITE:Int = 30001;
	public static inline var VALUE_NONE:Int = 30002;
	public static inline var PawnValue:Int = 90;
	public static inline var LanceValue:Int = 315;
	public static inline var KnightValue:Int = 405;
	public static inline var SilverValue:Int = 495;
	public static inline var GoldValue:Int = 540;
	public static inline var BishopValue:Int = 855;
	public static inline var RookValue:Int = 990;
	public static inline var ProPawnValue:Int = 540;
	public static inline var ProLanceValue:Int = 540;
	public static inline var ProKnightValue:Int = 540;
	public static inline var ProSilverValue:Int = 540;
	public static inline var HorseValue:Int = 945;
	public static inline var DragonValue:Int = 1395;
	public static inline var KingValue:Int = 15000;
	private static var flipSquare:Array<Int> = [
		80, 79, 78, 77, 76, 75, 74, 73, 72,
		71, 70, 69, 68, 67, 66, 65, 64, 63,
		62, 61, 60, 59, 58, 57, 56, 55, 54,
		53, 52, 51, 50, 49, 48, 47, 46, 45,
		44, 43, 42, 41, 40, 39, 38, 37, 36,
		35, 34, 33, 32, 31, 30, 29, 28, 27,
		26, 25, 24, 23, 22, 21, 20, 19, 18,
		17, 16, 15, 14, 13, 12, 11, 10,  9,
		 8,  7,  6,  5,  4,  3,  2,  1,  0,
	];
	public static var bbToSquare:Array<Int> = [
		72, 63, 54, 45, 36, 27, 18,  9,  0,
		73, 64, 55, 46, 37, 28, 19, 10,  1,
		74, 65, 56, 47, 38, 29, 20, 11,  2,
		75, 66, 57, 48, 39, 30, 21, 12,  3,
		76, 67, 58, 49, 40, 31, 22, 13,  4,
		77, 68, 59, 50, 41, 32, 23, 14,  5,
		78, 69, 60, 51, 42, 33, 24, 15,  6,
		79, 70, 61, 52, 43, 34, 25, 16,  7,
		80, 71, 62, 53, 44, 35, 26, 17,  8,
	];
	// 与えられたSquareに対応する筋を返すテーブル。file_of()で用いる。
	private static var SquareToFile:Array<Int> = [//[SQ_NB_PLUS1] =
		FILE_1, FILE_1, FILE_1, FILE_1, FILE_1, FILE_1, FILE_1, FILE_1, FILE_1,
		FILE_2, FILE_2, FILE_2, FILE_2, FILE_2, FILE_2, FILE_2, FILE_2, FILE_2,
		FILE_3, FILE_3, FILE_3, FILE_3, FILE_3, FILE_3, FILE_3, FILE_3, FILE_3,
		FILE_4, FILE_4, FILE_4, FILE_4, FILE_4, FILE_4, FILE_4, FILE_4, FILE_4,
		FILE_5, FILE_5, FILE_5, FILE_5, FILE_5, FILE_5, FILE_5, FILE_5, FILE_5,
		FILE_6, FILE_6, FILE_6, FILE_6, FILE_6, FILE_6, FILE_6, FILE_6, FILE_6,
		FILE_7, FILE_7, FILE_7, FILE_7, FILE_7, FILE_7, FILE_7, FILE_7, FILE_7,
		FILE_8, FILE_8, FILE_8, FILE_8, FILE_8, FILE_8, FILE_8, FILE_8, FILE_8,
		FILE_9, FILE_9, FILE_9, FILE_9, FILE_9, FILE_9, FILE_9, FILE_9, FILE_9,
		FILE_NB, // 玉が盤上にないときにこの位置に移動させることがあるので
	];
	// 与えられたSquareに対応する段を返すテーブル。rank_of()で用いる。
	private static var SquareToRank:Array<Int> = [//[SQ_NB_PLUS1] =
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9,
		RANK_NB, // 玉が盤上にないときにこの位置に移動させることがあるので
	];

	// SquareからSquareWithWallへの変換テーブル
	public static var sqww_table:Array<SquareWithWall> = [];// [SQ_NB_PLUS1];

	// 型変換。下位8bit == Square
	public static function sqww_to_sq(sqww:SquareWithWall):Int { return sqww & 0xff; }

	// 型変換。Square型から。
	public static function to_sqww(sq:Int):SquareWithWall { return sqww_table[sq]; }

	// DirectからDirectionsへの逆変換
	public static function to_directions(d:Direct):Directions  { return 1 << d; }

	// 盤内か。壁(盤外)だとfalseになる。
	public static function is_ok(sqww:SquareWithWall):Bool { return (sqww & SquareWithWall.SQWW_BORROW_MASK) == 0; }

	// sqxsqx8dir
	public static var direc_table:Array<Array<Directions>> = [//Directions [SQ_NB_PLUS1][SQ_NB_PLUS1];
		[]
	];

	// DirectをSquareWithWall型の差分値で表現したもの。
	public static var DirectToDeltaWW_:Array<SquareWithWall>  = [SquareWithWall.SQWW_RU,SquareWithWall.SQWW_R,SquareWithWall.SQWW_RD,
		 SquareWithWall.SQWW_U,SquareWithWall.SQWW_D,SquareWithWall.SQWW_LU,SquareWithWall.SQWW_L,SquareWithWall.SQWW_LD];// [DIRECT_NB] =8
	public static function DirectToDeltaWW(d:Direct):SquareWithWall  { /* ASSERT_LV3(is_ok(d)); */ return DirectToDeltaWW_[d]; }

	// sq1にとってsq2がどのdirectionにあるか。
	// "Direction"ではなく"Directions"を返したほうが、縦横十字方向や、斜め方向の位置関係にある場合、
	// DIRECTIONS_CROSSやDIRECTIONS_DIAGのような定数が使えて便利。
	// extern Directions direc_table[SQ_NB_PLUS1][SQ_NB_PLUS1];
	public static function directions_of(sq1:Int, sq2:Int):Directions  {
		return direc_table[sq1][sq2];
	}

	// 与えられた3升が縦横斜めの1直線上にあるか。駒を移動させたときに開き王手になるかどうかを判定するのに使う。
	// 例) 王がsq1, pinされている駒がsq2にあるときに、pinされている駒をsq3に移動させたときにaligned(sq1,sq2,sq3)であれば、
	//  pinされている方向に沿った移動なので開き王手にはならないと判定できる。
	// ただし玉はsq3として、sq1,sq2は同じ側にいるものとする。(玉を挟んでの一直線は一直線とはみなさない)
	public static function aligned(sq1:Int, sq2:Int, sq3:Int/* is ksq */):Bool {
		return ( BB.ANDsq( BB.lineBB[sq1][sq2], sq3 ).IsNonZero() );
	}

	public static function Inv(sq:Int):Int { return (SQ_NB - 1) - sq; }
	// ply手で詰まされるときのスコア
	public static function mated_in(ply:Int) {  return (-VALUE_MATE + ply);}

	// pcが遠方駒であるかを判定する。LANCE,BISHOP(5)=0101,ROOK(6)=0110,HORSE(13)=1101,DRAGON(14)=1110
	public static function has_long_effect(pc:PC):Bool {
		return (type_of(pc) == LANCE) || (((pc+1) & 6)==6);// 0110
	}

	public static function OppColour(c:Int):Int {
		return c ^ 1;
	}

	public static function Is_SqOK(s:Int):Bool {
		return (s >= SQ_11 && s <= SQ_HB);
	}

	// 与えられたSquareに対応する筋を返す。
	// →　行数は長くなるが速度面においてテーブルを用いる。
	public static function file_of(s:Int):Int {
		// return Std.int(s / RANK_NB);
		return SquareToFile[s];
	}

	public static function rank_of(s:Int):Int {
		// return s % FILE_NB;
		return SquareToRank[s];
	}

	// ２つの升のfileの差、rankの差のうち大きいほうの距離を返す。sq1,sq2のどちらかが盤外ならINT_MAXが返る。
	public static function dist(sq1:Int, sq2:Int):Int {
		return (!is_ok(sq1) || !is_ok(sq2)) ? INT_MAX : MathUtil.max(MathUtil.abs(file_of(sq1) - file_of(sq2)), MathUtil.abs(rank_of(sq1) - rank_of(sq2))); }

	public static function FileString_Of(s:Int):String {
		return '${file_of(s) + 1}';
	}

	public static function File_To_Char(f:Int):String {
		return '${f + 1}';
	}

	public static function Rank_To_Char(r:Int, toLower:Bool = true):String {
		if (toLower) {
			return String.fromCharCode('a'.charCodeAt(0) + r);
		} else {
			return String.fromCharCode('A'.charCodeAt(0) + r);
		}
	}

	public static function Square_To_String(s:Int):String {
		return File_To_Char(file_of(s)) + Rank_To_Char(rank_of(s));
	}

	public static function Char_To_File(n:String):Int {
		return Std.parseInt(n) - 1;
	}

	public static function Char_To_Rank(a:String):Int {
		return a.charCodeAt(0) - 97;
	}

	public static function move_from(m:Move):Int {
		return (m >>> 7) & 0x7F;
	}

	public static function to_sq(m:Move):Int {
		return move_to(m);
	}
	public static function move_to(m:Move):Int {
		return m & 0x7F;
	}

	public static function Move_Dropped_Piece(m:Move):PR {
		return new PR((m >>> 7) & 0x7F);
	}

	public static function Move_Type(m:Move):Int {
		return m & (3 << 14);
	}

	public static function Move_To_String(m:Move):String {
		if (is_drop(m)) {
			var pc = PieceToChar(new PC(Move_Dropped_Piece(m)));
			var str = Square_To_String(move_to(m));
			return '$pc*$str';
		} else if (Is_Promote(m)) {
			return Square_To_String(move_from(m)) + Square_To_String(move_to(m)) + '+';
		} else { // move
			return Square_To_String(move_from(m)) + Square_To_String(move_to(m));
		}
	}

	public static function Move_To_StringLong(m:Move):String {
		return Move_To_String(m) + " " + Move_Type_String(m) + " : " + m;
	}

	public static function Move_Type_String(m:Move):String {
		if (Move_Type(m) == MOVE_DROP) {
			return "Drop";
		}
		if (Move_Type(m) == MOVE_PROMO) {
			return "Promo";
		}
		return "Normal";
	}

	public static function Make_Move(from:Int, to:Int):Move {
		return new Move(to | (from << 7));
	}

	public static function Make_Move_Promote(from:Int, to:Int):Move {
		return new Move(to | (from << 7) | MOVE_PROMO);
	}

	public static function Make_Move_Drop(pr:PR, sq:Int):Move {
		return new Move(sq | (pr << 7) | MOVE_DROP);
	}

	static public function generateMoveFromString(ft:String):Move {
		var f:Int = Char_To_File(ft.charAt(0));
		var r:Int = Char_To_Rank(ft.charAt(1));
		var from = Types.Square(f, r);
		f = Char_To_File(ft.charAt(2));
		r = Char_To_Rank(ft.charAt(3));
		var to = Types.Square(f, r);
		if (ft.indexOf('*') > 0) {
			var pr:PR = RawTypeOf(getPieceFromLabel(ft.charAt(0)));
			f = Char_To_File(ft.charAt(2));
			r = Char_To_Rank(ft.charAt(3));
			to = Types.Square(f, r);
			return Make_Move_Drop(pr, to);
		} else if (ft.indexOf('+') > 0) {
			return Make_Move_Promote(from, to);
		} else {
			return Make_Move(from, to);
		}
	}

	public static function Is_Move_OK(m:Move):Bool {
		return (move_from(m) != move_to(m));
	}

	public static function Is_Promote(m:Move):Bool {
		return (m & MOVE_PROMO) != 0;
	}

	public static function is_drop(m:Move):Bool {
		return (m & MOVE_DROP) != 0;
	}

	public static function RankString_Of(s:Int):String {
		return String.fromCharCode(97 + rank_of(s));
	}

	// 後手の歩→先手の歩のように、後手という属性を取り払った駒種を返す
	public static function type_of(pc:PC):PT {
		return new PT(pc & 15);// 1111
	}

	public static function raw_type_of(p:Int):PR {
		return RawTypeOf(p);
	}
	public static function RawTypeOf(p:Int):PR {
		return new PR(p % 8);
	}

	public static function Make_Piece(c:Int, pt:PT):PC {
		return new PC((c << 4) | pt);
	}

	public static function Square(f:Int, r:Int):Int {
		return (f * RANK_NB) + r;
	}

	public static function FlipSquare(sq:Int):Int {
		return flipSquare[sq];
	}

	public static function color_of(pc:PC):Int {
		return (pc & PIECE_WHITE) >> 4;
	}

	static public function getPieceColor(pc:PC):Int {
		if (pc == NO_PIECE)
			return -1;
		return (Std.int(pc) < 16) ? 0 : 1;
	}

	public static function TypeOf_Piece(pc:PC):PT {
		return new PT(pc % 16);
	}

	public static function PieceToChar(pc:PC):String {
		if (pc == B_PAWN) {
			return "P";
		}
		if (pc == B_LANCE) {
			return "L";
		}
		if (pc == B_SILVER) {
			return "S";
		}
		if (pc == B_KNIGHT) {
			return "N";
		}
		if (pc == B_BISHOP) {
			return "B";
		}
		if (pc == B_ROOK) {
			return "R";
		}
		if (pc == B_GOLD) {
			return "G";
		}
		if (pc == B_KING) {
			return "K";
		}
		if (pc == B_PRO_PAWN) {
			return "+P";
		}
		if (pc == B_PRO_LANCE) {
			return "+L";
		}
		if (pc == B_PRO_KNIGHT) {
			return "+N";
		}
		if (pc == B_PRO_SILVER) {
			return "+S";
		}
		if (pc == B_HORSE) {
			return "+B";
		}
		if (pc == B_DRAGON) {
			return "+R";
		}
		if (pc == W_PAWN) {
			return "p";
		}
		if (pc == W_LANCE) {
			return "l";
		}
		if (pc == W_KNIGHT) {
			return "n";
		}
		if (pc == W_SILVER) {
			return "s";
		}
		if (pc == W_BISHOP) {
			return "b";
		}
		if (pc == W_ROOK) {
			return "r";
		}
		if (pc == W_GOLD) {
			return "g";
		}
		if (pc == W_KING) {
			return "k";
		}
		if (pc == W_PRO_PAWN) {
			return "+p";
		}
		if (pc == W_PRO_LANCE) {
			return "+l";
		}
		if (pc == W_PRO_KNIGHT) {
			return "+n";
		}
		if (pc == W_PRO_SILVER) {
			return "+s";
		}
		if (pc == W_HORSE) {
			return "+b";
		}
		if (pc == W_DRAGON) {
			return "+r";
		}
		return "?";
	}

	static public function getPieceFromLabel(token:String):PC {
		switch (token) {
			case 'P':
				return B_PAWN;
			case 'L':
				return B_LANCE;
			case 'N':
				return B_KNIGHT;
			case 'S':
				return B_SILVER;
			case 'B':
				return B_BISHOP;
			case 'R':
				return B_ROOK;
			case 'G':
				return B_GOLD;
			case 'K':
				return B_KING;
			case 'p':
				return W_PAWN;
			case 'l':
				return W_LANCE;
			case 'n':
				return W_KNIGHT;
			case 's':
				return W_SILVER;
			case 'b':
				return W_BISHOP;
			case 'r':
				return W_ROOK;
			case 'g':
				return W_GOLD;
			case 'k':
				return W_KING;
			default:
				return NO_PIECE;
		}
	}

	static public function getPieceLabel(pt:PT):String {
		switch (Std.int(pt) % 16) {
			case 0:
				return '　';
			case 1:
				return '歩';
			case 2:
				return '香';
			case 3:
				return '桂';
			case 4:
				return '銀';
			case 5:
				return '角';
			case 6:
				return '飛';
			case 7:
				return '金';
			case 8:
				return '玉';
			case 9:
				return 'と';
			case 10:
				return '杏';
			case 11:
				return '圭';
			case 12:
				return '全';
			case 13:
				return '馬';
			case 14:
				return '龍';
			default:
				return '　';
		}
	}
}
