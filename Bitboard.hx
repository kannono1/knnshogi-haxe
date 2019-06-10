package;

class Bitboard {
	private static inline var NA:Int = 27;
	private static inline var NB:Int = 54;

	public var lower = 0;
	public var middle = 0;
	public var upper = 0;
	public var count:Int = 0;// ???
	public var needCount:Bool = false;

	public function new(l:Int = 0, m:Int = 0, u:Int = 0) {
		lower = l;
		middle = m;
		upper = u;
	}

	public function Copy(other:Bitboard) {
		lower = other.lower;
		middle = other.middle;
		upper = other.upper;
		count = other.count;
		needCount = other.needCount;
	}

	public function IsNonZero():Bool {
		return (lower != 0 || middle != 0 || upper != 0);
	}

	public function isSet(sq:Int):Bool {
		if (sq < NA) {
			return (lower & (1 << sq)) != 0;
		} else if (sq < NB) {
			return (middle & (1 << (sq - NA))) != 0;
		} else {
			return (upper & (1 << (sq - NB))) != 0;
		}
	}

	public function LSB():Int {
		if (lower != 0) {
			return LeastSB(lower);
		}
		if (middle != 0) {
			return LeastSB(middle) + 27;
		}
		if (upper != 0) {
			return LeastSB(upper) + 54;
		}
		return -1;
	}

	public static function LeastSB(theInt:Int):Int {
		var i:Int = -1;
		if ((theInt & 0x0000ffff) == 0) {
			i += 16;
			theInt >>>= 16;
		} // 11111111111111110000000000000000
		if ((theInt & 0x000000ff) == 0) {
			i += 8;
			theInt >>>= 8;
		} // 00000000000000001111111100000000
		if ((theInt & 0x0000000f) == 0) {
			i += 4;
			theInt >>>= 4;
		} // 00000000000000000000000011110000
		if ((theInt & 0x00000003) == 0) {
			i += 2;
			theInt >>>= 2;
		} // 00000000000000000000000000001100
		if ((theInt & 0x00000001) == 0) {
			i += 1;
			theInt >>>= 1;
		} // 00000000000000000000000000000010
		if ((theInt & 0x00000001) != 0) {
			i += 1;
		}
		return i;
	}

	public function OR(other:Bitboard) {
		lower |= other.lower;
		middle |= other.middle;
		upper |= other.upper;
		needCount = true;
	}

	public function PopLSB():Int {
		var index:Int = -1;
		if (lower != 0) {
			count--;
			index = LeastSB(lower);
			lower &= lower - 1;
			return index;
		}
		if (middle != 0) {
			count--;
			index = 27 + LeastSB(middle);
			middle &= middle - 1;
			return index;
		}
		if (upper != 0) {
			count--;
			index = 54 + LeastSB(upper);
			upper &= upper - 1;
			return index;
		}
		return -1;
	}

	public function SetBit(theIndex:Int) {
		if (theIndex < NA) {
			lower |= (1 << theIndex);
		} else if (theIndex < NB) {
			middle |= (1 << (theIndex - NA));
		} else {
			upper |= (1 << (theIndex - NB));
		}
		needCount = true;
	}

	public function toStringBB():String {
		var s = '';
		for (i in 0...81) {
			var f = 8 - (i % 9);
			var r = Std.int(i / 9);
			var sq = f * 9 + r;
			if (i % 9 == 0) {
				s += '\n';
			}
			if (isSet(sq)) {
				s += '1';
			} else {
				s += '0';
			}
		}
		return s;
	}
}
