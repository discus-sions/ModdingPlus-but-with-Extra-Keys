package;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import lime.system.System;
import DynamicSprite.DynamicAtlasFrames;
using StringTools;

#if sys
import flash.media.Sound;
import haxe.io.Path;
import lime.media.AudioBuffer;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
#end


class EdtNote extends FlxSprite
{
	public var mustBeUpdated:Bool = false;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var duoMode:Bool = false;
	public var oppMode:Bool = false;
	public var sustainLength:Float = 0;

	public var funnyMode:Bool = false;
	public var noteScore:Float = 1;
	public var altNote:Bool = false;
	public var altNum:Int = 0;
	public var isPixel:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;

	public var rating = "miss";
	public var isLiftNote:Bool = false;
	public var mineNote:Bool = false;
	public var healMultiplier:Float = 1;
	public var damageMultiplier:Float = 1;
	// Whether to always do the same amount of healing for hitting and the same amount of damage for missing notes
	public var consistentHealth:Bool = false;
	// How relatively hard it is to hit the note. Lower numbers are harder, with 0 being literally impossible
	public var timingMultiplier:Float = 1;
	// whether to play the sing animation for hitting this note
	public var shouldBeSung:Bool = true;
	public var ignoreHealthMods:Bool = false;
	public var nukeNote = false;
	public var drainNote = false;

	static var coolCustomGraphics:Array<FlxGraphic> = [];

	
	//ek stuff
	public var burning:Bool = false; //fire
	public var death:Bool = false;    //halo/death
	public var warning:Bool = false; //warning
	public var angel:Bool = false; //angel
	public var alt:Bool = false; //alt animation note
	public var bob:Bool = false; //bob arrow
	public var glitch:Bool = false; //glitch

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;
	public var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
//	public var noteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'orange'];
	//var pixelnoteColors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];

	public var children:Array<Note> = [];
	public var susActive:Bool = true;
	public static var tooMuch:Float = 30;
	public static var mania:Int = 0;
	public var noteYOff:Int = 0;

	public static var noteyOff1:Array<Float> = [4, 0, 0, 0, 0, 0];
	public static var noteyOff2:Array<Float> = [0, 0, 0, 0, 0, 0];
	public static var noteyOff3:Array<Float> = [0, 0, 0, 0, 0, 0];

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var multAlpha:Float = 1;
	public var noteColor:Int;

	public var noteType:Int = 0; //may be adding some custom notetypes soon lol.

	public static var noteScale:Float;
	public static var newNoteScale:Float = 0;
	public static var prevNoteScale:Float = 0.5;
	public static var pixelnoteScale:Float;
	public static var scaleSwitch:Bool = true;
	var frameN:Array<String> = ['purple', 'blue', 'green', 'red']; //moved so they can be used in update

