package ui;

import js.Browser;

class UI {
	public function new() {
		trace('UI::New');
		Browser.window.onload = onLoad;
	}

	function onLoad():Void {
		trace('haxe onload');
		var el = Browser.document.getElementById('output');
		trace(el);
		el.innerHTML = 'JJJJ';
	}
}
