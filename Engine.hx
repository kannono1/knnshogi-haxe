package;

import js.html.DedicatedWorkerGlobalScope;
import js.html.MessageEvent;
import Types.Move;

class Engine {
	static private var global:DedicatedWorkerGlobalScope = js.Lib.eval("self");
	static private var pos:Position;

	public function new() {
		trace('Engine:new');
	}

	static function main() {
		trace('Engine main');
		pos = new Position();
		Init();
		global.onmessage = onMessage;
	}

	static private function Init() {
		BB.Init();
		Position.Init();
		Evaluate.Init();
		Search.Init();
	}

	static private function onMessage(m:MessageEvent) {
		var msg:String = m.data;
		var res:String = '';
		trace('Endine get data = ${msg}');
		if (msg.indexOf('position ') == 0) {
			res = doThink(msg);
		}
		global.postMessage(res);
	}

	static private function doThink(msg:String):String {
		pos.setPosition(msg.substr(9));
		pos.printBoard();
		trace('Engine::doThink pos.c: ${pos.SideToMove()}');
		Search.Reset(pos);
		Search.Think();
		var moveResult:Move = Search.rootMoves[0].pv[0];
		var res = 'bestmove ${Types.Move_To_String(moveResult)}';
		trace(res);
		return res;
	}
}
