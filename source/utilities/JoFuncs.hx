package utilities;

/**
 * A bunch of functions that I felt like keeping.
 */
class JoFuncs {
	/**
	 * Re-maps a value from one range to another.
	 *
	 * Examples:
	 * - `5` in a range of `0 to 10` is `10` in a range of `0 to 20`
	 * - `10` in a range of `0 to 100` is `36` in a range of `0 to 360`
	 * - `400` in a range of `0 to 500` is `0.8` in a range of `0 to 1`
	 *
	 * @param _value the value you wish to convert to another range
	 * @param _currLow the lower bound of `_value`'s current range
	 * @param _currUpp the upper bound of `_value`'s current range
	 * @param _targetLow the lower bound of `_value`'s target range
	 * @param _targetUpp the upper bound of `_value`'s target range
	 * @return the value that `_value` would have if it was in the target range (`_targetLow`, `_targetUpp`) instead of the current range (`_currLow`, `_currUpp`)
	 */
	public static inline function map(_value:Float, _currLow:Float, _currUpp:Float, _targetLow:Float, _targetUpp:Float) {
		return _targetLow + (_targetUpp - _targetLow) * ((_value - _currLow) / (_currUpp - _currLow));
	}
}
