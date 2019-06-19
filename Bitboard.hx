package;

class Bitboard {
	private static inline var NA:Int = 27;
	private static inline var NB:Int = 54;

	public var lower = 0;
	public var middle = 0;
	public var upper = 0;
	public var count:Int = 0; // ???
	public var needCount:Bool = false;

	public function new(l:Int = 0, m:Int = 0, u:Int = 0) {
		lower = l;
		middle = m;
		upper = u;
	}

	public function Clear() {
		lower = 0;
		middle = 0;
		upper = 0;
		count = 0;
		needCount = false;
	}

	public function Copy(other:Bitboard) {
		lower = other.lower;
		middle = other.middle;
		upper = other.upper;
		count = other.count;
		needCount = other.needCount;
	}

	public function newCOPY():Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		return newBB;
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

	public function newOR(other:Bitboard):Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		newBB.OR(other);
		return newBB;
	}

	public function XOR(other:Bitboard) {
		lower ^= other.lower;
		middle ^= other.middle;
		upper ^= other.upper;
		needCount = true;
	}

	public function newXOR(other:Bitboard):Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		newBB.XOR(other);
		return newBB;
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

	public function ShiftL(theShift:Int) {
		if (theShift < 27) {
			upper = upper << theShift;
			upper |= (middle >>> (27 - theShift));
			middle = middle << theShift;
			middle |= (lower >>> (27 - theShift));
			lower = lower << theShift;
		} else if (theShift < 54) {
			upper = (middle >>> (theShift - 27));
			upper |= (lower >>> (54 - theShift));
			middle = lower << (theShift - 27);
			lower = 0;
		} else {
			upper = (lower << (theShift - 54));
			lower = 0;
		}
		needCount = true;
	}

	public function newShiftL(theShift:Int):Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		newBB.ShiftL(theShift);
		return newBB;
	}

	public function ShiftR(theShift:Int) {
		if (theShift < 27) {
			lower = lower >>> theShift;
			lower |= (((middle << (27 - theShift)) >>> (27 - theShift)) << (27 - theShift));
			middle = middle >>> theShift;
			middle |= (((upper << (27 - theShift)) >>> (27 - theShift)) << (27 - theShift));
			upper = upper >>> theShift;
		} else if (theShift < 54) {
			lower = middle >>> (theShift - 27);
			lower |= (((upper << (27 - theShift)) >>> (27 - theShift)) << (27 - theShift));
			middle = upper >>> (theShift - 27);
			upper = 0;
		} else {
			lower = (upper >>> (theShift - 54));
			middle = 0;
			upper = 0;
		}
		needCount = true;
	}

	public function newShiftR(theShift:Int):Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		newBB.ShiftR(theShift);
		return newBB;
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

	public function ClrBit(theIndex:Int) {
		if (theIndex < 27) {
			lower ^= (1 << theIndex);
		} else if (theIndex < 54) {
			middle ^= (1 << (theIndex - 27));
		} else {
			upper ^= (1 << (theIndex - 54));
		}
		needCount = true;
	}

	public function NORM27():Bitboard {
		lower &= 0x7FFFFFF;
		middle &= 0x7FFFFFF;
		upper &= 0x7FFFFFF;
		needCount = true;
		return this;
	}

	public function AND(other:Bitboard) {
		lower &= other.lower;
		middle &= other.middle;
		upper &= other.upper;
		needCount = true;
	}

	public function newAND(other:Bitboard):Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		newBB.AND(other);
		return newBB;
	}

	public function NOT() {
		lower = ~lower;
		middle = ~middle;
		upper = ~upper;
		count = 81 - count;
	}

	public function newNOT():Bitboard {
		var newBB:Bitboard = new Bitboard();
		newBB.Copy(this);
		newBB.NOT();
		return newBB;
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
