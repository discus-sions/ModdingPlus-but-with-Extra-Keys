package;

import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;

import sys.FileSystem;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;
class RankStar extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var starNum:Int = 0;

	public function new(song:String, diff:Int) {
		super();
		loadGraphic('assets/images/ranks/rank' + Highscore.getFCLevel(song, diff, 'best-fullcombo') + '.png');
		trace(song + diff + ' - ' + Highscore.getFCLevel(song, diff, 'best-fullcombo'));
		setGraphicSize(Std.int(width * 0.4));
		antialiasing = true;
		scrollFactor.set();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + (sprTracker.width - 50) + (width * 0.4 * starNum), sprTracker.y - 25);
	}
}
