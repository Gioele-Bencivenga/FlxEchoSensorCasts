package utilities;

/**
 * A bunch of functions that I felt like keeping.
 */
class JoFuncs {
	/**
	 * Re-maps a value from one range to another.
	 * @param _value the value you wish to convert to another range
	 * @param _currLow the lower bound of `_value`'s current range
	 * @param _currUpp the upper bound of `_value`'s current range
	 * @param _targetLow the lower bound of `_value`'s target range
	 * @param _targetUpp the upper bound of `_value`'s target range
	 */
	public static inline function map(_value:Float, _currLow:Float, _currUpp:Float, _targetLow:Float, _targetUpp:Float) {
		return _targetLow + (_targetUpp - _targetLow) * ((_value - _currLow) / (_currUpp - _currLow));
	}
}
