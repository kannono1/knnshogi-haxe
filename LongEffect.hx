import haxe.ds.Vector;
import Types.PC;
import Types.Directions;
import Types.SquareWithWall;
import Bitboard.Bitboard;
import Position.Position;

class ByteBoard {
	public var e:Vector<Int> = new Vector<Int>(Types.SQ_NB_PLUS1);

    public function new() {
        clear();
    }
    
    public function clear() {
        for(i in 0...Types.SQ_NB_PLUS1) {
            e[i] = 0;
        }
    }

	public function effect(sq:Int):Int {
		return e[sq];
	}
}

class WordBoard {
    // 各升のDirections(先後)
    // 先手のほうは下位8bit。後手のほうは上位8bit
    // public var le:Vector<Int> = new Vector<Int>(Types.SQ_NB_PLUS1);

    // 各升のDirections(先後)
    // 先手のほうは下位8bit。後手のほうは上位8bit
    public var le16:Vector<LongEffect16> = new Vector<LongEffect16>(Types.SQ_NB_PLUS1);

    public function new() {
        clear();
    }

    public function clear() {
        for(i in 0...Types.SQ_NB_PLUS1) {
            le16[i] = new LongEffect16();
        }
    }

    // ある升の長い利きの方向を得る(DirectionsBW型とみなして良い)
    public function long_effect16(sq:Int):Int { return le16[sq].u16; }
}

// Directions先後用
class LongEffect16 {
    public var dirs:Vector<Directions> = new Vector<Directions>(Types.COLOR_NB); // 先後個別に扱いたいとき用
    public var u16:Int;              // 直接整数として扱いたいとき用。long_effect_of()で取得可能

    public function new() {}
}

class LongEffect {
    // 各升のDirections(先後)
    // 先手のほうは下位8bit。後手のほうは上位8bit
    private static var le16:Vector<LongEffect16> = new Vector<LongEffect16>(Types.SQ_NB_PLUS1);
    // 先手の香と角と飛車の長い利きの方向
    private static var BISHOP_DIR:Directions = DIRECTIONS_LU | DIRECTIONS_LD | DIRECTIONS_RU | DIRECTIONS_RD;
    private static var ROOK_DIR:Directions = DIRECTIONS_R | DIRECTIONS_U | DIRECTIONS_D | DIRECTIONS_L;

    // ある駒に対する長い利きの方向
    // 1) 長い利きに関して、馬と龍は角と飛車と同じ。
    // 2) 後手の駒は (dir << 8)して格納する。(DirectionsBWの定義より。)
    private static var long_effect16_table:Array<Int> = [//[PIECE_NB]
        0,0,DIRECTIONS_U/*香*/,0,0,BISHOP_DIR/*角*/,ROOK_DIR/*飛*/,0,0,0,0,0,0,BISHOP_DIR/*馬*/,ROOK_DIR/*龍*/,0,                                          // 先手
        0,0,(DIRECTIONS_D<<8)/*香*/,0,0,(BISHOP_DIR<<8),(ROOK_DIR<<8),0,0,0,0,0,0,(BISHOP_DIR<<8),(ROOK_DIR<<8),0, // 後手
    ];
    private static function long_effect16_of(pc:PC):Int { return long_effect16_table[pc]; }

	public static function init(pos:Position) {
        trace('Longeffect::init');
        // var board_effect = pos.board_effect;
        // var long_effect = pos.long_effect;
		for(i in 0...Types.COLOR_NB) {
			pos.board_effect[i] = new ByteBoard();
		}
		pos.long_effect = new WordBoard();
    }

    // ある升にある長い利きの方向
    // この方向に利いている(遠方駒は、この逆方向にいる。sqの駒を取り除いたときにさらにこの方角に利きが伸びる)
    // private static function directions_of(us:Int , sq:Int): Directions {
    //     return le16[sq].dirs[us];
    // }

