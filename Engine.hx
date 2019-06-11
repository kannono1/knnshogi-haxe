package;

import js.html.DedicatedWorkerGlobalScope;
import js.html.MessageEvent;

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

	static private function Init(){
		BB.Init();
		Search.Init();
	}

	static private function onMessage(m:MessageEvent) {
		var msg:String = m.data;
		var res:String = '';
		trace('Endine get data = ${msg}');
		if (msg.indexOf('position ') == 0) {
			pos.setPosition(msg.substr(9));
			pos.printBoard();
			trace('pos.c: ${pos.SideToMove()}');
			Search.Reset(pos);
			Search.Think();
			var moveResult:Int = Search.rootMoves[0].pv[0];
			res = 'bestmove ${Types.Move_To_String( moveResult )}';
			trace(res);
			global.postMessage(res);
		}
	}
}
