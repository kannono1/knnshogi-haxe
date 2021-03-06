package;

import Types.Move;
import haxe.Timer;
import util.Assert;
import util.MathUtil;

class Signals {
	public static var stop:Bool = false;
	public static var startTime:Float = 0;
}

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
	private static var TT:TTable = null;
	private static var rootDepth:Int = 0;

	public function new() {}

	public static function Init() {
		trace('Search::Init');
		TT = new TTable();
		TT.SetSize(32);
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
		pos.resetNode();
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
		rootDepth = 0;
		var bestValue:Int = -Types.VALUE_INFINITE;
		var alpha:Int = -Types.VALUE_INFINITE; // 評価値が小さくなって打ち切ることをαカットといいます。
		var beta:Int = Types.VALUE_INFINITE;
		var delta:Int = Types.VALUE_INFINITE;
		Signals.stop = false;
		Signals.startTime = Timer.stamp();
		TT.NewSearch();
		while (++rootDepth < Types.MAX_PLY && !Signals.stop) { // depth loop
			trace('Search::IDLoop depth=${rootDepth} ');
			alpha = -Types.VALUE_INFINITE; // 評価値が小さくなって打ち切ることをαカットといいます。
			beta = Types.VALUE_INFINITE;
			#if debug
			DebugInfo.startDepth = rootDepth;
			#end
			bestValue = Search(pos, alpha, beta, rootDepth, NodeRoot);
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
		for (i in 0...20) {
			trace('rootMoves${i} ${Types.Move_To_StringLong(rootMoves[i].pv[0])}  score:${rootMoves[i].score}');
		}
		var elapsed = Timer.stamp() - Signals.startTime;
		var nps:Int = Std.int(pos.Nodes() / elapsed);
		trace('depth:${rootDepth} nps:${MathUtil.zeroPadding(nps)} nodes :${MathUtil.zeroPadding(pos.Nodes())} elapsed:${elapsed} rootMoves${0} ${Types.Move_To_StringLong(rootMoves[0].pv[0])}  score:${rootMoves[0].score}');
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
	inline static var MAX_DEPTH = -9;

	private static function Qsearch(pos:Position, alpha:Int, beta:Int, depth:Int):Int {
		// trace('Qsearch::start alpha:${alpha} beta:${beta} depth:${depth}');
		// 現在のnodeのrootからの手数。これカウンターが必要。
		// nanoだとこのカウンター持ってないので適当にごまかす。
		var ply_from_root:Int = Std.int(Types.MAX_PLY - depth / Types.ONE_PLY) + 1; // 詰みの時に手数を返すため
		var InCheck = pos.in_check(); // この局面で王手がかかっているのか
		var value:Int = 0;
		if (InCheck) {
			alpha = -Types.VALUE_INFINITE;
			value = Evaluate.DoEvaluate(pos, false); // knn ittan
			return value;
		} else {
			// trace('// この局面で何も指さないときのスコア。recaptureすると損をする変化もあるのでこのスコアを基準に考える。');
			value = Evaluate.DoEvaluate(pos, false);
			if (alpha < value) {
				alpha = value;
				if (alpha >= beta) {
					return alpha; // beta cut
				}
			}
			// 探索深さが-3以下ならこれ以上延長しない。
			if (depth < MAX_DEPTH * Types.ONE_PLY) {
				return alpha;
			}
		}
		// 取り合いの指し手だけ生成する
		var mp:MovePicker = new MovePicker();
		mp.InitB(pos);
		var move:Move;
		var si:StateInfo = new StateInfo();
		while ((move = mp.next_move()) != Types.MOVE_NONE) {
			if (!pos.legal(move)) {
				pos.countNode();
				continue;
			}
			#if debug
			DebugInfo.qmoves[depth] = move;
			DebugInfo.qnodes[depth] = pos.Nodes();
			DebugInfo.qcolors[depth] = pos.side_to_move();
			DebugInfo.lastQMove = move;
			DebugInfo.inQChecks[depth] = pos.in_check();
			DebugInfo.qdepth = depth;
			#end
			pos.do_move(move, si); // , pos.gives_check(move)
			value = -Qsearch(pos, -beta, -alpha, depth - Types.ONE_PLY);
			pos.undo_move(move);
			if (Signals.stop) {
				trace('qsearch Signals.stop !');
				return Types.VALUE_ZERO;
			}
			if (value > alpha) { // update alpha?
				alpha = value;
				if (alpha >= beta) {
					return alpha; // beta cut
				}
			}
		}
		// 王手がかかっている状況ですべての指し手を調べたということだから、これは詰みである
		if (InCheck && alpha == -Types.VALUE_INFINITE) {
			return Types.mated_in(ply_from_root);
		}
		return alpha;
	}

	private static function Search(pos:Position, alpha:Int, beta:Int, depth:Int, nodeType:Int):Int {
		var pvMove:Bool = true;
		var mp:MovePicker = new MovePicker();
		var move:Move = new Move(0);
		var rootNode:Bool = nodeType == NodeRoot; // Thinkから呼ばれたらRootNodeになる
		// PV nodeであるか(root nodeはPV nodeに含まれる)
		var PvNode:Bool = nodeType == NodePV || nodeType == NodeRoot;
		var value = 0;
		var st = new StateInfo();
		// 現在のnodeのrootからの手数。これカウンターが必要。
		// nanoだとこのカウンター持ってないので適当にごまかす。
		var ply_from_root:Int = (rootDepth - depth) + 1;
		// -----------------------
		//   置換表のprobe
		// -----------------------
		var posKey:Bitboard64 = pos.GetKey();
		var o:Dynamic = TT.Probe(posKey);
		var tte:TTEntry = o.tte;
		var ttHit:Bool = o.found;
		var ttMove:Move = (rootNode) ? rootMoves[0].pv[0]
			: (ttHit) ? tte.GetMove() : Types.MOVE_NONE;
		var ttValue = Types.VALUE_NONE;
		// 置換表上のスコア
		// 置換表にhitしなければVALUE_NONE
		var ttBound:Bool = false;
		if (tte != null) {
			ttValue = tte.GetValue();
			ttBound = ttValue >= beta ? (tte.GetBound() & Types.Bound.BOUND_LOWER) != 0 : (tte.GetBound() & Types.Bound.BOUND_UPPER) != 0;
		}
		if (!PvNode && ttHit && tte.GetDepth() >= depth && ttValue != Types.VALUE_NONE && ttBound) {
			return ttValue;
		}
		mp.InitA(pos);
		var bestMove:Move = Types.MOVE_NONE; // 置換表へ保存用
		while ((move = mp.next_move()) != Types.MOVE_NONE) { // この局面の全指し手を探索
			if (!pos.legal(move)) {
				pos.countNode();
				continue;
			}
			#if debug
			DebugInfo.moves[depth] = move;
			DebugInfo.nodes[depth] = pos.Nodes();
			DebugInfo.colors[depth] = pos.side_to_move();
			DebugInfo.lastMove = move;
			DebugInfo.inChecks[depth] = pos.in_check();
			DebugInfo.depth = depth;
			if(rootNode && move == -1 ) {
				DebugInfo.traceNode = true;
			}
			if(DebugInfo.traceNode) {
				trace('depth:${depth} c:${pos.side_to_move()} ${Types.Move_To_StringLong(move)} nodeType:${nodeType} rootNode:${rootNode}');
			}
			#end
			pos.do_move(move, st);
			value = depth - Types.ONE_PLY < Types.ONE_PLY ? -Qsearch(pos, -beta, -alpha, depth) // depthが0になったら静止探索をする。
				: -Search(pos, -beta, -alpha, depth - Types.ONE_PLY, NodeNonPV); // depth0になるまで再帰
			pos.undo_move(move);
			if (Signals.stop) {
				trace('search Signals.stop !');
				return Types.VALUE_ZERO;
			}
			var sa = Timer.stamp() - Signals.startTime;
			if (sa > Types.TIME_LIMIT) {
				trace('Time Over ...');
				Signals.stop = true;
				return Types.VALUE_ZERO;
			}
			if (rootNode) {
				#if debug
				DebugInfo.traceNode = false;
				#end
				var rm:SearchRootMove; // root move
				for (k in 0...numRootMoves) {
					if (rootMoves[k].Equals(move)) { // rootMoveにScoreを保存する
						rm = rootMoves[k];
						// if (pvMove || value > alpha) {
						if (value > alpha) {
							rm.score = value;
						} else {
							rm.score = -Types.VALUE_INFINITE;
						}
						break;
					}
				}
			}
			if (value > alpha) { // 下限値を更新
				alpha = value;
				// bestMove = move;
				if (alpha >= beta) {
					break;
				}
			}
		}
		// -----------------------
		//  置換表に保存する
		// -----------------------
		var key32:Int = posKey.upper;
		tte.Save(key32, value_to_tt(alpha, ply_from_root),
			alpha >= beta ? Types.Bound.BOUND_LOWER : PvNode
			&& (bestMove != Types.MOVE_NONE) ? Types.Bound.BOUND_EXACT : Types.Bound.BOUND_UPPER,
			// betaを超えているということはbeta cutされるわけで残りの指し手を調べていないから真の値はまだ大きいと考えられる。
			// すなわち、このとき値は下界と考えられるから、BOUND_LOWER。
			// さもなくば、(PvNodeなら)枝刈りはしていないので、これが正確な値であるはずだから、BOUND_EXACTを返す。
			// また、PvNodeでないなら、枝刈りをしているので、これは正確な値ではないから、BOUND_UPPERという扱いにする。
			// ただし、指し手がない場合は、詰まされているスコアなので、これより短い/長い手順の詰みがあるかも知れないから、
			// すなわち、スコアは変動するかも知れないので、BOUND_UPPERという扱いをする。
			depth, bestMove, Types.VALUE_NONE, TT.GetGeneration());
		return alpha;
	}

	// 詰みのスコアは置換表上は、このnodeからあと何手で詰むかというスコアを格納する。
	// しかし、search()の返し値は、rootからあと何手で詰むかというスコアを使っている。
	// (こうしておかないと、do_move(),undo_move()するごとに詰みのスコアをインクリメントしたりデクリメントしたり
	// しないといけなくなってとても面倒くさいからである。)
	// なので置換表に格納する前に、この変換をしなければならない。
	// 詰みにまつわるスコアでないなら関係がないので何の変換も行わない。
	// ply : root node からの手数。(ply_from_root)
	private static function value_to_tt(v:Int, ply:Int):Int {
		// Assert.ASSERT_LV3(-Types.VALUE_INFINITE < v && v < Types.VALUE_INFINITE);
		return v >= Types.VALUE_MATE_IN_MAX_PLY ? v + ply : v <= Types.VALUE_MATED_IN_MAX_PLY ? v - ply : v;
	}
}
