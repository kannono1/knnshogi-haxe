package ui;

import js.html.MessageEvent;
import js.html.Worker;
import util.StringUtil;
import ui.Mode.OPERATION_MODE;

import Types.Move;

class Game extends Position {
	public var playerColor:Int = 0;

	// private var _sfen = 'startpos';
	private var _sfen = 'sfen lnsgkgsnl/9/pppppppp1/9/9/8p/PPPPPPPPP/9/LNS1KGSN1 b BRGLbr 1';
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

	public function doPlayerMove(from:Int, to:Int) {
		trace('Game::doPlayerMove from: $from to: $to');
		var move:Move = Types.Make_Move(from, to);
		doMove(move);
	}

	override private function doMove(move:Move) {
		trace('Game::doMove ${Types.Move_To_String(move)}');
		moves.push(move);
		super.doMove(move);
		trace('hand $hand');
		if (isEnemyTurn()) {
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

	public function getMovableSq(sq:Int, pt:Int):Array<Int> {
		trace('Game::getMovableSq sq: $sq pt: $pt');
		var attack:Bitboard = BB.stepAttacksBB[pt][sq];
		var b:Bitboard = new Bitboard();
		var arr:Array<Int> = [];
		b.Copy(attack);
		while (b.IsNonZero()) {
			arr.push(b.PopLSB());
		}
		return arr;
	}

	private function isEnemyTurn():Bool {
		return (sideToMove == 1);
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
		ui.updateUi(OPERATION_MODE.SELECT);
	}
}
