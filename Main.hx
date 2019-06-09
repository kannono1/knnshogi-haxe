package;

import ui.UI;

@:expose
class Main {
    static public var gui:UI;
	static function main() {
		trace('Hello haxe');
		var ui = new UI();
        Main.gui = ui;


        var bb = new Bitboard(0x01, 0x03, 0x07);
        trace(bb.toStringBB());
	}
    // Main.onClickCell
    static public function onClickCell(sq:Int){
        gui.onClickCell(sq);
    }
}
