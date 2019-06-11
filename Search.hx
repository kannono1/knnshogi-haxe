package;

class Search {
	private static var rootPos:Position;
	public static var rootMoves:Array<SearchRootMove> = [];
	private static var numRootMoves:Int = 0;

	public function new() {}

	public static function Init() {
		trace('Search::Init');
		for (i in 0...Types.MAX_MOVES) {
			rootMoves.push(new SearchRootMove());
		}
	}

	public static function Reset(pos:Position) {
		trace('Search::Reset');
		for (i in 0...Types.MAX_MOVES) {
			rootMoves[i].Clear();
		}
		numRootMoves = 0;
		rootPos = pos;
		var moves = new MoveList();
		moves.Generate(rootPos);
		for (i in 0...moves.moveCount) {
			rootMoves[numRootMoves].SetMove(moves.mlist[i].move);
			numRootMoves++;
		}
	}

	public static function Think() {
		trace('Search::Think');
	}

	public static function Search(pos:Position):Int {
		trace('Search::Search');
		var mp:MovePicker = new MovePicker();
		var move:Int = 0;
		mp.InitA(pos);
		move = mp.NextMove();
		return move;
	}
}
