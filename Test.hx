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
		doThink('startpos');
	}

	static private function Init() {
		BB.Init();
		Position.Init();
		Evaluate.Init();
		Search.Init();
	}

	static private function doThink(msg:String):String {
		trace('doThink start: :${msg}');
		pos.setPosition(msg);
		pos.printBoard();
		trace('Test::doThink pos.c: ${pos.SideToMove()}');
		Search.Reset(pos);
		Search.Think();
		var moveResult:Move = Search.rootMoves[0].pv[0];
		var res = 'bestmove ${Types.Move_To_String(moveResult)}';
		trace(res);
		return res;
	}
}