	public static function calc_effect(pos:Position) {
        var board_effect = pos.board_effect;
        var long_effect = pos.long_effect;
		for(i in 0...Types.COLOR_NB) {
			board_effect[i].clear();
		}
        long_effect.clear();
        var b:Bitboard = pos.PiecesAll().newCOPY();
		while (b.IsNonZero()) {
            var sq = b.PopLSB();
            var pc = pos.piece_on(sq);
            var effect = effects_from(pc, sq, pos.pieces());
            var c = Types.color_of(pc);
            var eb = effect.newCOPY();
		    while (eb.IsNonZero()) {
                var to = eb.PopLSB();
                pos.ADD_BOARD_EFFECT(c, to, 1);
            }
            if (Types.has_long_effect(pc)) {
                // ただし、馬・龍に対しては、長い利きは、角・飛車と同じ方向だけなので成り属性を消して、利きを求め直す。
                if (Types.type_of(pc) != Types.LANCE){
                    effect = effects_from(new PC(pc & ~Types.PIECE_PROMOTE), sq, pos.pieces());
                }
                eb = effect.newCOPY();
                while (eb.IsNonZero()) {
                    var to:Int = eb.PopLSB();
                    var dir:Directions = Types.directions_of(sq, to);
                    long_effect.le16[to].dirs[c] ^= dir;// ビット単位の排他OR代入演算子
                }
            }
		}
    }

    // ----------------------
    //  do_move()での利きの更新用
    // ----------------------

    // 駒pcをsqの地点においたときの短い利きを取得する(長い利きは含まれない)
    private static function short_effects_from(pc:PC, sq:Int):Bitboard {
        switch (pc) {
            case Types.B_PAWN: return BB.pawnEffect(Types.BLACK, sq);
            case Types.W_PAWN: return BB.pawnEffect(Types.WHITE, sq);
            case Types.B_KNIGHT: return BB.knightEffect(Types.BLACK, sq);
            case Types.W_KNIGHT: return BB.knightEffect(Types.WHITE, sq);
            case Types.B_SILVER: return BB.silverEffect(Types.BLACK, sq);
            case Types.W_SILVER: return BB.silverEffect(Types.WHITE, sq);
            case Types.B_GOLD | Types.B_PRO_PAWN | Types.B_PRO_LANCE | Types.B_PRO_KNIGHT | Types.B_PRO_SILVER: return BB.goldEffect(Types.BLACK, sq);
            case Types.W_GOLD | Types.W_PRO_PAWN | Types.W_PRO_LANCE | Types.W_PRO_KNIGHT | Types.W_PRO_SILVER: return BB.goldEffect(Types.WHITE, sq);
            // 馬の短い利きは上下左右
            case Types.B_HORSE | Types.W_HORSE: return BB.cross00StepEffect(sq);
            // 龍の短い利きは斜め長さ1
            case Types.B_DRAGON | Types.W_DRAGON: return BB.cross45StepEffect(sq);
            case Types.B_KING | Types.W_KING: return BB.kingEffect(sq);
            // 短いを持っていないもの
            case Types.B_LANCE | Types.B_BISHOP | Types.B_ROOK: return BB.ZERO_BB;
            case Types.W_LANCE | Types.W_BISHOP | Types.W_ROOK: return BB.ZERO_BB;
            default: return BB.ZERO_BB;
        }
    }

