package;
import data.SwagSong;
import haxe.Int64;
import haxe.Int64Helper;
import haxe.zip.Compress;
import haxe.zip.Uncompress;
import io.BigBytes;
import serialize.SFNF;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.Path;
import io.ByteArray;
import sys.FileSystem;
import sys.io.File;
import util.Version;

/**
 * ...
 * @author Christopher Speciale
 */
class Main
{

	public function new()
	{
	
		//#if true
		//_convert(["D:/projects/SongTool/assets/test.json"]);
		//#else
		var args:Array<String> = Sys.args();

		if (args.length == 0)
		{
			_showInfo();
			return;
		}

		var primary:String = args.shift();

		switch (primary)
		{
			case "-convert":
				_convert(args);
			case "-h", "-help":
				_help();
			default:
				_error('Command: $primary is not a recognized SongTool command');
		}
		//#end
		

	}
	
	private function _showInfo():Void{
		Sys.command('echo \u001b[31;5m');
		Sys.print("
 (    (        )  (                          
 )\\ ) )\\ )  ( /(  )\\ )    *   )          (   
(()/((()/(  )\\())(()/(  ` )  /(          )\\  
 /(_))/(_))((_)\\  /(_))  ( )(_))(    (  ((_) 
(_)) (_))_| _((_)(_))_| (_(_()) )\\   )\\  _   
/ __|| |_  | \\| || |_   |_   _|((_) ((_)| |  
\\__ \\| __| | .` || __|    | | / _ \\/ _ \\| |  
|___/|_|   |_|\\_||_|      |_| \\___/\\___/|_|  
                                             
			");
		Sys.command('echo \u001b[0m');
		
		Sys.print("All rights reserved. 2024(c) Dimensionscape LLC \n");

		Sys.command('echo \u001b[37;1m');

		Sys.print("Command-Line Tool (v1.0.1)");

		Sys.command('echo \u001b[0m');
		
		Sys.println("Use sfnftool -help or -h for more commands");
		
		}
	private function _help():Void
	{
		Sys.println("Commands:");
		Sys.println("-help | -h");
		Sys.println("	Lists and documents available commands");
		Sys.println("-convert");
		Sys.println("	Converts a FNF song data from .json to .sfnf");
		Sys.println("	@source-path param the path to the json file you want to convert");
		Sys.println("	@compression-level param controls the compression level between 0-9");
		Sys.println("	Usage: '-convert' <source-path> [compression-level]");
	}

	private function _convert(args:Array<String>):Void
	{

		var compressionLv:Null<Int> = 0;
		var sourcePath:String = "";
		var destPath:String = "";
		var sfnfData:Bytes = null;
		
		var songObject:SwagSong = null;

		if (args.length > 2)
		{
			_error("Too many arguments for command: -convert | Expected '-convert' <source-path> [compression-level]");
		}
		else if (args.length == 0)
		{
			_error("Not enough arguments for command: -convert | Expected '-convert' <source-path> [compression-level]");
		}
		else{
			if (args.length > 0)
			{
				sourcePath = args[0];
				destPath = Path.withoutExtension(sourcePath) + ".sfnf";
			}

			if (args.length == 2)
			{

				//var filename:String = Path.withoutExtension(Path.withoutDirectory(sourcePath));
				//destPath = Path.directory(sourcePath) + "/" + filename + ".sfnf";
				compressionLv = Std.parseInt(args[1]);
				if (compressionLv == null || compressionLv < 0 || compressionLv > 9){
					_error("Compression argument must be a value between 0-9");
				}

			}
		}
		try{
			if (FileSystem.exists(sourcePath))
			{
				var jsonData:String = File.getContent(sourcePath);
			}
			else {
				_error("Source path does not exist");
			}
		}
		catch (e:Dynamic)
		{
			_error(e);
		}

		var jsonData:String = File.getContent(sourcePath);
		var jpTime:Float = Sys.time();
		songObject = Json.parse(jsonData);
		var jDelta:Float = Sys.time() - jpTime;
		
		sfnfData = SFNF.write(songObject);
		if (compressionLv > 0)
		{
			var cpTime:Float = Sys.time();
			var compressed:Bytes = Compress.run(sfnfData, compressionLv);
			var cDelta:Float = Sys.time() - cpTime;
			
			File.saveBytes(destPath, compressed );
			
			var dpTime:Float = Sys.time();
			var uncompressed:Bytes = Uncompress.run(compressed);
			var dDelta:Float = Sys.time() - dpTime;
			
			var rpTime:Float = Sys.time();
			SFNF.read(uncompressed);
			var rDelta:Float = Sys.time() - rpTime;
			Sys.println('Compressed File Size: ${compressed.length} bytes');
			Sys.println('-------- Benchmark --------');
			Sys.println('Binary Score: $rDelta');
			Sys.println('JSON Score: $jDelta');
			Sys.println('Compression(Lv.$compressionLv) Score: $cDelta');
			Sys.println('Decompression Score: $dDelta');
			
			
		}
		else {
			File.saveBytes(destPath, sfnfData);
			
			var rpTime:Float = Sys.time();
			SFNF.read(sfnfData);
			var rDelta:Float = Sys.time() - rpTime;
			Sys.println('Binary score: $rDelta');
			Sys.println('JSON Score: $jDelta');
		}

		Sys.println("Conversion Complete");
	}

	private function _error(error:String):Void
	{
		Sys.println(error);
		Sys.exit(0);
	}

}

