package;

import util.StringUtil;

class SFEN {
	private var startpos = 'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1 moves';
	private var board:Array<Int> = [];

	public function new(sfen:String) {
		if (sfen == 'startpos') {
			setPosition(startpos);
		} else {
			setPosition(sfen);
		}
	}

	public function getBoard():Array<Int> {
		var arr:Array<Int> = [];
		for (i in 0...81) {
			arr.push(board[i]);
		}
		return arr;
	}

	public function setPosition(sfen:String):Void {
		trace('SFEN::setPosition', sfen);
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
				var pt = Types.getPieceType(token);
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
	}
}
