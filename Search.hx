package;

import Types.Move;
import util.MathUtil;

class Search {
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
		var beta:Int = -Types.VALUE_INFINITE;
		var delta:Int = Types.VALUE_INFINITE;
		while (++depth <= Types.MAX_PLY) { // depth loop
			trace('depth==$depth');
			for (pvIdx in 0...pvSize) { // for Multu pv
				while (true) {
					bestValue = Search(pos, alpha, beta);
					StableSort(rootMoves, pvIdx, numRootMoves - 1);
					trace('IDLoop bestValue:$bestValue');
					if (bestValue <= alpha) {
						alpha = MathUtil.max(bestValue - delta, -Types.VALUE_INFINITE);
						trace('bestValue <= alpha: $alpha');
					} else {
						if (bestValue >= beta) {
							beta = MathUtil.min(bestValue + delta, Types.VALUE_INFINITE);
							trace('bestValue >= beta: $beta');
						} else {
							trace('BREAK;;');
							break;
						}
					}
					delta += Std.int(delta / 2);
			break; ///
				}
				StableSort(rootMoves, 0, MathUtil.min(numRootMoves - 1, pvIdx + 1));
			}
		}
		trace('Search::IDLoop end');
	}

	private static function StableSort(moves:Array<SearchRootMove>, begin:Int, end:Int) {
		trace('StableSoart start begin:$begin end:$end');
		if (begin == end) {
			trace('StableSoart return');
			return;
		}
		var swapped:Bool = false;
		var m:Move = new Move(0);
		var s:Int = 0;
		for (j in begin...end) {
			swapped = false;
			var i = end;
			while (i > j) {
				trace(i, j, moves[i - 1].score, ' < ', moves[i].score);
				if (moves[i - 1].score < moves[i].score) {
					swapped = true;
					var tmp:SearchRootMove = moves[i - 1];
					moves[i - 1] = moves[i];
					moves[i] = tmp;
					m = moves[i].pv[0];
					s = moves[i].score;
					trace('StableSoart swap ${Types.Move_To_StringLong(m)} $s');
				}
				i--;
			}
			if (!swapped) {
				trace('StableSoart break i:$i j:$j');
				break;
			}
		}
	}

	private static function Search(pos:Position, alpha:Int, beta:Int):Int {
		trace('Search::Search');
		var pvMove:Bool = true;
		var mp:MovePicker = new MovePicker();
		var move:Move = new Move(0);
		var rootNode:Bool = true;
		var bestValue:Int = Evaluate.DoEvaluate(pos, false);
		var value = 0;
		mp.InitA(pos);
		while ((move = mp.NextMove()) != Types.MOVE_NONE) {
			trace('Search mvoe==${Types.Move_To_String(move)}');
			bestValue = Evaluate.DoEvaluate(pos, false);
			value = bestValue;
			if (rootNode) { // Qsearchが終わってpvの更新が行われる？
				var rm:SearchRootMove; // root move
				for (k in 0...numRootMoves) {
					if (rootMoves[k].Equals(move)) { // MPのmoveからrootMovesのmoveを引く
						rm = rootMoves[k];
						if (pvMove || value > alpha) {
							rm.score = value;
							// 	rm.ExtractPVFromTT( pos, TT );
							//  	if( !pvMove ) {
							//   		bestMoveChanges++;
							// 	}
						} else {
							rm.score = -Types.VALUE_INFINITE;
						}
						break;
					}
				}
			}
			break; ///
		}
		trace('Search bestValue:$bestValue');
		return bestValue;
	}
}
