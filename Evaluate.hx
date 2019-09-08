package;

class Evaluate {
    public static var evalRootColour:Int = 0;
	public static function Init() {
		trace('Evaluate::Init ');
	}

	public static function DoEvaluate(pos:Position, doTrace:Bool):Int {
		var score:Int = 0;
		return Std.int(Math.random() * 100);
	}
}
