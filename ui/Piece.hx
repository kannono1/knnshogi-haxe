package ui;

class Piece{
    static public var effect:Array<Array<Int>> = [
        [],
        [-1],// p
        [-1, -2, -3, -4, -5, -6, -7, -8],// l
        [7, -7],// n
        [-1, 8, 10, -8, -10],// s
        [// b
            10, 20, 30, 40, 50, 60, 70, 80,
             8, 16, 24, 32, 40, 48, 56, 64,
            -10,-20,-30,-40,-50,-60,-70,-80,
            -8,-16,-24,-32,-40,-48,-56,-64
        ],
        [// r
            1,  2,  3,  4,  5,  6,  7,  8,
            9, 18, 27, 36, 45, 54, 63, 72,
            -1, -2, -3, -4, -5, -6, -7, -8,
            -9,-18,-27,-36,-45,-54,-63,-72,
        ],
        [1, -1, 9, -9, 8, -10], // g
        [1, -1, 9, -9, 8, -10, 10, -8], // k
    ];
    static public function getEffectedSq(pt:Int, from:Int):Array<Int>{
        var arr = effect[pt];
        for(i in 0...arr.length){
            arr[i] += from;
        }
        return arr;
    }
}