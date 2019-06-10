package ui;

import js.html.MessageEvent;
import js.html.Worker;
import data.Move;
import util.StringUtil;

class Game {
	public var board:Array<Int> = [];
	public var sideToMove:Int = 0;
	public var playerColor:Int = 0;

	private var ui:UI;
	private var worker:Worker;

	public function new(ui_:UI) {
		trace('Game::new');
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
		var move = Move.generateMove(from, to);
		doMove(move);
	}

	public function doMove(move:Move) {
		trace('Game::doMove ${move.toString()}');
		board[move.to] = board[move.from];
		board[move.from] = 0;
		changeSideToMove();
		if (isEnemyTurn()) {
			worker.postMessage('Hello worker ---');
		}
	}

	public function getMovableSq(sq:Int, pt:Int):Array<Int> {
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

	private function changeSideToMove() {
		sideToMove = (sideToMove + 1) % 2;
		trace('changeSideToMove: $sideToMove');
	}

	private function onMessage(s:MessageEvent) {
		trace('Game::onThink ${s.data}');
		var move = Move.generateMove(20, 21);
		doMove(move);
		ui.onEnemyMoved();
	}

	public function start() {
		trace('Game::start');
		setPosition('startpos');
	}

	public function setPosition(sfen:String):Void {
		trace('Game::setPosition', sfen);
        var sf:SFEN = new SFEN(sfen);
        board = sf.getBoard();
		ui.updateUi(Mode.OPERATION_SELECT);
	}
}
