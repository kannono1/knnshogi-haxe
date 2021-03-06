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

	public function new() { }

	public function moveCount():Int {
		return moves.moveCount;
	}

	public function InitA(p:Position) {// Searchから呼ばれる
		pos = p;
		moves.Reset();
		cur = 0;
		end = 0;
		if (p.in_check()) {
			stage = EVASION;
		} else {
			stage = MAIN_SEARCH;
		}
		GenerateNext(); // ittan
	}

	public function InitB(p:Position) {// QSearchから呼ばれる駒を取る手だけを生成する
		pos = p;
		moves.Reset();
		cur = 0;
		end = 0;
		stage = EVASION;
		var us = pos.SideToMove();
		var target:Bitboard = new Bitboard();
		var lastMove:Move = pos.state().lastMove;
		target.SetBit(Types.move_to(lastMove));
		if (p.in_check()) {
			GenerateNext(); // ittan
		} else {
			moves.GenerateAll(pos, us, target, MoveList.CAPTURES); // ittan
		}
	}

	public function GenerateNext() {
		cur = 0;
		if(stage == EVASION){
			moves.Generate(pos, MoveList.EVASIONS);
		}
		else{
			moves.Generate(pos, MoveList.LEGAL);
		}
		end = moves.moveCount;
		stage++;
	}

	public function next_move():Move {
		// if (generated) {
		// 	GenerateNext();
		// 	generated = true; // knn
		// }
		if (moves.moveCount == 0) {
			return Types.MOVE_NONE;
		}
		var move:Move = moves.mlist[cur].move;
		cur++;
		return move;
	}
}
