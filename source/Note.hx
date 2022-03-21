package;

import DynamicSprite.DynamicAtlasFrames;
import Judgement.TUI;
import openfl.errors.Error;
import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.system.System;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
using StringTools;
enum abstract Direction(Int) from Int to Int {
	var left;
	var down;
	var up;
	var right;

}
/**
 * What NoteiNfo jsons are like. 
 */
typedef NoteInfo = {
	/**
	 * The name of the note that appears in charting state
	 */
	var noteName:String;
	/**
	 * The animation names of the notes. 1-4
	 * left, down, up, right
	 * now even more, mid, left2, down2, up2, right2
	 */
	var animNames:Array<String>;
	/**
	 * Pixel animation thingies. same order as names.
	 */
	var animInt:Array<Int>;
	/**
	 * Amount to heal
	 */
	var ?healAmount:Null<Float>;
	/**
	 * Amount to damange. Is added so should be negative to hurt people!
	 */
	var ?damageAmount:Null<Float>;
	/**
	 * Whether it should be sung. 
	 */
	var ?shouldSing:Null<Bool>;
	/**
	 * Overwritten by healAmount. How much the healing should be multiplied.
	 */
	var ?healMultiplier:Null<Float>;
	/**
	 * Overwritten by damage amount. How much damage should be multiplied by.
	 */
	var ?damageMultiplier:Null<Float>;
	/**
	 * Whether to heal the same amount or hurt the same amount.
	 */
	var ?consistentHealth:Null<Bool>;
	/**
	 * When to stop healing and start hurting. can be
	 * sick
	 * good
	 * bad
	 * shit
	 * wayoff
	 * miss
	 */
	var ?healCutoff:Null<String>;
	/**
	 * How easy it is to hit note. Higher numbers are easier. 0 is literally impossible.
	 */
	var ?timingMultiplier:Null<Float>;
	/**
	 * Whether to ignore health modifiers and use straight numbers. 
	 */
	var ?ignoreHealthMods:Null<Bool>;
	/**
	 * Whether missing the note should add to the combo break counter
	 */
	var ?dontCountNote:Null<Bool>;
	/**
	 * Unused. 
	 */
	var ?dontStrum:Null<Bool>;
	/**
	 * Info about how the opponent sings the note. The opponent _always_ sings this note even if it isn't hit.
	 */
	var ?singInfo:Null<SingInfo>;
	/**
	 * An array of string that can be checked for.
	 */
	var ?classes:Null<Array<String>>;
	/**
	 * A unique string that can be checked for. 
	 */
	var ?id:Null<String>;
	/**
	 * The function for when a note is hit
	 */
	var ?noteHit:Null<String>;
		/**
	 * The function for when a note is missed
	 */
	var ?noteMiss:Null<String>;
	/**
	 * The function for when a note is at the strumline
	 */
	var ?noteStrum:Null<String>;
	/**
	 * Custom note path for if your note isn't in the selected note path
	 */
	var ?customNotePath:Null<String>;
}
/**
 * Used to make opponent sing.
 */
