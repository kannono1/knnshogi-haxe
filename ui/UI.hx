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
		trace('on click:', sq);
		if (this.operationMode == Mode.OPERATION_SELECT) {
			this.selectedSq = sq;
		    this.updateUi(Mode.OPERATION_PUT);
		} else if (this.operationMode == Mode.OPERATION_PUT) {
			game.doPlayerMove(this.selectedSq, sq);
		    this.updateUi(Mode.OPERATION_WAITING);
		}
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
        operationMode = mode;
        if (this.operationMode == Mode.OPERATION_PUT){
            var pt = game.board[this.selectedSq];
            trace('sq: ${selectedSq} pt: $pt');
            var b:Bitboard = BB.stepAttacksBB[pt][selectedSq];
            trace(b.toStringBB() );
        }
        trace('UI::updateUi mode:${operationMode}');
		for (sq in 0...81) {
			this.setCell(sq, game.board[sq]);
		}
		// this.operationMode++;
        // if(this.operationMode > Mode.OPERATION_WAITING){
    	// 	this.operationMode = Mode.OPERATION_SELECT;
        // }
	}

	private function setCell(sq:Int, pt:Int) {
		var c = Types.getPieceColor(pt);
		var s = '' + Types.getPieceLabel(pt);
		if (this.operationMode == Mode.OPERATION_SELECT) {
			if (isPlayerPiece(sq, pt)) {
				s = '<a href="javascript:Main.onClickCell(' + sq + ')">' + s + '</a>';
			}
		} else if (this.operationMode == Mode.OPERATION_PUT) {
			if (game.isMovableSq(this.selectedSq, sq)) {
				s = '<a href="javascript:Main.onClickCell(' + sq + ')">' + s + '</a>';
			}
		}
		var cell = Browser.document.getElementById('cell_' + sq);
		if (game.playerColor == c) {
			cell.style.transform = '';
		} else {
			cell.style.transform = 'rotate(180deg)';
		}
		cell.innerHTML = s;
	}
}
