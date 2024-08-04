package serialize;
import data.SongInfo;
import data.SwagSong;
import io.ByteArray;
import util.BytesUtil;
import util.StdUtil;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import util.Version;

/**
 * ...
 * @author Christopher Speciale
 */
@:access(serialize.SwagSongSerializer)
@:access(serialize.SongInfoSerializer)
class SFNF
{
	public static inline var VERSION:Version = "1.0.0";

	public static function write(object:SwagSong):Bytes
	{
		return SwagSongSerializer.serialize(object);
	}

	public static function read(data:Bytes):SwagSong
	{
		return SwagSongSerializer.deserialize(data);
		
	}
}


@:noCompletion class SongInfoHeader
{
	private function new(data:ByteArray):Void
	{

		length = data.readInt32();
		timeSignatureLength = data.readInt32();
		hasOffset = data.readBool();
		hasStrumlines = data.readBool();
		hasSpectator = data.readBool();
		hasStage = data.readBool();

	}

	private var length:Int;
	private var timeSignatureLength:Int;
	private var hasOffset:Bool;
	private var hasStrumlines:Bool;
	private var hasSpectator:Bool;
	private var hasStage:Bool;
	private var stage:Null<String>;

}


@:access(serialize.SongInfoHeader)
@:noCompletion class SongInfoSerializer
{

	private static function deserialize(data:ByteArray):SongInfo
	{
		var info:SongInfo = cast {};
		var header:SongInfoHeader = new SongInfoHeader(data);


		info.bpm = data.readFloat64();
		info.needsVoices = data.readBool();

		if (header.hasOffset)
		{
			info.offset = data.readInt32();
		}
		info.player1 = data.readUTF();
		info.player2 = data.readUTF();
		if (header.hasSpectator)
		{
			info.spectator = data.readUTF();
		}
		info.speed = data.readInt32();
		if (header.hasStage)
		{
			info.stage = data.readUTF();
		}
		if (header.hasStrumlines)
		{
			info.strumlines = data.readInt32();
		}
		info.time_signature = [];
		for (i in 0...header.timeSignatureLength)
		{
			info.time_signature.push(data.readInt32());
		}

		return info;
	}

	private static function serialize(object:SongInfo):Bytes
	{

		var body:Bytes = serializeBody(object);
		var header:Bytes = getHeader(object, body);

		var b:Bytes = Bytes.alloc(body.length + header.length);
		b.blit(0, header, 0, header.length);
		b.blit(header.length, body, 0, body.length);

		return b;
	}

	@:noCompletion private static function getHeader(object:SongInfo, body:Bytes):Bytes
	{
		var hasStrumlines:Bool = object.strumlines != null;
		var hasOffset:Bool = object.offset != null;
		var hasSpectator:Bool = object.spectator != null;
		var hasStage:Bool = object.stage != null;

		var length:Int = body.length;

		var timeSignatureLength:Int = object.time_signature.length;
		var timeSignatureOffset:Int = length - timeSignatureLength;

		var header:BytesBuffer = new BytesBuffer();
		header.addInt32(length);
		header.addInt32(timeSignatureLength);
		header.addByte(StdUtil.bool(hasOffset));
		header.addByte(StdUtil.bool(hasStrumlines));
		header.addByte(StdUtil.bool(hasSpectator));
		header.addByte(StdUtil.bool(hasStage));

		return header.getBytes();
	}

	@:noCompletion private static function serializeBody(object:SongInfo):Bytes
	{
		var buffer:BytesBuffer = new BytesBuffer();
		buffer.addDouble(object.bpm);
		buffer.addByte(StdUtil.bool(object.needsVoices));
		if (object.offset != null)
		{
			buffer.addInt32(object.offset);
		}

		BytesUtil.writeUTFToBytesBuffer(buffer, object.player1);
		BytesUtil.writeUTFToBytesBuffer(buffer, object.player2);

		if (object.spectator != null)
		{
			BytesUtil.writeUTFToBytesBuffer(buffer, object.spectator);
		}

		buffer.addFloat(object.speed);

		if (object.stage != null)
		{
			BytesUtil.writeUTFToBytesBuffer(buffer, object.stage);
		}

		if (object.strumlines != null)
		{
			buffer.addInt32(object.strumlines);
		}

		for (signature in object.time_signature)
		{
			buffer.addInt32(signature);
		}

		return buffer.getBytes();
	}
}

