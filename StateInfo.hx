package;

import Types.PT;

class StateInfo {
	public var checkersBB:Bitboard = new Bitboard();
	public var capturedType:PT = new PT(0);

	public function new() {
		trace('new StateInfo');
	}

	public function Clear() {
		checkersBB.Clear();
		capturedType = new PT(0);
	}

	public function Copy(other:StateInfo) {
		checkersBB.Copy(other.checkersBB);
		capturedType = other.capturedType;
	}
}
