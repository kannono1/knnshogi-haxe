package;

import Evaluate.DirtyPiece;
import Types.PT;
import haxe.ds.Vector;

class StateInfo {
	public var checkersBB:Bitboard = new Bitboard();//王手している駒
	public var blockersForKing:Vector<Bitboard> = new Vector(2);
	public var pinners:Vector<Bitboard> = new Vector(2);
	public var capturedType:PT = new PT(0);//取った駒
	public var materialValue:Int = 0;//駒得
	public var previous:StateInfo;//前の情報
	public var dirtyPiece = new DirtyPiece();
	public var sum:EvalSum = new EvalSum();

	public function new() {
		for(c in Types.BLACK...Types.COLOR_NB){
			blockersForKing[c] = new Bitboard();
			pinners[c] = new Bitboard();
		}
	}

	public function Clear() {
		checkersBB.Clear();
		capturedType = new PT(0);
		materialValue = 0;
		dirtyPiece = new DirtyPiece();
	}

	public function Copy(other:StateInfo) {
		checkersBB.Copy(other.checkersBB);
		capturedType = other.capturedType;
		materialValue = other.materialValue;
		previous = other.previous;
	}
}
