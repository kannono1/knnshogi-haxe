package;

class Types {
    static public final BLACK:Int = 0;
    static public final WHITE:Int = 1;
    
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
	static public function getPieceLabel(pt:Int): String {
        switch(pt%16){
            case  0: return '　';
            case  1: return '歩';
            case  2: return '香';
            case  3: return '桂';
            case  4: return '銀';
            case  5: return '角';
            case  6: return '飛';
            case  7: return '金';
            case  8: return '玉';
            case  9: return 'と';
            case 10: return 'と';
            case 11: return '杏';
            case 12: return '圭';
            case 13: return '全';
            case 14: return '馬';
            case 15: return '龍';
            default: return '　';
        }
    }
}