	var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(1 == 1 ? ChartingState._song.speed : 1, 2));
	var alreadyCalculated:Bool = false;

	// altNote can be int or bool. int just determines what alt is played
	// format: [strumTime:Float, noteDirection:Int, sustainLength:Float, altNote:Union<Bool, Int>, isLiftNote:Bool, healMultiplier:Float, damageMultipler:Float, consistentHealth:Bool, timingMultiplier:Float, shouldBeSung:Bool, ignoreHealthMods:Bool, animSuffix:Union<String, Int>]
	public function new(strumTime:Float, noteData:Int, ?LiftNote:Bool = false, ?noteType:Int = 0)
	{
		super();
		// uh oh notedata sussy :flushed:
		swagWidth = 160 * 0.7; //factor not the same as noteScale
		noteScale = 0.7;
		pixelnoteScale = 1;
		mania = 0;

		if (!alreadyCalculated) {
			var options = CoolUtil.parseJson(FNFAssets.getJson('assets/data/options'));
			stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(options.scrollSpeed == 1 ? PlayState.SONG.speed : options.scrollSpeed, 2));
			alreadyCalculated = true;
			trace('generated step');
			}
		if (ChartingState._song.mania == 1)
			{
				swagWidth = 120 * 0.7;
				noteScale = 0.6;
				pixelnoteScale = 0.83;
				mania = 1;
			}
			else if (ChartingState._song.mania == 2)
			{
				swagWidth = 95 * 0.7;
				noteScale = 0.5;
				pixelnoteScale = 0.7;
				mania = 2;
			}
			else if (ChartingState._song.mania == 3)
				{
					swagWidth = 130 * 0.7;
					noteScale = 0.65;
					pixelnoteScale = 0.9;
					mania = 3;
				}
			else if (ChartingState._song.mania == 4)
				{
					swagWidth = 110 * 0.7;
					noteScale = 0.58;
					pixelnoteScale = 0.78;
					mania = 4;
				}
			else if (ChartingState._song.mania == 5)
				{
					swagWidth = 100 * 0.7;
					noteScale = 0.55;
					pixelnoteScale = 0.74;
					mania = 5;
				}
	
			else if (ChartingState._song.mania == 6)
				{
					swagWidth = 200 * 0.7;
					noteScale = 0.7;
					pixelnoteScale = 1;
					mania = 6;
				}
			else if (ChartingState._song.mania == 7)
				{
					swagWidth = 180 * 0.7;
					noteScale = 0.7;
					pixelnoteScale = 1;
					mania = 7;
				}
			else if (ChartingState._song.mania == 8)
				{
					swagWidth = 170 * 0.7;
					noteScale = 0.7;
					pixelnoteScale = 1;
					mania = 8;
				}
		isLiftNote = LiftNote;
		if (isLiftNote)
			shouldBeSung = false;
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		//if (this.strumTime < 0 )
		//	this.strumTime = 0;
		this.strumTime = strumTime;

		this.noteData = noteData % 8;
	//	this.noteData = noteData % 9;
		burning = noteType == 1;
		death = noteType == 2;
		warning = noteType == 3;
		angel = noteType == 4;
		alt = noteType == 5;
		bob = noteType == 6;
		glitch = noteType == 7;
		var sussy:Bool = false;
		if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4)
		{
			mineNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6)
		{
			isLiftNote = true;
		}
		// die : )
		if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8)
		{
			nukeNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10)
		{
			drainNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 10)
		{
			sussy = true;
		}

		// var daStage:String = ChartingState._song.curStage;
		frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png',
			'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
		if (sussy)
		{
			// we need to load a unique instance
			// we only need 1 unique instance per number so we do save the graphics
			var sussyInfo = Math.floor(noteData / (NOTE_AMOUNT * 2)) - 5;
			if (coolCustomGraphics[sussyInfo] == null)
				coolCustomGraphics[sussyInfo] = FlxGraphic.fromAssetKey('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png', true);

			frames = FlxAtlasFrames.fromSparrow(coolCustomGraphics[sussyInfo], 'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
		}
		/*animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');*/
		for (i in 0...9)
		{
			animation.addByPrefix(noteColors[i] + 'Scroll', noteColors[i] + '0'); // Normal notes
			animation.addByPrefix(noteColors[i] + 'hold', noteColors[i] + ' hold piece'); // Hold
			animation.addByPrefix(noteColors[i] + 'holdend', noteColors[i] + ' hold end'); // Tails
		}
		if (isLiftNote || nukeNote || mineNote) {
			var gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png',
			'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
				frames = gotFrames;
		
		if (isLiftNote)
		{
			animation.addByPrefix('greenScroll', 'green lift');
			animation.addByPrefix('redScroll', 'red lift');
			animation.addByPrefix('blueScroll', 'blue lift');
			animation.addByPrefix('purpleScroll', 'purple lift');
		}
		if (nukeNote)
		{
			animation.addByPrefix('greenScroll', 'green nuke');
			animation.addByPrefix('redScroll', 'red nuke');
			animation.addByPrefix('blueScroll', 'blue nuke');
			animation.addByPrefix('purpleScroll', 'purple nuke');
		}
		if (mineNote)
		{
			animation.addByPrefix('greenScroll', 'green mine');
			animation.addByPrefix('redScroll', 'red mine');
			animation.addByPrefix('blueScroll', 'blue mine');
			animation.addByPrefix('purpleScroll', 'purple mine');
		}
	}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		switch (mania)
		{
			case 1: 
				frameN = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];
			case 2: 
				frameN = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
			case 3: 
				frameN = ['purple', 'blue', 'white', 'green', 'red'];
			case 4: 
				frameN = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
			case 5: 
				frameN = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'];
			case 6: 
				frameN = ['white'];
			case 7: 
				frameN = ['purple', 'red'];
			case 8: 
				frameN = ['purple', 'white', 'red'];

		}

		x += swagWidth * noteData;
		animation.play(frameN[noteData] + 'Scroll');
		noteColor = noteData;

		if (noteData >= NOTE_AMOUNT * 10)
		{
			var sussyInfo = Math.floor(noteData / (NOTE_AMOUNT * 2));
			sussyInfo -= 4;
			var text = new FlxText(0, 0, 0, cast sussyInfo, 64);
			stamp(text, Std.int(this.width / 2), 20);
		}
	}
}
