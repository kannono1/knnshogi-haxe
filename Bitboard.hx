package;

class Bitboard {
	private static inline var NA:Int = 27;
	private static inline var NB:Int = 54;

	public var lower = 0;
	public var middle = 0;
	public var upper = 0;
	public var needCount:Bool = false;

	public function new(l:Int = 0, m:Int = 0, u:Int = 0) {
		lower = l;
		middle = m;
		upper = u;
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

	public function OR(other:Bitboard) {
		lower |= other.lower;
		middle |= other.middle;
		upper |= other.upper;
		needCount = true;
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
