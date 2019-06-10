package;

class Search {
	private static var rootPos:Position;
	public static var rootMoves:Array<SearchRootMove> = [];

	public function new() {}

	public static function Init() {
		trace('Search::Init');
		for (i in 0...Types.MAX_MOVES) {
			rootMoves.push(new SearchRootMove());
		}
	}

	public static function Reset(pos:Position) {
		trace('Search::Reset');
		rootPos = pos;
		var moves = new MoveList();
		moves.Generate(rootPos);
	}

	public static function Think() {
		trace('Search::Think');
	}
}