@:noCompletion class SwagSongHeader
{
	private function new(data:ByteArray):Void
	{
		version = data.readInt32();
		length = data.readInt32();
		noteDataLength = data.readInt32();
		bpmChangesLength = data.readInt32();
		hasSong = data.readBool();
		
		var v:Version = version;
		Sys.println('SFNF File Version: $v\nUncompressed File Size: $length bytes');
	}

	private var version:Int;
	private var length:Int;
	private var noteDataLength:Int;
	private var bpmChangesLength:Int;
	private var hasSong:Bool;
}


@:access(serialize.SwagSongHeader)
@:access(serialize.SongInfoSerializer)
@:noCompletion class SwagSongSerializer
{


	private static function deserialize(data:ByteArray):SwagSong
	{
		var swagSong:SwagSong = cast {};

		var header:SwagSongHeader = new SwagSongHeader(data);	

		swagSong.bpmChanges = _read2DFloatArray(data, header.bpmChangesLength);

		swagSong.noteData = _read2DFloatArray(data, header.noteDataLength);

		if (header.hasSong)
		{
			swagSong.song = data.readUTF();
		}

		swagSong.info = SongInfoSerializer.deserialize(data);

		return swagSong;
	}

	private static function serialize(object:SwagSong):Bytes
	{
		var body:Bytes = serializeBody(object);
		var header:Bytes = getHeader(object, body);

		var b:Bytes = Bytes.alloc(body.length + header.length);
		b.blit(0, header, 0, header.length);
		b.blit(header.length, body, 0, body.length);

		return b;
	}


	private static function getHeader(object:SwagSong, body:Bytes):Bytes
	{
		var version:Int = SFNF.VERSION;
		var noteDataLength:Int = _get2DFloatArrayLength(object.noteData);
		var bpmChangesLength:Int = _get2DFloatArrayLength(object.bpmChanges);
		var length:Int = body.length + 40;
		var hasSong:Bool = object.song != null;

		//var noteDataOffset:Int = length - noteDataLength;
		//var bpmChangesOffset:Int = length - noteDataLength;

		var header:BytesBuffer = new BytesBuffer();
		header.addInt32(version);
		header.addInt32(length);
		header.addInt32(noteDataLength);
		header.addInt32(bpmChangesLength);
		header.addByte(StdUtil.bool(hasSong));

		return header.getBytes();
	}

	private static function _get2DFloatArrayLength(arrayData:Array<Array<Float>>):Int
	{
		if (arrayData.length == 0)
		{
			return 0;
		}

		var length:Int = arrayData.length;

		return length;
	}

	private static function serializeBody(object:SwagSong):Bytes
	{
		var noteData:Array<Array<Float>> = object.noteData;
		var bpmChanges:Array<Array<Float>> = object.bpmChanges;
		var infoBytes:Bytes = SongInfoSerializer.serialize(object.info);

		var buffer:BytesBuffer = new BytesBuffer();

		_write2DFloatArray(buffer, bpmChanges);
		_write2DFloatArray(buffer, noteData);
		if (object.song != null)
		{
			BytesUtil.writeUTFToBytesBuffer(buffer, object.song);
		}
		buffer.addBytes(infoBytes, 0, infoBytes.length);
		return buffer.getBytes();

	}

	private static function _write2DFloatArray(buffer:BytesBuffer, array:Array<Array<Float>>):Void
	{
		for (x in 0...array.length)
		{
			var nestedArray:Array<Float> = array[x];
			for (y in 0...nestedArray.length)
			{
				var n:Float = nestedArray[y];
				buffer.addDouble(n);
			}
		}
	}

	private static function _read2DFloatArray(bytes:ByteArray, len:Int):Array<Array<Float>>
	{

		var arrayLength:Int = Std.int(len);
		var array:Array<Array<Float>> = [];

		for (x in 0...arrayLength)
		{
			var nestedArray:Array<Float> = [];
			for (y in 0...5)
			{
				var n:Float = bytes.readFloat64();
				nestedArray.push(n);
			}
			array.push(nestedArray);
		}

		return array;
	}

}

