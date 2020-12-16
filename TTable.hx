/**
    TTEntryを管理する
**/
class TTable {
	private static inline var ClusterSize:Int = 4;

	private var hashMask:Int;
	private var numEntries:Int;
	private var hashTable:Array<TTEntry>;
	private var generation:Int;

	public function new() {
		hashMask = 0;
		generation = 0;
	}

	public function NewSearch():Void {
		generation++;
		if (generation > 255) {
			generation = 0;
		}
	}

	public function FirstEntry(key:Bitboard64):TTEntry {
		return hashTable[FirstIndex(key)];
	}

	private function FirstIndex(key:Bitboard64):Int {
		return (key.lower & hashMask);
	}

	public function GetEntry(key:Bitboard64, i:Int):TTEntry {
		return hashTable[FirstIndex(key) + i];
    }

	public function GetGeneration():Int {
		return generation;
	}

	public function Refresh(tte:TTEntry):Void {
		tte.SetGeneration(generation);
	}

	public function SetSize(mbSize:Int):Void {
		var size:Int = ClusterSize << Bitboard64.MostSB(Std.int((mbSize << 20) / (TTEntry.TTEntrySizeBytes * ClusterSize)));
		if (hashMask == size - ClusterSize) {
			return;
		}
		hashMask = size - ClusterSize;
		hashTable = new Array<TTEntry>();
		numEntries = size;
		for (i in 0...numEntries) {
			hashTable[i] = new TTEntry();
		}
		Clear();
	}

	public function Clear():Void {
		for (i in 0...numEntries) {
			hashTable[i].Clear();
		}
	}

	public function Probe(key:Bitboard64):Dynamic {
		var tte:TTEntry = FirstEntry(key);
        var key32:Int = key.upper;
        var found:Bool = false;
		for (i in 0...ClusterSize) {
			tte = GetEntry(key, i);
			if (tte.GetKey() == key32) {
                found = true;
                break;
			}
		}
		return {found:found, tte:tte};
	}
}
