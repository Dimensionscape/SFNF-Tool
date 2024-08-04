package util;

/**
 * ...
 * @author Christopher Speciale
 */
class StdUtil 
{

	public static inline function bool(value:Bool):Int{
		return value ? 1 : 0;
	}
	
	public static inline function toBool(value:Int):Bool{
		return value > 0;
	}
	
}