    // ある升から8方向のrayに対する長い利きの更新処理。先後同時に更新が行えて、かつ、
    // 発生と消滅が一つのコードで出来る。
    // dir_bw_usの方角のrayを更新するときはUs側の利きが+pされる。
    // dir_bw_othersの方角のrayを更新するときはそのrayの手番側の利きが-pされる。
    // これは
    // 1) toの地点にUsの駒を移動させるなら、toの地点で発生する利き(dir_bw_us)以外は、遮断された利きであるから、このray上の利きは減るべき。
    // 2) toの地点からUsの駒を移動させるなら、toの地点から取り除かれる利き(dir_bw_us)以外は、遮断されていたものが回復する利きであるから、このray上の利きは増えるべき。
    // 1)の状態か2の状態かをpで選択する。1)ならp=+1 ,  2)なら p=-1。
    private static function UPDATE_LONG_EFFECT_FROM_(pos:Position, EFFECT_FUNC:Dynamic,to:Int,dir_bw_us:Int,dir_bw_others:Int,p:Int) {
        var Us = pos.sideToMove;
        var sq;
        var dir_bw:Int = dir_bw_us ^ dir_bw_others;  /* trick a) */
        var toww:SquareWithWall = Types.to_sqww(to);
        while (dir_bw > 0) {
            /* 更新していく方角*/
            var dir:Int = Bitboard.LeastSB(dir_bw) & 7; /* Effect8::Direct型*/
            /* 更新していく値。これは先後の分、同時に扱いたい。*/
            var value:Int = ((1 << dir) | (1 << (dir + 8)));
            /* valueに関する上記の2つのbitをdir_bwから取り出す */
            value &= dir_bw;
            dir_bw &= ~value; /* dir_bwのうち、上記の2つのbitをクリア*/
            var delta = Types.DirectToDeltaWW(dir);
            /* valueにUs側のrayを含むか */
            var the_same_color:Bool = (Us == Types.BLACK && (value & 0xff) != 0) || ((Us == Types.WHITE) && (value & 0xff00) != 0);
            var e1:Int = (dir_bw_us & value) != 0 ? p : (the_same_color ? -p : 0);
            var not_the_same:Bool = (Us == Types.BLACK && (value & 0xff00) != 0) || ((Us == Types.WHITE) && (value & 0xff) != 0);
            var e2:Int = not_the_same ? -p : 0;
            var toww2:Int = toww;
            do {
                toww2 += delta;
                if (!Types.is_ok(toww2)) break; /* 壁に当たったのでこのrayは更新終了*/
                sq = Types.sqww_to_sq(toww2);
                /* trick b) xorで先後同時にこの方向の利きを更新*/
                pos.long_effect.le16[sq].u16 ^= value;
                EFFECT_FUNC(pos, Us, sq, e1, e2);
            } while (pos.piece_on(sq) == Types.NO_PIECE);
        }
    }

    // do_move()のときに使う用。
    private static function UPDATE_LONG_EFFECT_FROM(pos:Position, to:Int, dir_bw_us:Int, dir_bw_others:Int, p:Int) {
        UPDATE_LONG_EFFECT_FROM_(pos, ADD_BOARD_EFFECT_BOTH,to,dir_bw_us,dir_bw_others,p);
    }

    // undo_move()で巻き戻すときに使う用。(利きの更新関数が違う)
    private static function UPDATE_LONG_EFFECT_FROM_REWIND(pos:Position, to:Int, dir_bw_us:Int, dir_bw_others:Int, p:Int) {
        UPDATE_LONG_EFFECT_FROM_(pos, ADD_BOARD_EFFECT_BOTH_REWIND,to,dir_bw_us,dir_bw_others,p);
    }

