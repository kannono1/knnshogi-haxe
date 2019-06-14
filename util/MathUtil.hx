package util;

class MathUtil {
    static public function abs(a:Int):Int {
        return (a >= 0)? a : -a ;
    }
    static public function max(a:Int, b:Int):Int {
        return (a > b)? a : b ;
    }
    static public function min(a:Int, b:Int):Int {
        return (a < b)? a : b ;
    }
}