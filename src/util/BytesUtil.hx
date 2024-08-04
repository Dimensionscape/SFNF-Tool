package util;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.Encoding;

/**
 * ...
 * @author Christopher Speciale
 */
class BytesUtil 
{
	/*
	 * Writes a utf string to the BytesBuffer, prefixed with the length of the string bytes.
	 */
	public static inline function writeUTFToBytesBuffer(buffer:BytesBuffer, value:String):Void
	{	
		var bytes:Bytes = Bytes.ofString(value, UTF8);
		buffer.addInt32(bytes.length);
		buffer.addBytes(bytes, 0, bytes.length);
	}
	
	public static inline function readUTFFromBytes(bytes:Bytes, position:Int):String
	{	
		var length:Int = bytes.getInt32(position);
		var result:String = bytes.getString(position + 4, length);
		
		return result;
	}
	
}