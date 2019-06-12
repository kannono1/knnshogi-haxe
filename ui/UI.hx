package ui;

import js.Browser;
import ui.Mode.OPERATION_MODE;

class UI {
	private var game:Game;
	private var operationMode = OPERATION_MODE.SELECT;
	private var selectedSq:Int = 0;
	private var selectedHand:Int = 0; // pr

	public function new() {
		Browser.window.onload = onLoad;
		game = new Game(this);
	}

	function onLoad():Void {
		game.start();
	}

	public function onClickCell(sq:Int) {
		trace('on clickCell:', sq);
		switch (this.operationMode) {
			case SELECT:
				this.selectedSq = sq;
				this.updateUi(OPERATION_MODE.MOVE);
			case MOVE:
				game.doPlayerMove(this.selectedSq, sq);
				this.updateUi(OPERATION_MODE.WAIT);
			case PUT:
				game.doPlayerPut(this.selectedHand, sq);
				this.updateUi(OPERATION_MODE.WAIT);
			default:
		}
	}

	public function onClickHand(pr:Int) {
		trace('on clickHand:', pr);
		switch (this.operationMode) {
			case SELECT:
				this.selectedHand = pr;
				this.updateUi(OPERATION_MODE.PUT);
			default:
		}
	}

	public function onEnemyMoved() {
		trace('UI::onEnemyMoved');
		this.updateUi(OPERATION_MODE.SELECT);
	}

	public function onEndGame(winner:Int) {
		Browser.alert('${winner}の勝ちです');
	}

	private function isPlayerPiece(sq:Int, pt:Int):Bool {
		var c = Types.getPieceColor(pt);
		return (game.sideToMove == c && pt > 0);
	}

	public function updateUi(mode:OPERATION_MODE) {
		var linkable:Bool = false;
		var pt:Int = 0;
		operationMode = mode;
		switch (this.operationMode) {
			case SELECT:
				for (sq in 0...81) {
					pt = game.board[sq];
					linkable = isPlayerPiece(sq, pt);
					this.setCell(sq, game.board[sq], linkable);
				}
				for (i in 1...8) {
					setHand(Types.BLACK, i, game.hand[Types.BLACK][i], (game.hand[Types.BLACK][i] > 0));
					setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
				}
			case MOVE:
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
			case PUT:
				var arr:Array<Int> = game.getEmptySq(selectedHand);
				for (sq in 0...81) {
					linkable = (arr.indexOf(sq) > -1);
					this.setCell(sq, game.board[sq], linkable);
				}
				for (i in 1...8) {
					setHand(Types.BLACK, i, game.hand[Types.BLACK][i], false);
					setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
				}
			default:
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
