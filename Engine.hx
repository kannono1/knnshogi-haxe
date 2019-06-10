package;

import js.html.DedicatedWorkerGlobalScope;
import js.html.MessageEvent;
import data.Move;

class Engine {
	static private var global:DedicatedWorkerGlobalScope = js.Lib.eval("self");

	public function new() {
		trace('Engine:new');
	}

	static function main() {
		trace('Engine main');
		global.onmessage = onMessage;
	}

	static private function onMessage(m:MessageEvent) {
		var msg:String = m.data;
		trace('Endine get data = ${msg}');
		if (msg.indexOf('position ') == 0) {
			var mvs = msg.split('moves ')[1];
			trace(mvs);
			var m = Move.generateMoveFromString(mvs);
			trace(m.toString());
			global.postMessage(msg + "!!");
		}
	}
}
