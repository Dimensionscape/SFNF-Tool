package data;

/**
 * ...
 * @author Christopher Speciale
 */
typedef SongInfo =
{
	var stage:Null<String>;
	var player1:Null<String>;
	var player2:Null<String>;
	var spectator:Null<String>;
	var speed:Float;
	var bpm:Float;
	var time_signature:Array<Int>;
	var offset:Null<Int>;
	var needsVoices:Bool;
	@:optional var strumlines:Null<Int>;
}

