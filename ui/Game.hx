package ui;

import js.html.MessageEvent;
import js.html.Worker;
import util.StringUtil;
import ui.Mode.OPERATION_MODE;
import Types.Move;
import Types.PR;
import Types.PC;

class Game extends Position {
	public var playerColor:Int = Types.BLACK;

	// private var _sfen = 'startpos';
	private var _sfen = 'sfen lnsg1gsnl/1r311b1/ppppppp1k/9/9/9/PPPPPPP1P/1B5R1/LNSGKGSN1 w plL 1';
	// private var _sfen = 'sfen lnsgkgsnl/1r5b1/pppppp1pp/8P/9/9/PPPPPPP1P/1B5R1/LNSGKGSNL b - 1';
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

	private function createWorker() {
		trace('Game::createWorker');
		worker = new Worker('Engine.js');
		worker.onmessage = onMessage;
	}

	public function doPlayerMove(from:Int, to:Int, promote:Bool) {
		if (promote) {
			doMove(Types.Make_Move_Promote(from, to));
		} else {
			doMove(Types.Make_Move(from, to));
		}
	}

	public function doPlayerPut(pr:PR, to:Int) {
		trace('Game::doPlayerPut pr: $pr to: $to');
		var move:Move = Types.Make_Move_Drop(pr, to);
		doMove(move);
	}

	override public function doMove(move:Move) {
		trace('Game::doMove ${Types.Move_To_String(move)}');
		moves.push(move);
		super.doMove(move);
		printBoard();
		trace('hand $hand');
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
		var attack:Bitboard = AttacksFromPTypeSQ(sq, pc); // (Types.hasLongEffect(pt)) ? BB.AttacksBB(sq, occ, pt) : BB.stepAttacksBB[pt][sq];
		var target:Bitboard = byColorBB[us].newNOT();
		var b = attack.newAND(target);
		while (b.IsNonZero()) {
			arr.push(b.PopLSB());
		}
		return arr;
	}

	public function getEmptySq():Array<Int> {
		var b:Bitboard = PiecesAll().newNOT().NORM27();
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
			doMove(move);
			ui.onEnemyMoved();
		}
	}

	public function start() {
		trace('Game::start');
		setPosition(_sfen);
	}

	public function endGame() {
		trace('Game::End');
		ui.onEndGame(sideToMove);
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
