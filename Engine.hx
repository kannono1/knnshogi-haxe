package;

import js.html.DedicatedWorkerGlobalScope;
import js.html.MessageEvent;
import data.Move;

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
		Search.Init();
	}

	static private function onMessage(m:MessageEvent) {
		var msg:String = m.data;
		trace('Endine get data = ${msg}');
		if (msg.indexOf('position ') == 0) {
			pos.setPosition(msg.substr(9));
			pos.printBoard();
			Search.Reset(pos);
			Search.Think();
			global.postMessage(msg + "!!");
		}
	}
}
