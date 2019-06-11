package ui;

import js.html.MessageEvent;
import js.html.Worker;
import data.Move;
import util.StringUtil;

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
		var move = Move.generateMove(from, to);
		doMove(move);
	}

	override private function doMove(move:Move) {
		trace('Game::doMove ${move.toString()}');
        var to:Int = move.to;
        var from:Int = move.from;
        var captured:Int = Types.TypeOf_Piece( PieceOn(to) );
		var capturedRaw:Int= Types.RawTypeOf(captured);
        trace('catured: $captured capturedRaw: $capturedRaw');
		if( captured != 0 ) {
			// AddHand(us, capturedRaw);
        }
        moves.push(move);
        super.doMove(move);
		if (isEnemyTurn()) {
			worker.postMessage('position $_sfen moves '+getMovesString() );
		}
	}

    private function getMovesString():String {
        var s = moves[0].toString();
        for(i in 1...moves.length){
            s += ' ' + moves[i].toString();
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

	// private function changeSideToMove() {
	// 	sideToMove = (sideToMove + 1) % 2;
	// 	trace('changeSideToMove: $sideToMove');
	// }

	private function onMessage(s:MessageEvent) {
		trace('Game::onThink ${s.data}');
        var tokens = s.data.split(' ');
		var move = Move.generateMoveFromString(tokens[1]);
		doMove(move);
		ui.onEnemyMoved();
	}

	public function start() {
		trace('Game::start');
		setPosition(_sfen);
	}

	override public function setPosition(sfen:String):Void {
        super.setPosition(sfen);
		ui.updateUi(Mode.OPERATION_SELECT);
	}
}
