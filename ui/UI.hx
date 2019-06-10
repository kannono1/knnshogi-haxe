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
	public function onClickCell(sq:Int){
        trace('on click:', sq );
        if(this.operationMode == Mode.OPERATION_SELECT){
            this.selectedSq = sq;
        }
        else if(this.operationMode == Mode.OPERATION_PUT){
            game.doPlayerMove(this.selectedSq, sq);
        }
        this.operationMode++;
        this.updateUi();
    }
    public function onEnemyMoved(){
        trace('UI::onEnemyMoved');
        this.operationMode = Mode.OPERATION_SELECT;
        this.updateUi();
    }
    private function isPlayerPiece(sq:Int, pt:Int):Bool{
        var c = Types.getPieceColor(pt);
        return (game.sideToMove == c && pt > 0);
    }
	private function setCell(sq:Int, pt:Int) {
        var c = Types.getPieceColor(pt);
        var s = '' + Types.getPieceLabel(pt);
        if(this.operationMode == Mode.OPERATION_SELECT){
            if(isPlayerPiece(sq, pt) ){
                s = '<a href="javascript:Main.onClickCell('+sq+')">'+s+'</a>';
            }
        }
        else if(this.operationMode == Mode.OPERATION_PUT){
            if(game.isMovableSq(this.selectedSq, sq)){
                s = '<a href="javascript:Main.onClickCell('+sq+')">'+s+'</a>';
            }
        }
        var cell = Browser.document.getElementById('cell_' + sq);
        if(game.playerColor == c){
            cell.style.transform = '';
        }
        else{
            cell.style.transform = 'rotate(180deg)';
        }
        cell.innerHTML = s;
    }
    public function updateUi(){
        for(sq in 0...81){
            this.setCell(sq, game.board[sq]);
        }
    }
}