typedef SingInfo = {
	/**
	 * Direction of singing. 0-3 left, down, up, right
	 */
	var direction:Int;
	/**
	 * Alt note. 0 is no alt. 
	 */
	var ?alt:Null<Int>;
	/**
	 * Whether to miss or not. 
	 */
	var ?miss:Null<Bool>;
}
// sinful dynamic sprite
class Note extends DynamicSprite
{
	public var strumTime:Float = 0;
	public static var getFrames:Bool = true;
	static var gotFrames:FlxAtlasFrames = null;
	public static var getSpecialFrames:Bool = true;
	static var specialFramesKey:Array<String> = [];
	static var gotSpecialFrames:Array<FlxAtlasFrames> = [];
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var duoMode:Bool = false;
	public var oppMode:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var modifiedByLua:Bool = false;
	public var funnyMode:Bool = false;
	public var noteScore:Float = 1;
	public var altNote:Bool = false;
	public var altNum:Int = 0;
	public var isPixel:Bool = false;
	public static var swagWidth:Float;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;
	public static var specialNoteJson:Null<Array<NoteInfo>>;
	public var damageAmount:Null<Float> = null;
	public var healAmount:Null<Float> = null;
	// pwease freeplay state don't edit me i already have special info :grief: :grief:
	public var dontEdit:Bool = false;
	public var rating = "miss";
	public var isLiftNote:Bool = false;
	public var mineNote:Bool = false;
	// like expurgation's notes; insta die lmao
	public var nukeNote:Bool = false;
	// tabi mod
	public var drainNote:Bool =  false;
	public var healMultiplier:Float = 1;
	public var damageMultiplier:Float = 1;
	// Whether to always do the same amount of healing for hitting and the same amount of damage for missing notes
	public var consistentHealth:Bool = false;
	// How relatively hard it is to hit the note. Lower numbers are harder, with 0 being literally impossible
	public var timingMultiplier:Float = 1;
	// whether to play the sing animation for hitting this note
	public var shouldBeSung:Bool = true;
	public var ignoreHealthMods:Bool = false;
	public var healCutoff:Null<String>;
	var specialNoteInfo:NoteInfo;
	public var dontCountNote = false;
	public var dontStrum = false;
	public var noteHit:Null<String> = null;
	public var noteMiss:Null<String> = null;
	public var noteStrum:Null<String> = null;
	public var oppntAnim:Null<String> = null;
	public var classes:Null<Array<String>> = [];
	public var coolId:Null<String> = null;
	public var oppntSing:Null<SingInfo>;
	public var customNotePath:Null<String> = null;

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

