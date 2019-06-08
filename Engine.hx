package;

import js.html.DedicatedWorkerGlobalScope;
import js.html.MessageEvent;

class Engine {
	public function new() {
		trace('Engine:new');
	}

	static function main() {
		trace('Engine main');
		var global:DedicatedWorkerGlobalScope = js.Lib.eval("self");
		global.onmessage = function(m:MessageEvent) {
            trace('Endine get data = ${m.data}');
			global.postMessage(m.data + "!!");
		};
	}
}
