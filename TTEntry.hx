import Types.Move;

class TTEntry {
	public static inline var TTEntrySizeBytes:Int = 16;

	private var key32:Int;
	private var int1:Int;
	private var int2:Int;
	private var int3:Int;

	public function new() {}

	public function GetKey():Int {
		return key32;
	}

	public function GetDepth():Int {
		return ((int2 >>> 16) & 0xFFFF) - 32768;
	}

	public function GetMove():Move {
		return new Move((int1 >>> 16) & 0xFFFF);
	}

	public function GetValue():Int {
		return (int1 & 0xFFFF) - 32768;
	}

	public function GetBound():Int {
		return int3 & 0xFF;
	}

	public function SetGeneration(g:Int):Void {
		int3 = (g << 8) | (int3 & 0xFF);
	}

    /**
        @k Key
        @v Value
        @b Bound
        @d Depth
        @m best move
        @ev evaluated value
        @g generation
    **/
	public function Save(k:Int, v:Int, b:Int, d:Int, m:Int, ev:Int, g:Int):Void {
        // trace('TTEntry::Save k:${k} v:${v} b:${b} d:${d} m:${m} g:${g} ev:${ev}');
		v += 32768;// 1000 0000 0000 0000
		ev += 32768;
		d += 32768;

		key32 = k;
		int1 = (m << 16) | v;
		int2 = (d << 16) | ev;
		int3 = (g << 8) | b;
	}

	public function Clear():Void {
		key32 = 0;
		int1 = 0;
		int2 = 0;
		int3 = 0;
	}
}
