package util;

class Assert {
    public static function ASSERT_LV3(expected:Bool) {
		if(!expected){
			throw('ASSERT_LV3::Error');
		}
    }
}