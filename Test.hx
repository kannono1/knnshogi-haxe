package;

import Types.Move;
import Types.PR;

class Test {
	static private var pos:Position;

	public function new() {
		trace('Test:new');
	}

	static function main() {
		trace('Test main');
		pos = new Position();
		Init();
		TestAll();
	}

	static private function TestAll(){
		// pos.setPosition('startpos');
		// var m:Move = Types.Make_Move(60, 59);//先手の角道を開ける
		// trace('try1');
		// pos.do_move(m, new StateInfo());
		// Search.Reset(pos);
		// Search.Think();
		// pos.undo_move(m);
		// pos.do_move(m, new StateInfo());
		// trace('try2');
		// Search.Reset(pos);
		// Search.Think();
		// pos.printBoard();
		// return;
		AssertFn('Depth6 後手角頭を歩で守る', 'lnsgk1snl/1r4gb1/pppppp2p/6pR1/9/9/PPPPPPP1P/1B7/LNSGKGSNL w Pp 1'
			, (bm)-> bm == Types.Make_Move_Drop(new PR(Types.PAWN), 11));
		AssertFn('Depth6 後手の角頭を金で守る', 'lnsgkgsnl/1r5b1/pppppp1pp/6p2/7P1/9/PPPPPPP1P/1B5R1/LNSGKGSNL w - 1'
			, (bm)-> bm == Types.Make_Move(27, 19));
		pos.setPosition('startpos');
		var m:Move = Types.Make_Move(60, 59);//先手の角道を開ける
		pos.do_move(m, new StateInfo());
        LongEffect.printBoardEffect(pos.board_effect, Types.BLACK);
        LongEffect.printBoardEffect(pos.board_effect, Types.WHITE);
		LongEffect.printLongEffect(pos.long_effect);
		Assert('LongEffect::5eの地点の効きは1になる', pos.board_effect[Types.BLACK].e[40]==1);
		//
		AssertFn('Depth5 err 駒打ち後の先手玉の開き王手', 'lnsgk1snl/1r4g2/pppp1p1p1/9/4p3p/6Sb1/PPPPP3P/1B2GR3/LNSGK2NL w 3Pp 1'
			, (bm)-> bm != new Move(0));
		AssertFn('Depth5 err 先手玉の開き王手by飛車', 'lnsgk1snl/4r1gb1/pppp3p1/9/5pp1p/2PPP4/PP4S1P/1B2G2R1/LNSGK2NL w 3Pp 1'
			, (bm)-> bm != new Move(0));
		AssertFn('Depth4 err st.chekersが手番変更前として判定していた', 'ln1gk1snl/1sP4p1/pp1ppppg1/9/2L1s3p/2R6/PP1P1PP1+b/4G3b/L1SGK3+p w R2n3p 1'
			, (bm)-> bm != new Move(0));
		AssertFn('探索内での先手玉の王手回避(後手角成で王手がかかる)', 'lnsgkgsnl/1r5b1/pppppp1pp/6p2/7P1/9/PPPPPPP1P/1B5R1/LNSGKGSNL w - 1'
			, (bm)-> bm != new Move(0));
		AssertFn('王の近くに馬(王の自殺手チェック)', 'rnslkslnb/1g5g1/ppppB+Lppp/9/9/9/PPPPPPPPP/7R1/LNSGKGSN1 w - 1'
			, (bm)-> bm != new Move(0));
		AssertFn('王手回避', 'rnslklsnb/1g5g1/ppppLpppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSN1 w - 1'
			, (bm:Move)->[Types.Make_Move(36, 46), Types.Make_Move(36, 28)].indexOf(bm) != -1);
		AssertFn('平手開始局面','startpos', (bm)-> bm != new Move(0));
	}

	static private function Init() {
		BB.Init();
		Position.Init();
		Evaluate.Init();
		Search.Init();
	}

	static private function doThink(sfen:String):Move {
		trace('doThink start: :${sfen}');
		pos.setPosition(sfen);
		pos.printBoard();
		trace('doThink pos.c: ${pos.SideToMove()}');
		Search.Reset(pos);
		Search.Think();
		var moveResult:Move = Search.rootMoves[0].pv[0];
		trace('bestmove ${Types.Move_To_String(moveResult)}');
		return moveResult;
	}

	static private function Assert(msg:String, expected:Bool) {
		trace('Assert ${msg} start');
		if(!expected){
			throw('AssertionError');
		}
		trace('Assert ${msg} OK !!');
	}

	static private function AssertFn(msg:String, sfen:String, fn) {
		trace('AssertFn ${msg} start');
		var bm = doThink(sfen);
		var expected = fn(bm);
		if(!expected){
			throw('AssertionFnError ${msg} ${sfen} bm:${bm}');
		}
		trace('Assert ${msg} OK !!');
		trace('+++++++++++++++++++++++++++++++++++');
	}
}
