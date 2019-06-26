package;

import ui.UI;
import Types.PR;

@:expose
class Main {
	static public var gui:UI;

	static function main() {
		trace('Hello haxe');
		var ui = new UI();
		Main.gui = ui;
	}

	static public function onClickCell(sq:Int) {
		gui.onClickCell(sq);
	}

	static public function onClickHand(pr:PR) {
		gui.onClickHand(pr);
	}

	static public function onClickPromote(b:Int) {
		gui.onClickPromote((b == 1));
	}
}
