package ui;

import js.Browser;
import ui.Mode.OPERATION_MODE;
import Types.PC;
import Types.PR;
import Types.PT;

class UI {
	private var game:Game;
	private var operationMode = OPERATION_MODE.SELECT;
	private var selectedSq:Int = 0;
	private var toSq:Int = 0;
	private var selectedHand:PR = new PR(0); // pr

	public function new() {
		Browser.window.onload = onLoad;
		game = new Game(this);
	}

	function onLoad():Void {
		Init();
		game.start();
	}

	private function Init() {
		initDialog();
	}

	private function initDialog() {
		var dialog:Dynamic = Browser.document.getElementById('dialog_promote');
		dialog.addEventListener('cancel', function(e:Dynamic) {
			e.preventDefault();
		});
		dialog.addEventListener('close', function(e:Dynamic) {
			var promote = (dialog.returnValue == 'yes');
			game.doPlayerMove(this.selectedSq, toSq, promote);
			this.updateUi(OPERATION_MODE.WAIT);
		});
	}

	private function isPromotable(sq:Int, pc:PC):Bool {
		trace('isPromotable sq:$sq pc:$pc');
		if (pc % 16 > Types.PIECE_PROMOTE) {
			return false; // 成駒だったらFalse
		} else if (Types.Rank_Of(sq) < 3) {
			return true;
		} else if (Types.Rank_Of(selectedSq) <= 3) {
			return true;
		} else {
			return false;
		}
	}

	public function onClickCell(sq:Int) {
		trace('on clickCell:', sq);
		switch (this.operationMode) {
			case SELECT:
				this.selectedSq = sq;
				this.updateUi(OPERATION_MODE.MOVE);
			case MOVE:
				this.toSq = sq;
				var from_pc:PC = game.PieceOn(selectedSq);
				if (isPromotable(toSq, from_pc)) {
					var dialog:Dynamic = Browser.document.getElementById('dialog_promote');
					dialog.showModal();
				} else {
					game.doPlayerMove(this.selectedSq, toSq, false);
					this.updateUi(OPERATION_MODE.WAIT);
				}
			case PUT:
				game.doPlayerPut(this.selectedHand, sq);
				this.updateUi(OPERATION_MODE.WAIT);
			default:
		}
	}

	public function onClickHand(pr:PR) {
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

	private function isPlayerPiece(sq:Int, pc:PC):Bool {
		var c = Types.getPieceColor(pc);
		return (game.sideToMove == c && Std.int(pc) > 0);
	}

	public function updateUi(mode:OPERATION_MODE) {
		var linkable:Bool = false;
		var pc:PC = new PC(0);
		operationMode = mode;
		switch (this.operationMode) {
			case SELECT:
				for (sq in 0...81) {
					pc = game.PieceOn(sq);
					if (isPlayerPiece(sq, pc)) {
						var arr:Array<Int> = game.getMovableSq(sq, pc);
						if (arr.length > 0) {
							linkable = true;
						} else {
							linkable = false;
						}
					} else {
						linkable = false;
					}
					this.setCell(sq, game.PieceOn(sq), linkable);
				}
				for (i in 1...8) {
					setHand(Types.BLACK, i, game.hand[Types.BLACK][i], (game.hand[Types.BLACK][i] > 0));
					setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
				}
			case MOVE:
				pc = game.PieceOn(this.selectedSq);
				var arr:Array<Int> = game.getMovableSq(selectedSq, pc);
				for (sq in 0...81) {
					linkable = (arr.indexOf(sq) > -1);
					this.setCell(sq, game.PieceOn(sq), linkable);
				}
				for (i in 1...8) {
					setHand(Types.BLACK, i, game.hand[Types.BLACK][i], false);
					setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
				}
			case PUT:
				var arr:Array<Int> = game.getEmptySq();
				for (sq in 0...81) {
					linkable = (arr.indexOf(sq) > -1);
					this.setCell(sq, game.PieceOn(sq), linkable);
				}
				for (i in 1...8) {
					setHand(Types.BLACK, i, game.hand[Types.BLACK][i], false);
					setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
				}
			default:
				for (sq in 0...81) {
					this.setCell(sq, game.PieceOn(sq), false);
				}
				for (i in 1...8) {
					setHand(Types.BLACK, i, game.hand[Types.BLACK][i], false);
					setHand(Types.WHITE, i, game.hand[Types.WHITE][i], false);
				}
		}
	}

	private function setCell(sq:Int, pc:PC, linkable:Bool) {
		var c = Types.getPieceColor(pc);
		var s = '' + Types.getPieceLabel(Types.TypeOf_Piece(pc));
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
			s = '${Types.getPieceLabel(new PT(i))}$n';
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
