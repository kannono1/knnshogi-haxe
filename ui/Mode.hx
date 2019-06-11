package ui;

@:enum
abstract OPERATION_MODE(Int){
    var SELECT = 0;
    var MOVE = 1;
    var PUT = 2;
    var WAIT = 3;
}

// class Mode {
//     static public inline var OPERATION_SELECT:Int = 0;
//     static public inline var OPERATION_PUT:Int = 1;
//     static public inline var OPERATION_WAITING:Int = 2;
// }