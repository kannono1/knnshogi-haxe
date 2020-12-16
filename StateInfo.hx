package;

import Evaluate.DirtyPiece;
import Types.PT;
import Types.Move;
import haxe.ds.Vector;

class StateInfo {
	public var checkersBB:Bitboard = new Bitboard(); // 王手している駒
	public var blockersForKing:Vector<Bitboard> = new Vector<Bitboard>(2);
	public var pinners:Vector<Bitboard> = new Vector<Bitboard>(2);
	public var capturedType:PT = new PT(0); // 取った駒
	public var materialValue:Int = 0; // 駒得
	public var previous:StateInfo; // 前の情報
	public var dirtyPiece = new DirtyPiece();
	public var sum:EvalSum = new EvalSum();
	// 盤面(盤上の駒)と手駒に関するhash key
	public var board_key_:Bitboard64 = new Bitboard64(); // やねうらおうではHASH_KEY 64bit
	public var hand_key_:Bitboard64 = new Bitboard64();
	public var lastMove:Move;

	public function new() {
		for (c in Types.BLACK...Types.COLOR_NB) {
			blockersForKing[c] = new Bitboard();
			pinners[c] = new Bitboard();
		}
	}

	public function key():Bitboard64 {
		return long_key();
	}

	private function long_key():Bitboard64 {
		return board_key_.newPLUS(hand_key_);
	}

	public function printKey():Void {
		trace('KEY:${key().toStringBB()}');
	}

	public function Clear() {
		checkersBB.Clear();
		capturedType = new PT(0);
		materialValue = 0;
		dirtyPiece = new DirtyPiece();
		checkersBB = new Bitboard();
		for (c in Types.BLACK...Types.COLOR_NB) {
			blockersForKing[c] = new Bitboard();
			pinners[c] = new Bitboard();
		}
		previous = null;
		sum = new EvalSum();
	}

	public function Copy(other:StateInfo) {
		checkersBB.Copy(other.checkersBB);
		capturedType = other.capturedType;
		materialValue = other.materialValue;
		previous = other.previous;
		for (c in Types.BLACK...Types.COLOR_NB) {
			blockersForKing[c].Copy(other.blockersForKing[c]);
			pinners[c].Copy(other.pinners[c]);
		}
		board_key_ = other.board_key_.newCOPY();
		hand_key_ = other.hand_key_.newCOPY();
		lastMove = other.lastMove;
	}
}
