package io;
import haxe.Int64;
import haxe.io.Bytes;
import util.StdUtil;

/**
 * ...
 * @author Christopher Speciale
 */
@:access(io.BytesAccess)
abstract ByteArray(BytesAccess) from BytesAccess to BytesAccess
{	
	public var position(get, set):Int;
	public var length(get, never):Int;
	
	private function get_length():Int{
		return this.length;
	}
	
	public function writeInt32(value:Int):Void{
		this.setInt32(position, value);
		position += 4;
	}
	
	public function writeInt64(value:Int64):Void{
		this.setInt64(position, value);
		position += 8;
	}

	public function writeFloat32(value:Float):Void{
		this.setFloat(position, value);
		position += 4;
	}
	
	public function writeFloat64(value:Float):Void{
		this.setDouble(position, value);
		position += 8;
	}
	
	public function writeBool(value:Bool):Void{
		this.setInt32(position, StdUtil.bool(value));
		position += 4;
	}
	
	public function writeByte(value:Int):Void{
		this.set(position, value);
		position += 4;
	}
	
	public function writeBytes(bytes:Bytes):Void{
		for (i in 0...bytes.length){
			writeByte(bytes.get(i));
		}		
	}
	
	public function writeUTF(value:String):Void{		
		var b:Bytes = Bytes.ofString(value, UTF8);
		writeInt32(b.length);
		writeBytes(b);
	}
	
	public function writeUTFBytes(value:String):Void{
		var b:Bytes = Bytes.ofString(value, UTF8);
		writeBytes(b);
	}
	
	public function readInt32():Int{
		var value:Int = this.getInt32(position);
		position += 4;
		return value;
	}
	
	public function readInt64():Int64{
		var value:Int64 = this.getInt64(position);
		position += 8;
		return value;
	}

	public function readFloat32():Float{
		var value:Float = this.getFloat(position);
		position += 4;
		return value;
	}
	
	public function readFloat64():Float{
		var value:Float = this.getDouble(position);
		position += 8;
		return value;
	}
	
	public function readBool():Bool{
		var value:Bool = StdUtil.toBool(this.get(position));
		position += 1;
		return value;
	}
	
	public function readByte():Int{
		var value:Int = this.get(position);
		position += 4;
		return value;
	}
	
	public function readBytes(length:Int):ByteArray{
		var ba:ByteArray = new ByteArray(length);
		
		for (i in 0...length){
			ba.writeByte(readByte());
		}		
		
		return ba;
	}
	
	public function readUTFBytes(length:Int):String{
		var s:String = this.getString(position, length, UTF8);
		position += length;
		
		return s;
	}
	
	public function readUTF():String{		
		var len:Int = readInt32();
		var s:String = readUTFBytes(len);	
		return s;
	}
		
	private function get_position():Int{
		return this._position;
	}
	
	private function set_position(value:Int):Int{
		return this._position = value;
	}
	public inline function new(length:Int)
	{
		this = cast Bytes.alloc(length);
		position = 0;
	}	
	
	@:to @:noCompletion private inline function toBytes():Bytes
	{	
		return (this : BytesAccess);		
	}
	
	@:from private static inline function fromBytes(bytes:Bytes):ByteArray
	{
		var ba:BytesAccess = Type.createEmptyInstance(BytesAccess);
		@:privateAccess ba.b = bytes.b;
		@:privateAccess ba.length = bytes.length;
		@:privateAccess ba._position = 0;
		
		return ba;
	}
	
	@:from private static inline function fromBytesAccess(ba:BytesAccess):ByteArray
	{		
		return cast ba;
	}
}

@:noCompletion class BytesAccess extends Bytes{
	@:noCompletion private var _position:Int;	

}

