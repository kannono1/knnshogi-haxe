package;

class Types {
	static public inline var BLACK:Int = 0;
	static public inline var WHITE:Int = 1;
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
    public static inline var PIECE_NB:Int	= 31;
	public static inline var SQ_A1:Int = 0;
	public static inline var SQ_HB:Int = 80;
	public static inline var SQ_NB:Int = 81;
    public static inline var FILE_NB:Int	= 9;
    public static inline var RANK_NB:Int	= 9;//8;

    public static function Is_SqOK( s:Int ) : Bool { return ( s >= SQ_A1 && s <= SQ_HB ); }
    public static function File_Of( s:Int ) : Int { return s % FILE_NB; }	
	public static function Rank_Of( s:Int ) : Int { return Std.int(s / RANK_NB); }	
    public static function RawTypeOf( p:Int ) : Int { return p % 8; }
    public static function Make_Piece( c:Int, pt:Int ) : Int { return (c << 4) | pt; }// == (c * PIECE_WHITE) + pt

	static public function getPieceColor(pt:Int):Int {
		if (pt == 0)
			return -1;
		return (pt < 16) ? 0 : 1;
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
