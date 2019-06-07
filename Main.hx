package;

import ui.UI;

@:expose
class Main {
    static public var gui:UI;
	static function main() {
		trace('Hello haxe');
		var ui = new UI();
        Main.gui = ui;
	}
    // Main.onClickCell
    static public function onClickCell(sq:Int){
        gui.onClickCell(sq);
    }
}
