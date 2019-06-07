package util;

class StringUtil {
    public static function isNumberString(s:String):Bool {
        var r = ~/[0-9]+/;
        return r.match(s);
    }
}