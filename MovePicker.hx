package;

import Types.Move;

class MovePicker {
	public static inline var MAIN_SEARCH:Int = 0;
	public static inline var CAPTURES_S1:Int = 1;
	public static inline var KILLERS_S1:Int = 2;
	public static inline var QUIETS_1_S1:Int = 3;
	public static inline var QUIETS_2_S1:Int = 4;
	public static inline var BAD_CAPTURES_S1:Int = 5;
	public static inline var EVASION:Int = 6;
	public static inline var EVASIONS_S2:Int = 7;
	public static inline var QSEARCH_0:Int = 8; //
	public static inline var CAPTURES_S3:Int = 9;
	public static inline var QUIET_CHECKS_S3:Int = 10; // 駒を取らない王手になる指し手のみ生成。
	public static inline var QSEARCH_1:Int = 11;
	public static inline var CAPTURES_S4:Int = 12;
	public static inline var PROBCUT:Int = 13;
	public static inline var CAPTURES_S5:Int = 14;
	public static inline var RECAPTURE:Int = 15;
	public static inline var CAPTURES_S6:Int = 16;
	public static inline var STOP:Int = 17;

	private var pos:Position;
	private var moves:MoveList = new MoveList();
	private var cur:Int = 0;
	private var end:Int = 0;
	private var stage:Int = 0;

	private var generated:Bool = false;

	public function new() {
		trace('MovePicker::new');
	}

	public function InitA(p:Position) {
		trace('MovePicker::InitA');
		pos = p;
		moves.Reset();
		cur = 0;
		end = 0;
		if (p.Checkers().IsNonZero()) {
			stage = EVASION;
		} else {
			stage = MAIN_SEARCH;
		}
		trace('stage == $stage');
		// GenerateNext(); // ittan
	}

	public function GenerateNext() {
		cur = 0;
		moves.Generate(pos, MoveList.LEGAL);
		end = moves.moveCount;
		stage++;
		trace('MovePicker::GenerateNext stage=', stage);
	}

	public function NextMove():Move {
		trace('MovePicker::NextMove cur:$cur end:$end moveCount:${moves.moveCount}');
		if (generated) {
			// if (cur == end) {
			GenerateNext();
			generated = true;// knn
		}
		if (cur > 1) {
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
