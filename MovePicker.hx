package;

import Types.Move;

class MovePicker {
	private var pos:Position;
	private var moves:MoveList = new MoveList();
	private var cur:Int = 0;
	private var end:Int = 0;
	private var stage:Int = 0;

	public function new() {
		trace('MovePicker::new');
	}

	public function InitA(p:Position) {
		trace('MovePicker::InitA');
		pos = p;
		GenerateNext();// ittan
	}

	public function GenerateNext() {
		cur = 0;
		moves.Reset();
		moves.Generate(pos, MoveList.LEGAL);
		end = moves.moveCount;
		stage++;
		trace('MovePicker::GenerateNext stage=', stage);
	}

	public function NextMove():Move {
		trace('MovePicker::NextMove cur:$cur moveCount:${moves.moveCount}');
		if (moves.moveCount < cur) {
			trace('MovePicker return MOVE_NONE');
			return Types.MOVE_NONE;
		} else {
			var move:Move = new Move(0);
			move = moves.mlist[cur].move;
			cur++;
			trace('MovePicker return ${Types.Move_To_String(move)}');
			return move;
		}
	}
}