    // Usの手番で駒pcをtoに移動させ、成りがある場合、moved_after_pcになっており、捕獲された駒captured_pcがあるときの盤面の利きの更新
    public static function update_by_capturing_piece(pos:Position, from:Int, to:Int, moved_pc:PC, moved_after_pc:PC, captured_pc:PC) {
        var Us = pos.sideToMove;
        var board_effect = pos.board_effect;
        var long_effect = pos.long_effect;
        // -- 移動させた駒と捕獲された駒による利きの更新
        // 利きを減らさなければならない場所 = fromの地点における動かした駒の利き
        var dec_target:Bitboard = short_effects_from(moved_pc, from).newCOPY();
        // 利きを増やさなければならない場所 = toの地点における移動後の駒の利き
        var inc_target:Bitboard = short_effects_from(moved_after_pc, to).newCOPY();
        // 利きのプラス・マイナスが相殺する部分を消しておく。
        var and_target:Bitboard = inc_target.newAND(dec_target);
        inc_target.XOR(and_target);
        dec_target.XOR(and_target);
        while (inc_target.IsNonZero()) {
            var sq = inc_target.PopLSB();
            pos.ADD_BOARD_EFFECT( Us, sq , 1);
        }
        while (dec_target.IsNonZero()) {
            var sq = dec_target.PopLSB();
            pos.ADD_BOARD_EFFECT( Us, sq , -1);
        }
        // 捕獲された駒の利きの消失
        dec_target = short_effects_from(captured_pc, to).newCOPY();
        while (dec_target.IsNonZero()) {
            var sq = dec_target.PopLSB();
            pos.ADD_BOARD_EFFECT(Types.OppColour(Us), sq , -1);
        }
        // -- fromの地点での長い利きの更新。
        // この駒が移動することにより、ここに利いていた長い利きが延長されるのと、この駒による長い利きに関する更新。
        // このタイミングでは(captureではない場合)toにまだ駒はない。
        // fromには駒はあるが、toに駒をおいてもfromより向こう側(toと直線上)の長い利きの状態は変わらない。
        // (toに移動した駒による長い利きが、移動前もfromから同じように発生していたと考えられるから。)
        // だから、移動させる方向と反対方向のrayは更新してはならない。(敵も味方も共通で)
        // fromからtoへの反対方向への利きをマスクする(ちょっとこれ求めるの嫌かも..)
        var dir = Types.directions_of(from, to);
        var dir_mask;
        if (dir != 0) {
            // 桂以外による移動
            var dir_cont = (1 << (7 - Bitboard.LeastSB(dir)));
            dir_mask = ~(dir_cont | (dir_cont << 8));
        } else {
            // 桂による移動(non mask)
            dir_mask = 0xffff;
        }
        var dir_bw_us = long_effect16_of(moved_pc) & dir_mask;  // 移動させた駒による長い利きは無くなって
        var dir_bw_others = pos.long_effect.long_effect16(from) & dir_mask; // そこで遮断されていた利きの分だけ増える
        UPDATE_LONG_EFFECT_FROM(pos, from, dir_bw_us, dir_bw_others, -1);
        // -- toの地点での長い利きの更新。
        // ここはもともと今回捕獲された駒があって利きが遮断されていたので、
        // ここに移動させた駒からの長い利きと、今回捕獲した駒からの長い利きに関する更新だけで十分
        dir_bw_us = long_effect16_of(moved_after_pc);
        dir_bw_others = long_effect16_of(captured_pc);
        UPDATE_LONG_EFFECT_FROM(pos, to, dir_bw_us , dir_bw_others , 1);
    }

    // Usの手番で駒pcをtoに移動させ、成りがある場合、moved_after_pcになっている(捕獲された駒はない)ときの盤面の利きの更新
    public static function update_by_no_capturing_piece(pos:Position, from:Int, to:Int, moved_pc:PC, moved_after_pc:PC) {
        var Us = pos.sideToMove;
        var board_effect = pos.board_effect;
        var long_effect = pos.long_effect;
        // -- 移動させた駒と捕獲された駒による利きの更新
        var dec_target = short_effects_from(moved_pc, from).newCOPY();
        var inc_target = short_effects_from(moved_after_pc, to).newCOPY();
        var and_target = inc_target.newAND(dec_target);
        inc_target.XOR(and_target);
        dec_target.XOR(and_target);
        while (inc_target.IsNonZero()) {
            var sq = inc_target.PopLSB();
            pos.ADD_BOARD_EFFECT(Us, sq , 1);
        }
        while (dec_target.IsNonZero()) {
            var sq = dec_target.PopLSB();
            pos.ADD_BOARD_EFFECT(Us, sq , -1);
        }
        // -- fromの地点での長い利きの更新。(capturesのときと同様)
        var dir = Types.directions_of(from, to);
        var dir_mask;
        if (dir != 0) {
            // 桂以外による移動
            var dir_cont = (1 << (7 - Bitboard.LeastSB(dir)));
            dir_mask = ~(dir_cont | (dir_cont << 8));
        } else {
            // 桂による移動(non mask)
            dir_mask = 0xffff;
        }
        var dir_bw_us:Int = long_effect16_of(moved_pc) & dir_mask;
        var dir_bw_others:Int = pos.long_effect.long_effect16(from) & dir_mask;
        UPDATE_LONG_EFFECT_FROM(pos, from, dir_bw_us, dir_bw_others, -1);
        // -- toの地点での長い利きの更新。
        // ここに移動させた駒からの長い利きと、これにより遮断された長い利きに関する更新
        dir_bw_us = long_effect16_of(moved_after_pc);
        dir_bw_others = pos.long_effect.long_effect16(to);
        UPDATE_LONG_EFFECT_FROM(pos, to, dir_bw_us, dir_bw_others, 1);
    }

