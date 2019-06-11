// Generated by Haxe 4.0.0-rc.2+77068e1
(function () { "use strict";
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
	haxe_Log.trace("Init::BB",{ fileName : "BB.hx", lineNumber : 74, className : "BB", methodName : "Init"});
	BB.filesBB = [];
	BB.ranksBB = [];
	var _g = 0;
	while(_g < 9) {
		var i = _g++;
		BB.filesBB.push(new Bitboard(511,0,0));
		BB.filesBB[i].ShiftL(9 * i);
		BB.ranksBB.push(new Bitboard(262657,262657,262657));
		BB.ranksBB[i].ShiftL(i);
	}
	BB.enemyField1[1] = BB.ranksBB[8].newCOPY();
	BB.enemyField1[0] = BB.ranksBB[0].newCOPY();
	BB.enemyField2[1] = BB.ranksBB[8].newOR(BB.ranksBB[7]);
	BB.enemyField2[0] = BB.ranksBB[0].newOR(BB.ranksBB[1]);
	BB.enemyField3[1] = BB.enemyField2[1].newOR(BB.ranksBB[6]);
	BB.enemyField3[0] = BB.enemyField2[0].newOR(BB.ranksBB[2]);
	var _g1 = 0;
	while(_g1 < 81) {
		var sq = _g1++;
		BB.squareBB[sq] = new Bitboard();
		BB.squareBB[sq].SetBit(sq);
	}
	var _g2 = 0;
	while(_g2 < 81) {
		var s1 = _g2++;
		BB.squareDistance[s1] = [];
		var _g21 = 0;
		while(_g21 < 81) {
			var s2 = _g21++;
			BB.squareDistance[s1][s2] = util_MathUtil.max(BB.FileDistance(s1,s2),BB.RankDistance(s1,s2));
		}
	}
	var _g3 = 0;
	while(_g3 < 31) {
		var pt = _g3++;
		BB.stepAttacksBB[pt] = [];
		var _g31 = 0;
		while(_g31 < 81) {
			var s11 = _g31++;
			BB.stepAttacksBB[pt][s11] = new Bitboard();
		}
	}
	var _g4 = 0;
	while(_g4 < 1) {
		var c = _g4++;
		var _g41 = 1;
		while(_g41 < 14) {
			var pt1 = _g41++;
			var _g42 = 0;
			while(_g42 < 81) {
				var s = _g42++;
				var _g43 = 0;
				while(_g43 < 9) {
					var k = _g43++;
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
BB.ShiftBB = function(b,deltta) {
	if(deltta == -1) {
		return b.newShiftR(1);
	}
	if(deltta == 1) {
		return b.newShiftL(1);
	}
	if(deltta == -10) {
		return b.newAND(BB.filesBB[8].newNOT()).newShiftL(10);
	}
	if(deltta == -8) {
		return b.newAND(BB.filesBB[8].newNOT()).newShiftR(8);
	}
	if(deltta == 8) {
		return b.newAND(BB.filesBB[0].newNOT()).newShiftL(8);
	}
	if(deltta == 10) {
		return b.newAND(BB.filesBB[0].newNOT()).newShiftR(10);
	}
	var zero = new Bitboard();
	return zero;
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
	this.count = 0;
	this.upper = 0;
	this.middle = 0;
	this.lower = 0;
	this.lower = l;
	this.middle = m;
	this.upper = u;
};
Bitboard.__name__ = true;
Bitboard.LeastSB = function(theInt) {
	var i = -1;
	if((theInt & 65535) == 0) {
		i += 16;
		theInt >>>= 16;
	}
	if((theInt & 255) == 0) {
		i += 8;
		theInt >>>= 8;
	}
	if((theInt & 15) == 0) {
		i += 4;
		theInt >>>= 4;
	}
	if((theInt & 3) == 0) {
		i += 2;
		theInt >>>= 2;
	}
	if((theInt & 1) == 0) {
		++i;
		theInt >>>= 1;
	}
	if((theInt & 1) != 0) {
		++i;
	}
	return i;
};
Bitboard.prototype = {
	Copy: function(other) {
		this.lower = other.lower;
		this.middle = other.middle;
		this.upper = other.upper;
		this.count = other.count;
		this.needCount = other.needCount;
	}
	,newCOPY: function() {
		var newBB = new Bitboard();
		newBB.Copy(this);
		return newBB;
	}
	,IsNonZero: function() {
		if(!(this.lower != 0 || this.middle != 0)) {
			return this.upper != 0;
		} else {
			return true;
		}
	}
	,isSet: function(sq) {
		if(sq < 27) {
			return (this.lower & 1 << sq) != 0;
		} else if(sq < 54) {
			return (this.middle & 1 << sq - 27) != 0;
		} else {
			return (this.upper & 1 << sq - 54) != 0;
		}
	}
	,LSB: function() {
		if(this.lower != 0) {
			return Bitboard.LeastSB(this.lower);
		}
		if(this.middle != 0) {
			return Bitboard.LeastSB(this.middle) + 27;
		}
		if(this.upper != 0) {
			return Bitboard.LeastSB(this.upper) + 54;
		}
		return -1;
	}
	,OR: function(other) {
		this.lower |= other.lower;
		this.middle |= other.middle;
		this.upper |= other.upper;
		this.needCount = true;
	}
	,newOR: function(other) {
		var newBB = new Bitboard();
		newBB.Copy(this);
		newBB.OR(other);
		return newBB;
	}
	,PopLSB: function() {
		var index = -1;
		if(this.lower != 0) {
			this.count--;
			index = Bitboard.LeastSB(this.lower);
			this.lower &= this.lower - 1;
			return index;
		}
		if(this.middle != 0) {
			this.count--;
			index = 27 + Bitboard.LeastSB(this.middle);
			this.middle &= this.middle - 1;
			return index;
		}
		if(this.upper != 0) {
			this.count--;
			index = 54 + Bitboard.LeastSB(this.upper);
			this.upper &= this.upper - 1;
			return index;
		}
		return -1;
	}
	,ShiftL: function(theShift) {
		if(theShift < 27) {
			this.upper <<= theShift;
			this.upper |= this.middle >>> 27 - theShift;
			this.middle <<= theShift;
			this.middle |= this.lower >>> 27 - theShift;
			this.lower <<= theShift;
		} else if(theShift < 54) {
			this.upper = this.middle >>> theShift - 27;
			this.upper |= this.lower >>> 54 - theShift;
			this.middle = this.lower << theShift - 27;
			this.lower = 0;
		} else {
			this.upper = this.lower << theShift - 54;
			this.lower = 0;
		}
		this.needCount = true;
	}
	,newShiftL: function(theShift) {
		var newBB = new Bitboard();
		newBB.Copy(this);
		newBB.ShiftL(theShift);
		return newBB;
	}
	,ShiftR: function(theShift) {
		if(theShift < 27) {
			this.lower >>>= theShift;
			this.lower |= this.middle << 27 - theShift >>> 27 - theShift << 27 - theShift;
			this.middle >>>= theShift;
			this.middle |= this.upper << 27 - theShift >>> 27 - theShift << 27 - theShift;
			this.upper >>>= theShift;
		} else if(theShift < 54) {
			this.lower = this.middle >>> theShift - 27;
			this.lower |= this.upper << 27 - theShift >>> 27 - theShift << 27 - theShift;
			this.middle = this.upper >>> theShift - 27;
			this.upper = 0;
		} else {
			this.lower = this.upper >>> theShift - 54;
			this.middle = 0;
			this.upper = 0;
		}
		this.needCount = true;
	}
	,newShiftR: function(theShift) {
		var newBB = new Bitboard();
		newBB.Copy(this);
		newBB.ShiftR(theShift);
		return newBB;
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
	,ClrBit: function(theIndex) {
		if(theIndex < 27) {
			this.lower ^= 1 << theIndex;
		} else if(theIndex < 54) {
			this.middle ^= 1 << theIndex - 27;
		} else {
			this.upper ^= 1 << theIndex - 54;
		}
		this.needCount = true;
	}
	,NORM27: function() {
		this.lower &= 134217727;
		this.middle &= 134217727;
		this.upper &= 134217727;
		this.needCount = true;
		return this;
	}
	,AND: function(other) {
		this.lower &= other.lower;
		this.middle &= other.middle;
		this.upper &= other.upper;
		this.needCount = true;
	}
	,newAND: function(other) {
		var newBB = new Bitboard();
		newBB.Copy(this);
		newBB.AND(other);
		return newBB;
	}
	,NOT: function() {
		this.lower = ~this.lower;
		this.middle = ~this.middle;
		this.upper = ~this.upper;
		this.count = 81 - this.count;
	}
	,newNOT: function() {
		var newBB = new Bitboard();
		newBB.Copy(this);
		newBB.NOT();
		return newBB;
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
var Engine = function() {
	haxe_Log.trace("Engine:new",{ fileName : "Engine.hx", lineNumber : 11, className : "Engine", methodName : "new"});
};
Engine.__name__ = true;
Engine.main = function() {
	haxe_Log.trace("Engine main",{ fileName : "Engine.hx", lineNumber : 15, className : "Engine", methodName : "main"});
	Engine.pos = new Position();
	Engine.Init();
	Engine.global.onmessage = Engine.onMessage;
};
Engine.Init = function() {
	BB.Init();
	Search.Init();
};
Engine.onMessage = function(m) {
	var msg = m.data;
	var res = "";
	haxe_Log.trace("Endine get data = " + msg,{ fileName : "Engine.hx", lineNumber : 29, className : "Engine", methodName : "onMessage"});
	if(msg.indexOf("position ") == 0) {
		Engine.pos.setPosition(HxOverrides.substr(msg,9,null));
		Engine.pos.printBoard();
		haxe_Log.trace("pos.c: " + Engine.pos.SideToMove(),{ fileName : "Engine.hx", lineNumber : 33, className : "Engine", methodName : "onMessage"});
		Search.Reset(Engine.pos);
		Search.Think();
		var moveResult = Search.rootMoves[0].pv[0];
		res = "bestmove " + Types.Move_To_String(moveResult);
		haxe_Log.trace(res,{ fileName : "Engine.hx", lineNumber : 38, className : "Engine", methodName : "onMessage"});
		Engine.global.postMessage(res);
	}
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) {
		return undefined;
	}
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
Math.__name__ = true;
var MoveExt = function() {
	this.score = 0;
	this.move = 0;
	haxe_Log.trace("MoveExt::new",{ fileName : "MoveExt.hx", lineNumber : 8, className : "MoveExt", methodName : "new"});
};
MoveExt.__name__ = true;
var MoveList = function() {
	this.moveCount = 0;
	this.curIndex = 0;
	this.mlist = [];
	haxe_Log.trace("MoveList::new",{ fileName : "MoveList.hx", lineNumber : 9, className : "MoveList", methodName : "new"});
	var _g = 0;
	while(_g < 600) {
		var i = _g++;
		this.mlist[i] = new MoveExt();
	}
};
MoveList.__name__ = true;
MoveList.prototype = {
	Reset: function() {
		this.curIndex = 0;
		this.moveCount = 0;
	}
	,SerializePawns: function(b,delta,us) {
		var pb = b.newAND(BB.enemyField3[us]).NORM27();
		var nb = b.newAND(BB.enemyField3[us].newNOT()).NORM27();
		var to = 0;
		while(pb.IsNonZero()) {
			to = pb.PopLSB();
			this.mlist[this.moveCount].move = Types.Make_Move_Promote(to - delta,to);
			this.moveCount++;
		}
		while(nb.IsNonZero()) {
			to = nb.PopLSB();
			this.mlist[this.moveCount].move = Types.Make_Move(to - delta,to);
			this.moveCount++;
		}
	}
	,generatePawnMoves: function(pos,us,target) {
		haxe_Log.trace("MoveList::GeneratePawnMoves c: " + us,{ fileName : "MoveList.hx", lineNumber : 37, className : "MoveList", methodName : "generatePawnMoves"});
		var up = 1;
		var tRank8BB = BB.ranksBB[8];
		if(us == 0) {
			up = -1;
			tRank8BB = BB.ranksBB[0];
		}
		var emptySquares = target;
		var pawnsNotOn7 = pos.PiecesColourType(us,1).newAND(tRank8BB.newNOT());
		var b1 = BB.ShiftBB(pawnsNotOn7,up).newAND(emptySquares);
		this.SerializePawns(b1,up,us);
	}
	,GenerateAll: function(pos,us,target) {
		haxe_Log.trace("MoveList::GenerateAll c: " + us,{ fileName : "MoveList.hx", lineNumber : 52, className : "MoveList", methodName : "GenerateAll"});
		this.generatePawnMoves(pos,us,target);
	}
	,Generate: function(pos) {
		var us = pos.SideToMove();
		var pc;
		haxe_Log.trace("MoveList::Generate c: " + us,{ fileName : "MoveList.hx", lineNumber : 59, className : "MoveList", methodName : "Generate"});
		var target = pos.PiecesAll().newNOT();
		haxe_Log.trace(target.toStringBB(),{ fileName : "MoveList.hx", lineNumber : 61, className : "MoveList", methodName : "Generate"});
		this.GenerateAll(pos,us,target);
	}
};
var MovePicker = function() {
	this.stage = 0;
	this.cur = 0;
	this.moves = new MoveList();
	haxe_Log.trace("MovePicker::new",{ fileName : "MovePicker.hx", lineNumber : 10, className : "MovePicker", methodName : "new"});
};
MovePicker.__name__ = true;
MovePicker.prototype = {
	InitA: function(p) {
		haxe_Log.trace("MovePicker::InitA",{ fileName : "MovePicker.hx", lineNumber : 14, className : "MovePicker", methodName : "InitA"});
		this.pos = p;
	}
	,GenerateNext: function() {
		this.cur = 0;
		this.moves.Reset();
		this.stage++;
		haxe_Log.trace("MovePicker::GenerateNext stage=",{ fileName : "MovePicker.hx", lineNumber : 22, className : "MovePicker", methodName : "GenerateNext", customParams : [this.stage]});
	}
	,NextMove: function() {
		var move = 0;
		return move;
	}
};
var Position = function() {
	this.byColorBB = [];
	this.byTypeBB = [];
	this.hand = [];
	this.sideToMove = 0;
	this.board = [];
	haxe_Log.trace("Posision::new",{ fileName : "Position.hx", lineNumber : 12, className : "Position", methodName : "new"});
	this.InitBB();
};
Position.__name__ = true;
Position.prototype = {
	InitBB: function() {
		haxe_Log.trace("Posision::InitBB",{ fileName : "Position.hx", lineNumber : 17, className : "Position", methodName : "InitBB"});
		this.byTypeBB = [];
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byTypeBB.push(new Bitboard());
		this.byColorBB = [];
		this.byColorBB.push(new Bitboard());
		this.byColorBB.push(new Bitboard());
	}
	,PiecesAll: function() {
		return this.byTypeBB[0];
	}
	,PiecesColourType: function(c,pt) {
		return this.byColorBB[c].newAND(this.byTypeBB[pt]);
	}
	,PieceOn: function(sq) {
		return this.board[sq];
	}
	,changeSideToMove: function() {
		this.sideToMove = (this.sideToMove + 1) % 2;
	}
	,doMove: function(move) {
		this.doMoveFull(move);
	}
	,doMoveFull: function(move) {
		haxe_Log.trace("Position::doMove " + Types.Move_To_String(move),{ fileName : "Position.hx", lineNumber : 49, className : "Position", methodName : "doMoveFull"});
		var from = Types.Move_FromSq(move);
		var to = Types.Move_ToSq(move);
		var us = this.sideToMove;
		var them = Types.OppColour(us);
		var pc = this.board[from];
		var pt = Types.TypeOf_Piece(pc);
		var captured = Types.TypeOf_Piece(this.PieceOn(to));
		var capturedRaw = Types.RawTypeOf(captured);
		haxe_Log.trace("catured: " + captured + " capturedRaw: " + capturedRaw,{ fileName : "Position.hx", lineNumber : 58, className : "Position", methodName : "doMoveFull"});
		if(captured != 0) {
			var capsq = to;
			this.AddHand(us,capturedRaw);
			this.RemovePiece(capsq,them,captured);
		}
		this.RemovePiece(from,us,pt);
		this.MovePiece(from,to,us,pt);
		this.changeSideToMove();
	}
	,PutPiece: function(sq,c,pt) {
		haxe_Log.trace("Position::PutPiece sq:" + sq + " c:" + c + " pt:" + pt,{ fileName : "Position.hx", lineNumber : 70, className : "Position", methodName : "PutPiece"});
		this.board[sq] = Types.Make_Piece(c,pt);
		this.byColorBB[c].SetBit(sq);
		this.byTypeBB[0].SetBit(sq);
		this.byTypeBB[pt].SetBit(sq);
	}
	,MovePiece: function(from,to,c,pt) {
		haxe_Log.trace("Position::MovePiece from:" + from + " to:" + to + " c:" + c + " pt:" + pt,{ fileName : "Position.hx", lineNumber : 78, className : "Position", methodName : "MovePiece"});
		this.board[to] = Types.Make_Piece(c,pt);
		this.board[from] = 0;
		this.byColorBB[c].SetBit(to);
		this.byTypeBB[0].SetBit(to);
		this.byTypeBB[pt].SetBit(to);
	}
	,RemovePiece: function(sq,c,pt) {
		haxe_Log.trace("Position::RemovePiece sq:" + sq + " c:" + c + " pt:" + pt,{ fileName : "Position.hx", lineNumber : 87, className : "Position", methodName : "RemovePiece"});
		this.board[sq] = 0;
		this.byColorBB[c].ClrBit(sq);
		this.byTypeBB[0].ClrBit(sq);
		this.byTypeBB[pt].ClrBit(sq);
	}
	,HandExists: function(c,pr) {
		return this.hand[c][pr] > 0;
	}
	,AddHand: function(c,pr,n) {
		if(n == null) {
			n = 1;
		}
		this.hand[c][pr] += n;
	}
	,SubHand: function(c,pr,n) {
		if(n == null) {
			n = 1;
		}
		this.hand[c][pr] -= n;
	}
	,HandCount: function(c,pr) {
		return this.hand[c][pr];
	}
	,setPosition: function(sfen) {
		var sf = new SFEN(sfen);
		this.sideToMove = sf.SideToMove();
		this.board = sf.getBoard();
		var _g = 0;
		while(_g < 81) {
			var i = _g++;
			var pc = this.board[i];
			var pt = Types.TypeOf_Piece(pc);
			var c = Types.getPieceColor(pc);
			if(pc == 0) {
				continue;
			}
			this.PutPiece(i,c,pt);
		}
		haxe_Log.trace("Position::setPosition " + sfen,{ fileName : "Position.hx", lineNumber : 123, className : "Position", methodName : "setPosition"});
		this.hand = sf.getHand();
		var moves = sf.getMoves();
		var _g1 = 0;
		var _g2 = moves.length;
		while(_g1 < _g2) {
			var i1 = _g1++;
			this.doMove(moves[i1]);
		}
		haxe_Log.trace(this.board,{ fileName : "Position.hx", lineNumber : 129, className : "Position", methodName : "setPosition"});
	}
	,SideToMove: function() {
		return this.sideToMove;
	}
	,printBoard: function() {
		var s = "";
		s += "\n";
		var f = 8;
		while(f >= 0) {
			var sq = Types.Square(f,0);
			s += HxOverrides.substr("  " + this.board[sq],-3,null);
			--f;
		}
		s += "\n";
		var f1 = 8;
		while(f1 >= 0) {
			var sq1 = Types.Square(f1,1);
			s += HxOverrides.substr("  " + this.board[sq1],-3,null);
			--f1;
		}
		s += "\n";
		var f2 = 8;
		while(f2 >= 0) {
			var sq2 = Types.Square(f2,2);
			s += HxOverrides.substr("  " + this.board[sq2],-3,null);
			--f2;
		}
		s += "\n";
		var f3 = 8;
		while(f3 >= 0) {
			var sq3 = Types.Square(f3,3);
			s += HxOverrides.substr("  " + this.board[sq3],-3,null);
			--f3;
		}
		s += "\n";
		var f4 = 8;
		while(f4 >= 0) {
			var sq4 = Types.Square(f4,4);
			s += HxOverrides.substr("  " + this.board[sq4],-3,null);
			--f4;
		}
		s += "\n";
		var f5 = 8;
		while(f5 >= 0) {
			var sq5 = Types.Square(f5,5);
			s += HxOverrides.substr("  " + this.board[sq5],-3,null);
			--f5;
		}
		s += "\n";
		var f6 = 8;
		while(f6 >= 0) {
			var sq6 = Types.Square(f6,6);
			s += HxOverrides.substr("  " + this.board[sq6],-3,null);
			--f6;
		}
		s += "\n";
		var f7 = 8;
		while(f7 >= 0) {
			var sq7 = Types.Square(f7,7);
			s += HxOverrides.substr("  " + this.board[sq7],-3,null);
			--f7;
		}
		s += "\n";
		var f8 = 8;
		while(f8 >= 0) {
			var sq8 = Types.Square(f8,8);
			s += HxOverrides.substr("  " + this.board[sq8],-3,null);
			--f8;
		}
		haxe_Log.trace(s,{ fileName : "Position.hx", lineNumber : 147, className : "Position", methodName : "printBoard"});
	}
};
var SFEN = function(sfen) {
	this.moves = [];
	this.hand = [[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]];
	this.sideToMove = 0;
	this.board = [];
	this.setPosition(sfen);
};
SFEN.__name__ = true;
SFEN.prototype = {
	getBoard: function() {
		var arr = [];
		var _g = 0;
		while(_g < 81) {
			var i = _g++;
			arr.push(this.board[i]);
		}
		return arr;
	}
	,getHand: function() {
		return this.hand;
	}
	,getMoves: function() {
		return this.moves;
	}
	,SideToMove: function() {
		return this.sideToMove;
	}
	,setPosition: function(sfen) {
		sfen = StringTools.replace(sfen,"startpos","lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1");
		sfen = StringTools.replace(sfen,"sfen ","");
		haxe_Log.trace("SFEN::setPosition",{ fileName : "SFEN.hx", lineNumber : 43, className : "SFEN", methodName : "setPosition", customParams : [sfen]});
		var tokens = sfen.split(" ");
		var f = 8;
		var r = 0;
		var promote = false;
		var i = 0;
		var token = "";
		var sq = 0;
		this.board = [];
		haxe_Log.trace(tokens,{ fileName : "SFEN.hx", lineNumber : 52, className : "SFEN", methodName : "setPosition"});
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
		this.sideToMove = tokens[1] == "b" ? 0 : 1;
		var ct = 0;
		var _g21 = 0;
		var _g3 = tokens[2].length;
		while(_g21 < _g3) {
			var i2 = _g21++;
			var token2 = tokens[2].charAt(i2);
			if(token2 == "-") {
				break;
			} else if(util_StringUtil.isNumberString(token2)) {
				ct = Std.parseInt(token2) + ct * 10;
			} else {
				ct = util_MathUtil.max(ct,1);
				var pc = Types.getPieceType(token2);
				this.hand[Types.getPieceColor(pc)][Types.RawTypeOf(pc)] = ct;
				ct = 0;
			}
		}
		if(sfen.indexOf("moves") > 0) {
			var mvs = sfen.split("moves ")[1].split(" ");
			var _g4 = 0;
			var _g5 = mvs.length;
			while(_g4 < _g5) {
				var i3 = _g4++;
				var m = Types.generateMoveFromString(mvs[i3]);
				this.moves.push(m);
			}
		}
	}
};
var Search = function() {
};
Search.__name__ = true;
Search.Init = function() {
	haxe_Log.trace("Search::Init",{ fileName : "Search.hx", lineNumber : 11, className : "Search", methodName : "Init"});
	var _g = 0;
	while(_g < 600) {
		var i = _g++;
		Search.rootMoves.push(new SearchRootMove());
	}
};
Search.Reset = function(pos) {
	haxe_Log.trace("Search::Reset",{ fileName : "Search.hx", lineNumber : 18, className : "Search", methodName : "Reset"});
	var _g = 0;
	while(_g < 600) {
		var i = _g++;
		Search.rootMoves[i].Clear();
	}
	Search.numRootMoves = 0;
	Search.rootPos = pos;
	var moves = new MoveList();
	moves.Generate(Search.rootPos);
	var _g1 = 0;
	var _g2 = moves.moveCount;
	while(_g1 < _g2) {
		var i1 = _g1++;
		Search.rootMoves[Search.numRootMoves].SetMove(moves.mlist[i1].move);
		Search.numRootMoves++;
	}
};
Search.Think = function() {
	haxe_Log.trace("Search::Think",{ fileName : "Search.hx", lineNumber : 33, className : "Search", methodName : "Think"});
};
Search.Search = function(pos) {
	haxe_Log.trace("Search::Search",{ fileName : "Search.hx", lineNumber : 37, className : "Search", methodName : "Search"});
	var mp = new MovePicker();
	var move = 0;
	mp.InitA(pos);
	move = mp.NextMove();
	return move;
};
var SearchRootMove = function() {
	this.pv = [];
};
SearchRootMove.__name__ = true;
SearchRootMove.prototype = {
	Clear: function() {
		this.score = 0;
		this.prevScore = 0;
		this.pv[0] = 0;
		this.numMoves = 0;
	}
	,SetMove: function(m) {
		this.score = -30001;
		this.prevScore = -30001;
		this.pv[0] = m;
		this.numMoves = 1;
	}
};
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
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
var Types = function() { };
Types.__name__ = true;
Types.OppColour = function(c) {
	return c ^ 1;
};
Types.Is_SqOK = function(s) {
	if(s >= 0) {
		return s <= 80;
	} else {
		return false;
	}
};
Types.File_Of = function(s) {
	return s / 9 | 0;
};
Types.Rank_Of = function(s) {
	return s % 9;
};
Types.FileString_Of = function(s) {
	return "" + (Types.File_Of(s) + 1);
};
Types.File_To_Char = function(f) {
	return "" + (f + 1);
};
Types.Rank_To_Char = function(r,toLower) {
	if(toLower == null) {
		toLower = true;
	}
	if(toLower) {
		var code = HxOverrides.cca("a",0) + r;
		return String.fromCodePoint(code);
	} else {
		var code1 = HxOverrides.cca("A",0) + r;
		return String.fromCodePoint(code1);
	}
};
Types.Square_To_String = function(s) {
	return Types.File_To_Char(Types.File_Of(s)) + Types.Rank_To_Char(Types.Rank_Of(s));
};
Types.Move_FromSq = function(m) {
	return m >>> 7 & 127;
};
Types.Move_ToSq = function(m) {
	return m & 127;
};
Types.Move_Dropped_Piece = function(m) {
	return m >>> 7 & 127;
};
Types.Move_Type = function(m) {
	return m & 49152;
};
Types.Move_To_String = function(m) {
	if(Types.Is_Drop(m)) {
		return Types.PieceToChar(Types.Move_Dropped_Piece(m)) + "*" + Types.Square_To_String(Types.Move_ToSq(m));
	} else {
		return Types.Square_To_String(Types.Move_FromSq(m)) + Types.Square_To_String(Types.Move_ToSq(m));
	}
};
Types.Move_To_StringLong = function(m) {
	return Types.Move_To_String(m) + " " + Types.Move_Type_String(m) + " : " + m;
};
Types.Move_Type_String = function(m) {
	if(Types.Move_Type(m) == 16384) {
		return "Drop";
	}
	if(Types.Move_Type(m) == 32768) {
		return "Promo";
	}
	return "Normal";
};
Types.Make_Move = function(from,to) {
	return to | from << 7;
};
Types.Make_Move_Promote = function(from,to) {
	return to | from << 7 | 32768;
};
Types.Make_Move_Drop = function(pt,sq) {
	return sq | pt << 7 | 16384;
};
Types.generateMoveFromString = function(ft) {
	var f = Std.parseInt(HxOverrides.substr(ft,0,1)) - 1;
	var r = HxOverrides.cca(ft,1) - 97;
	var from = Types.Square(f,r);
	f = Std.parseInt(HxOverrides.substr(ft,2,1)) - 1;
	r = HxOverrides.cca(ft,3) - 97;
	var to = Types.Square(f,r);
	return Types.Make_Move(from,to);
};
Types.Is_Move_OK = function(m) {
	return Types.Move_FromSq(m) != Types.Move_ToSq(m);
};
Types.Is_Promote = function(m) {
	return (m & 32768) != 0;
};
Types.Is_Drop = function(m) {
	return (m & 16384) != 0;
};
Types.RankString_Of = function(s) {
	var code = 97 + Types.Rank_Of(s);
	return String.fromCodePoint(code);
};
Types.RawTypeOf = function(p) {
	return p % 8;
};
Types.Make_Piece = function(c,pt) {
	return c << 4 | pt;
};
Types.Square = function(f,r) {
	return f * 9 + r;
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
Types.TypeOf_Piece = function(pc) {
	return pc % 16;
};
Types.PieceToChar = function(pt) {
	if(pt == 17) {
		return "P";
	}
	if(pt == 18) {
		return "L";
	}
	if(pt == 20) {
		return "S";
	}
	if(pt == 19) {
		return "N";
	}
	if(pt == 21) {
		return "B";
	}
	if(pt == 22) {
		return "R";
	}
	if(pt == 23) {
		return "G";
	}
	if(pt == 24) {
		return "K";
	}
	if(pt == 25) {
		return "+P";
	}
	if(pt == 26) {
		return "+L";
	}
	if(pt == 27) {
		return "+N";
	}
	if(pt == 28) {
		return "+S";
	}
	if(pt == 29) {
		return "+B";
	}
	if(pt == 30) {
		return "+R";
	}
	if(pt == 1) {
		return "p";
	}
	if(pt == 2) {
		return "l";
	}
	if(pt == 3) {
		return "n";
	}
	if(pt == 4) {
		return "s";
	}
	if(pt == 5) {
		return "b";
	}
	if(pt == 6) {
		return "r";
	}
	if(pt == 7) {
		return "g";
	}
	if(pt == 8) {
		return "k";
	}
	if(pt == 9) {
		return "+p";
	}
	if(pt == 10) {
		return "+l";
	}
	if(pt == 11) {
		return "+n";
	}
	if(pt == 12) {
		return "+s";
	}
	if(pt == 13) {
		return "+b";
	}
	if(pt == 14) {
		return "+r";
	}
	return "?";
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
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
String.__name__ = true;
Array.__name__ = true;
Object.defineProperty(js__$Boot_HaxeError.prototype,"message",{ get : function() {
	return String(this.val);
}});
js_Boot.__toStr = ({ }).toString;
BB.squareDistance = [];
BB.stepAttacksBB = [];
BB.squareBB = [];
BB.enemyField1 = [];
BB.enemyField2 = [];
BB.enemyField3 = [];
BB.steps = [[0,0,0,0,0,0,0,0,0],[-1,0,0,0,0,0,0,0,0],[-1,-2,-3,-4,-5,-6,-7,-8,0],[7,-11,0,0,0,0,0,0,0],[-1,8,10,-10,-8,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[-1,8,9,-1,-10,-9,0,0,0],[-1,8,9,-1,-10,-9,10,-8,0],[-1,8,9,-1,-10,-9,0,0,0],[-1,8,9,-1,-10,-9,0,0,0],[-1,8,9,-1,-10,-9,0,0,0],[-1,8,9,-1,-10,-9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]];
Bitboard.NA = 27;
Bitboard.NB = 54;
Engine.global = eval("self");
SFEN.startpos = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1";
Search.rootMoves = [];
Search.numRootMoves = 0;
Types.BLACK = 0;
Types.WHITE = 1;
Types.FILE_A = 0;
Types.RANK_1 = 0;
Types.COLOR_NB = 2;
Types.ALL_PIECES = 0;
Types.PIECE_TYPE_NB = 0;
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
Types.MAX_MOVES = 600;
Types.DELTA_N = -1;
Types.DELTA_E = -9;
Types.DELTA_S = 1;
Types.DELTA_W = 9;
Types.DELTA_NN = -2;
Types.DELTA_NE = -10;
Types.DELTA_SE = -8;
Types.DELTA_SS = 2;
Types.DELTA_SW = 10;
Types.DELTA_NW = 8;
Types.MOVE_NONE = 0;
Types.MOVE_NORMAL = 0;
Types.MOVE_DROP = 16384;
Types.MOVE_PROMO = 32768;
Types.VALUE_ZERO = 0;
Types.VALUE_DRAW = 0;
Types.VALUE_KNOWN_WIN = 15000;
Types.VALUE_MATE = 30000;
Types.VALUE_INFINITE = 30001;
Types.VALUE_NONE = 30002;
Engine.main();
})();
