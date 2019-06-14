package;

import Types.Move;

class SearchRootMove {
	public var pv:Array<Move> = [];
    public var score:Int;
	public var prevScore:Int;
	public var numMoves:Int;

	public function new() {}

    public function Clear()  {
		score = 0;
		prevScore = 0;
		pv[0] = Types.MOVE_NONE;
		numMoves = 0;
	}
	public function SetMove( m:Move )  {
		score = -Types.VALUE_INFINITE;
		prevScore = -Types.VALUE_INFINITE;
		pv[0] = m;
		numMoves = 1;
	}
	public function Equals( m:Move ) : Bool {
		return ( pv[0] == m );
	}
}