    // Usの手番で駒pcをtoに配置したときの盤面の利きの更新
    public static function update_by_dropping_piece(pos:Position , to:Int, dropped_pc:PC) {
        var Us = pos.sideToMove;
        var board_effect = pos.board_effect;
        // 駒打ちなので
        // 1) 打った駒による利きの数の加算処理
        var inc_target:Bitboard = short_effects_from(dropped_pc, to).newCOPY();
        while (inc_target.IsNonZero()) {
            var sq = inc_target.PopLSB();
            pos.ADD_BOARD_EFFECT(Us, sq, 1);
        }
        // 2) この駒が遠方駒なら長い利きの加算処理 + この駒によって遮断された利きの減算処理
        // これらは実は一度に行なうことが出来る。
        // trick a) (右側から)左方向への長い利きがあり、toの地点でそれを遮ったとして、しかしtoの地点に持って行った駒が飛車であれば、
        // この左方向の長い利きは遮ったことにはならならず、左方向への長い利きの更新処理は不要である。
        // このようにtoの地点の升での現在の長い利きと、toの地点に持って行った駒から発生する長い利きとをxorすることで
        // この利きの相殺処理がうまく行える。
        // trick b) (右側から)左方向への後手の長い利きをtoの升で遮断し、toの升に持って行った駒が飛車で左方向の長い利きが発生した場合、
        // WordBoardを採用しているとこの２つの利きを同時に更新して行ける。更新のときにxorを用いれば、利きの消失と発生を同時に行なうことが出来る。
        // This tricks are developed by yaneurao in 2016.
        var long_effect = pos.long_effect;
        var dir_bw_us:Int = long_effect16_of(dropped_pc); // 自分の打った駒による利きは増えて
        var dir_bw_others:Int = pos.long_effect.long_effect16(to); // その駒によって遮断された利きは減る
        UPDATE_LONG_EFFECT_FROM(pos, to , dir_bw_us, dir_bw_others, 1);
    }

    // ----------------------
    //  undo_move()での利きの更新用
    // ----------------------
    // 上の3つの関数の逆変換を行なう関数。
    public static function rewind_by_dropping_piece(pos:Position, to:Int, dropped_pc:PC) {
        var Us = pos.sideToMove;
        var board_effect = pos.board_effect;
        var inc_target = short_effects_from(dropped_pc, to).newCOPY();
        while (inc_target.IsNonZero()) {
            var sq = inc_target.PopLSB();
            ADD_BOARD_EFFECT_REWIND(pos, Us, sq, -1); // rewind時には-1
        }
        var long_effect = pos.long_effect;
        var dir_bw_us = long_effect16_of(dropped_pc);
        var dir_bw_others = pos.long_effect.long_effect16(to);
        UPDATE_LONG_EFFECT_FROM_REWIND(pos, to, dir_bw_us, dir_bw_others, -1); // rewind時には-1
    }

