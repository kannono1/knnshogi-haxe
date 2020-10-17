package;

import Types.Move;

class Test {
	static private var pos:Position;

	public function new() {
		trace('Test:new');
	}

	static function main() {
		trace('Test main');
		pos = new Position();
		Init();
		Assert('平手開始局面', doThink('startpos') != new Move(0));
	}

	static private function Init() {
		BB.Init();
		Position.Init();
		Evaluate.Init();
		Search.Init();
	}

	static private function doThink(sfen:String):Move {
		trace('doThink start: :${sfen}');
		pos.setPosition(sfen);
		pos.printBoard();
		trace('doThink pos.c: ${pos.SideToMove()}');
		Search.Reset(pos);
		Search.Think();
		var moveResult:Move = Search.rootMoves[0].pv[0];
		trace('bestmove ${Types.Move_To_String(moveResult)}');
		return moveResult;
	}

	static private function Assert(msg:String, expected:Bool) {
		trace('Assert ${msg} start');
		if(!expected){
			throw('AssertionError');
		}
		trace('Assert ${msg} OK !!');
	}
}
