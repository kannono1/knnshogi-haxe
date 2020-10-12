package;

class EvalSum {
    public var m:Array<Int> = [];
    public var p:Array<Array<Int>> = [
        [],
        [],
        []
    ];// KK

    public function new(){}

    public function sum(c:Int):Int {
        // p[0][1]とp[1][1]は使っていないタイプのEvalSum
        var scoreBoard:Int = p[0][0] - p[1][0] + p[2][0];
        // 手番に依存する評価値合計
        var scoreTurn:Int = p[2][1];
        // この関数は手番側から見た評価値を返すのでscoreTurnは必ずプラス
        return (c == Types.BLACK ? scoreBoard : -scoreBoard) + scoreTurn;
    }
    
}