    public static function rewind_by_capturing_piece(pos:Position, from:Int, to:Int, moved_pc:PC, moved_after_pc:PC, captured_pc:PC) {
        var Us = pos.sideToMove;
        var board_effect = pos.board_effect;
        var long_effect = pos.long_effect;
        var inc_target = short_effects_from(moved_pc, from).newCOPY();
        var dec_target = short_effects_from(moved_after_pc, to).newCOPY();
        var and_target = inc_target.newAND(dec_target);
        inc_target.XOR(and_target);
        dec_target.XOR(and_target);
        while (inc_target.IsNonZero()) {
            var sq = inc_target.PopLSB();
            ADD_BOARD_EFFECT_REWIND(pos, Us, sq, 1);
        }
        while (dec_target.IsNonZero()) {
            var sq = dec_target.PopLSB();
            ADD_BOARD_EFFECT_REWIND(pos, Us, sq, -1);
        }
        // 捕獲された駒の利きの復活
        inc_target = short_effects_from(captured_pc, to).newCOPY();
        while (inc_target.IsNonZero()) {
            var sq = inc_target.PopLSB();
            ADD_BOARD_EFFECT_REWIND(pos, Types.OppColour(Us), sq, 1);
        }
        // -- toの地点での長い利きの更新。
        var dir_bw_us = long_effect16_of(moved_after_pc);
        var dir_bw_others = long_effect16_of(captured_pc);
        UPDATE_LONG_EFFECT_FROM_REWIND(pos,to, dir_bw_us, dir_bw_others, -1); // rewind時はこの符号が-1
        // -- fromの地点での長い利きの更新。
        var dir = Types.directions_of(from, to);
        var dir_mask;
        if (dir != 0) {
            // 桂以外による移動
            var dir_cont = (1 << (7 - Bitboard.LeastSB(dir)));
            dir_mask = ~(dir_cont | (dir_cont << 8));
        } else {
            // 桂による移動(non mask)
            dir_mask = 0xffff;
        }
        dir_bw_us = long_effect16_of(moved_pc) & dir_mask;
        dir_bw_others = pos.long_effect.long_effect16(from) & dir_mask;
        UPDATE_LONG_EFFECT_FROM_REWIND(pos, from, dir_bw_us, dir_bw_others, 1); // rewind時はこの符号が+1
    }

    public static function rewind_by_no_capturing_piece(pos:Position, from:Int,  to:Int, moved_pc:PC, moved_after_pc:PC) {
        var Us = pos.sideToMove;
        var board_effect = pos.board_effect;
        var long_effect = pos.long_effect;
        var inc_target = short_effects_from(moved_pc, from).newCOPY();
        var dec_target = short_effects_from(moved_after_pc, to).newCOPY();
        var and_target = inc_target.newAND(dec_target);
        inc_target.XOR(and_target);
        dec_target.XOR(and_target);
        while (inc_target.IsNonZero()) { var sq = inc_target.PopLSB(); ADD_BOARD_EFFECT_REWIND(pos, Us, sq, 1); }
        while (dec_target.IsNonZero()) { var sq = dec_target.PopLSB(); ADD_BOARD_EFFECT_REWIND(pos, Us, sq, -1); }
        // -- toの地点での長い利きの更新。
        var dir_bw_us = long_effect16_of(moved_after_pc);
        var dir_bw_others = pos.long_effect.long_effect16(to);
        UPDATE_LONG_EFFECT_FROM_REWIND(pos, to, dir_bw_us, dir_bw_others, -1); // rewind時はこの符号が-1
        // -- fromの地点での長い利きの更新。(capturesのときと同様)
        var dir = Types.directions_of(from, to);
        var dir_mask;
        if (dir != 0) {
            // 桂以外による移動
            var dir_cont = (1 << (7 - Bitboard.LeastSB(dir)));
            dir_mask = ~(dir_cont | (dir_cont << 8));
        } else {
            // 桂による移動(non mask)
            dir_mask = 0xffff;
        }
        dir_bw_us = long_effect16_of(moved_pc) & dir_mask;
        dir_bw_others = pos.long_effect.long_effect16(from) & dir_mask;
        UPDATE_LONG_EFFECT_FROM_REWIND(pos, from, dir_bw_us, dir_bw_others, 1); // rewind時はこの符号が+1
    }

