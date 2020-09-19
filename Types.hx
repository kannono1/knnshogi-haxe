package;

enum abstract PieceNumber(Int) {
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
	static public inline var ONE_PLY:Int = 1;
	static public inline var BLACK:Int = 0;
	static public inline var WHITE:Int = 1;
	public static inline var FILE_A:Int = 0;
	public static inline var RANK_1:Int = 0;
	static public inline var COLOR_NB:Int = 2;
	public static inline var ALL_PIECES:Int = 0;
	public static inline var PIECE_TYPE_NB:Int = 15;
	public static inline var PIECE_PROMOTE:Int = 8;
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
	public static inline var SQ_A1:Int = 0;
	public static inline var SQ_HB:Int = 80;
	public static inline var SQ_NB:Int = 81;
	public static inline var SQ_NONE:Int = 81;
	public static inline var FILE_NB:Int = 9;
	public static inline var RANK_NB:Int = 9;
	public static inline var MAX_MOVES:Int = 600;
	public static inline var MAX_PLY:Int = 2; // 最大探索深度
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

	public static function hasLongEffect(pt:PT):Bool {
		switch (pt) {
			case ROOK:
				return true;
			case BISHOP:
				return true;
			case DRAGON:
				return true;
			case HORSE:
				return true;
			default:
				return false;
		}
	}

	public static function OppColour(c:Int):Int {
		return c ^ 1;
	}

	public static function Is_SqOK(s:Int):Bool {
		return (s >= SQ_A1 && s <= SQ_HB);
	}

	public static function File_Of(s:Int):Int {
		return Std.int(s / RANK_NB);
	}

	public static function Rank_Of(s:Int):Int {
		return s % FILE_NB;
	}

	public static function FileString_Of(s:Int):String {
		return '${File_Of(s) + 1}';
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
		return File_To_Char(File_Of(s)) + Rank_To_Char(Rank_Of(s));
	}

	public static function Char_To_File(n:String):Int {
		return Std.parseInt(n) - 1;
	}

	public static function Char_To_Rank(a:String):Int {
		return a.charCodeAt(0) - 97;
	}

	public static function Move_FromSq(m:Move):Int {
		return (m >>> 7) & 0x7F;
	}

	public static function Move_ToSq(m:Move):Int {
		return m & 0x7F;
	}

	public static function Move_Dropped_Piece(m:Move):PR {
		return new PR((m >>> 7) & 0x7F);
	}

	public static function Move_Type(m:Move):Int {
		return m & (3 << 14);
	}

	public static function Move_To_String(m:Move):String {
		if (Is_Drop(m)) {
			var pc = PieceToChar(new PC(Move_Dropped_Piece(m)));
			var str = Square_To_String(Move_ToSq(m));
			return '$pc*$str';
		} else if (Is_Promote(m)) {
			return Square_To_String(Move_FromSq(m)) + Square_To_String(Move_ToSq(m)) + '+';
		} else { // move
			return Square_To_String(Move_FromSq(m)) + Square_To_String(Move_ToSq(m));
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
		return (Move_FromSq(m) != Move_ToSq(m));
	}

	public static function Is_Promote(m:Move):Bool {
		return (m & MOVE_PROMO) != 0;
	}

	public static function Is_Drop(m:Move):Bool {
		return (m & MOVE_DROP) != 0;
	}

	public static function RankString_Of(s:Int):String {
		return String.fromCharCode(97 + Rank_Of(s));
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
