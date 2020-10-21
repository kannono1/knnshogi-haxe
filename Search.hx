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

	// Qsearchの時はdepthがマイナスになる
	private static function Qsearch(pos:Position, alpha:Int, beta:Int, depth:Int):Int {
		// 現在のnodeのrootからの手数。これカウンターが必要。
		// nanoだとこのカウンター持ってないので適当にごまかす。
		var ply_from_root:Int = Std.int(Types.MAX_PLY - depth / Types.ONE_PLY) + 1;// 詰みの時に手数を返すため
		var InCheck = pos.in_check(); // この局面で王手がかかっているのか
		var value:Int = 0;
		if (InCheck) {
			alpha = -Types.VALUE_INFINITE;
			if (depth < -9 * Types.ONE_PLY){
				return Evaluate.DoEvaluate(pos, false); // knn ittan
			}
		} else {
			// この局面で何も指さないときのスコア。recaptureすると損をする変化もあるのでこのスコアを基準に考える。
			value = Evaluate.DoEvaluate(pos, false);
			if (alpha < value) {
				alpha = value;
				if (alpha >= beta){
					return alpha; // beta cut
				}
			}
			// 探索深さが-3以下ならこれ以上延長しない。
			if (depth < -3 * Types.ONE_PLY) return alpha;
		}
		// 取り合いの指し手だけ生成する
		var mp:MovePicker = new MovePicker();
		mp.InitB(pos);
		var move:Move;
		var si:StateInfo = new StateInfo();
		while ((move = mp.next_move()) != Types.MOVE_NONE) {
			if (!pos.legal(move)) continue;
			pos.do_move(move, si);//, pos.gives_check(move)
			value = -Qsearch(pos, -beta, -alpha, depth - Types.ONE_PLY);
			pos.undo_move(move);
			// if (Signals.stop) return VALUE_ZERO;
			if (value > alpha) { // update alpha?
				alpha = value;
				if (alpha >= beta){
					return alpha; // beta cut
				}
			}
		}
		// 王手がかかっている状況ですべての指し手を調べたということだから、これは詰みである
		if (InCheck && alpha == -Types.VALUE_INFINITE) return Types.mated_in(ply_from_root);
		return alpha;
	}

	private static function Search(pos:Position, alpha:Int, beta:Int, depth:Int, nodeType:Int):Int {
		var pvMove:Bool = true;
		var mp:MovePicker = new MovePicker();
		var move:Move = new Move(0);
		var rootNode:Bool = nodeType == NodeRoot;// Thinkから呼ばれたらRootNodeになる
		var value = 0;
		var st = new StateInfo();
		mp.InitA(pos);
		while ((move = mp.next_move()) != Types.MOVE_NONE) {// この局面の全指し手を探索
			if (!pos.legal(move))
				continue;
			// trace('depth:${depth}', Types.Move_To_StringLong(move), 'nodeType:${nodeType} rootNode:${rootNode}');
			pos.do_move(move, st);
			value = depth - Types.ONE_PLY < Types.ONE_PLY 
				? -Qsearch(pos, -beta, -alpha, depth) // depthが0になったら静止探索をする。
				: -Search(pos, -beta, -alpha, depth - Types.ONE_PLY, NodeNonPV);// depth0になるまで再帰
			pos.undo_move(move);
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
				// bestMove = move;
				if (alpha >= beta) {
					break;
				}
			}
		}
		return alpha;
	}
}