    // 盤上sqに駒pc(先後の区別あり)を置いたときの利き。
    private static function effects_from(pc:PC, sq:Int, occ:Bitboard):Bitboard  {
      switch (pc) {
      case Types.B_PAWN: return BB.pawnEffect(Types.BLACK, sq);
      case Types.B_LANCE: return BB.lanceEffect(Types.BLACK, sq, occ);
      case Types.B_KNIGHT: return BB.knightEffect(Types.BLACK, sq);
      case Types.B_SILVER: return BB.silverEffect(Types.BLACK, sq);
      case Types.B_GOLD | Types.B_PRO_PAWN | Types.B_PRO_LANCE | Types.B_PRO_KNIGHT | Types.B_PRO_SILVER:
          return BB.goldEffect(Types.BLACK, sq);

      case Types.W_PAWN: return BB.pawnEffect(Types.WHITE, sq);
      case Types.W_LANCE: return BB.lanceEffect(Types.WHITE, sq, occ);
      case Types.W_KNIGHT: return BB.knightEffect(Types.WHITE, sq);
      case Types.W_SILVER: return BB.silverEffect(Types.WHITE, sq);
      case Types.W_GOLD | Types.W_PRO_PAWN | Types.W_PRO_LANCE| Types.W_PRO_KNIGHT| Types.W_PRO_SILVER:
          return BB.goldEffect(Types.WHITE, sq);

        //　先後同じ移動特性の駒
      case Types.B_BISHOP | Types.W_BISHOP: return BB.bishopEffect(sq, occ);
      case Types.B_ROOK   | Types.W_ROOK:   return BB.rookEffect(sq, occ);
      case Types.B_HORSE  | Types.W_HORSE:  return BB.horseEffect(sq, occ);
      case Types.B_DRAGON | Types.W_DRAGON: return BB.dragonEffect(sq, occ);
      case Types.B_KING   | Types.W_KING:   return BB.kingEffect(sq);
    //   case Types.B_QUEEN:  case Types.W_QUEEN:  return BB.horseEffect(sq, occ).newOR(BB.dragonEffect(sq, occ));
    //   case Types.NO_PIECE: case Types.PIECE_WHITE: return Types.ZERO_BB; // これも入れておかないと初期化が面倒になる。

    //   default: Types.UNREACHABLE; return Types.ALL_BB;
        default: return new Bitboard();
      }
    }

    // e1 = color側の利きの加算量 , e2 = ~color側の利きの加算量
    private static function ADD_BOARD_EFFECT_BOTH(pos:Position, color_:Int, sq_:Int, e1_:Int, e2_:Int) {
        pos.board_effect[color_].e[sq_] += e1_;
        pos.board_effect[Types.OppColour(color_)].e[sq_] += e2_;
    }

    // ↑の関数のundo_move()時用。こちらは、評価関数の差分更新を行わない。(評価関数の値を巻き戻すのは簡単であるため)
    private static function ADD_BOARD_EFFECT_REWIND(pos:Position, color_:Int, sq_:Int, e1_:Int) {
        pos.board_effect[color_].e[sq_] += e1_;
    }

    private static function ADD_BOARD_EFFECT_BOTH_REWIND(pos:Position, color_:Int, sq_:Int, e1_:Int, e2_:Int) {
        pos.board_effect[color_].e[sq_] += e1_;
        pos.board_effect[Types.OppColour(color_)].e[sq_] += e2_;
    }

}