	var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(1 == 1 ? PlayState.SONG.speed : 1, 2));
	//what is this variable
	var alreadyCalculated:Bool = false;

	// altNote can be int or bool. int just determines what alt is played
	// format: [strumTime:Float, noteDirection:Int, sustainLength:Float, altNote:Union<Bool, Int>, isLiftNote:Bool, healMultiplier:Float, damageMultipler:Float, consistentHealth:Bool, timingMultiplier:Float, shouldBeSung:Bool, ignoreHealthMods:Bool, animSuffix:Union<String, Int>]
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:Int = 0, ?customImage:Null<BitmapData>, ?customXml:Null<String>, ?customEnds:Null<BitmapData>, ?LiftNote:Bool=false, ?animSuffix:String, ?numSuffix:Int)
	{
		super(42);
		if (!alreadyCalculated) {
		var options = CoolUtil.parseJson(FNFAssets.getJson('assets/data/options'));
		stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(options.scrollSpeed == 1 ? PlayState.SONG.speed : options.scrollSpeed, 2));
		alreadyCalculated = true;
		trace('generated step');
		}
		swagWidth = 160 * 0.7; //factor not the same as noteScale
		noteScale = 0.7;
		pixelnoteScale = 1;
		mania = 0;
		if (PlayState.SONG.mania == 1)
		{
			swagWidth = 120 * 0.7;
			noteScale = 0.6;
			pixelnoteScale = 0.83;
			mania = 1;
		}
		else if (PlayState.SONG.mania == 2)
		{
			swagWidth = 95 * 0.7;
			noteScale = 0.5;
			pixelnoteScale = 0.7;
			mania = 2;
		}
		else if (PlayState.SONG.mania == 3)
			{
				swagWidth = 130 * 0.7;
				noteScale = 0.65;
				pixelnoteScale = 0.9;
				mania = 3;
			}
		else if (PlayState.SONG.mania == 4)
			{
				swagWidth = 110 * 0.7;
				noteScale = 0.58;
				pixelnoteScale = 0.78;
				mania = 4;
			}
		else if (PlayState.SONG.mania == 5)
			{
				swagWidth = 100 * 0.7;
				noteScale = 0.55;
				pixelnoteScale = 0.74;
				mania = 5;
			}

		else if (PlayState.SONG.mania == 6)
			{
				swagWidth = 200 * 0.7;
				noteScale = 0.7;
				pixelnoteScale = 1;
				mania = 6;
			}
		else if (PlayState.SONG.mania == 7)
			{
				swagWidth = 180 * 0.7;
				noteScale = 0.7;
				pixelnoteScale = 1;
				mania = 7;
			}
		else if (PlayState.SONG.mania == 8)
			{
				swagWidth = 170 * 0.7;
				noteScale = 0.7;
				pixelnoteScale = 1;
				mania = 8;
			}

		// uh oh notedata sussy :flushed:
		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.noteType = noteType;
		isSustainNote = sustainNote;
		isLiftNote = LiftNote;
		
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (this.strumTime < 0 )
			this.strumTime = 0;
		this.strumTime = strumTime;

		//this.noteData = noteData % 9;
		burning = noteType == 1;
		death = noteType == 2;
		warning = noteType == 3;
		angel = noteType == 4;
		alt = noteType == 5;
		bob = noteType == 6;
		glitch = noteType == 7;

		this.noteData = noteData % NOTE_AMOUNT;
		// overloading : )
		if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4) {
			mineNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6) {
			isLiftNote = true;
		}
		// die : )
		if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8) {
			nukeNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10) {
			drainNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 10 && specialNoteJson != null) {
			// special note...
			// get the note thingie
			var sussyNoteThing = Math.floor(noteData/ (NOTE_AMOUNT * 2));
			// there are already 4 thingies and the thing is index 0 
			sussyNoteThing -= 5;
			var thingie = specialNoteJson[sussyNoteThing];
			dontEdit = true;
			if (thingie.damageAmount != null) {
				damageAmount = thingie.damageAmount;
			} else if (thingie.damageMultiplier != null) {
				damageMultiplier = thingie.damageMultiplier;
			}
			if (thingie.healAmount != null) {
				healAmount = thingie.healAmount;
			} else if (thingie.healMultiplier != null) {
				healMultiplier = thingie.healMultiplier;
			}
			
			if (thingie.shouldSing != null) {
				shouldBeSung = thingie.shouldSing;
			}

			if (thingie.consistentHealth != null) {
				consistentHealth = thingie.consistentHealth;
			}
			if (healAmount < 0 || healMultiplier < 0) {
				dontCountNote = true;
			}
			if (thingie.dontCountNote != null)
				dontCountNote = thingie.dontCountNote;
			if (thingie.healCutoff != null) {
				healCutoff = thingie.healCutoff;
			}
			if (thingie.timingMultiplier != null) {
				timingMultiplier = thingie.timingMultiplier;
			} 
			if (thingie.dontStrum != null) {
				dontStrum = thingie.dontStrum;
			}
			if (thingie.noteHit != null) {
				noteHit = thingie.noteHit;
			}
			if (thingie.noteMiss != null) {
				noteMiss = thingie.noteMiss;
			}
			if (thingie.noteStrum != null) {
				noteStrum = thingie.noteStrum;
			}
			if (thingie.classes != null) {
				classes = thingie.classes;
			}
			if (thingie.id != null) {
				coolId = thingie.id;
			}
			if (thingie.singInfo != null) {
				oppntSing = thingie.singInfo;
				if (oppntSing.alt == null) {
					oppntSing.alt = 0;
				}
				if (oppntSing.miss == null)
					oppntSing.miss = false;
			}
			if (thingie.customNotePath != null) {
				customNotePath = thingie.customNotePath;
			}
			specialNoteInfo = thingie;
			ignoreHealthMods = cast thingie.ignoreHealthMods;
		}
		if (mineNote || nukeNote) {
			shouldBeSung = false;
			dontCountNote = true;
			dontStrum = true;
		}
		if (isLiftNote) {
			shouldBeSung = false;
			// dontStrum = true;
		}
		var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
		// var daStage:String = PlayState.curStage;
		if (!curUiType.isPixel) {	
			if (customNotePath != null) {
				if (getSpecialFrames) {
					getSpecialFrames = false;
					specialFramesKey = [];
					gotSpecialFrames = [];
				}
				var funnyNum = specialFramesKey.indexOf(customNotePath);
				if (funnyNum == -1) {
					var daFrames = DynamicAtlasFrames.fromSparrow(customNotePath + '.png', customNotePath + '.xml');
					specialFramesKey.push(customNotePath);
					gotSpecialFrames.push(daFrames);
					funnyNum = specialFramesKey.length - 1;
				}
				frames = gotSpecialFrames[funnyNum];
			} else {
				if (getFrames) {
					getFrames = false;
					gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
						+ curUiType.uses
						+ "/NOTE_assets.png",
						'assets/images/custom_ui/ui_packs/'
						+ curUiType.uses
						+ "/NOTE_assets.xml");
				}
				frames = gotFrames;
			}
			if (animSuffix == null) {
				animSuffix = '';
			} else {
				animSuffix = ' ' + animSuffix;
			}
			/*animation.addByPrefix('greenScroll', 'green${animSuffix}0');
			animation.addByPrefix('redScroll', 'red${animSuffix}0');
			animation.addByPrefix('blueScroll', 'blue${animSuffix}0');
			animation.addByPrefix('purpleScroll', 'purple${animSuffix}0');

			animation.addByPrefix('purpleholdend', 'pruple end hold${animSuffix}');
			animation.addByPrefix('greenholdend', 'green hold end${animSuffix}');
			animation.addByPrefix('redholdend', 'red hold end${animSuffix}');
			animation.addByPrefix('blueholdend', 'blue hold end${animSuffix}');

			animation.addByPrefix('purplehold', 'purple hold piece${animSuffix}');
			animation.addByPrefix('greenhold', 'green hold piece${animSuffix}');
			animation.addByPrefix('redhold', 'red hold piece${animSuffix}');
			animation.addByPrefix('bluehold', 'blue hold piece${animSuffix}');*/
			//frames = Paths.getSparrowAtlas('noteassets/NOTE_assets');
			for (i in 0...9)
			{
				animation.addByPrefix(noteColors[i] + 'Scroll', noteColors[i] + '0'); // Normal notes
				animation.addByPrefix(noteColors[i] + 'hold', noteColors[i] + ' hold piece'); // Hold
				animation.addByPrefix(noteColors[i] + 'holdend', noteColors[i] + ' hold end'); // Tails
			}
			
			if (isLiftNote) {
				var gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.png",
				'assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.xml");
				frames = gotFrames;
				animation.addByPrefix('greenScroll', 'green lift${animSuffix}');
				animation.addByPrefix('redScroll', 'red lift${animSuffix}');
				animation.addByPrefix('blueScroll', 'blue lift${animSuffix}');
				animation.addByPrefix('purpleScroll', 'purple lift${animSuffix}');
			}
			if (nukeNote) {
				var gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.png",
				'assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.xml");
				frames = gotFrames;
				animation.addByPrefix('greenScroll', 'green nuke${animSuffix}');
				animation.addByPrefix('redScroll', 'red nuke${animSuffix}');
				animation.addByPrefix('blueScroll', 'blue nuke${animSuffix}');
				animation.addByPrefix('purpleScroll', 'purple nuke${animSuffix}');
			}
			
			if (mineNote) {
				var gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.png",
				'assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.xml");
				frames = gotFrames;
				animation.addByPrefix('greenScroll', 'green mine${animSuffix}');
				animation.addByPrefix('redScroll', 'red mine${animSuffix}');
				animation.addByPrefix('blueScroll', 'blue mine${animSuffix}');
				animation.addByPrefix('purpleScroll', 'purple mine${animSuffix}');
			}
			if (dontEdit) {
				var gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.png",
				'assets/images/custom_ui/ui_packs/'
				+ curUiType.uses
				+ "/NOTE_assets_more.xml");
				frames = gotFrames;
				animation.addByPrefix('greenScroll', specialNoteInfo.animNames[2]);
				animation.addByPrefix('redScroll', specialNoteInfo.animNames[3]);
				animation.addByPrefix('purpleScroll', specialNoteInfo.animNames[0]);
				animation.addByPrefix('blueScroll', specialNoteInfo.animNames[1]);

			}
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
			// when arrowsEnds != arrowEnds :laughing_crying:
		}
		else
		{
			isPixel = true;
			if (customNotePath != null)
				loadGraphic(customNotePath + '.png', true, 17, 17);
			else
				loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png", true, 17, 17);

			if (animSuffix != null && numSuffix == null) {
				numSuffix = Std.parseInt(animSuffix);
			}
			if (numSuffix != null) {
				loadGraphic(Paths.image('custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png"), true, 17, 17);
				if (isSustainNote && noteType == 0)
					loadGraphic(Paths.image('custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png"), true, 7, 6);

				for (i in 0...9)
				{
					animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
					animation.add(noteColors[i] + 'hold', [i]); // Holds
					animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
				}
			} else {
				loadGraphic(Paths.image('custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png"), true, 17, 17);
				if (isSustainNote && noteType == 0)
					loadGraphic(Paths.image('custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png"), true, 7, 6);

				for (i in 0...9)
				{
					animation.add(noteColors[i] + 'Scroll', [i + 9]); // Normal notes
					animation.add(noteColors[i] + 'hold', [i]); // Holds
					animation.add(noteColors[i] + 'holdend', [i + 9]); // Tails
				}
				
				if (isLiftNote) {
					loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels_more.png", true, 17, 17);
					animation.add('greenScroll', [22]);
					animation.add('redScroll', [23]);
					animation.add('blueScroll', [21]);
					animation.add('purpleScroll', [20]);
				}
				if (mineNote) {
					loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels_more.png", true, 17, 17);
					animation.add('greenScroll', [26]);
					animation.add('redScroll', [27]);
					animation.add('blueScroll', [25]);
					animation.add('purpleScroll', [24]);
				}
				if (nukeNote) {
					loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels_more.png", true, 17, 17);
					animation.add('greenScroll', [30]);
					animation.add('redScroll', [31]);
					animation.add('blueScroll', [29]);
					animation.add('purpleScroll', [28]);
				}
			}
			if (dontEdit) {
				loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels_more.png", true, 17, 17);
				animation.add('greenScroll', [specialNoteInfo.animInt[2]]);
				animation.add('redScroll', [specialNoteInfo.animInt[3]]);
				animation.add('purpleScroll', [specialNoteInfo.animInt[0]]);
				animation.add('blueScroll', [specialNoteInfo.animInt[1]]);
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
		}

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
		// trace(prevNote);
		if (isSustainNote && OptionsHandler.options.downscroll) {
			flipY = true;
		}
		if (isSustainNote && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData % NOTE_AMOUNT) {
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (isPixel)
				x += 30;

			if (prevNote.isSustainNote) {
				// DO mod it because we DIDN'T do that
				animation.play(frameN[noteData] + 'holdend');

				//prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				//prevNote.updateHitbox();
				prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOff = Math.round(-offset.y);

				// prevNote.setGraphicSize();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		// if we are player one and it's bf's note or we are duo mode or we are player two and it's p2's note
		// and it isn't demo mode
		if ((((mustPress && !oppMode) || duoMode) || (oppMode && !mustPress)) && !funnyMode) {
			var signedDiff = Conductor.songPosition - strumTime;
			// ok.... so if strumTime is bigger than songPosition that means it is waiting to be hit because well the song hasn't reached it???
			// negative is early, positive is late
			var noteDiff = Math.abs(signedDiff);
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			if (noteDiff < Judge.wayoffJudge * timingMultiplier) {
				canBeHit = true;
			} else
				canBeHit = false;
			// Nuke notes can only be hit with a bad or better because nuke notes are weird champ
			if (nukeNote && !(noteDiff < Judge.badJudge * timingMultiplier)) {
				canBeHit = false;
			}
			if (mineNote && !(noteDiff < Judge.shitJudge * timingMultiplier)) {
				canBeHit = false;
			}
			if (signedDiff > Judge.wayoffJudge)
				tooLate = true;
			if (nukeNote && signedDiff > Judge.badJudge) {
				tooLate = true;
			}
			if (mineNote && signedDiff > Judge.shitJudge) {
				tooLate = true;
			}
		} else {
			if (!dontStrum) {
				canBeHit = false;

				if (strumTime <= Conductor.songPosition) {
					wasGoodHit = true;
				}
			}
			
		}

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
	// inline because it's 1 fucking line dumbass
	public inline function daStrumTime():Float {
		return strumTime + OptionsHandler.options.offset;
	}
	public static inline function getTrueStrumTime(strumTime:Float):Float {
		return strumTime + OptionsHandler.options.offset;
	}
	public function getHealth(rating:String):Float {
		if (mineNote) {
			if (rating != 'miss') {
				return -0.45;
			} else {
				return 0;
			}
		}
		if (nukeNote) {
			if (rating != 'miss')
				return -69;
			else
				return 0;
		}
		if (consistentHealth)
		{
			var ouchie = false;
			switch (healCutoff)
			{
				case 'shit':
					ouchie = rating == 'shit' || rating == 'wayoff' || rating == 'miss';
				case 'wayoff':
					ouchie = rating == 'wayoff' || rating == 'miss';
				case 'miss':
					ouchie = rating == 'miss';
				case 'bad' | null:
					ouchie = rating == 'shit' || rating == 'wayoff' || rating == 'bad' || rating == 'miss';
				case 'good':
					ouchie = rating == 'shit' || rating == 'wayoff' || rating == 'bad' || rating == 'miss' || rating == 'good';
				case 'sick':
					ouchie = true;
				case 'none':
					ouchie = false;
			}
			if (ouchie)
			{
				if (damageAmount != null)
				{
					return damageAmount * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
				else
				{
					return damageMultiplier * -0.04 * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
			}
			else
			{
				if (healAmount != null)
				{
					return healAmount * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier);
				}
				else
				{
					return healMultiplier * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier) * 0.04;
				}
			}
		} else {
			var healies = 0.0;
			var shitHeal = OptionsHandler.options.useKadeHealth ? 0.2 : 0.06;
			var badHeal = OptionsHandler.options.useKadeHealth ? 0.06 : 0.03;
			var goodHeal = OptionsHandler.options.useKadeHealth ? 0.04  : 0.03;
			var missHeal = 0.04;
			var sickHeal = OptionsHandler.options.useKadeHealth ? 0.1 : 0.07;
			switch (healCutoff) {
				case "shit":
					switch (rating) {
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "bad" | null: 
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = -badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "good": 
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = -badHeal;
						case "good":
							healies = -goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "wayoff":
					switch (rating)
					{
						case "shit":
							healies = shitHeal;
						case 'wayoff': 
							healies = -shitHeal;
						case "bad":
							healies = badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "miss":
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = shitHeal;
						case "bad":
							healies = badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}

				case "sick":
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = -badHeal;
						case "good":
							healies = -goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = -sickHeal;
					}
			}
			if (healies > 0) {
				// this was pointless then :grief:
				if (healAmount != null) {
					return healAmount * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier);
				} else {
					return healMultiplier * healies * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier);

				}

			} else {
				if (damageAmount != null)
				{
					return damageAmount * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
				else
				{
					return damageMultiplier * healies * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
			}
		}
		
		
	}
}
