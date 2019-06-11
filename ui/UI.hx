package ui;

import js.Browser;

class UI {
	private var game:Game;
	private var operationMode:Int = Mode.OPERATION_SELECT;
	private var selectedSq:Int = 0;

	public function new() {
		Browser.window.onload = onLoad;
		game = new Game(this);
	}

	function onLoad():Void {
		game.start();
	}

	public function onClickCell(sq:Int) {
		trace('on clickCell:', sq);
		if (this.operationMode == Mode.OPERATION_SELECT) {
			this.selectedSq = sq;
			this.updateUi(Mode.OPERATION_PUT);
		} else if (this.operationMode == Mode.OPERATION_PUT) {
			game.doPlayerMove(this.selectedSq, sq);
			this.updateUi(Mode.OPERATION_WAITING);
		}
	}

    public function onClickHand(pr:Int) {
		trace('on clickHand:', pr);
        
    }

	public function onEnemyMoved() {
		trace('UI::onEnemyMoved');
		this.updateUi(Mode.OPERATION_SELECT);
	}

	private function isPlayerPiece(sq:Int, pt:Int):Bool {
		var c = Types.getPieceColor(pt);
		return (game.sideToMove == c && pt > 0);
	}

	public function updateUi(mode:Int) {
		var linkable:Bool = false;
		var pt:Int = 0;
		operationMode = mode;
		if (this.operationMode == Mode.OPERATION_SELECT) {
			for (sq in 0...81) {
				pt = game.board[sq];
				linkable = isPlayerPiece(sq, pt);
				this.setCell(sq, game.board[sq], linkable);
			}
			for (i in 1...8) {
				setHand(Types.BLACK, i, game.hand[Types.BLACK][i], (game.hand[Types.BLACK][i] > 0) );
				setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false );
			}
		} else if (this.operationMode == Mode.OPERATION_PUT) {
			pt = game.board[this.selectedSq];
			var arr:Array<Int> = game.getMovableSq(selectedSq, pt);
			for (sq in 0...81) {
				linkable = (arr.indexOf(sq) > -1);
				this.setCell(sq, game.board[sq], linkable);
			}
			for (i in 1...8) {
				setHand(Types.BLACK, i, game.hand[Types.BLACK][i], false);
				setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
			}
		} else {
			for (sq in 0...81) {
				this.setCell(sq, game.board[sq], false);
			}
			for (i in 1...8) {
				setHand(Types.BLACK, i, game.hand[Types.BLACK][i], false);
				setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
			}
		}
	}

	private function setCell(sq:Int, pt:Int, linkable:Bool) {
		var c = Types.getPieceColor(pt);
		var s = '' + Types.getPieceLabel(pt);
		if (linkable) {
			s = '<a href="javascript:Main.onClickCell(' + sq + ')">' + s + '</a>';
		}
		var cell = Browser.document.getElementById('cell_' + sq);
		if (game.playerColor == c) {
			cell.style.transform = '';
		} else {
			cell.style.transform = 'rotate(180deg)';
		}
		cell.innerHTML = s;
	}

	private function setHand(c:Int, i:Int, n:Int, linkable:Bool) {
		trace('setHand c:$c i:$i n:$n');
		var cell = Browser.document.getElementById('hand_${c}_${i}');
		var s = '　';
		if (n > 0) {
			s = '${Types.getPieceLabel(i)}$n';
		}
		if (linkable) {
			s = '<a href="javascript:Main.onClickHand($i)">$s</a>';
		}
		if (game.playerColor == c) {
			cell.style.transform = '';
		} else {
			cell.style.transform = 'rotate(180deg)';
		}
		cell.innerHTML = s;
	}
}
