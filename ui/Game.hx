package ui;

import js.html.MessageEvent;
import js.html.Worker;
import data.Move;
import util.StringUtil;
// import engine.Engine;

class Game {
	private var ui:UI;
	private var sfen = 'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1 moves';
	public var board:Array<Int> = [];
    public var sideToMove:Int = 0;
    public var playerColor:Int = 0;
	private var worker:Worker;
	// private var engine:Engine;

	public function new(ui_:UI) {
		trace('Game::new');
		ui = ui_;
		// engine = new Engine();
		// engine.onThink = onThink;
		createWorker();
	}

	private function createWorker(){
		trace('Game::createWorker');
		worker = new Worker('Engine.js');
		worker.onmessage = onThink;
	}

	public function doMove(move:Move){
		trace('Game::doMove', move.toString() );
		board[move.to] = board[move.from];
		board[move.from] = 0;
		worker.postMessage('Hello worker ---');
		// var worker = js.html.Worker('');
		// var sfen = 's f e n';
		// engine.think(sfen);
	}

	private function onThink(s:MessageEvent){
		trace('Game::onThink ${s.data}');
	}

    public function start() {
        trace('Game::start');
		setPosition(sfen);
    }

	public function setPosition(sfen:String):Void {
		trace('Game::setPosition', sfen);
		var tokens:Array<String> = sfen.split(' ');
		var f = 8;
		var r = 0;
		var promote = false;
		var i = 0;
		var token = '';
		var sq = 0;
		board = [];
		trace(tokens);
		for (i in 0...tokens[0].length) {
			var token = tokens[0].charAt(i);
			if (StringUtil.isNumberString(token)) {
				for (n in 0...Std.parseInt(token)) {
					sq = f * 9 + r;
					this.board[sq] = 0;
					f--;
				}
			} else if (token == '+') {
				promote = true;
			} else if (token == '/') {
				f = 8;
				r++;
			} else {
				sq = f * 9 + r;
				var pt = this.getPieceType(token);
				if (promote)
					pt += 8;
				this.board[sq] = pt;
				f--;
				promote = false;
			}
		}
		// //
		// this.sideToMove = this.getColorType(tokens[1]);
		// //
		// var ct = 0;
		// for (i = 0; i < tokens[2].length; i++) {
		//     var token = tokens[2][i];
		//     if (token == '-') {
		//         break;
		//     }
		//     else if (isNaN(token) == false) {
		//         ct = parseInt(token) + ct * 10;
		//     }
		//     else {
		//         ct = Math.max(ct, 1);
		//         var pt = this.getPieceType(token);
		//         this.setHand(this.getPieceColor(pt), this.getPieceRaw(pt), ct);
		//         ct = 0;
		//     }
		// }
		this.updateUi();
	}

	public function updateUi() {
		for (sq in 0...81) {
			ui.setCell(sq, this.board[sq]);
		}
	}

	public function getPieceColor(pt:Int):Int {
		if (pt == 0)
			return -1;
		return (pt < 16) ? 0 : 1;
	}

	private function getPieceType(token:String):Int {
		switch (token) {
			case 'P':
				return 1;
			case 'L':
				return 2;
			case 'N':
				return 3;
			case 'S':
				return 4;
			case 'B':
				return 5;
			case 'R':
				return 6;
			case 'G':
				return 7;
			case 'K':
				return 8;
			case 'p':
				return 17;
			case 'l':
				return 18;
			case 'n':
				return 19;
			case 's':
				return 20;
			case 'b':
				return 21;
			case 'r':
				return 22;
			case 'g':
				return 23;
			case 'k':
				return 24;
			default:
				return 0;
		}
	}
}
