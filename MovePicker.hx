package;

class MovePicker {
	private var pos:Position;
	private var moves:MoveList = new MoveList();
	private var cur:Int = 0;
	private var stage:Int = 0;

	public function new() {
		trace('MovePicker::new');
	}

	public function InitA(p:Position) {
		trace('MovePicker::InitA');
		pos = p;
	}

	public function GenerateNext() {
		cur = 0;
		moves.Reset();
		stage++;
		trace('MovePicker::GenerateNext stage=', stage);
	}

	public function NextMove():Int {
		var move:Int = 0;
		return move;
	}
}
