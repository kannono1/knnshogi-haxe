package ui;

import js.html.MessageEvent;
import js.html.Worker;
import util.StringUtil;
import ui.Mode.OPERATION_MODE;
import Types.Move;
import Types.PC;
import Types.PR;
import Types.PT;

class Game extends Position {
	public var playerColor:Int = Types.BLACK;

	private var _sfen = 'startpos';
	// private var _sfen = 'lnsgkgsnl/1R5b1/ppppppppp/9/4N4/9/PPPPPPPPP/1B5R1/LNSGKGS1L b - 1';
	// private var _sfen = 'sfen lnsgkg1n1/1r4sb1/pppppppp1/9/8p/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1';
	private var ui:UI;
	private var worker:Worker;
	private var moves:Array<Move> = [];

	public function new(ui_:UI) {
		trace('Game::new');
		super();
		ui = ui_;
		createWorker();
		BB.Init();
	}

	public function getLastMove():Move {
		if(moves.length == 0)
			return null;
		else
			return moves[moves.length-1];
	}

	private function createWorker() {
		trace('Game::createWorker');
		worker = new Worker('Engine.js');
		worker.onmessage = onMessage;
	}

	public function doPlayerMove(from:Int, to:Int, promote:Bool) {
		if (promote) {
			do_move(Types.Make_Move_Promote(from, to), new StateInfo());
		} else {
			do_move(Types.Make_Move(from, to), new StateInfo());
		}
	}

	public function doPlayerPut(pr:PR, to:Int) {
		trace('Game::doPlayerPut pr: $pr to: $to');
		var move:Move = Types.Make_Move_Drop(pr, to);
		do_move(move, new StateInfo());
	}

	override public function do_move(move:Move, newSt:StateInfo) {
		trace('Game::do_move ${Types.Move_To_String(move)}');
		moves.push(move);
		super.do_move(move, newSt);
		// printBoard();
		// printPieceNo();
		// trace('hand $hand');
		if (isEnemyTurn()) {
			startThink();
		}
	}

	private function startThink() {
		if (moves.length == 0) {
			worker.postMessage('position $_sfen');
		} else {
			worker.postMessage('position $_sfen moves ' + getMovesString());
		}
	}

	private function getMovesString():String {
		var s = Types.Move_To_String(moves[0]);
		for (i in 1...moves.length) {
			s += ' ' + Types.Move_To_String(moves[i]);
		}
		return s;
	}

	public function getMovableSq(sq:Int, pc:PC):Array<Int> {
		var arr:Array<Int> = [];
		var us = sideToMove;
		var attack:Bitboard = AttacksFromPTypeSQ(sq, pc); // (Types.has_long_effect(pt)) ? BB.AttacksBB(sq, occ, pt) : BB.stepAttacksBB[pt][sq];
		var target:Bitboard = byColorBB[us].newNOT();
		var b = attack.newAND(target);
		while (b.IsNonZero()) {
			arr.push(b.PopLSB());
		}
		return arr;
	}

	public function getEmptySq(pr:PR):Array<Int> {
		var us = sideToMove;
		var b:Bitboard = PiecesAll().newNOT().NORM27();
		if(new PT(pr) == Types.PAWN) {
			b.AND(BB.pawnLineBB[us].newNOT());
		}
		trace(b.toStringBB());
		var arr:Array<Int> = [];
		while (b.IsNonZero()) {
			arr.push(b.PopLSB());
		}
		return arr;
	}

	private function isEnemyTurn():Bool {
		return (sideToMove != playerColor);
	}

	private function onMessage(s:MessageEvent) {
		trace('Game::onThink ${s.data}');
		var tokens = s.data.split(' ');
		var move:Move = Types.generateMoveFromString(tokens[1]);
		if (move == 0) {
			endGame();
		} else {
			do_move(move, new StateInfo());
			ui.onEnemyMoved();
		}
	}

	public function start() {
		trace('Game::start');
		setPosition(_sfen);
	}

	public function endGame() {
		trace('Game::End');
		ui.onEndGame(Types.OppColour(sideToMove));
	}

	override public function setPosition(sfen:String):Void {
		super.setPosition(sfen);
		if (isEnemyTurn()) {
			ui.updateUi(OPERATION_MODE.WAIT);
			startThink();
		} else {
			ui.updateUi(OPERATION_MODE.SELECT);
		}
	}
}
