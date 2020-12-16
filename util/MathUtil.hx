package util;

class RKiss {
	public var a:Bitboard64 = new Bitboard64();
	public var b:Bitboard64 = new Bitboard64();
	public var c:Bitboard64 = new Bitboard64();
	public var d:Bitboard64 = new Bitboard64();

	public function new() {}

	private static function Rotate(x:Bitboard64, k:Int):Bitboard64 {
		var tmpBB:Bitboard64 = x.newShiftL(k);
		tmpBB.OR(x.newShiftR(64 - k));
		return tmpBB;
	}

	public function Rand64():Bitboard64 {
		var e:Bitboard64 = a.newMINUS(Rotate(b, 7));
		a = b.newXOR(Rotate(c, 13));
		b = c.newPLUS(Rotate(d, 37));
		c = d.newPLUS(e);
		d = e.newPLUS(a);
		return d;
	}

	public function SF_RKiss() {
		var seed:Int = 73;
		a.Init(0xF1EA, 0x5EED);
		b.Init(0xD4E1, 0x2C77);
		c.Init(0xD4E1, 0x2C77);
		d.Init(0xD4E1, 0x2C77);
		for (i in 0...seed)
			/* Scramble a few rounds */ {
			Rand64();
		}
    }
}

class MathUtil {
	static public function abs(a:Int):Int {
		return (a >= 0) ? a : -a;
	}

	static public function max(a:Int, b:Int):Int {
		return (a > b) ? a : b;
	}

	static public function min(a:Int, b:Int):Int {
		return (a < b) ? a : b;
	}
    
    static public function zeroPadding(v:Int):String {
        var ereg = ~/\B(?=(\d\d\d)+(?!\d))/g;
        return ereg.replace('${v}', ",");
    }
}
