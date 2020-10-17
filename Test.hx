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
		TestAll();
	}

	static private function TestAll(){
		AssertFn('王手回避', 'rnslklsnb/1g5g1/ppppLpppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSN1 w - 1'
			, (bm:Move)->[Types.Make_Move(36, 46), Types.Make_Move(36, 28)].indexOf(bm) != -1);
		AssertFn('平手開始局面','startpos', (bm)-> bm != new Move(0));
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

	static private function AssertFn(msg:String, sfen:String, fn) {
		trace('AssertFn ${msg} start');
		var bm = doThink(sfen);
		var expected = fn(bm);
		if(!expected){
			throw('AssertionFnError ${msg} ${sfen} bm:${bm}');
		}
		trace('Assert ${msg} OK !!');
		trace('+++++++++++++++++++++++++++++++++++');
	}
}
