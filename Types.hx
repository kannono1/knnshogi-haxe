package;

class Types {
	static public inline var BLACK:Int = 0;
	static public inline var WHITE:Int = 1;
	public static inline var FILE_A:Int = 0;
	public static inline var RANK_1:Int = 0;
	static public inline var COLOR_NB:Int = 2;
	public static inline var ALL_PIECES:Int = 0;
	public static inline var PIECE_TYPE_NB:Int = 0;
	public static inline var NO_PIECE_TYPE:Int = 0;
	public static inline var PAWN:Int = 1;
	public static inline var LANCE:Int = 2;
	public static inline var KNIGHT:Int = 3;
	public static inline var SILVER:Int = 4;
	public static inline var BISHOP:Int = 5;
	public static inline var ROOK:Int = 6;
	public static inline var GOLD:Int = 7;
	public static inline var KING:Int = 8;
	public static inline var PRO_PAWN:Int = 9;
	public static inline var PRO_LANCE:Int = 10;
	public static inline var PRO_KNIGHT:Int = 11;
	public static inline var PRO_SILVER:Int = 12;
	public static inline var HORSE:Int = 13;
	public static inline var DRAGON:Int = 14;
	public static inline var NO_PIECE:Int = 0;
	public static inline var W_PAWN:Int = 1;
	public static inline var W_LANCE:Int = 2;
	public static inline var W_KNIGHT:Int = 3;
	public static inline var W_SILVER:Int = 4;
	public static inline var W_BISHOP:Int = 5;
	public static inline var W_ROOK:Int = 6;
	public static inline var W_GOLD:Int = 7;
	public static inline var W_KING:Int = 8;
	public static inline var W_PRO_PAWN:Int = 9;
	public static inline var W_PRO_LANCE:Int = 10;
	public static inline var W_PRO_KNIGHT:Int = 11;
	public static inline var W_PRO_SILVER:Int = 12;
	public static inline var W_HORSE:Int = 13;
	public static inline var W_DRAGON:Int = 14;
	public static inline var PIECE_WHITE:Int = 16;
	public static inline var B_PAWN:Int = 17; // W_PARN + PIECE_WHITE
	public static inline var B_LANCE:Int = 18;
	public static inline var B_KNIGHT:Int = 19;
	public static inline var B_SILVER:Int = 20;
	public static inline var B_BISHOP:Int = 21;
	public static inline var B_ROOK:Int = 22;
	public static inline var B_GOLD:Int = 23;
	public static inline var B_KING:Int = 24;
	public static inline var B_PRO_PAWN:Int = 25;
	public static inline var B_PRO_LANCE:Int = 26;
	public static inline var B_PRO_KNIGHT:Int = 27;
	public static inline var B_PRO_SILVER:Int = 28;
	public static inline var B_HORSE:Int = 29;
	public static inline var B_DRAGON:Int = 30;
	public static inline var PIECE_NB:Int = 31;
	public static inline var SQ_A1:Int = 0;
	public static inline var SQ_HB:Int = 80;
	public static inline var SQ_NB:Int = 81;
	public static inline var FILE_NB:Int = 9;
	public static inline var RANK_NB:Int = 9;
	public static inline var MAX_MOVES:Int = 600;
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
	public static inline var MOVE_NONE:Int = 0;
	public static inline var MOVE_NORMAL:Int = 0;
	public static inline var MOVE_DROP:Int = 1 << 14;
	public static inline var MOVE_PROMO:Int = 1 << 15;
	public static inline var VALUE_ZERO:Int = 0;
	public static inline var VALUE_DRAW:Int = 0;
	public static inline var VALUE_KNOWN_WIN:Int = 15000;
	public static inline var VALUE_MATE:Int = 30000;
	public static inline var VALUE_INFINITE:Int = 30001;
	public static inline var VALUE_NONE:Int = 30002;

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
			return String.fromCharCode(('a').charCodeAt(0) + r);
		} else {
			return String.fromCharCode(('A').charCodeAt(0) + r);
		}
	}

	public static function Square_To_String(s:Int):String {
		return File_To_Char(File_Of(s)) + Rank_To_Char(Rank_Of(s));
	}

	public static function Move_FromSq(m:Int):Int {
		return (m >>> 7) & 0x7F;
	}

	public static function Move_Dropped_Piece(m:Int):Int {
		return (m >>> 7) & 0x7F;
	}

	public static function Move_ToSq(m:Int):Int {
		return m & 0x7F;
	}

	public static function Move_Type(m:Int):Int {
		return m & (3 << 14);
	}

	public static function Move_To_String(m:Int):String {
		if (Is_Drop(m)) {
			return PieceToChar(Move_Dropped_Piece(m)) + "*" + Square_To_String(Move_ToSq(m)) + " " + Move_Type_String(m) + " : " + m;
		} else { // move
			return Square_To_String(Move_FromSq(m)) + Square_To_String(Move_ToSq(m)) + " " + Move_Type_String(m) + " : " + m;
		}
	}

	public static function Move_Type_String(m:Int):String {
		if (Move_Type(m) == MOVE_DROP) {
			return "Drop";
		}
		if (Move_Type(m) == MOVE_PROMO) {
			return "Promo";
		}
		return "Normal";
	}

	public static function Make_Move(from:Int, to:Int):Int {
		return to | (from << 7);
	}

	public static function Make_Move_Promote(from:Int, to:Int):Int {
		return to | (from << 7) | MOVE_PROMO;
	}

	public static function Make_Move_Drop(pt:Int, sq:Int):Int {
		return sq | (pt << 7) | MOVE_DROP;
	}

	public static function Is_Move_OK(m:Int):Bool {
		return (Move_FromSq(m) != Move_ToSq(m));
	}

	public static function Is_Promote(m:Int):Bool {
		return (m & MOVE_PROMO) != 0;
	}

	public static function Is_Drop(m:Int):Bool {
		return (m & MOVE_DROP) != 0;
	}

	public static function RankString_Of(s:Int):String {
		return String.fromCharCode(97 + Rank_Of(s));
	}

	public static function RawTypeOf(p:Int):Int {
		return p % 8;
	}

	public static function Make_Piece(c:Int, pt:Int):Int {
		return (c << 4) | pt;
	}

	public static function Square(f:Int, r:Int):Int {
		return (f * RANK_NB) + r;
	}

	static public function getPieceColor(pt:Int):Int {
		if (pt == 0)
			return -1;
		return (pt < 16) ? 0 : 1;
	}

	public static function TypeOf_Piece(pc:Int):Int {
		return pc % 16;
	}

	public static function PieceToChar(pt:Int):String {
		if (pt == B_PAWN) {
			return "P";
		}
		if (pt == B_LANCE) {
			return "L";
		}
		if (pt == B_SILVER) {
			return "S";
		}
		if (pt == B_KNIGHT) {
			return "N";
		}
		if (pt == B_BISHOP) {
			return "B";
		}
		if (pt == B_ROOK) {
			return "R";
		}
		if (pt == B_GOLD) {
			return "G";
		}
		if (pt == B_KING) {
			return "K";
		}
		if (pt == B_PRO_PAWN) {
			return "+P";
		}
		if (pt == B_PRO_LANCE) {
			return "+L";
		}
		if (pt == B_PRO_KNIGHT) {
			return "+N";
		}
		if (pt == B_PRO_SILVER) {
			return "+S";
		}
		if (pt == B_HORSE) {
			return "+B";
		}
		if (pt == B_DRAGON) {
			return "+R";
		}
		if (pt == W_PAWN) {
			return "p";
		}
		if (pt == W_LANCE) {
			return "l";
		}
		if (pt == W_KNIGHT) {
			return "n";
		}
		if (pt == W_SILVER) {
			return "s";
		}
		if (pt == W_BISHOP) {
			return "b";
		}
		if (pt == W_ROOK) {
			return "r";
		}
		if (pt == W_GOLD) {
			return "g";
		}
		if (pt == W_KING) {
			return "k";
		}
		if (pt == W_PRO_PAWN) {
			return "+p";
		}
		if (pt == W_PRO_LANCE) {
			return "+l";
		}
		if (pt == W_PRO_KNIGHT) {
			return "+n";
		}
		if (pt == W_PRO_SILVER) {
			return "+s";
		}
		if (pt == W_HORSE) {
			return "+b";
		}
		if (pt == W_DRAGON) {
			return "+r";
		}
		return "?";
	}

	static public function getPieceType(token:String):Int {
		switch (token) {
			case 'P':
				return 1;
			case 'L':
				return 2;
			case 'N':
				return 3;
			case 'S':
				return 4;
			case 'B':
				return 5;
			case 'R':
				return 6;
			case 'G':
				return 7;
			case 'K':
				return 8;
			case 'p':
				return 17;
			case 'l':
				return 18;
			case 'n':
				return 19;
			case 's':
				return 20;
			case 'b':
				return 21;
			case 'r':
				return 22;
			case 'g':
				return 23;
			case 'k':
				return 24;
			default:
				return 0;
		}
	}

	static public function getPieceLabel(pt:Int):String {
		switch (pt % 16) {
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
				return 'と';
			case 11:
				return '杏';
			case 12:
				return '圭';
			case 13:
				return '全';
			case 14:
				return '馬';
			case 15:
				return '龍';
			default:
				return '　';
		}
	}
}
