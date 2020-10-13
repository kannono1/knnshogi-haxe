package;

import Types.Move;
import util.MathUtil;

class Search {
	private static inline var NodeRoot:Int = 0;
	private static inline var NodePV:Int = 1;
	private static inline var NodeNonPV:Int = 2;
	public static var rootMoves:Array<SearchRootMove> = [];
	private static var rootPos:Position;
	private static var numRootMoves:Int = 0;
	private static var rootColor:Int = 0;
	private static var maxPly:Int = 0;
	private static var pvSize:Int = 1;

	public function new() {}

	public static function Init() {
		trace('Search::Init');
		for (i in 0...Types.MAX_MOVES) {
			rootMoves.push(new SearchRootMove());
		}
	}

	public static function Reset(pos:Position) {
		trace('Search::Reset');
		for (i in 0...Types.MAX_MOVES) {
			rootMoves[i].Clear();
		}
		numRootMoves = 0;
		rootPos = pos;
		var moves = new MoveList();
		moves.Generate(rootPos, MoveList.LEGAL);
		for (i in 0...moves.moveCount) {
			rootMoves[numRootMoves].SetMove(moves.mlist[i].move);
			numRootMoves++;
		}
	}

	public static function Think() {
		trace('Search::Think');
		maxPly = 0;
		rootColor = rootPos.SideToMove();
		Evaluate.evalRootColour = rootColor;
		IDLoop(rootPos);
	}

	private static function IDLoop(pos:Position) {
		trace('====================');
		trace('Search::IDLoop start');
		var depth:Int = 0;
		var bestValue:Int = -Types.VALUE_INFINITE;
		var alpha:Int = -Types.VALUE_INFINITE; // 評価値が小さくなって打ち切ることをαカットといいます。
		var beta:Int = Types.VALUE_INFINITE;
		var delta:Int = Types.VALUE_INFINITE;
		while (++depth < Types.MAX_PLY) { // depth loop
			trace('Search::IDLoop depth=$depth');
			alpha = -Types.VALUE_INFINITE; // 評価値が小さくなって打ち切ることをαカットといいます。
			beta = Types.VALUE_INFINITE;
			bestValue = Search(pos, alpha, beta, depth, NodeRoot);
			StableSort(rootMoves, 0, numRootMoves - 1);
			// if (bestValue <= alpha) {
			// 	alpha = MathUtil.max(bestValue - delta, -Types.VALUE_INFINITE);
			// } else {
			// 	if (bestValue >= beta) {
			// 		beta = MathUtil.min(bestValue + delta, Types.VALUE_INFINITE);
			// 	}
			// }
			// delta += Std.int(delta / 2);
			// StableSort(rootMoves, 0, MathUtil.min(numRootMoves - 1, 1));
		}
		trace('Search::IDLoop end');
		for (i in 0...30) {
			trace('rootMoves${i} ${Types.Move_To_String(rootMoves[i].pv[0])} ${rootMoves[i].score}');
		}
	}

	private static function StableSort(moves:Array<SearchRootMove>, begin:Int, end:Int) {
		if (begin == end) {
			return;
		}
		var swapped:Bool = false;
		var m:Move = new Move(0);
		var s:Int = 0;
		for (j in begin...end) {
			swapped = false;
			var i = end;
			while (i > j) {
				if (moves[i - 1].score < moves[i].score) {
					swapped = true;
					var tmp:SearchRootMove = moves[i - 1];
					moves[i - 1] = moves[i];
					moves[i] = tmp;
					m = moves[i].pv[0];
					s = moves[i].score;
				}
				i--;
			}
			if (!swapped) {
				break;
			}
		}
	}

	private static function Qsearch(pos:Position, alpha:Int, beta:Int, depth:Int):Int {
		var value = 0;
		value = Evaluate.DoEvaluate(pos, false);
		// trace('Qsearch depth:${depth} alpha:${alpha} beta:${beta} value:${bestValue}');
		// if (value > alpha) // update alpha?
		// {
		// 	alpha = value;
		// 	if (alpha >= beta) {
		// 		return alpha; // beta cut
		// 	}
		// }
		return value;
	}

	private static function Search(pos:Position, alpha:Int, beta:Int, depth:Int, nodeType:Int):Int {
		var pvMove:Bool = true;
		var mp:MovePicker = new MovePicker();
		var move:Move = new Move(0);
		var rootNode:Bool = nodeType == NodeRoot;// Thinkから呼ばれたらRootNodeになる
		var value = 0;
		var st = new StateInfo();
		mp.InitA(pos);
		while ((move = mp.NextMove()) != Types.MOVE_NONE) {// この局面の全指し手を探索
			trace('depth:${depth}', Types.Move_To_StringLong(move));
			pos.doMove(move, st);
			value = depth - Types.ONE_PLY < Types.ONE_PLY 
				? -Qsearch(pos, -beta, -alpha, depth) // depthが0になったら静止探索をする。
				: -Search(pos, -beta, -alpha, depth - Types.ONE_PLY, NodeNonPV);// depth0になるまで再帰
			pos.undoMove(move);
			if (rootNode) {
				var rm:SearchRootMove; // root move
				for (k in 0...numRootMoves) {
					if (rootMoves[k].Equals(move)) { // rootMoveにScoreを保存する
						rm = rootMoves[k];
						// if (pvMove || value > alpha) {
						rm.score = value;
						// } else {
						// 	rm.score = -Types.VALUE_INFINITE;
						// }
						break;
					}
				}
			}
			if (value > alpha) {// 下限値を更新
				alpha = value;
				// 	// bestMove = move;
				// 	if (alpha >= beta) {
				// 		break;
				// 	}
			}
		}
		trace('Search bestValue:${alpha}');
		return alpha;
	}
}
