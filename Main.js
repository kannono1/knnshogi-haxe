// Generated by Haxe 4.0.0-rc.2+77068e1
(function ($hx_exports) { "use strict";
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var BB = function() { };
BB.__name__ = true;
BB.SquareDistance = function(s1,s2) {
	return BB.squareDistance[s1][s2];
};
BB.FileDistance = function(s1,s2) {
	return util_MathUtil.abs(Types.File_Of(s1) - Types.File_Of(s2));
};
BB.RankDistance = function(s1,s2) {
	return util_MathUtil.abs(Types.Rank_Of(s1) - Types.Rank_Of(s2));
};
BB.Init = function() {
	var _g = 0;
	while(_g < 81) {
		var sq = _g++;
		BB.squareBB[sq] = new Bitboard();
		BB.squareBB[sq].SetBit(sq);
	}
	var _g1 = 0;
	while(_g1 < 81) {
		var s1 = _g1++;
		BB.squareDistance[s1] = [];
		var _g11 = 0;
		while(_g11 < 81) {
			var s2 = _g11++;
			BB.squareDistance[s1][s2] = util_MathUtil.max(BB.FileDistance(s1,s2),BB.RankDistance(s1,s2));
		}
	}
	var _g2 = 0;
	while(_g2 < 31) {
		var pt = _g2++;
		BB.stepAttacksBB[pt] = [];
		var _g21 = 0;
		while(_g21 < 81) {
			var s11 = _g21++;
			BB.stepAttacksBB[pt][s11] = new Bitboard();
		}
	}
	var _g3 = 0;
	while(_g3 < 1) {
		var c = _g3++;
		var _g31 = 1;
		while(_g31 < 14) {
			var pt1 = _g31++;
			var _g32 = 0;
			while(_g32 < 81) {
				var s = _g32++;
				var _g33 = 0;
				while(_g33 < 9) {
					var k = _g33++;
					if(BB.steps[pt1][k] == 0) {
						continue;
					}
					var to = s;
					if(c == 0) {
						to += BB.steps[pt1][k];
					} else {
						to -= BB.steps[pt1][k];
					}
					if(Types.Is_SqOK(to) == false) {
						continue;
					}
					if(BB.SquareDistance(s,to) >= 3 && Types.RawTypeOf(pt1) != 2) {
						continue;
					}
					BB.stepAttacksBB[Types.Make_Piece(c,pt1)][s].OR(BB.squareBB[to]);
				}
			}
		}
	}
};
var Bitboard = function(l,m,u) {
	if(u == null) {
		u = 0;
	}
	if(m == null) {
		m = 0;
	}
	if(l == null) {
		l = 0;
	}
	this.needCount = false;
	this.upper = 0;
	this.middle = 0;
	this.lower = 0;
	this.lower = l;
	this.middle = m;
	this.upper = u;
};
Bitboard.__name__ = true;
Bitboard.prototype = {
	isSet: function(sq) {
		if(sq < 27) {
			return (this.lower & 1 << sq) != 0;
		} else if(sq < 54) {
			return (this.middle & 1 << sq - 27) != 0;
		} else {
			return (this.upper & 1 << sq - 54) != 0;
		}
	}
	,OR: function(other) {
		this.lower |= other.lower;
		this.middle |= other.middle;
		this.upper |= other.upper;
		this.needCount = true;
	}
	,SetBit: function(theIndex) {
		if(theIndex < 27) {
			this.lower |= 1 << theIndex;
		} else if(theIndex < 54) {
			this.middle |= 1 << theIndex - 27;
		} else {
			this.upper |= 1 << theIndex - 54;
		}
		this.needCount = true;
	}
	,toStringBB: function() {
		var s = "";
		var _g = 0;
		while(_g < 81) {
			var i = _g++;
			var f = 8 - i % 9;
			var r = i / 9 | 0;
			var sq = f * 9 + r;
			if(i % 9 == 0) {
				s += "\n";
			}
			if(this.isSet(sq)) {
				s += "1";
			} else {
				s += "0";
			}
		}
		return s;
	}
};
var EReg = function(r,opt) {
	this.r = new RegExp(r,opt.split("u").join(""));
};
EReg.__name__ = true;
EReg.prototype = {
	match: function(s) {
		if(this.r.global) {
			this.r.lastIndex = 0;
		}
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
};
var Main = $hx_exports["Main"] = function() { };
Main.__name__ = true;
Main.main = function() {
	haxe_Log.trace("Hello haxe",{ fileName : "Main.hx", lineNumber : 10, className : "Main", methodName : "main"});
	var ui1 = new ui_UI();
	Main.gui = ui1;
};
Main.onClickCell = function(sq) {
	Main.gui.onClickCell(sq);
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x, x && x[0]=="0" && (x[1]=="x" || x[1]=="X") ? 16 : 10);
	if(isNaN(v)) {
		return null;
	}
	return v;
};
var Types = function() { };
Types.__name__ = true;
Types.Is_SqOK = function(s) {
	if(s >= 0) {
		return s <= 80;
	} else {
		return false;
	}
};
Types.File_Of = function(s) {
	return s % 9;
};
Types.Rank_Of = function(s) {
	return s / 9 | 0;
};
Types.RawTypeOf = function(p) {
	return p % 8;
};
Types.Make_Piece = function(c,pt) {
	return c << 4 | pt;
};
Types.getPieceColor = function(pt) {
	if(pt == 0) {
		return -1;
	}
	if(pt < 16) {
		return 0;
	} else {
		return 1;
	}
};
Types.getPieceType = function(token) {
	switch(token) {
	case "B":
		return 5;
	case "G":
		return 7;
	case "K":
		return 8;
	case "L":
		return 2;
	case "N":
		return 3;
	case "P":
		return 1;
	case "R":
		return 6;
	case "S":
		return 4;
	case "b":
		return 21;
	case "g":
		return 23;
	case "k":
		return 24;
	case "l":
		return 18;
	case "n":
		return 19;
	case "p":
		return 17;
	case "r":
		return 22;
	case "s":
		return 20;
	default:
		return 0;
	}
};
Types.getPieceLabel = function(pt) {
	switch(pt % 16) {
	case 0:
		return "　";
	case 1:
		return "歩";
	case 2:
		return "香";
	case 3:
		return "桂";
	case 4:
		return "銀";
	case 5:
		return "角";
	case 6:
		return "飛";
	case 7:
		return "金";
	case 8:
		return "玉";
	case 9:
		return "と";
	case 10:
		return "と";
	case 11:
		return "杏";
	case 12:
		return "圭";
	case 13:
		return "全";
	case 14:
		return "馬";
	case 15:
		return "龍";
	default:
		return "　";
	}
};
var data_Move = function() {
	this.to = 0;
	this.from = 0;
};
data_Move.__name__ = true;
data_Move.generateMove = function(from,to) {
	var m = new data_Move();
	m.from = from;
	m.to = to;
	return m;
};
data_Move.prototype = {
	toString: function() {
		return "from: " + this.from + " to: " + this.to;
	}
};
var haxe_Log = function() { };
haxe_Log.__name__ = true;
haxe_Log.formatOutput = function(v,infos) {
	var str = Std.string(v);
	if(infos == null) {
		return str;
	}
	var pstr = infos.fileName + ":" + infos.lineNumber;
	if(infos != null && infos.customParams != null) {
		var _g = 0;
		var _g1 = infos.customParams;
		while(_g < _g1.length) {
			var v1 = _g1[_g];
			++_g;
			str += ", " + Std.string(v1);
		}
	}
	return pstr + ": " + str;
};
haxe_Log.trace = function(v,infos) {
	var str = haxe_Log.formatOutput(v,infos);
	if(typeof(console) != "undefined" && console.log != null) {
		console.log(str);
	}
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o.__enum__) {
			var e = $hxEnums[o.__enum__];
			var n = e.__constructs__[o._hx_index];
			var con = e[n];
			if(con.__params__) {
				s += "\t";
				var tmp = n + "(";
				var _g = [];
				var _g1 = 0;
				var _g2 = con.__params__;
				while(_g1 < _g2.length) {
					var p = _g2[_g1];
					++_g1;
					_g.push(js_Boot.__string_rec(o[p],s));
				}
				return tmp + _g.join(",") + ")";
			} else {
				return n;
			}
		}
		if(((o) instanceof Array)) {
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g3 = 0;
			var _g11 = l;
			while(_g3 < _g11) {
				var i1 = _g3++;
				str += (i1 > 0 ? "," : "") + js_Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e1 ) {
			var e2 = ((e1) instanceof js__$Boot_HaxeError) ? e1.val : e1;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var k = null;
		var str1 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str1.length != 2) {
			str1 += ", \n";
		}
		str1 += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str1 += "\n" + s + "}";
		return str1;
	case "string":
		return o;
	default:
		return String(o);
	}
};
var ui_Game = function(ui_) {
	this.playerColor = 0;
	this.sideToMove = 0;
	this.board = [];
	this.sfen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1 moves";
	haxe_Log.trace("Game::new",{ fileName : "ui/Game.hx", lineNumber : 18, className : "ui.Game", methodName : "new"});
	this.ui = ui_;
	this.createWorker();
	BB.Init();
};
ui_Game.__name__ = true;
ui_Game.prototype = {
	createWorker: function() {
		haxe_Log.trace("Game::createWorker",{ fileName : "ui/Game.hx", lineNumber : 25, className : "ui.Game", methodName : "createWorker"});
		this.worker = new Worker("Engine.js");
		this.worker.onmessage = $bind(this,this.onMessage);
	}
	,isMovableSq: function(from,to) {
		var pt = this.board[from];
		if(from - to == 1) {
			return true;
		} else if(from - to == 2) {
			return true;
		} else {
			return false;
		}
	}
	,doPlayerMove: function(from,to) {
		haxe_Log.trace("Game::doPlayerMove from: " + from + " to: " + to,{ fileName : "ui/Game.hx", lineNumber : 41, className : "ui.Game", methodName : "doPlayerMove"});
		var move = data_Move.generateMove(from,to);
		this.doMove(move);
	}
	,doMove: function(move) {
		haxe_Log.trace("Game::doMove " + move.toString(),{ fileName : "ui/Game.hx", lineNumber : 46, className : "ui.Game", methodName : "doMove"});
		this.board[move.to] = this.board[move.from];
		this.board[move.from] = 0;
		this.changeSideToMove();
		if(this.isEnemyTurn()) {
			this.worker.postMessage("Hello worker ---");
		}
	}
	,isEnemyTurn: function() {
		return this.sideToMove == 1;
	}
	,changeSideToMove: function() {
		this.sideToMove = (this.sideToMove + 1) % 2;
		haxe_Log.trace("changeSideToMove: " + this.sideToMove,{ fileName : "ui/Game.hx", lineNumber : 61, className : "ui.Game", methodName : "changeSideToMove"});
	}
	,onMessage: function(s) {
		haxe_Log.trace("Game::onThink " + Std.string(s.data),{ fileName : "ui/Game.hx", lineNumber : 65, className : "ui.Game", methodName : "onMessage"});
		var move = data_Move.generateMove(20,21);
		this.doMove(move);
		this.ui.onEnemyMoved();
	}
	,start: function() {
		haxe_Log.trace("Game::start",{ fileName : "ui/Game.hx", lineNumber : 72, className : "ui.Game", methodName : "start"});
		this.setPosition(this.sfen);
	}
	,setPosition: function(sfen) {
		haxe_Log.trace("Game::setPosition",{ fileName : "ui/Game.hx", lineNumber : 77, className : "ui.Game", methodName : "setPosition", customParams : [sfen]});
		var tokens = sfen.split(" ");
		var f = 8;
		var r = 0;
		var promote = false;
		var i = 0;
		var token = "";
		var sq = 0;
		this.board = [];
		haxe_Log.trace(tokens,{ fileName : "ui/Game.hx", lineNumber : 86, className : "ui.Game", methodName : "setPosition"});
		var _g = 0;
		var _g1 = tokens[0].length;
		while(_g < _g1) {
			var i1 = _g++;
			var token1 = tokens[0].charAt(i1);
			if(util_StringUtil.isNumberString(token1)) {
				var _g2 = 0;
				var _g11 = Std.parseInt(token1);
				while(_g2 < _g11) {
					var n = _g2++;
					sq = f * 9 + r;
					this.board[sq] = 0;
					--f;
				}
			} else if(token1 == "+") {
				promote = true;
			} else if(token1 == "/") {
				f = 8;
				++r;
			} else {
				sq = f * 9 + r;
				var pt = Types.getPieceType(token1);
				if(promote) {
					pt += 8;
				}
				this.board[sq] = pt;
				--f;
				promote = false;
			}
		}
		this.updateUi();
	}
	,updateUi: function() {
		this.ui.updateUi();
	}
};
var ui_Mode = function() { };
ui_Mode.__name__ = true;
var ui_UI = function() {
	this.selectedSq = 0;
	this.operationMode = 0;
	window.onload = $bind(this,this.onLoad);
	this.game = new ui_Game(this);
};
ui_UI.__name__ = true;
ui_UI.prototype = {
	onLoad: function() {
		this.game.start();
	}
	,onClickCell: function(sq) {
		haxe_Log.trace("on click:",{ fileName : "ui/UI.hx", lineNumber : 18, className : "ui.UI", methodName : "onClickCell", customParams : [sq]});
		if(this.operationMode == 0) {
			this.selectedSq = sq;
		} else if(this.operationMode == 1) {
			this.game.doPlayerMove(this.selectedSq,sq);
		}
		this.operationMode++;
		this.updateUi();
	}
	,onEnemyMoved: function() {
		haxe_Log.trace("UI::onEnemyMoved",{ fileName : "ui/UI.hx", lineNumber : 29, className : "ui.UI", methodName : "onEnemyMoved"});
		this.operationMode = 0;
		this.updateUi();
	}
	,isPlayerPiece: function(sq,pt) {
		var c = Types.getPieceColor(pt);
		if(this.game.sideToMove == c) {
			return pt > 0;
		} else {
			return false;
		}
	}
	,setCell: function(sq,pt) {
		var c = Types.getPieceColor(pt);
		var s = "" + Types.getPieceLabel(pt);
		if(this.operationMode == 0) {
			if(this.isPlayerPiece(sq,pt)) {
				s = "<a href=\"javascript:Main.onClickCell(" + sq + ")\">" + s + "</a>";
			}
		} else if(this.operationMode == 1) {
			if(this.game.isMovableSq(this.selectedSq,sq)) {
				s = "<a href=\"javascript:Main.onClickCell(" + sq + ")\">" + s + "</a>";
			}
		}
		var cell = window.document.getElementById("cell_" + sq);
		if(this.game.playerColor == c) {
			cell.style.transform = "";
		} else {
			cell.style.transform = "rotate(180deg)";
		}
		cell.innerHTML = s;
	}
	,updateUi: function() {
		var _g = 0;
		while(_g < 81) {
			var sq = _g++;
			this.setCell(sq,this.game.board[sq]);
		}
	}
};
var util_MathUtil = function() { };
util_MathUtil.__name__ = true;
util_MathUtil.abs = function(a) {
	if(a >= 0) {
		return a;
	} else {
		return -a;
	}
};
util_MathUtil.max = function(a,b) {
	if(a > b) {
		return a;
	} else {
		return b;
	}
};
var util_StringUtil = function() { };
util_StringUtil.__name__ = true;
util_StringUtil.isNumberString = function(s) {
	var r = new EReg("[0-9]+","");
	return r.match(s);
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = m.bind(o); o.hx__closures__[m.__id__] = f; } return f; }
String.__name__ = true;
Array.__name__ = true;
Object.defineProperty(js__$Boot_HaxeError.prototype,"message",{ get : function() {
	return String(this.val);
}});
js_Boot.__toStr = ({ }).toString;
BB.squareDistance = [];
BB.stepAttacksBB = [];
BB.squareBB = [];
BB.steps = [[0,0,0,0,0,0,0,0,0],[9,0,0,0,0,0,0,0,0],[9,18,27,36,45,54,63,72,0],[17,19,0,0,0,0,0,0,0],[9,8,10,-10,-8,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[9,8,10,-1,1,-9,0,0,0],[9,8,10,-1,1,-9,-10,-8,0],[9,8,10,-1,1,-9,0,0,0],[9,8,10,-1,1,-9,0,0,0],[9,8,10,-1,1,-9,0,0,0],[9,8,10,-1,1,-9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]];
Bitboard.NA = 27;
Bitboard.NB = 54;
Types.BLACK = 0;
Types.WHITE = 1;
Types.NO_PIECE_TYPE = 0;
Types.PAWN = 1;
Types.LANCE = 2;
Types.KNIGHT = 3;
Types.SILVER = 4;
Types.BISHOP = 5;
Types.ROOK = 6;
Types.GOLD = 7;
Types.KING = 8;
Types.PRO_PAWN = 9;
Types.PRO_LANCE = 10;
Types.PRO_KNIGHT = 11;
Types.PRO_SILVER = 12;
Types.HORSE = 13;
Types.DRAGON = 14;
Types.NO_PIECE = 0;
Types.W_PAWN = 1;
Types.W_LANCE = 2;
Types.W_KNIGHT = 3;
Types.W_SILVER = 4;
Types.W_BISHOP = 5;
Types.W_ROOK = 6;
Types.W_GOLD = 7;
Types.W_KING = 8;
Types.W_PRO_PAWN = 9;
Types.W_PRO_LANCE = 10;
Types.W_PRO_KNIGHT = 11;
Types.W_PRO_SILVER = 12;
Types.W_HORSE = 13;
Types.W_DRAGON = 14;
Types.PIECE_WHITE = 16;
Types.B_PAWN = 17;
Types.B_LANCE = 18;
Types.B_KNIGHT = 19;
Types.B_SILVER = 20;
Types.B_BISHOP = 21;
Types.B_ROOK = 22;
Types.B_GOLD = 23;
Types.B_KING = 24;
Types.B_PRO_PAWN = 25;
Types.B_PRO_LANCE = 26;
Types.B_PRO_KNIGHT = 27;
Types.B_PRO_SILVER = 28;
Types.B_HORSE = 29;
Types.B_DRAGON = 30;
Types.PIECE_NB = 31;
Types.SQ_A1 = 0;
Types.SQ_HB = 80;
Types.SQ_NB = 81;
Types.FILE_NB = 9;
Types.RANK_NB = 9;
ui_Mode.OPERATION_SELECT = 0;
ui_Mode.OPERATION_PUT = 1;
Main.main();
})(typeof exports != "undefined" ? exports : typeof window != "undefined" ? window : typeof self != "undefined" ? self : this);
