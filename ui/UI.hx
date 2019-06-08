package ui;

import js.Browser;

// @:expose
class UI {
	private var game:Game;
	private var operationMode:Int = 0;
	private var selectedSq:Int = 0;
    private var OPE_MODE_SELECT_PIECE = 0;
    private var OPE_MODE_PUT_PIECE = 1;
    private var OPE_MODE_WAITING = 2;

	public function new() {
		trace('UI::New');
		Browser.window.onload = onLoad;
		game = new Game(this);
		// Browser.window['aaa'] = "NNN";
		// js.Lib.eval('window.ccc=999;');
		// js.Lib.eval('window.ccc=UI;');
	}

	function onLoad():Void {
		trace('haxe onload');
		game.start();
	}
	private function getPieceLabel(pt:Int): String {
        switch(pt%16){
            case  0: return '　';
            case  1: return '歩';
            case  2: return '香';
            case  3: return '桂';
            case  4: return '銀';
            case  5: return '角';
            case  6: return '飛';
            case  7: return '金';
            case  8: return '玉';
            case  9: return 'と';
            case 10: return 'と';
            case 11: return '杏';
            case 12: return '圭';
            case 13: return '全';
            case 14: return '馬';
            case 15: return '龍';
            default: return '　';
        }
    }
	public function onClickCell(sq:Int){
        trace('on click:', sq );
        if(this.operationMode==this.OPE_MODE_SELECT_PIECE){
            this.selectedSq = sq;
        }
        else if(this.operationMode==this.OPE_MODE_PUT_PIECE){
            game.doPlayerMove(this.selectedSq, sq);
        }
        this.operationMode++;
        this.updateUi();
    }
    public function onEnemyMoved(){
        trace('UI::onEnemyMoved');
        this.operationMode = 0;
        this.updateUi();
    }
	public function setCell(sq:Int, pt:Int) {
        var c = game.getPieceColor(pt);
        var s = '' + this.getPieceLabel(pt);
        if(this.operationMode == 0){
            if(game.sideToMove == c && pt > 0){
                s = '<a href="javascript:Main.onClickCell('+sq+')">'+s+'</a>';
            }
        }
        else if(this.operationMode == 1){
            if(sq == this.selectedSq -1){
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
    private function updateUi(){
        for(sq in 0...81){
            this.setCell(sq, game.board[sq]);
        }
    }
}
