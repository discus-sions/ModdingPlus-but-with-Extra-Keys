package;

#if web
import js.lib.intl.RelativeTimeFormat.RelativeTimeUnit;
#end
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.Lib;
import flixel.util.typeLimit.OneOfTwo;
import Character.EpicLevel;
import flixel.ui.FlxButton.FlxTypedButton;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.FlxGame;
import flixel.FlxObject;
#if desktop
import Sys;
import sys.FileSystem;
#end
#if cpp
import Discord.DiscordClient;
#end
import DifficultyIcons;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSubState;
import flash.display.BitmapData;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import lime.system.System;
import openfl.media.Sound;
import flixel.group.FlxGroup;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;

#end
import tjson.TJSON;
import Judgement.TUI;
import lime.app.Application;

//leather_engine

import NoteSplash;
import twelvekey.TwelveKeyStrum;
import twelvekey.LeatherUtils;
import twelvekey.NoteVariables;
import twelvekey.NoteHandler;
import flixel.graphics.frames.FlxFramesCollection;
//import twelvekey.LeatherSplash;

//anti-skip
import flash.system.System;

// work-around for "controls has no field L1"
import flixel.input.FlxInput.FlxInputState;

using StringTools;
using CoolUtil.FlxTools;
typedef LuaAnim = {
	var prefix : String;
	@:optional var indices: Array<Int>;
	var name : String;
	@:optional var fps : Int;
	@:optional var loop : Bool;
}
enum abstract DisplayLayer(Int) from Int to Int {
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}

class Ana
{
	public var hitTime:Float;
	public var nearestNote:Array<Dynamic>;
	public var hit:Bool;
	public var hitJudge:String;
	public var key:Int;
	public function new(_hitTime:Float,_nearestNote:Array<Dynamic>,_hit:Bool,_hitJudge:String, _key:Int) {
		hitTime = _hitTime;
		nearestNote = _nearestNote;
		hit = _hit;
		hitJudge = _hitJudge;
		key = _key;
	}
}

class Analysis
{
	public var anaArray:Array<Ana>;

	public function new() {
		anaArray = [];
	}
}

class PlayState extends MusicBeatState
{
	#if windows
	public static var customPrecence = FNFAssets.getText("assets/discord/presence/play.txt");
	#end
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var defaultPlaylistLength = 0;
	public static var campaignScoreDef = 0;
	public static var mania:Int = 0;
	public static var maniaToChange:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	public static var ss:Bool = true;
	private var vocals:FlxSound;
	// use old bf
	private var oldMode:Bool = false;
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	var grace:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;
	var totalNotesHit:Float = 0;
	var totalPlayed:Int =0;
	var totalNotesHitDefault:Float = 0;
	public var camFollow:FlxObject;
	private var player1Icon:String;
	private var player2Icon:String;
	public static var prevCamFollow:FlxObject;
	public static var misses:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	public static var sicks:Int = 0;
	public var songPosBar:FlxBar;
	public var songPosBG:FlxSprite;
	public var songPositionBar:Float = 0;
	var songLength:Float = 0.0;
	var songScoreDef:Int = 0;
	var nps:Int = 0;
	var currentTimingShown:FlxText;
	var playingAsRpc:String = "";
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;
	private var playerComboBreak:FlxTypedGroup<FlxSprite>;
	private var enemyComboBreak:FlxTypedGroup<FlxSprite>;
	public var shitBreakColor:FlxColor = 0xFF175DB3;
	public var wayoffBreakColor:FlxColor = 0xFFAF0000;
	public var missBreakColor:FlxColor = 0xFFDD0A93;
	
	private var camZooming:Bool = false;
	private var scriptableCamera:String = 'false';
	var scriptCamPos:Array<Float> = [0, 0, 0, 0];
	private var curSong:String = "";
	private var strumming2:Array<Bool> = [false, false, false, false];
	private var strumming1:Array<Bool> = [false,false,false,false];

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	private var combo:Int = 0;
	private var daScrollSpeed:Float = 1;
	public static var duoMode:Bool = false;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	//private var enemyColor:FlxColor = 0xFFFF0000;
	//private var opponentColor:FlxColor = 0xFFBC47FF;
	// private var playerColor:FlxColor = 0xFF66FF33;
	// private var poisonColor:FlxColor = 0xFFA22CD1;
	// private var poisonColorEnemy:FlxColor = 0xFFEA2FFF;
	// private var bfColor:FlxColor = 0xFF149DFF;
	private var barShowingPoison:Bool = false;
	private var pixelUI:Bool = false;
	#if (windows && cpp)
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	/**
	 * Icon of player one
	 */
	public var iconP1:HealthIcon;
	/**
	 * Icon of player two
	 */
	public var iconP2:HealthIcon;
	/**
	 * HUD Camera (arrows, health)
	 */
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public var doof:DialogueBox;

	public static var arrowSliced:Array<Bool> = [false, false, false, false, false, false, false, false, false]; //leak :)

	var talking:Bool = true;
	var songScore:Int = 0;
	var trueScore:Int = 0;
	var scoreTxt:FlxText;
	var healthTxt:FlxText;
	var accuracyTxt:FlxText;
	var difficTxt:FlxText;
	// hehe fuck around with these lamo
	public static var oldx:Float;
	public static var oldy:Float;
	/**
	 * The total score of the week. Not a good idea to touch
	 * as it is a total and not divided until the end.
	 */
	public static var campaignScore:Int = 0;
	/**
	 * Total Accuracy of the week. Not a good idea to touch as it is a total. 
	 */
	public static var campaignAccuracy:Float = 0;
	public var defaultCamZoom:Float = 1.05;
	public var disableScoreChange:Bool = false;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	/**
	 * How big pixel assets are stretched
	 */
	public static var daPixelZoom:Float = 6;

	var bfoffset = [0.0, 0.0];
	var gfoffset = [0.0, 0.0];
	var dadoffset = [0.0, 0.0];
	var swapOffsets = [770.0, 450.0, 400.0, 130.0, 100.0, 100.0];
	var dadcam = [0, 0];
	var bfcam = [0, 0];
	var inCutscene:Bool = false;
	var alwaysDoCutscenes = false;
	var fullComboMode:Bool = false;
	var perfectMode:Bool = false;
	var practiceMode:Bool = false;
	public static var healthLossMultiplier:Float = 1;
	public static var healthGainMultiplier:Float = 1;
	var poisonExr:Bool = false;
	var poisonPlus:Bool = false;
	var beingPoisioned:Bool = false;
	var poisonTimes:Int = 0;
	var flippedNotes:Bool = false;
	var noteSpeed:Float = 0.45;
	var practiceDied:Bool = false;
	var practiceDieIcon:HealthIcon;
	private var regenTimer:FlxTimer;
	var sickFastTimer:FlxTimer;
	var accelNotes:Bool = false;
	var notesHit:Float = 0;
	var notesPassing:Int = 0;
	var vnshNotes:Bool = false;
	var invsNotes:Bool = false;
	var snakeNotes:Bool = false;
	var snekNumber:Float = 0;
	var drunkNotes:Bool = false;
	var alcholTimer:FlxTimer;
	var notesHitArray:Array<Date> = [];
	var alcholNumber:Float = 0;
	var inALoop:Bool = false;
	var useVictoryScreen:Bool = true;
	var demoMode:Bool = false;
	var downscroll:Bool = false;
	var luaRegistered:Bool = false;
	var currentFrames:Int = 0;
	var supLove:Bool = false;
	var loveMultiplier:Float = 0;
	var poisonMultiplier:Float = 0;
	var goodCombo:Bool = false;
	public var player1GoodHitSignal:Signal<Note>;
	public var player2GoodHitSignal:Signal<Note>;
	private var judgementList:Array<String> = [];
	private var preferredJudgement:String = '';
	/**
	 * If we are playing as opponent. 
	 */
	public static var opponentPlayer:Bool = false;
	/**
	 *  How much health is drained/regened with Supportive love 
	 * or Poison Fright
	 */
	 @:deprecated("REPLACED BY MODIFIER NUMBERS")
	public var drainBy:Float = 0.005;
	/**
	 * Auto update note x pos to be under their correct strumline pos. 
	 * 
	 */
	public var snapToStrumline:Bool = true;
	var oldStrumlineX:Float = 0;
	// this is just so i can collapse it lol
	#if true
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			trace("Function doesn't exist, silently skipping...");
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
		}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function getHaxeActor(name:String):Dynamic {
		switch (name) {
			case "boyfriend" | "bf":
				return boyfriend;
			case "girlfriend" | "gf":
				return gf;
			case "dad":
				return dad;
			default:
				return strumLineNotes.members[Std.parseInt(name)];
		}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("BEHIND_GF", BEHIND_GF);
		interp.variables.set("BEHIND_BF", BEHIND_BF);
		interp.variables.set("BEHIND_DAD", BEHIND_DAD);
		interp.variables.set("BEHIND_ALL", BEHIND_ALL);
		interp.variables.set("BEHIND_NONE", 0);
		interp.variables.set("switchCharacter", switchCharacter);
		interp.variables.set("difficulty", storyDifficulty);
		interp.variables.set("bpm", Conductor.bpm);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("scrollSpeed", daScrollSpeed);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("camHUD", camHUD);
		
		interp.variables.set("setPresence", function (to:String) {
			#if (windows && cpp)
			customPrecence = to;
			updatePrecence();
			#else 
			FlxG.log.warn("Ignoring hscript setPresence as we aren't on windows");
			#end
		});
		
		interp.variables.set("showOnlyStrums", false);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("mustHit", false);
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("startShader", function (shader:String) { 
			return (new ShaderHandler(shader)); // wigglestuff
		});
		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("gf", gf);
		interp.variables.set("dad", dad);
		interp.variables.set("vocals", vocals);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);
		interp.variables.set("health", health);
		interp.variables.set("healthChange", healthChange);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("paused", paused);
		interp.variables.set("window", Lib.application.window);
		// give them access to save data, everything will be fine ;)
		interp.variables.set("isInCutscene", function () return inCutscene);
		trace("set vars");
		interp.variables.set("camZooming", false);
		interp.variables.set("scriptableCamera", 'false');
		interp.variables.set("scriptCamPos", scriptCamPos);
		// callbacks
		interp.variables.set("start", function (song) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerOneMiss", function() {});
		interp.variables.set("playerOneSing", function() { });
		interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {});
		interp.variables.set("addSprite", function (sprite, position) {
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_GF != 0)
				remove(gf);
			if (position & BEHIND_DAD != 0)
				remove(dad);
			if (position & BEHIND_BF != 0)
				remove(boyfriend);
			add(sprite);
			if (position & BEHIND_GF != 0)
				add(gf);
			if (position & BEHIND_DAD != 0)
				add(dad);
			if (position & BEHIND_BF != 0)
				add(boyfriend); 
		});
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("setDefaultZoom", function(zoom:Float){
			defaultCamZoom = zoom;
			FlxG.camera.zoom = zoom;
		});
		interp.variables.set("removeSprite", function(sprite) {
			remove(sprite);
		});
		interp.variables.set("getHaxeActor", getHaxeActor);
		interp.variables.set("instancePluginClass", instanceExClass);
		interp.variables.set("scaleChar", function (char:String, amount:Float) {
			switch(char) {
				case 'boyfriend':
					remove(boyfriend);
					boyfriend.setGraphicSize(Std.int(boyfriend.width * amount));
					boyfriend.y *= amount;
					add(boyfriend);
				case 'dad':
					remove(dad);
					dad.setGraphicSize(Std.int(dad.width * amount));
					dad.y *= amount;
					add(dad);
				case 'gf':
					remove(gf);
					gf.setGraphicSize(Std.int(gf.width * amount));
					gf.y *= amount;
					add(gf);
			}
		});
		/*interp.variables.set("swapChar", function (charState:String, charTo:String) {
			switch(charState) {
				case 'boyfriend':
					var sussyBoyfriend = new Character(770, 450, charTo, true);
					var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
					camPos.x += sussyBoyfriend.camOffsetX;
					camPos.y += sussyBoyfriend.camOffsetY;
					sussyBoyfriend.x += sussyBoyfriend.playerOffsetX;
					sussyBoyfriend.y += sussyBoyfriend.playerOffsetY;
					if (sussyBoyfriend.likeGf) {
						sussyBoyfriend.setPosition(gf.x, gf.y);
						gf.visible = false;
						if (isStoryMode)
						{
							camPos.x += 600;
							tweenCamIn();
						}
					} else if (!dad.likeGf) {
						gf.visible = true;
					}
					sussyBoyfriend.x += bfoffset[0];
					sussyBoyfriend.y += bfoffset[1];
					iconP1.switchAnim(charTo);
					replace(boyfriend,sussyBoyfriend);
					boyfriend = sussyBoyfriend;
					
				case 'dad':
					
					var susdad = new Character(100, 100, charTo);
					var camPos = new FlxPoint(susdad.getGraphicMidpoint().x, susdad.getGraphicMidpoint().y);
					susdad.x += susdad.enemyOffsetX;
					susdad.y += susdad.enemyOffsetY;
					camPos.x += susdad.camOffsetX;
					camPos.y += susdad.camOffsetY;
					if (susdad.likeGf) {
						susdad.setPosition(gf.x, gf.y);
						gf.visible = false;
						if (isStoryMode)
						{
							camPos.x += 600;
							tweenCamIn();
						}
					} else if (!boyfriend.likeGf) {
						gf.visible = true;
					}
					susdad.x += dadoffset[0];
					susdad.y += dadoffset[1];
					iconP2.switchAnim(charTo);
					replace(dad, susdad);
					dad = susdad;
					// Layering nonsense
				case 'gf':

					var sussygf = new Character(400, 130, charTo);
					sussygf.scrollFactor.set(0.95, 0.95);
					sussygf.x += gfoffset[0];
					sussygf.y += gfoffset[1];
					replace(gf, sussygf);
					gf = sussygf;
			}
		});*/

		//no sus here
		interp.variables.set("addCharacter", addCharacter);
		interp.variables.set('switchToChar', switchToChar);
		interp.variables.set("switchCharacter", switchCharacter);
		interp.variables.set("swapOffsets", swapOffsets);

		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
	}
	function makeHaxeStateUI(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getText(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("difficulty", storyDifficulty);
	    interp.variables.set("Math", Math);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("duoMode", duoMode);
		interp.variables.set("opponentPlayer", opponentPlayer);
		interp.variables.set("demoMode", demoMode);
		interp.variables.set("disableScoreChange", function(funny:Bool) {disableScoreChange = funny;});
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("downscroll", downscroll);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("changeNoteType", function(player, type, trans) {
			generateStaticArrows(player, type, trans);
		});
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("health", health);
		interp.variables.set("scoreTxt", scoreTxt);
		interp.variables.set("difficTxt", difficTxt);
		interp.variables.set('useSongBar', useSongBar);
		interp.variables.set("songPosBG", songPosBG);
		interp.variables.set("songPosBar", songPosBar);
		interp.variables.set("songName", songName);
		interp.variables.set("NewBar", function (daX:Float, daY:Float, width:Int, height:Int, min:Float, max:Float, barColor:Bool = true) {
			var daBar = new FlxBar(daX, daY, LEFT_TO_RIGHT, width, height, this, 'songPositionBar', min, max);
			if (barColor) {
				var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
				if (duoMode)
					leftSideFill = dad.opponentColor;
				var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
				if (duoMode)
					rightSideFill = boyfriend.bfColor;
				daBar.createFilledBar(leftSideFill, rightSideFill);
			} else
				daBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			return daBar;
		});
		interp.variables.set("healthBar", healthBar);
		interp.variables.set("healthBarBG", healthBarBG);
		//interp.variables.set("currentTimingShown", currentTimingShown);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);

		//funny numbers (how do I make them read only????????)
		interp.variables.set("songScore", songScore);
		interp.variables.set("songScoreDef", songScoreDef);
		interp.variables.set("nps", nps);
		interp.variables.set("accuracy", accuracy);
		interp.variables.set("combo", combo);

		interp.variables.set("start", function (song) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerOneMiss", function() {});
		interp.variables.set("playerOneSing", function() {});
		interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {}); //this doesn't work :(
		interp.variables.set("addSprite", function (sprite) {add(sprite);});
		interp.variables.set("removeSprite", function(sprite) {remove(sprite);});
		interp.variables.set("replaceSprite", function(sprite, replaced) {replace(sprite, replaced);});
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("HelperFunctions", HelperFunctions);
		interp.variables.set("instancePluginClass", instanceExClass);
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
		
	}

	function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return exInterp.createScriptClassInstance(classname, args);
	}
	function makeHaxeExState(usehaxe:String, path:String, filename:String)
	{
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseModule(FNFAssets.getHscript(path + filename));
		trace("set stuff");
		exInterp.registerModule(program);

		trace('executed');
	}
	#end
	var useCustomInput:Bool = false;
	var showMisses:Bool = false;
	var nightcoreMode:Bool = false;
	var daycoreMode:Bool = false;
	var useSongBar:Bool = true;
	var useTimings:Bool = true;
	var useNoteSplashes:Bool = true;
	var camNotes:Bool = false;
	var songName:FlxText;
	var uiSmelly:TUI;

	//random ek helper stuff
	private var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var bfsDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var replacableTypeList:Array<Int> = [3,4,7]; //note types do wanna hit
	var nonReplacableTypeList:Array<Int> = [1,2,6]; //note types you dont wanna hit
	var hold:Array<Bool>;
	var press:Array<Bool>;
	var release:Array<Bool>;

	// WHAT TYPE OF ENGINE DOESN'T HAVE AN "INSTANCE"???????????????
	public static var instance:PlayState = null;

	// leather_engine

	var binds:Array<String>;

	public var ui_Settings:Array<String>;
	public var mania_size:Array<String>;
	public var mania_offset:Array<String>;
	public var mania_gap:Array<String>;
	public var types:Array<String>;

	public var arrow_Configs:Map<String, Array<String>> = new Map<String, Array<String>>();
	public var type_Configs:Map<String, Array<String>> = new Map<String, Array<String>>();

	var splashesSkin:String = "default";

	public var splashesSettings:Array<String>;
	public var splash_Texture:FlxFramesCollection;

	public var arrow_Type_Sprites:Map<String, FlxFramesCollection> = [];

	public static var songMultiplier:Float = 1;
	public static var previousScrollSpeedLmao:Float = 0;

	//anti-skip
	var bgDim:FlxSprite;
	var fullDim = false;
	var noticeTime = 0;

	override public function create()
	{
		instance = this;
		#if desktop
		// pre lowercasing the song name (create)
        var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
        switch (songLowercase) {
            case 'dad-battle': songLowercase = 'dadbattle';
            case 'philly-nice': songLowercase = 'philly';
        }
		#end
		Note.getFrames = true;
		Note.getSpecialFrames = true;
		Note.specialNoteJson = null;
		if (FNFAssets.exists('assets/data/${SONG.song.toLowerCase()}/noteInfo.json')) {
			Note.specialNoteJson = CoolUtil.parseJson(FNFAssets.getText('assets/data/${SONG.song.toLowerCase()}/noteInfo.json'));
		}
		Judgement.uiJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_ui/ui_packs/ui.json'));
		uiSmelly = Reflect.field(Judgement.uiJson, SONG.uiType);
		misses = 0;
		bads = 0;
		goods = 0;
		sicks = 0;
		shits = 0;
		ss = true;
		// use current note amount
		Note.NOTE_AMOUNT = SONG.preferredNoteAmount;
		judgementList = CoolUtil.coolTextFile('assets/data/judgements.txt');
		preferredJudgement = judgementList[OptionsHandler.options.preferJudgement];
		if (preferredJudgement == 'none' || SONG.forceJudgements) {
			preferredJudgement = SONG.uiType;
			// if it is not using its own folder make preferred judgement
			if (Reflect.hasField(Judgement.uiJson, preferredJudgement) && Reflect.field(Judgement.uiJson, preferredJudgement).uses != preferredJudgement)
				preferredJudgement = Reflect.field(Judgement.uiJson, preferredJudgement).uses;
		}
		#if windows
		// Making difficulty text for Discord Rich Presence.
		// I JUST REALIZED THIS IS NOT VERY COMPATIBILE
		/*
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}
		*/
		storyDifficultyText = DifficultyManager.getDiffName(storyDifficulty);
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;
		mania = SONG.noteMania;
		trace('amount of keys in song is: ' + keyAmmo[mania]);

		/*if (PlayStateChangeables.bothSide)
			mania = 5;
		else if (FlxG.save.data.mania != 0 && PlayStateChangeables.randomNotes)
			mania = FlxG.save.data.mania;*/
		maniaToChange = mania;
		alwaysDoCutscenes = OptionsHandler.options.alwaysDoCutscenes;
		useCustomInput = OptionsHandler.options.useCustomInput;
		useVictoryScreen = !OptionsHandler.options.skipVictoryScreen;
		downscroll = OptionsHandler.options.downscroll;
		useSongBar = OptionsHandler.options.showSongPos;
		useTimings = OptionsHandler.options.showTimings;
		useNoteSplashes = OptionsHandler.options.showNoteSplashes;
		camNotes = OptionsHandler.options.camNotes;
		Judge.setJudge(cast OptionsHandler.options.judge);
		pixelUI = uiSmelly.isPixel;
		if (!OptionsHandler.options.skipModifierMenu) {
			fullComboMode = ModifierState.namedModifiers.fc.value;
			goodCombo = ModifierState.namedModifiers.gfc.value;
			perfectMode = ModifierState.namedModifiers.mfc.value;
			practiceMode = ModifierState.namedModifiers.practice.value;
			flippedNotes = false;
			accelNotes = ModifierState.namedModifiers.accel.value;
			vnshNotes = ModifierState.namedModifiers.vanish.value;
			invsNotes = ModifierState.namedModifiers.invis.value;
			snakeNotes = ModifierState.namedModifiers.snake.value;
			drunkNotes = ModifierState.namedModifiers.drunk.value;
			// nightcoreMode = ModifierState.modifiers[18].value;
			// daycoreMode = ModifierState.modifiers[19].value;
			inALoop = ModifierState.namedModifiers.loop.value;
			duoMode = ModifierState.namedModifiers.duo.value;
			opponentPlayer = ModifierState.namedModifiers.oppnt.value;
			demoMode = ModifierState.namedModifiers.demo.value;
			if (ModifierState.namedModifiers.healthloss.value)
				healthLossMultiplier = ModifierState.namedModifiers.healthloss.amount;
			if (ModifierState.namedModifiers.healthgain.value)
				healthGainMultiplier = ModifierState.namedModifiers.healthgain.amount;
			if (ModifierState.namedModifiers.slow.value)
				noteSpeed = 0.3;
			if (accelNotes) {
				noteSpeed = 0.45;
				trace("accel arrows");
			}
			if (daycoreMode) {
				noteSpeed = 0.5;
			}


			if (ModifierState.namedModifiers.fast.value)
				noteSpeed = 0.9;
			if (ModifierState.namedModifiers.regen.value) {
				loveMultiplier = ModifierState.namedModifiers.regen.amount;
				supLove = true;
			}
			if (ModifierState.namedModifiers.degen.value) {
				poisonMultiplier = ModifierState.namedModifiers.degen.amount;
				poisonExr = true;
			}
			poisonPlus = ModifierState.namedModifiers.poison.value;
		} else {
			ModifierState.scoreMultiplier = 1;
		}
		player1GoodHitSignal = new Signal<Note>();
		player2GoodHitSignal = new Signal<Note>();
		// rebind always, to support djkf
		if (!opponentPlayer && !duoMode) {
			controls.setKeyboardScheme(Solo(false));
		}
		if (opponentPlayer) {
			controlsPlayerTwo.setKeyboardScheme(Solo(false));
		} else {
			controlsPlayerTwo.setKeyboardScheme(Duo(false));
		}
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var sploosh = new NoteSplash(100, 100, 0);
		sploosh.alpha = 0.1;
		grpNoteSplashes.add(sploosh);
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		var dialogSuffix = "";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix = "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix = "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix = "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix = "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix = "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix = "-depressed";
		} else if (practiceMode) {
			dialogSuffix = "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix = "-perfect";
		}
		var filename:Null<String> = null;
		if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt'))
		{	
			filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		}
		else if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt'))
		{
			filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		}
		else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog.txt'))
		{
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt'))
			{
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		}
		else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt'))
		{
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt'))
			{
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}

		splash_Texture = Paths.getSparrowAtlas("leather_engine/ui/Note_Splashes", 'shared');
		splashesSettings = CoolUtil.coolTextFile(Paths.txt("leather_engine/ui/config"));
		mania_gap = CoolUtil.coolTextFile(Paths.txt("leather_engine/ui/maniagap"));
		mania_size = CoolUtil.coolTextFile(Paths.txt("leather_engine/ui/maniasize"));
		mania_offset = CoolUtil.coolTextFile(Paths.txt("leather_engine/ui/maniaoffset"));

		arrow_Type_Sprites.set("default", Paths.getSparrowAtlas("leather_engine/ui/default", 'shared'));

		types = CoolUtil.coolTextFile(Paths.txt("leather_engine/ui/types"));
		arrow_Configs.set("default", CoolUtil.coolTextFile(Paths.txt("leather_engine/ui/default")));
		type_Configs.set("default", CoolUtil.coolTextFile(Paths.txt("leather_engine/types/default")));

		#if desktop
		if (FileSystem.exists('assets/data/' + songLowercase  + "/preload.txt")) {
			var characters:Array<String> = CoolUtil.coolTextFile('assets/data/' + songLowercase  + "/preload.txt");
			for (i in 0...characters.length) {
				var data:Array<String> = characters[i].split(':');
				switch(data[1]) {
					case 'dad':
						dad = new Character (0, 0, data[0]);
						iconP2 = new HealthIcon(data[0], false);
					case 'bf':
						boyfriend = new Character (0, 0, data[0]);
						iconP1 = new HealthIcon(data[0], true);
					case 'gf':
						gf = new Character (0, 0, data[0]);
					case 'play':
						dad = new Character (0, 0, data[0]);
						iconP2 = new HealthIcon(data[0], false);
						boyfriend = new Character (0, 0, data[0]);
						iconP1 = new HealthIcon(data[0], true);
					case 'all':
						dad = new Character (0, 0, data[0]);
						iconP2 = new HealthIcon(data[0], false);
						boyfriend = new Character (0, 0, data[0]);
						iconP1 = new HealthIcon(data[0], true);
						gf = new Character (0, 0, data[0]);
				}
			}
		}
		#end

		if (OptionsHandler.options.scrollSpeed == 1)
			daScrollSpeed = SONG.speed;
		else
			daScrollSpeed = OptionsHandler.options.scrollSpeed;
		
		trace(SONG.gf);
		gf = new Character(400, 130, SONG.gf);
		gf.scrollFactor.set(0.95, 0.95);
		gf.x += gf.gfOffsetX;
		gf.y += gf.gfOffsetY;
		
		dad = new Character(100, 100, SONG.player2);
		if (duoMode || opponentPlayer)
			dad.beingControlled = true;
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		dad.x += dad.enemyOffsetX;
		dad.y += dad.enemyOffsetY;
		camPos.x += dad.camOffsetX;
		camPos.y += dad.camOffsetY;
		if (dad.likeGf) {
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode) {
				camPos.x += 600;
				tweenCamIn();
			}
		}

		boyfriend = new Character(770, 450, SONG.player1, true);
		if (!opponentPlayer && !demoMode)
			boyfriend.beingControlled = true;
		trace("newBF");
		camPos.x += boyfriend.camOffsetX;
		camPos.y += boyfriend.camOffsetY;
		boyfriend.x += boyfriend.playerOffsetX;
		boyfriend.y += boyfriend.playerOffsetY;
		if (boyfriend.likeGf) {
			boyfriend.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode) {
				camPos.x += 600;
				tweenCamIn();
			}
		}

		// REPOSITIONING PER STAGE
		boyfriend.x += bfoffset[0];
		boyfriend.y += bfoffset[1];
		gf.x += gfoffset[0];
		gf.y += gfoffset[1];
		dad.x += dadoffset[0];
		dad.y += dadoffset[1];
		trace('befpre spoop check');
		if (SONG.isSpooky) {
			trace("WOAH SPOOPY");
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			evilTrail.framesEnabled = false;
			// evilTrail.changeValuesEnabled(false, false, false, false);
			// evilTrail.changeGraphic()
			trace(evilTrail);
			add(evilTrail);
		}
		add(gf);
		trace('dad');
		add(dad);
		trace('dy UWU');
		add(boyfriend);
		trace('bf cheeks');

		doof = new DialogueBox(false, goodDialog);
		trace('doofensmiz');
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		Conductor.songPosition = -5000;
		trace('prepare your strumlime');
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (downscroll) {
			strumLine.y = FlxG.height - 165;
		}
		playerComboBreak = new FlxTypedGroup<FlxSprite>();
		enemyComboBreak = new FlxTypedGroup<FlxSprite>();
		playerComboBreak.cameras = [camHUD];
		enemyComboBreak.cameras = [camHUD];
		add(playerComboBreak);
		add(enemyComboBreak);
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);
		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		
		// startCountdown();
		trace('before generate');
		generateSong(SONG.song);

		// add(strumLine);
		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		trace('gay');
		songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
		if (downscroll)
			songPosBG.y = FlxG.height * 0.9 + 45;
		songPosBG.screenCenter(X);
		songPosBG.scrollFactor.set();
		add(songPosBG);
		songPosBG.cameras = [camHUD];

		songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
			'songPositionBar', 0, 1);
		songPosBar.scrollFactor.set();
		songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		songPosBar.numDivisions = 1000;
		add(songPosBar);
		songPosBar.cameras = [camHUD];

		songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
		if (downscroll)
			songName.y -= 3;
		songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.scrollFactor.set();
		add(songName);
		songName.cameras = [camHUD];

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('assets/images/healthBar.png');
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
		if (duoMode)
			leftSideFill = dad.opponentColor;
		var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
		if (duoMode)
			rightSideFill = boyfriend.bfColor;
		healthBar.createFilledBar(leftSideFill, rightSideFill);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x, healthBarBG.y + 40, 0, "", 200);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		healthTxt = new FlxText(healthBarBG.x + healthBarBG.width - 300, scoreTxt.y, 0, "", 200);
		healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		healthTxt.scrollFactor.set();
		healthTxt.visible = false;
		accuracyTxt = new FlxText(healthBarBG.x, scoreTxt.y, 0, "", 200);
		accuracyTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		accuracyTxt.scrollFactor.set();
		// shitty work around but okay
		accuracyTxt.visible = false;
		difficTxt = new FlxText(10, FlxG.height, 0, "", 150);
		
		difficTxt.setFormat("assets/fonts/vcr.ttf", 15, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		difficTxt.scrollFactor.set();
		difficTxt.y -= difficTxt.height;
		if (downscroll) {
			difficTxt.y = 0;
		}
		// screwy way of getting text
		difficTxt.text = DifficultyIcons.changeDifficultyFreeplay(storyDifficulty, 0).text + ' - M+ ${MainMenuState.version}';
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		practiceDieIcon = new HealthIcon('bf-old', false);
		practiceDieIcon.y = healthBar.y - (practiceDieIcon.height / 2);
		practiceDieIcon.x = healthBar.x - 130;
		practiceDieIcon.animation.curAnim.curFrame = 1;
		add(practiceDieIcon);
		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		practiceDieIcon.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		healthTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		difficTxt.cameras = [camHUD];
		practiceDieIcon.visible = false;

		add(scoreTxt);
		add(difficTxt);

		startingSong = true;
		trace('finish uo');
		
		var stageJson = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_stages/custom_stages.json"));
		makeHaxeState("stages", "assets/images/custom_stages/" + SONG.stage + "/", "../"+Reflect.field(stageJson, SONG.stage));

		trace('stage done');

		var uiJson = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_ui/ui_layouts/ui.json"));
		makeHaxeStateUI("ui", "assets/images/custom_ui/ui_layouts/" + Reflect.field(uiJson, 'layout') + "/", "../" + Reflect.field(uiJson, 'layout') + ".hscript");

		trace('ui done');

	if (alwaysDoCutscenes || isStoryMode )
		{

			switch (SONG.cutsceneType)
			{
				/*
				case "monster":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				*/
				case 'senpai':
					schoolIntro(doof);
				case 'angry-senpai':
					
					schoolIntro(doof);
				case 'none':
					startCountdown();
				default:
					// schoolIntro(doof);
					customIntro(doof);
			}
		}
		else
		{

			startCountdown();
		}

		super.create();

	}

	function customIntro(?dialogueBox:DialogueBox) {
		var goodJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_cutscenes/cutscenes.json'));
		if (!Reflect.hasField(goodJson, SONG.cutsceneType)) {
			schoolIntro(dialogueBox);
			return;
		}
		makeHaxeState("cutscene", "assets/images/custom_cutscenes/"+SONG.cutsceneType+'/', "../"+Reflect.field(goodJson, SONG.cutsceneType));
		
	}
	function schoolIntro(?dialogueBox:DialogueBox, intro:Bool=true):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		/*
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		var senpaiSound:Sound;
		// try and find a player2 sound first
		if (FNFAssets.exists('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg')) {
			senpaiSound = FNFAssets.getSound('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg');
		// otherwise, try and find a song one
		} else if (FNFAssets.exists('assets/data/'+SONG.song.toLowerCase()+'/Senpai_Dies.ogg')) {
			senpaiSound = FNFAssets.getSound('assets/data/'+SONG.song.toLowerCase()+'Senpai_Dies.ogg');
		// otherwise, use the default sound
		} else {
			senpaiSound = FNFAssets.getSound('assets/sounds/Senpai_Dies.ogg');
		}
		var senpaiEvil:FlxSprite = new FlxSprite();
		// dialog box overwrites character
		if (FNFAssets.exists('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png')) {
			var evilImage = FNFAssets.getBitmapData('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png');
			var evilXml = FNFAssets.getText('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.xml');
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		// character then takes precendence over default
		// will make things like monika way way easier
		} else if (FNFAssets.exists('assets/images/custom_chars/'+SONG.player2+'/crazy.png')) {
			var evilImage = FNFAssets.getBitmapData('assets/images/custom_chars/'+SONG.player2+'/crazy.png');
			var evilXml = FNFAssets.getText('assets/images/custom_chars/'+SONG.player2+'/crazy.xml');
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		} else {
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/senpaiCrazy.png', 'assets/images/weeb/senpaiCrazy.xml');
		}

		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		if (dad.isPixel) {
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		}
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		*/
		if (SONG.cutsceneType == 'angry-senpai')
		{
			remove(black);
			/*
			if (SONG.cutsceneType == 'spirit')
			{
				add(red);
			}
			*/
		}
		
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					// haha weeeee
					/*
					if (SONG.cutsceneType == 'spirit')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(senpaiSound, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						
					}
					*/
					add(dialogueBox);
				}
				else
					if (intro)
						startCountdown();
					else 
						endForReal();

				remove(black);
			}
		});
	}
	function videoIntro(filename:String) {
		startCountdown();
		/*
		var b = new FlxSprite(-200, -200).makeGraphic(2*FlxG.width,2*FlxG.height, -16777216);
		b.scrollFactor.set();
		add(b);
		trace(filename);
		new FlxVideo(filename).finishCallback = function () {
			remove(b);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});
			startCountdown();
		}*/
	}
	var startTimer:FlxTimer;
	var perfectModeOld:Bool = false;
	var keys = [false, false, false, false, false, false, false, false, false];

	public function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0, SONG.uiType, true);
		generateStaticArrows(1, SONG.uiType, true);

		switch(mania) //moved it here because i can lol
		{
			case 0: 
				keys = [false, false, false, false];
			case 1: 
				keys = [false, false, false, false, false, false];
			case 2: 
				keys = [false, false, false, false, false, false, false, false, false];
			case 3: 
				keys = [false, false, false, false, false];
			case 4: 
				keys = [false, false, false, false, false, false, false];
			case 5: 
				keys = [false, false, false, false, false, false, false, false];
			case 6: 
				keys = [false];
			case 7: 
				keys = [false, false];
			case 8: 
				keys = [false, false, false];
		}

		if (FNFAssets.exists("assets/data/" + SONG.song.toLowerCase() + "/modchart", Hscript))
		{
			makeHaxeState("modchart", "assets/data/" + SONG.song.toLowerCase() + "/", "modchart");	
		}
		if (duoMode)
		{
			controls.setKeyboardScheme(Duo(true));
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (!duoMode || opponentPlayer)
				dad.dance();
			if (opponentPlayer)
				boyfriend.dance();
			gf.dance();


			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();

			for (field in Reflect.fields(Judgement.uiJson)) {
				if (Reflect.field(Judgement.uiJson, field).isPixel)
					introAssets.set(field, [
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/ready-pixel.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set-pixel.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses+'/date-pixel.png']);
				else
					introAssets.set(field, [
						'custom_ui/ui_packs/' + field + '/ready.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses+'/go.png']);
			
			}

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var intro3Sound:Sound;
			var intro2Sound:Sound;
			var intro1Sound:Sound;
			var introGoSound:Sound;
			for (value in introAssets.keys())
			{
				if (value == SONG.uiType)
				{
					introAlts = introAssets.get(value);
					// ok so apparently a leading slash means absolute soooooo
					if (pixelUI)
						altSuffix = '-pixel';
				}
			}

			// god is dead for we have killed him
			if (FNFAssets.exists("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg')) {
				intro3Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg');
				intro2Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro2' + altSuffix + '.ogg');
				intro1Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro1' + altSuffix + '.ogg');
				// apparently this crashes if we do it from audio buffer?
				// no it just understands 'hey that file doesn't exist better do an error'
				introGoSound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/introGo' + altSuffix + '.ogg');
			} else {
				intro3Sound = FNFAssets.getSound('assets/sounds/intro3.ogg');
				intro2Sound = FNFAssets.getSound('assets/sounds/intro2.ogg');
				intro1Sound = FNFAssets.getSound('assets/sounds/intro1.ogg');
				introGoSound = FNFAssets.getSound('assets/sounds/introGo.ogg');
			}
	


			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(intro3Sound, 0.6);
				case 1:
					// my life is a lie, it was always this simple
					var sussyPath = 'assets/images/ready.png';
					if (FNFAssets.exists('assets/images/' + introAlts[0]))
						sussyPath = 'assets/images/' + introAlts[0];
					var readyImage = FNFAssets.getBitmapData(sussyPath);
					var ready:FlxSprite = new FlxSprite().loadGraphic(readyImage);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (pixelUI)
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(intro2Sound, 0.6);
				case 2:
					var sussyPath = 'assets/images/set.png';
					if (FNFAssets.exists('assets/images/' + introAlts[1]))
						sussyPath = 'assets/images/' + introAlts[1];
					var setImage = FNFAssets.getBitmapData(sussyPath);
					// can't believe you can actually use this as a variable name
					var set:FlxSprite = new FlxSprite().loadGraphic(setImage);
					set.scrollFactor.set();

					if (pixelUI)
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(intro1Sound, 0.6);
				case 3:
					var sussyPath = 'assets/images/go.png';
					if (FNFAssets.exists('assets/images/' + introAlts[2]))
						sussyPath = 'assets/images/' + introAlts[2];
					var goImage = FNFAssets.getBitmapData(sussyPath);
					var go:FlxSprite = new FlxSprite().loadGraphic(goImage);
					go.scrollFactor.set();

					if (pixelUI)
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(introGoSound, 0.6);
				case 4:
					// what is this here for?
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		/*
		regenTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			var bonus = drainBy;
			if (opponentPlayer) {
				bonus = -1 * drainBy;
			}
			if (poisonExr && !paused)
				health -= bonus;
			if (supLove && !paused)
				health +=  bonus;
		}, 0);
		*/
		sickFastTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			if (accelNotes && !paused) {
				trace("tick:" + noteSpeed);
				noteSpeed += 0.01;
			}

		}, 0);
		var snekBase:Float = 0;
		var snekTimer = new FlxTimer().start(0.01, function (tmr:FlxTimer) {
			if (snakeNotes && !paused) {
				snekNumber = Math.sin(snekBase) * 100;
				snekBase += Math.PI/100;
			}

		}, 0);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
		{
			for (key => value in FlxKey.fromStringMap)
			{
				if (charCode == value)
					return key;
			}
			return null;
		}
		
	
	
	
		private function releaseInput(evt:KeyboardEvent):Void // handles releases
		{
			@:privateAccess
			var key = FlxKey.toStringMap.get(evt.keyCode);
	
			var binds:Array<String> = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.up, FlxG.save.data.keys.right];
			var data = -1;
			switch(maniaToChange)
			{
				case 0: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys // why the fuck are arrow keys hardcoded it fucking breaks the controls with extra keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 1: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind, FlxG.save.data.keys.L2Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 3;
						case 40:
							data = 4;
						case 39:
							data = 5;
					}
				case 2: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
				case 3: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.up, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 3;
						case 39:
							data = 4;
					}
				case 4: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind,FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.L2Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 4;
						case 40:
							data = 5;
						case 39:
							data = 6;
					}
				case 5: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 4;
						case 40:
							data = 5;
						case 38:
							data = 6;
						case 39:
							data = 7;
					}
				case 6: 
					binds = [FlxG.save.data.keys.N4Bind];
				case 7: 
					binds = [FlxG.save.data.keys.left, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys 
					{
						case 37:
							data = 0;
						case 39:
							data = 1;
					}
	
				case 8: 
					binds = [FlxG.save.data.keys.left, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys 
					{
						case 37:
							data = 0;
						case 39:
							data = 2;
					}
				case 10: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right, null, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 11: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind, null, FlxG.save.data.keys.L2Bind, null, null, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 1;
						case 39:
							data = 8;
					}
				case 12: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
				case 13: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right, FlxG.save.data.keys.N4Bind, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 14: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.L2Bind, null, null, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 1;
						case 39:
							data = 8;
					}
				case 15: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, null, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
				case 16: 
					binds = [null, null, null, null, FlxG.save.data.keys.N4Bind, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 4;
						case 39:
							data = 8;
					}
				case 17: 
					binds = [FlxG.save.data.keys.left, null, null, FlxG.save.data.keys.right, null, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 18: 
					binds = [FlxG.save.data.keys.left, null, null, FlxG.save.data.keys.right, FlxG.save.data.keys.N4Bind, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
			}
	
			
	
	
			for (i in 0...binds.length) // binds
			{
				if (binds[i].toLowerCase() == key.toLowerCase())
					data = i;
			}
	
			if (data == -1)
				return;
	
			keys[data] = false;
		}
	
		public var closestNotes:Array<Note> = [];
	
		private function handleInput(evt:KeyboardEvent, ?playerOne:Bool = true):Void { // this actually handles press inputs
	
			if (demoMode || paused)
				return;
	
			// first convert it from openfl to a flixel key code
			// then use FlxKey to get the key's name based off of the FlxKey dictionary
			// this makes it work for special characters
	
			@:privateAccess
			var key = FlxKey.toStringMap.get(evt.keyCode);
			var data = -1;
			var binds:Array<String> = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right];
			switch(maniaToChange)
			{
				case 0: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys // why the fuck are arrow keys hardcoded it fucking breaks the controls with extra keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 1: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind, FlxG.save.data.keys.L2Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 3;
						case 40:
							data = 4;
						case 39:
							data = 5;
					}
				case 2: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
				case 3: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.up, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 3;
						case 39:
							data = 4;
					}
				case 4: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind,FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.L2Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 4;
						case 40:
							data = 5;
						case 39:
							data = 6;
					}
				case 5: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 4;
						case 40:
							data = 5;
						case 38:
							data = 6;
						case 39:
							data = 7;
					}
				case 6: 
					binds = [FlxG.save.data.keys.N4Bind];
				case 7: 
					binds = [FlxG.save.data.keys.left, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys 
					{
						case 37:
							data = 0;
						case 39:
							data = 1;
					}
	
				case 8: 
					binds = [FlxG.save.data.keys.left, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.right];
					switch(evt.keyCode) // arrow keys 
					{
						case 37:
							data = 0;
						case 39:
							data = 2;
					}
				case 10: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right, null, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 11: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind, null, FlxG.save.data.keys.L2Bind, null, null, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 1;
						case 39:
							data = 8;
					}
				case 12: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
				case 13: 
					binds = [FlxG.save.data.keys.left,FlxG.save.data.keys.down, FlxG.save.data.keys.up, FlxG.save.data.keys.right, FlxG.save.data.keys.N4Bind, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 14: 
					binds = [FlxG.save.data.keys.L1Bind, FlxG.save.data.keys.D1Bind, FlxG.save.data.keys.U1Bind, FlxG.save.data.keys.R1Bind, FlxG.save.data.keys.N4Bind, FlxG.save.data.keys.L2Bind, null, null, FlxG.save.data.keys.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 1;
						case 39:
							data = 8;
					}
				case 15: 
					binds = [FlxG.save.data.keys.N0Bind, FlxG.save.data.keys.N1Bind, FlxG.save.data.keys.N2Bind, FlxG.save.data.keys.N3Bind, null, FlxG.save.data.keys.N5Bind, FlxG.save.data.keys.N6Bind, FlxG.save.data.keys.N7Bind, FlxG.save.data.keys.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
				case 16: 
					binds = [null, null, null, null, FlxG.save.data.keys.N4Bind, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 4;
						case 39:
							data = 8;
					}
				case 17: 
					binds = [FlxG.save.data.keys.left, null, null, FlxG.save.data.keys.right, null, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 18: 
					binds = [FlxG.save.data.keys.left, null, null, FlxG.save.data.keys.right, FlxG.save.data.keys.N4Bind, null, null, null, null];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
	
			}
	
				for (i in 0...binds.length) // binds
					{
						if (binds[i].toLowerCase() == key.toLowerCase())
							data = i;
					}
					if (data == -1)
					{
						trace("couldn't find a keybind with the code " + key);
						return;
					}
					if (keys[data])
					{
						trace("ur already holding " + key);
						return;
					}
			
					keys[data] = true;
			
					var ana = new Ana(Conductor.songPosition, null, false, "miss", data);
			
					var dataNotes = [];
					for(i in closestNotes)
						if (i.noteData == data)
							dataNotes.push(i);
	
					
				//	if (!FlxG.save.data.keys.gthm)
			//		{
						if (dataNotes.length != 0)
							{
								var coolNote = null;
					
								for (i in dataNotes)
									if (!i.isSustainNote)
									{
										coolNote = i;
										break;
									}
					
								if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
								{
									return;
								}
					
								if (dataNotes.length > 1) // stacked notes or really close ones
								{
									for (i in 0...dataNotes.length)
									{
										if (i == 0) // skip the first note
											continue;
					
										var note = dataNotes[i];
					
										if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
										{
											trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
											// just fuckin remove it since it's a stacked note and shouldn't be there
											note.kill();
											notes.remove(note, true);
											note.destroy();
										}
									}
								}
					
								goodNoteHit(coolNote, playerOne);
								var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
								ana.hit = true;
								ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((Conductor.safeFrames / 60) * 1000));
								ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							
							}
						else if (!FlxG.save.data.keys.ghost && songStarted && !grace)
							{
								noteMiss(data, true /*remind me to add support*/, null);
								ana.hit = false;
								ana.hitJudge = "shit";
								ana.nearestNote = [];
								//health -= 0.20;
							}
				//	}
			
		}

		var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		if (FlxG.sound.music != null) {
			// cuck lunchbox
			FlxG.sound.music.stop();
		}
		// : )
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		var useSong = "assets/songs/"+ SONG.song.toLowerCase() + '/' + SONG.song + "_Inst" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "/Shit_Inst.ogg"))
			useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "/Shit_Inst.ogg";
		if (!paused)
			FlxG.sound.playMusic(FNFAssets.getSound(useSong), 1, false);
		songLength = FlxG.sound.music.length;

		if (useNoteSplashes)
			{
				switch (mania)
				{
					case 0: 
						NoteSplash.colors = ['purple', 'blue', 'green', 'red'];
					case 1: 
						NoteSplash.colors = ['purple', 'green', 'red', 'yellow', 'blue', 'darkblue'];	
					case 2: 
						NoteSplash.colors = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'darkblue'];
					case 3: 
						NoteSplash.colors = ['purple', 'blue', 'white', 'green', 'red'];
					//	if (FlxG.save.data.gthc)
						//	NoteSplash.colors = ['green', 'red', 'yellow', 'darkblue', 'orange'];
					case 4: 
						NoteSplash.colors = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'darkblue'];
					case 5: 
						NoteSplash.colors = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'darkblue'];
					case 6: 
						NoteSplash.colors = ['white'];
					case 7: 
						NoteSplash.colors = ['purple', 'red'];
					case 8: 
						NoteSplash.colors = ['purple', 'white', 'red'];
				}
			}

		Application.current.window.title = "Friday Night Disappointin' Modding Plus | with EK mod by Discussions - " + SONG.song + " on "+ DifficultyIcons.changeDifficultyFreeplay(storyDifficulty, 0).text + " Mode";

		/*if (useSongBar) // I dont wanna talk about this code :(
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0) {
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}*/
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		var useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "_Voices" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "Shit_Voices.ogg"))
			useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "Shit_Voices.ogg";
		if (SONG.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile(useSong);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded(useSong);
			#end
		}	else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var customImage:Null<BitmapData> = null;
		var customXml:Null<String> = null;
		var arrowEndsImage:Null<BitmapData> = null;
		if (!pixelUI) {
			trace("has this been reached");
			customImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/NOTE_assets.png');
			customXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/NOTE_assets.xml');
		} else {
			customImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/arrows-pixels.png');
			arrowEndsImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/arrowEnds.png');
		}
		
		var daSection:Int = 1;

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			var mn:Int = keyAmmo[mania];

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + OptionsHandler.options.offset;
				//var daNoteData:Int = Std.int(songNotes[1] % Note.NOTE_AMOUNT);
				var daNoteData:Int = Std.int(songNotes[1] % mn);
				var daNoteTypeData:Int = FlxG.random.int(0, mn - 1);
				var daLift:Bool = songNotes[4];
				var noteHeal:Float = songNotes[5] == null ? 1 : songNotes[5];
				var noteDamage:Float = songNotes[6] == null ? 1 : songNotes[6];
				var consitentNote:Bool = cast songNotes[7];
				var timeThingy:Float = songNotes[8] == null ? 1 : songNotes[8];
				// casting is not ok as default is true
				var shouldSing:Bool = if (songNotes[9] == null) true else songNotes[9];
				// casting is ok as null is falsey
				var ignoreHealthMods:Bool = cast songNotes[10];
				var animSuffix:Null<String> = songNotes[11];
				var gottaHitNote:Bool = section.mustHitSection;
				var altNote:Bool = false;
				var isRandomNoteType:Bool = false;
				var isReplaceable:Bool = false;
				var newNoteType:Int = 0;
				
				if (songNotes[1] % 8 > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				//if (daNoteData > 7) //failsafe
				//	daNoteData -= 4;

				/*var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] >= mn)
				{
					gottaHitNote = !section.mustHitSection;

				}*/

				/*
				if (songNotes[1] >= 8 && songNotes[1] < 16) {
					// sussy fire note support? :flushed:
					// Percent in decimal divided by health thingie
					noteHeal = 0.125 / 0.04;
					consitentNote = true;
					shouldSing = false;
					timeThingy = 0.5;
					noteDamage = 0;
					ignoreHealthMods = true;
					animSuffix = "lift";
				}
				*/
				if (songNotes[3] || section.altAnim)
				{
					altNote = true;
				}
				// force nuke notes : )
				if (songNotes[1] >= Note.NOTE_AMOUNT * 2 && songNotes[1] < Note.NOTE_AMOUNT * 4 && SONG.convertMineToNuke) {
					songNotes[1] += Note.NOTE_AMOUNT * 4;
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				// stand back i am a professional idiot
				var swagNote:Note = new Note(daStrumTime, songNotes[1], oldNote, false, customImage, customXml, arrowEndsImage, daLift, animSuffix);
				if (!swagNote.dontEdit && !swagNote.mineNote && !swagNote.nukeNote && !swagNote.isLiftNote) {
					swagNote.shouldBeSung = shouldSing;
					swagNote.ignoreHealthMods = ignoreHealthMods;
					swagNote.timingMultiplier = timeThingy;
					swagNote.healMultiplier = noteHeal;
					swagNote.damageMultiplier = noteDamage;
					swagNote.consistentHealth = consitentNote;
				}
				

				// altNote
				swagNote.altNote = altNote;
				swagNote.altNum = songNotes[3] == null ? (swagNote.altNote ? 1 : 0) : songNotes[3];
				// so much more complicated but makes playstation like shit work
				if (flippedNotes) {
					if (swagNote.animation.curAnim.name == 'greenScroll') {
						swagNote.animation.play('blueScroll');
					} else if (swagNote.animation.curAnim.name == 'blueScroll') {
						swagNote.animation.play('greenScroll');
					} else if (swagNote.animation.curAnim.name == 'redScroll') {
						swagNote.animation.play('purpleScroll');
					} else if (swagNote.animation.curAnim.name == 'purpleScroll') {
						swagNote.animation.play('redScroll');
					}
				}
				if (duoMode)
				{
					swagNote.duoMode = true;
				}
				if (opponentPlayer) {
					swagNote.oppMode = true;
				}
				if (demoMode)
					swagNote.funnyMode = true;
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				// when the imposter is sus XD
				if (susLength != 0) {
					for (susNote in 0...Math.floor(susLength)) // no + 2 please and thanks <3
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						if (OptionsHandler.options.emuOsuLifts && susLength < susNote)
						{
							// simulate osu!mania holds by adding lifts at the end
							var liftNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, false,
								customImage, customXml, arrowEndsImage, true);
							if (duoMode)
								liftNote.duoMode = true;
							if (opponentPlayer)
								liftNote.oppMode = true;
							if (demoMode)
								liftNote.funnyMode = true;
							liftNote.scrollFactor.set();
							unspawnNotes.push(liftNote);
							liftNote.mustPress = gottaHitNote;
							if (liftNote.mustPress)
								liftNote.x += FlxG.width / 2;

							// how haxe works by default is exclusive?
						}
						else if (susLength > susNote)
						{
							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote,
								true, customImage, customXml, arrowEndsImage);
							if (duoMode)
							{
								sustainNote.duoMode = true;
							}
							if (opponentPlayer)
							{
								sustainNote.oppMode = true;
							}
							if (demoMode)
								sustainNote.funnyMode = true;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							sustainNote.shouldBeSung = shouldSing;
							sustainNote.ignoreHealthMods = ignoreHealthMods;
							sustainNote.timingMultiplier = timeThingy;
							sustainNote.healMultiplier = noteHeal;
							sustainNote.damageMultiplier = noteDamage;
							sustainNote.consistentHealth = consitentNote;
							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}
				}
				

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daSection += 1;
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;
		// to get around how pecked up the note system is
		for (epicNote in unspawnNotes) {
			if (epicNote.isSustainNote) {
				if (flippedNotes) {
					if (epicNote.animation.curAnim.name == 'greenhold') {
						epicNote.animation.play('bluehold');
					} else if (epicNote.animation.curAnim.name == 'bluehold') {
						epicNote.animation.play('greenhold');
					} else if (epicNote.animation.curAnim.name == 'redhold') {
						epicNote.animation.play('purplehold');
					} else if (epicNote.animation.curAnim.name == 'purplehold') {
						epicNote.animation.play('redhold');
					} else if (epicNote.animation.curAnim.name == 'greenholdend') {
						epicNote.animation.play('blueholdend');
					} else if (epicNote.animation.curAnim.name == 'blueholdend') {
						epicNote.animation.play('greenholdend');
					} else if (epicNote.animation.curAnim.name == 'redholdend') {
						epicNote.animation.play('purpleholdend');
					} else if (epicNote.animation.curAnim.name == 'purpleholdend') {
						epicNote.animation.play('redholdend');
					}
				}
			}
		}
		
		unspawnNotes.sort(sortByShit);
		defaultNoteWidth = unspawnNotes[0].width;
		generatedMusic = true;
	}
	var defaultNoteWidth:Float;
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, type:String, transition:Bool):Void {
		var daType = Reflect.field(Judgement.uiJson, type);
		if (player == 1) {
			playerStrums.forEach(function (spr) {
				spr.kill();
				//playerStrums.remove(spr, true);
				//spr.destroy();
			});
		} else {
			enemyStrums.forEach(function (spr) {
				spr.kill();
				//enemyStrums.remove(spr, true);
				//spr.destroy();
			});
		}
		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			if (!uiSmelly.isPixel)
			{
				var noteXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + daType.uses + "/NOTE_assets.xml");
				var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/NOTE_assets.png");
				babyArrow.frames = FlxAtlasFrames.fromSparrow(notePic, noteXml);
				var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var pPre:Array<String> = ['purple', 'blue', 'green', 'red'];
				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));
				switch (mania)
				{
					case 1:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];
	
					case 2:
						nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						pPre = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
						babyArrow.x -= Note.tooMuch;
					case 3: 
						nSuf = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
						pPre = ['purple', 'blue', 'white', 'green', 'red'];
						if (FlxG.save.data.gthc)
						{
							nSuf = ['UP', 'RIGHT', 'LEFT', 'RIGHT', 'UP'];
							pPre = ['green', 'red', 'yellow', 'dark', 'orange'];
						}
					case 4: 
						nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
					case 5: 
						nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						pPre = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'];
					case 6:
						nSuf = ['SPACE'];
						pPre = ['white'];
					case 7: 
						nSuf = ['LEFT', 'RIGHT'];
						pPre = ['purple', 'red'];
					case 8: 
						nSuf = ['LEFT', 'SPACE', 'RIGHT'];
						pPre = ['purple', 'white', 'red'];
				}

				trace(pPre[i]);

				babyArrow.x += Note.swagWidth * i;
				babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
				babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}
			else
			{
				var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.png");
				babyArrow.loadGraphic(notePic, true, 17, 17);
				babyArrow.animation.add('green', [11]);
					babyArrow.animation.add('red', [12]);
					babyArrow.animation.add('blue', [10]);
					babyArrow.animation.add('purplel', [9]);

					babyArrow.animation.add('white', [13]);
					babyArrow.animation.add('yellow', [14]);
					babyArrow.animation.add('violet', [15]);
					babyArrow.animation.add('black', [16]);
					babyArrow.animation.add('darkred', [16]);
					babyArrow.animation.add('orange', [16]);
					babyArrow.animation.add('dark', [17]);


					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom * Note.pixelnoteScale));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					var numstatic:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8]; //this is most tedious shit ive ever done why the fuck is this so hard
					var startpress:Array<Int> = [9, 10, 11, 12, 13, 14, 15, 16, 17];
					var endpress:Array<Int> = [18, 19, 20, 21, 22, 23, 24, 25, 26];
					var startconf:Array<Int> = [27, 28, 29, 30, 31, 32, 33, 34, 35];
					var endconf:Array<Int> = [36, 37, 38, 39, 40, 41, 42, 43, 44];
						switch (mania)
						{
							case 1:
								numstatic = [0, 2, 3, 5, 1, 8];
								startpress = [9, 11, 12, 14, 10, 17];
								endpress = [18, 20, 21, 23, 19, 26];
								startconf = [27, 29, 30, 32, 28, 35];
								endconf = [36, 38, 39, 41, 37, 44];

							case 2: 
								babyArrow.x -= Note.tooMuch;
							case 3: 
								numstatic = [0, 1, 4, 2, 3];
								startpress = [9, 10, 13, 11, 12];
								endpress = [18, 19, 22, 20, 21];
								startconf = [27, 28, 31, 29, 30];
								endconf = [36, 37, 40, 38, 39];
							case 4: 
								numstatic = [0, 2, 3, 4, 5, 1, 8];
								startpress = [9, 11, 12, 13, 14, 10, 17];
								endpress = [18, 20, 21, 22, 23, 19, 26];
								startconf = [27, 29, 30, 31, 32, 28, 35];
								endconf = [36, 38, 39, 40, 41, 37, 44];
							case 5: 
								numstatic = [0, 1, 2, 3, 5, 6, 7, 8];
								startpress = [9, 10, 11, 12, 14, 15, 16, 17];
								endpress = [18, 19, 20, 21, 23, 24, 25, 26];
								startconf = [27, 28, 29, 30, 32, 33, 34, 35];
								endconf = [36, 37, 38, 39, 41, 42, 43, 44];
							case 6: 
								numstatic = [4];
								startpress = [13];
								endpress = [22];
								startconf = [31];
								endconf = [40];
							case 7: 
								numstatic = [0, 3];
								startpress = [9, 12];
								endpress = [18, 21];
								startconf = [27, 30];
								endconf = [36, 39];
							case 8: 
								numstatic = [0, 4, 3];
								startpress = [9, 13, 12];
								endpress = [18, 22, 21];
								startconf = [27, 31, 30];
								endconf = [36, 40, 39];


						}
					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [numstatic[i]]);
					babyArrow.animation.add('pressed', [startpress[i], endpress[i]], 12, false);
					babyArrow.animation.add('confirm', [startconf[i], endconf[i]], 24, false);
			}
			

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (transition) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			
			babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				enemyStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			enemyStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});
	
			strumLineNotes.add(babyArrow);

			if (player == 1) {
				playerComboBreak.forEach(function (spr) {
					spr.kill();
				});
			} else {
				enemyComboBreak.forEach(function (spr) {
					spr.kill();
				});
			}

			// does not need to be unique because it uses special thingies
			var comboBreakThing = new FlxSprite(babyArrow.x, 0).makeGraphic(Std.int(babyArrow.width), FlxG.height, FlxColor.WHITE);
			comboBreakThing.visible = false;
			comboBreakThing.alpha = 0.6;
			if (player == 1)
				playerComboBreak.add(comboBreakThing);
			else
				enemyComboBreak.add(comboBreakThing);
		}
	}
	function comboBreak(dir:Int, playerOne:Bool = true, rating:String = 'miss') {
	
		if (!OptionsHandler.options.showComboBreaks)
			return;
		var coolor = switch (rating) {
			case 'miss':
				missBreakColor;
			case 'wayoff':
				wayoffBreakColor;
			case 'shit':
				shitBreakColor;
			default:
				// just return, as we shouldn't even be here
				return;
		}
		var breakGroup = playerOne ? playerComboBreak : enemyComboBreak;
		dir = dir % 4;
		var thingToDisplay = breakGroup.members[dir];
		thingToDisplay.color = coolor;
		thingToDisplay.alpha = 1;
		thingToDisplay.visible = true;
		FlxTween.tween(thingToDisplay, {alpha: 0}, 1, {onComplete: function(_) {thingToDisplay.visible = false;}});
	}
	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	 function healthChange(healthVar:Float = -69, additive:Bool = false) {
		trace('changing health');
		if (healthVar != -69) { //lol thats the funny number
			trace('health changed');
			if (additive == true)
				health += healthVar;
			else
				health = healthVar;
		}
	}

	function switchCharacter(charTo:String, charState:String) { //the non sus version
	    switch(charState) {
			case 'boyfriend' | 'bf' | 'player1':
			    remove(boyfriend);
				boyfriend.destroy();
				boyfriend = new Character(swapOffsets[0], swapOffsets[1], charTo, true);
				if (!opponentPlayer && !demoMode)
					boyfriend.beingControlled = true;
				boyfriend.x += boyfriend.playerOffsetX;
				boyfriend.y += boyfriend.playerOffsetY;
				if (boyfriend.likeGf) {
					boyfriend.setPosition(gf.x, gf.y);
					gf.visible = false;
				} else if (!dad.likeGf) {
					gf.visible = true;
				}
				iconP1.switchAnim(charTo);

				// Layering nonsense
				if (dad.likeGf) {
					add(boyfriend);
				} else {
				    remove(dad);
				    add(boyfriend);
				    add(dad);
				}
				setAllHaxeVar("boyfriend", boyfriend);
			case 'dad' | 'opponent' | 'player2':
				remove(dad);
				dad.destroy();
				dad = new Character(swapOffsets[4], swapOffsets[5], charTo);
				if (duoMode || opponentPlayer)
					dad.beingControlled = true;
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				if (dad.likeGf) {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
				} else if (!boyfriend.likeGf) {
					gf.visible = true;
				}
				iconP2.switchAnim(charTo);

				// Layering nonsense
				if (boyfriend.likeGf) {
				    add(dad);
				} else {
				    remove(boyfriend);
				    add(dad);
				    add(boyfriend);
				}
				setAllHaxeVar("dad", dad);
			case 'gf' | 'girlfriend' | 'player3':
				remove(gf);
				gf.destroy();
				gf = new Character(swapOffsets[2], swapOffsets[3], charTo);
				gf.scrollFactor.set(0.95, 0.95);
				gf.x += gf.gfOffsetX;
				gf.y += gf.gfOffsetY;

				// Layering nonsense
				remove(boyfriend);
				remove(dad);
				add(gf);
				add(dad);
				add(boyfriend);
				setAllHaxeVar("gf", gf);
		}
	}

	function addCharacter(charTo:String = 'dad', charState:String = 'dad') {
		var flipChar = false;
		if(charState == 'boyfriend' || charState == 'bf' || charState == 'player1') flipChar = true;
		var newChar = new Character(0, 0, charTo, flipChar);
		switch(charState) {
			case 'boyfriend' | 'bf' | 'player1':
			    newChar.setPosition(swapOffsets[0], swapOffsets[1]);
				newChar.x += newChar.playerOffsetX;
				newChar.y += newChar.playerOffsetY;
				if (newChar.likeGf) {
					newChar.setPosition(gf.x, gf.y);
					newChar.scrollFactor.set(0.95, 0.95);
				}
			case 'dad' | 'opponent' | 'player2':
				newChar.setPosition(swapOffsets[4], swapOffsets[5]);
				newChar.x += newChar.enemyOffsetX;
				newChar.y += newChar.enemyOffsetY;
				if (newChar.likeGf) {
					newChar.setPosition(gf.x, gf.y);
					newChar.scrollFactor.set(0.95, 0.95);
				}
			case 'gf' | 'girlfriend':
				newChar.setPosition(swapOffsets[2], swapOffsets[3]);
				newChar.x += newChar.gfOffsetX;
				newChar.y += newChar.gfOffsetY;
				newChar.scrollFactor.set(0.95, 0.95);
		}
		return newChar;
	}

	function switchToChar(daCharacter:Character, charState:String) {
		switch(charState) {
			case 'boyfriend' | 'bf' | 'player1':
				remove(boyfriend);
				if (!opponentPlayer && !demoMode)
					daCharacter.beingControlled = true;
				boyfriend = daCharacter;
				iconP1.switchAnim(daCharacter.curCharacter);
				add(boyfriend);
			case 'dad' | 'opponent' | 'player2':
				remove(dad);
				if (duoMode || opponentPlayer)
					daCharacter.beingControlled = true;
				dad = daCharacter;
				iconP2.switchAnim(daCharacter.curCharacter);
				add(dad);
			case 'gf' | 'girlfriend':
				remove(gf);
				gf = daCharacter;
				remove(boyfriend);
				remove(dad);
				add(gf);
				add(boyfriend);
				add(dad);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			controls.setKeyboardScheme(Solo(false));
			#if windows
			var ae = FNFAssets.getText("assets/discord/presence/playpause.txt");
			DiscordClient.changePresence(ae
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC, null, null, playingAsRpc);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();
			if (!opponentPlayer && !duoMode)
				controls.setKeyboardScheme(Solo(false));
			if (duoMode)
				controls.setKeyboardScheme(Duo(true));
			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			setAllHaxeVar("paused", paused);
			var currentIconState = "";
			if (opponentPlayer) {
				if (healthBar.percent > 80) {
					currentIconState = "Dying";
				} else {
					currentIconState = "Playing";
				}
				if (poisonTimes != 0) {
					currentIconState = "Being Posioned";
				}
			} else {
				if (healthBar.percent > 20) {
					currentIconState = "Dying";
				} else {
					currentIconState = "Playing";
				}
				if (poisonTimes != 0) {
					currentIconState = "Being Posioned";
				}
			}
			#if windows
			if (startTimer.finished) {
				DiscordClient.changePresence(customPrecence
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition, playingAsRpc);
			} else {
				DiscordClient.changePresence(customPrecence, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy), iconRPC,
					playingAsRpc);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void {
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		
		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,
			playingAsRpc);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float) {
		#if !debug
		perfectModeOld = false;
		#end
		oldStrumlineX = strumLine.x;
		setAllHaxeVar('camZooming', camZooming);
		setAllHaxeVar('gfSpeed', gfSpeed);
		setAllHaxeVar('health', health);
		callAllHScript('update', [elapsed]);
		
		if (hscriptStates.exists("modchart")) {
			if (getHaxeVar("showOnlyStrums", "modchart"))
			{
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}
			camZooming = getHaxeVar("camZooming", "modchart");
			gfSpeed = getHaxeVar("gfSpeed", "modchart");
			//health = getHaxeVar("health", "modchart");
		}

		var joe = notesHitArray.length-1;
		while (joe >= 0)
		{
			var mama:Date = notesHitArray[joe];
			if (mama != null && mama.getTime() + 1000 < Date.now().getTime())
				notesHitArray.remove(mama);
			else
				joe = 0;
			joe--;
		}
		nps = notesHitArray.length;
		setAllHaxeVar('nps', nps);

		super.update(elapsed);
		if (snapToStrumline) {
			notes.forEachAlive(function(daNote) {
				var noteData = daNote.noteData;
				if (daNote.mustPress)
					noteData += 4; 
				daNote.x = strumLineNotes.members[noteData].x;
				if (daNote.isSustainNote)
					daNote.x += defaultNoteWidth / 2 - daNote.width / 2; 
			});
			for (i in 0...playerStrums.members.length)  {
				playerComboBreak.members[i].x = playerStrums.members[i].x;
			}
			for (i in 0...enemyStrums.members.length) {
				enemyComboBreak.members[i].x = enemyStrums.members[i].x;
			}
		}
		var properHealth = opponentPlayer ? 100 - Math.round(health*50) : Math.round(health*50);
		healthTxt.text = "Health:" + properHealth + "%";
		/*
		switch (OptionsHandler.options.accuracyMode) {
			case Simple | Binary | Complex: 
				if (notesPassing != 0)
					accuracy = HelperFunctions.truncateFloat((notesHit / notesPassing) * 100, 2);
				else
					accuracy = 100;
			case None:
				accuracy = 0;
		}*/
		if (disableScoreChange == false) {
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, accuracy);
		}
		if (perfectMode && !Ratings.CalculateFullCombo(Sick))
		{
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		if (fullComboMode && !Ratings.CalculateFullCombo(Bad)) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		if (goodCombo && !Ratings.CalculateFullCombo(Good)) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		accuracyTxt.text = "Accuracy:" + accuracy + "%";
		if (FlxG.keys.justPressed.G)
			resyncVocals();
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			setAllHaxeVar("paused", paused);

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN && !OptionsHandler.options.danceMode)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			LoadingState.loadAndSwitchState(new ChartingState());
		}
		if (FlxG.keys.justPressed.NINE) {
			oldMode = !oldMode;
			if (oldMode) {
				if (boyfriend.isPixel)
					iconP1.switchAnim("bf-pixel-old");
				else
					iconP1.switchAnim("bf-old");
			} else {
				iconP1.switchAnim(SONG.player1);
			}
		}
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		practiceDieIcon.setGraphicSize(Std.int(FlxMath.lerp(150, practiceDieIcon.width, 0.50)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		practiceDieIcon.updateHitbox();
		var iconOffset:Int = 26;
		
		if (poisonTimes > 0 && !barShowingPoison) {
			var leftSideFill = opponentPlayer ? dad.poisonColorEnemy : dad.enemyColor;
			var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.poisonColor;
			healthBar.createFilledBar(leftSideFill, rightSideFill);
			barShowingPoison = true;
		} else if (poisonTimes == 0 && barShowingPoison) {
			var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
			var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
			if (duoMode) {
				leftSideFill = dad.opponentColor;
				rightSideFill = boyfriend.bfColor;
			}
			healthBar.createFilledBar(leftSideFill, rightSideFill);
			barShowingPoison = false;
		}

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		player1Icon = SONG.player1;
		switch(SONG.player1) {
			case "bf-car":
				player1Icon = "bf";
			case "bf-christmas":
				player1Icon = "bf";
			case "bf-holding-gf":
				player1Icon = "bf";
			case "monster-christmas":
				player1Icon = "monster";
			case "mom-car":
				player1Icon = "mom";
			case "pico-speaker":
				player1Icon = "pico";
			case "gf-car":
				player1Icon = "gf";
			case "gf-christmas":
				player1Icon = "gf";
			case "gf-pixel":
				player1Icon = "gf";
			case "gf-tankman":
				player1Icon = "gf";
				
		}
		if (healthBar.percent < 20) {
			iconP1.iconState = Dying;
			iconP2.iconState = Winning;
			#if windows
			iconRPC = player1Icon + "-dead";
			#end
		} else {
			iconP1.iconState = Normal;
			#if windows
			iconRPC = player1Icon;
			#end
		}
		if (!opponentPlayer && poisonTimes != 0) {
			iconP1.iconState = Poisoned;
			#if windows
			iconRPC = player1Icon + "-dazed";
			#end
		}	
		
		// duo mode shouldn't show low health
		if (properHealth < 20 && !duoMode) {
			healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.RED, RIGHT, OUTLINE, FlxColor.BLACK);
		} else {
			healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		}	
		player2Icon = SONG.player2;
		switch (SONG.player2)
		{
			case "bf-car":
				player2Icon = "bf";
			case "bf-christmas":
				player2Icon = "bf";
			case "bf-holding-gf":
				player2Icon = "bf";
			case "monster-christmas":
				player2Icon = "monster";
			case "mom-car":
				player2Icon = "mom";
			case "pico-speaker":
				player2Icon = "pico";
			case "gf-car":
				player2Icon = "gf";
			case "gf-christmas":
				player2Icon = "gf";
			case "gf-pixel":
				player2Icon = "gf";
			case "gf-tankman":
				player2Icon = "gf";
		}

		if (healthBar.percent > 80) {
			iconP2.iconState = Dying;
			if (iconP1.iconState != Poisoned) {
				iconP1.iconState = Winning;
			}
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon + "-dead";
			#end
		} else {
			iconP2.iconState = Normal;
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon;
			#end
		}
		if (healthBar.percent < 20) {
			iconP2.iconState = Winning;
		}
		if (poisonTimes != 0 && opponentPlayer) {
			iconP2.iconState = Poisoned;
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon + "-dazed";
			#end
		}

		if (FlxG.keys.justPressed.EIGHT && !OptionsHandler.options.danceMode) // stop checking for debug so i can fix my offsets!
			LoadingState.loadAndSwitchState(new AnimationDebug(SONG.player2, SONG.player1));
		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition / songLength;
			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camNotes) {
			if (dad.camOffsets.exists(dad.animation.curAnim.name)) {
				var daCam = dad.camOffsets.get(dad.animation.curAnim.name);
				dadcam = [daCam[0], daCam[1]];
			} else {
				var dadAnim = dad.animation.curAnim.name.split('-');
				switch(dadAnim[0]) {
					case 'singLEFT':
						dadcam = [-25, 0];
					case 'singRIGHT':
						dadcam = [25, 0];
					case 'singUP':
						dadcam = [0, -25];
					case 'singDOWN':
						dadcam = [0, 25];
					default:
						dadcam = [0, 0];
				}
			}

			if (boyfriend.camOffsets.exists(boyfriend.animation.curAnim.name)) {
				var daCam = boyfriend.camOffsets.get(boyfriend.animation.curAnim.name);
				bfcam = [daCam[0], daCam[1]];
			} else {
				var boyfriendAnim = boyfriend.animation.curAnim.name.split('-');
				switch(boyfriendAnim[0]) {
					case 'singLEFT':
						bfcam = [-25, 0];
					case 'singRIGHT':
						bfcam = [25, 0];
					case 'singUP':
						bfcam = [0, -25];
					case 'singDOWN':
						bfcam = [0, 25];
					default:
						bfcam = [0, 0];
				}
			}
		}

		if (endingSong)
			return;
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {
			setAllHaxeVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) {
				switch(scriptableCamera) {
					case 'static':
						camFollow.setPosition(scriptCamPos[0], scriptCamPos[1]);
					case 'char':
						camFollow.setPosition(scriptCamPos[2], scriptCamPos[3]);
					default:
						camFollow.setPosition(dad.getMidpoint().x + dad.followCamX + dadcam[0], dad.getMidpoint().y + dad.followCamY + dadcam[1]);
				}
				callAllHScript("playerTwoTurn", []);
				vocals.volume = 1;
			}
			var currentIconState = "";
			if (opponentPlayer) {
				if (healthBar.percent > 80) {
					currentIconState = "Dying";
				} else {
					currentIconState = "Playing";
				}
				if (poisonTimes != 0) {
					currentIconState = "Being Posioned";
				}
			} else {
				if (healthBar.percent < 20) {
					currentIconState = "Dying";
				} else {
					currentIconState = "Playing";
				}
				if (poisonTimes != 0) {
					currentIconState = "Being Posioned";
				}
			}
			if (supLove) {
				health += loveMultiplier * (opponentPlayer ? -1 : 1) / 600000;
			}
			if (poisonExr) {
				health -= poisonMultiplier * (opponentPlayer ? -1 : 1)/ 700000;
			}
			playingAsRpc = "Playing as " + (opponentPlayer ? player2Icon : player1Icon) + " | " + currentIconState;
			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) {
				switch(scriptableCamera) {
					case 'static' | 'char':
						camFollow.setPosition(scriptCamPos[0], scriptCamPos[1]);
					default:
						camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.followCamX + bfcam[0], boyfriend.getMidpoint().y - 100 + boyfriend.followCamY + bfcam[1]);
				}
				callAllHScript("playerOneTurn", []);
				
				/*
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
				*/
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (FlxG.keys.justPressed.R && !duoMode) {
			if (opponentPlayer)
				health = 2;
			else
				health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT) {
			health += 1;
			trace("User is cheating!");
		}

		if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceMode && !duoMode) {
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			setAllHaxeVar("paused", paused);

			vocals.stop();
			FlxG.sound.music.stop();

			Application.current.window.title = "Friday Night Disappointin' Modding Plus | with EK mod by Discussions - " + PlayState.SONG.song + " on "+ DifficultyIcons.changeDifficultyFreeplay(storyDifficulty, 0).text + " Mode - DEAD";
			
			if (inALoop) {
				FlxG.resetState();
			} else {
				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					LoadingState.loadAndSwitchState(new GitarooPause());
				}
				else
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, null, null,
					playingAsRpc);
				#end

			}

			
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		else if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceDied && practiceMode) {
			practiceDied = true;
			practiceDieIcon.visible = true;
		}
		health = FlxMath.bound(health,0,2);
		if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			switch(mania)
			{
			case 0: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				bfsDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 1: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
				bfsDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
			case 2: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
				bfsDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'Hey', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 3: 
				sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
				bfsDir = ['LEFT', 'DOWN', 'Hey', 'UP', 'RIGHT'];
			case 4: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
				bfsDir = ['LEFT', 'UP', 'RIGHT', 'Hey', 'LEFT', 'DOWN', 'RIGHT'];
			case 5: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
				bfsDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 6: 
				sDir = ['UP'];
				bfsDir = ['Hey'];
			case 7: 
				sDir = ['LEFT', 'RIGHT'];
				bfsDir = ['LEFT', 'RIGHT'];
			case 8:
				sDir = ['LEFT', 'UP', 'RIGHT'];
				bfsDir = ['LEFT', 'Hey', 'RIGHT'];
			}
			if (generatedMusic)
				{
					var l1c = FlxG.keys.checkStatus(FlxKey.fromString(FlxG.save.data.keys.L1Bind), FlxInputState.PRESSED);
					switch(maniaToChange)
					{
						case 0: 
							hold = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
						case 1: 
							hold = [l1c, controls.U1, controls.R1, controls.L2, controls.D1, controls.R2];
						case 2: 
							hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N4, controls.N5, controls.N6, controls.N7, controls.N8];
						case 3: 
							hold = [controls.LEFT, controls.DOWN, controls.N4, controls.UP, controls.RIGHT];
						case 4: 
							hold = [l1c, controls.U1, controls.R1, controls.N4, controls.L2, controls.D1, controls.R2];
						case 5: 
							hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N5, controls.N6, controls.N7, controls.N8];
						case 6: 
							hold = [controls.N4];
						case 7: 
							hold = [controls.LEFT, controls.RIGHT];
						case 8: 
							hold = [controls.LEFT, controls.N4, controls.RIGHT];
	
						case 10: //changing mid song (mania + 10, seemed like the best way to make it change without creating more switch statements)
							hold = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT,false,false,false,false,false];
						case 11: 
							hold = [l1c, controls.D1, controls.U1, controls.R1, false, controls.L2, false, false, controls.R2];
						case 12: 
							hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N4, controls.N5, controls.N6, controls.N7, controls.N8];
						case 13: 
							hold = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT, controls.N4,false,false,false,false];
						case 14: 
							hold = [l1c, controls.D1, controls.U1, controls.R1, controls.N4, controls.L2, false, false, controls.R2];
						case 15:
							hold = [controls.N0, controls.N1, controls.N2, controls.N3, false, controls.N5, controls.N6, controls.N7, controls.N8];
						case 16: 
							hold = [false, false, false, false, controls.N4, false, false, false, false];
						case 17: 
							hold = [controls.LEFT, false, false, controls.RIGHT, false, false, false, false, false];
						case 18: 
							hold = [controls.LEFT, false, false, controls.RIGHT, controls.N4, false, false, false, false];
					}
				}
			var holdArray:Array<Bool> = hold;
			notes.forEachAlive(function(daNote:Note) {
				/*if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = !invsNotes;
					daNote.active = true;
				}*/
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}
				var coolMustPress = daNote.mustPress;
				if (duoMode)
					coolMustPress = true;
				if (opponentPlayer)
					coolMustPress = !daNote.mustPress;
							
				if (!daNote.modifiedByLua) {
					if (downscroll) {
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? daScrollSpeed : FlxG.save.data.scrollSpeed,
									2));
						else
							daNote.y = (enemyStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? daScrollSpeed : FlxG.save.data.scrollSpeed,
									2));
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;
							
							if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								&& (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height) >= (strumLine.y + Note.swagWidth / 2)
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								// Clip to strumline
								// upon further inspection, this is purely visual :hueh:
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}

						}
					} else {
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? daScrollSpeed : FlxG.save.data.scrollSpeed,
									2));
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? daScrollSpeed : FlxG.save.data.scrollSpeed,
									2));
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
							
						}
						}
					}
					/*
					if (downscroll) {
						daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(daScrollSpeed, 2)));
					} else {
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(daScrollSpeed, 2)));
					}
					

					// i am so fucking sorry for this if condition
					if (daNote.isSustainNote
						&& (((daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2) && !downscroll)
						|| (downscroll && (daNote.y + daNote.offset.y >= strumLine.y + Note.swagWidth / 2)))
						&& (((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && !opponentPlayer && !duoMode)
						|| ((daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && opponentPlayer)))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}*/
				
				

				if (!daNote.mustPress && daNote.wasGoodHit && ((!duoMode && !opponentPlayer) || demoMode)) {
					camZooming = true;
					dad.altAnim = "";
					dad.altNum = 0;
					if (daNote.altNote) {
						dad.altAnim = '-alt';
						dad.altNum = 1;
					}
					dad.altNum = daNote.altNum;
					if (SONG.notes[Math.floor(curStep / 16)] != null) {
						if ((SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0 && SONG.notes[Math.floor(curStep / 16)].altAnimNum != null) || SONG.notes[Math.floor(curStep / 16)].altAnim)
							// backwards compatibility shit
							if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1 || SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.altNote)
								dad.altNum = 1;
							else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum != 0)
								dad.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
					}
					
					if (dad.altNum == 1) {
						dad.altAnim = '-alt';
					} else if (dad.altNum > 1) {
						dad.altAnim = '-' + dad.altNum + 'alt';
					}
					callAllHScript("playerTwoSing", []);
					// go wild <3
					if (daNote.shouldBeSung) {
						dad.singBetter('sing' + sDir[daNote.noteData], false, dad.altNum);
						//dad.playAnim('sing' + sDir[daNote.noteData] + dad.altAnim , true);
						enemyStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
								sustain2(spr.ID, spr, daNote);
							}
						});
						if (daNote.oppntSing != null) {
							boyfriend.singBetter('sing' + bfsDir[daNote.noteData], daNote.oppntSing.miss, daNote.oppntSing.alt);
						}
					}

					if (daNote.noteHit != null)
						callHscript(daNote.noteHit, [], "modchart");

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				} else if (daNote.mustPress && daNote.wasGoodHit && (opponentPlayer || demoMode)) {
					camZooming = true;
					callAllHScript("playerOneSing", []);
					if (daNote.shouldBeSung) {
						boyfriend.singBetter('sing' + bfsDir[daNote.noteData]);
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									switch(maniaToChange)
									{
										case 0: 
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 1: 
											spr.offset.x -= 16;
											spr.offset.y -= 16;
										case 2: 
											spr.offset.x -= 22;
											spr.offset.y -= 22;
										case 3: 
											spr.offset.x -= 15;
											spr.offset.y -= 15;
										case 4: 
											spr.offset.x -= 18;
											spr.offset.y -= 18;
										case 5: 
											spr.offset.x -= 20;
											spr.offset.y -= 20;
										case 6: 
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 7: 
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 8:
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 10: 
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 11: 
											spr.offset.x -= 16;
											spr.offset.y -= 16;
										case 12: 
											spr.offset.x -= 22;
											spr.offset.y -= 22;
										case 13: 
											spr.offset.x -= 15;
											spr.offset.y -= 15;
										case 14: 
											spr.offset.x -= 18;
											spr.offset.y -= 18;
										case 15: 
											spr.offset.x -= 20;
											spr.offset.y -= 20;
										case 16: 
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 17: 
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										case 18:
											spr.offset.x -= 13;
											spr.offset.y -= 13;
									}
								}
								else
									spr.centerOffsets();
						});
						if (daNote.oppntSing != null) {
							dad.singBetter('sing' + sDir[daNote.noteData], daNote.oppntSing.miss, daNote.oppntSing.alt);
							// don't strum it because there isn't actually a note
						}
					}

					if (daNote.noteHit != null)
						callHscript(daNote.noteHit, [], "modchart");

					boyfriend.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var neg = downscroll ? -1 : 1;
				if (drunkNotes) {
					daNote.y = (strumLine.y - neg * (Conductor.songPosition - daNote.strumTime) * ((Math.sin(songTime/400)/6)+0.5) * noteSpeed * FlxMath.roundDecimal(daScrollSpeed, 2));
				} else {
					daNote.y = (strumLine.y - neg * (Conductor.songPosition - daNote.strumTime) * (noteSpeed * FlxMath.roundDecimal(daScrollSpeed, 2)));
				}
				if (vnshNotes) {
					if (downscroll) {
						daNote.alpha = FlxMath.remapToRange(-daNote.y, -strumLine.y,0 , 0, 1);
					} else {
						daNote.alpha = FlxMath.remapToRange(daNote.y, strumLine.y, FlxG.height, 0, 1);
					}
				}
					
				if (snakeNotes) {
					if (daNote.mustPress) {
						daNote.x = (FlxG.width/2)+snekNumber+(Note.swagWidth*daNote.noteData)+50;
					} else {
						daNote.x = snekNumber+(Note.swagWidth*daNote.noteData)+50;
					}
				}
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				// this is not work well >:(
				if ((daNote.y >= getHaxeActor('0').y - 20 && daNote.y <= getHaxeActor('0').y + 20) && daNote.noteStrum != null) {
					callHscript(daNote.noteStrum, [], "modchart");
					daNote.noteStrum = null;
				}

				if (((daNote.y < -daNote.height && !downscroll) || (daNote.y > FlxG.height + daNote.height && downscroll)) && !daNote.dontCountNote) {

						if ((daNote.tooLate || !daNote.wasGoodHit) /* && !daNote.isSustainNote */) {
							// always show the graphic
							noteMiss(daNote.noteData, true, daNote, false);
							//popUpScore(Conductor.songPosition, daNote, daNote.mustPress, true);
							if (!OptionsHandler.options.dontMuteMiss)
								vocals.volume = 0;
							if (poisonPlus && poisonTimes < 3)
							{
								poisonTimes += 1;
								var poisonPlusTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									if (opponentPlayer)
										health += 0.04;
									else
										health -= 0.04;
								}, 0);
								// stop timer after 3 seconds
								new FlxTimer().start(3, function(tmr:FlxTimer)
								{
									poisonPlusTimer.cancel();
									poisonTimes -= 1;
								});
							}
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
				}
				if ((!duoMode && !opponentPlayer) || demoMode) {
					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (strumming2[spr.ID])
						{
							spr.animation.play("confirm", true);
						}

						if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !daNote.isPixel)
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});
				} 
				if (opponentPlayer || demoMode) {
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && SONG.uiType != 'pixel')
							{
								spr.centerOffsets();
								switch(maniaToChange)
								{
									case 0: 
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 1: 
										spr.offset.x -= 16;
										spr.offset.y -= 16;
									case 2: 
										spr.offset.x -= 22;
										spr.offset.y -= 22;
									case 3: 
										spr.offset.x -= 15;
										spr.offset.y -= 15;
									case 4: 
										spr.offset.x -= 18;
										spr.offset.y -= 18;
									case 5: 
										spr.offset.x -= 20;
										spr.offset.y -= 20;
									case 6: 
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 7: 
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 8:
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 10: 
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 11: 
										spr.offset.x -= 16;
										spr.offset.y -= 16;
									case 12: 
										spr.offset.x -= 22;
										spr.offset.y -= 22;
									case 13: 
										spr.offset.x -= 15;
										spr.offset.y -= 15;
									case 14: 
										spr.offset.x -= 18;
										spr.offset.y -= 18;
									case 15: 
										spr.offset.x -= 20;
										spr.offset.y -= 20;
									case 16: 
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 17: 
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 18:
										spr.offset.x -= 13;
										spr.offset.y -= 13;
								}
							}
							else
								spr.centerOffsets();
					});
				}
				
			});
		}

		if (!inCutscene && !demoMode) {
			// is that why it was crashing
			if (!opponentPlayer)
				keyShit(true);
			if (duoMode || opponentPlayer)
			{
				keyShit(false);
			}
		}
			

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}
	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
	{
		var length:Float = note.sustainLength;
		/*if (length > 0)
		{
			if (opponentPlayer)
				strumming1[strum] = true;
			else
				strumming2[strum] = true;
		}*/

		var bps:Float = Conductor.bpm / 60;
		var spb:Float = 1 / bps;

		if (!note.isSustainNote)
		{
			new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
			{
				if (spr.animation.curAnim.finished) {
					spr.animation.play('static', true);
				} else {
					tmr.reset(0.1);
				}

				/*if (opponentPlayer) {
					if (!strumming1[strum])
					{
						spr.animation.play("static", true);
					}
					else if (length > 0)
					{
						strumming1[strum] = false;
						spr.animation.play("static", true);
					}
				} else {
					if (!strumming2[strum])
					{
						spr.animation.play("static", true);
					}
					else if (length > 0)
					{
						strumming2[strum] = false;
						spr.animation.play("static", true);
					}
				}*/
			});
		}
	}
	function endSong():Void
	{
		endingSong = true;
		canPause = false;
		FlxG.sound.music.volume = 0;
		if (!OptionsHandler.options.dontMuteMiss)
			vocals.volume = 0;
		vocals.pause();
		trace(vocals.getActualVolume());
		var dialogSuffix = "-end";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix += "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix += "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix += "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix += "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix += "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix += "-depressed";
		} else if (practiceMode) {
			dialogSuffix += "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix += "-perfect";
		}
		var filename:Null<String> = null;
		if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt'))
		{	
			filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		}
		else if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt'))
		{
			filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		}
		else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog-end.txt'))
		{
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog-end.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt'))
			{
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		}
		else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue-end.txt'))
		{
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue-end.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt'))
			{
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}
		// never play it if the file doesn't exist
		if ((OptionsHandler.options.alwaysDoCutscenes || isStoryMode) && filename != null) {
			doof = new DialogueBox(false, goodDialog);
			doof.scrollFactor.set();
			doof.finishThing = endForReal;

			doof.cameras = [camHUD];
			schoolIntro(doof, false);
		} else {
			endForReal();
		}
		
	}
	function endForReal() {
		#if !switch
		if (!demoMode && ModifierState.scoreMultiplier > 0)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, accuracy / 100, Ratings.CalculateFCRating(), OptionsHandler.options.judge);
		#end
		controls.setKeyboardScheme(Solo(false));
		if (isStoryMode) {
			campaignScore += songScore;
			campaignScoreDef += songScoreDef;
			campaignAccuracy += accuracy;
			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				if (!demoMode && ModifierState.scoreMultiplier > 0)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty, campaignAccuracy / defaultPlaylistLength);
				campaignAccuracy = campaignAccuracy / defaultPlaylistLength;
				if (useVictoryScreen)
				{
					#if windows
					DiscordClient.changePresence("Reviewing Score -- "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, playingAsRpc);
					#end
					LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,
						gf.getScreenPosition().x, gf.getScreenPosition().y, campaignAccuracy, campaignScore, dad.getScreenPosition().x,
						dad.getScreenPosition().y));
				} else {
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					LoadingState.loadAndSwitchState(new StoryMenuState());
				}
				FlxG.save.flush();
			} else {
				var difficulty:String = "";

				difficulty = DifficultyIcons.getEndingFP(storyDifficulty);
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog') {
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (SONG.song.toLowerCase() == 'senpai') {
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
				}
				if (FNFAssets.exists('assets/data/'
					+ PlayState.storyPlaylist[0].toLowerCase() + '/' + PlayState.storyPlaylist[0].toLowerCase() + difficulty + '.json'))
					// do this to make custom difficulties not as unstable
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				else
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			if (useVictoryScreen) {
				#if windows
				DiscordClient.changePresence("Reviewing Score -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, playingAsRpc);
				#end
				LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,
					gf.getScreenPosition().x, gf.getScreenPosition().y, accuracy, songScore, dad.getScreenPosition().x, dad.getScreenPosition().y));
			} else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	var timeShown:Int = 0;
	private function popUpScore(strumtime:Float, daNote:Note, playerOne:Bool, forceMiss:Bool = false):Void {
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var noteDiffSigned:Float = Conductor.songPosition - daNote.strumTime;
		var wife:Float = HelperFunctions.wife3(noteDiffSigned, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		camZooming = true;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		if (daNote.mineNote)
			// make note diff sussy and harder to hit because mine notes are weird champ
			noteDiff *= 1.9;
		if (daNote.nukeNote)
			noteDiff *= 3;
		daNote.rating = Ratings.CalculateRating(noteDiff);
		daRating = daNote.rating;
		trace(daRating);
		var healthBonus = 0.0;
		// you can't really control how you hit sustains so always make em sick
		if (daNote.isSustainNote) {
			daRating = 'sick';
		}
		if (forceMiss) {
			daRating = 'miss';
		}
		if (OptionsHandler.options.accuracyMode == Complex)
			totalNotesHit += wife;
		
		// SHIT IS A COMBO BREAKER IN ETTERNA NERDS
		// GIT GUD
		var dontCountNote = daNote.dontCountNote;
		if (!daNote.mineNote) {
			switch (daRating)
			{
				case 'shit':
					if (!dontCountNote)
					{
						ss = false;
						shits++;
						
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						} 
						misses++;
						setAllHaxeVar("misses", misses);
						score = -300;
						combo = 0;
						setAllHaxeVar("combo", combo);
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'wayoff':
					if (!dontCountNote)
					{
						score = -300;
						combo = 0;
						setAllHaxeVar("combo", combo);
						misses++;
						setAllHaxeVar("misses", misses);
						ss = false;
						shits++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						}
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'bad':
					if (!dontCountNote)
					{
						score = 0;
						ss = false;
						bads++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 0.50;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
					}
					daRating = 'bad';

					// healthBonus -= 0.03 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'good':
					if (!dontCountNote)
					{
						score = 200;
						ss = false;
						goods++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 0.75;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
					}
					daRating = 'good';

					// healthBonus += 0.03 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;

				case 'sick':
					// healthBonus += 0.07 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;
					if (!dontCountNote)
					{
						// if it be binary or not
						// it shall be a 1
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 1;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
						sicks++;
					}

					if (!daNote.isSustainNote && useNoteSplashes)
					{
						var recycledNote = grpNoteSplashes.recycle(NoteSplash);
						recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
						grpNoteSplashes.add(recycledNote);
					}

				case 'miss':
					// noteMiss(daNote.noteData, playerOne);
					// healthBonus = -0.04 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;
					if (!dontCountNote)
					{
						misses++;
						setAllHaxeVar("misses", misses);
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						}
						ss = false;
						score = -5;
					}
			}
		}
		if (daNote.nukeNote && daRating != 'miss')
			// die <3
			healthBonus = -4;
		healthBonus = daNote.getHealth(daRating);
		if (daNote.dontEdit)
			trace(healthBonus);
		if (daNote.isSustainNote) {
			healthBonus  *= 0.2;
		}
		if (!playerOne)
			health -= healthBonus;
		else
			health += healthBonus;
		updateAccuracy();
		if (daNote.isSustainNote) {
			return;
		}
		if (notesHit > notesPassing) {
			notesHit = notesPassing;
		}
		if (!dontCountNote) {
			songScore += Math.round(ConvertScore.convertScore(noteDiff) * ModifierState.scoreMultiplier);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
			trueScore += Math.round(ConvertScore.convertScore(noteDiff));
		}
		comboBreak(daNote.noteData % 4, playerOne, daRating);

		setAllHaxeVar('songScore', songScore);
		setAllHaxeVar('songScoreDef', songScoreDef);

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		if (uiSmelly.isPixel) {
			pixelShitPart2 = '-pixel';
		}
		var ratingImage:BitmapData;
		ratingImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/' + daRating + pixelShitPart2 + ".png");
		trace(pixelUI);
		rating = new Judgement(0, 0, daRating, preferredJudgement,
			noteDiffSigned < 0, pixelUI);
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		if (OptionsHandler.options.newJudgementPos) {
			rating.cameras = [camHUD];
			rating.y = 0;
			rating.x = 0;
			if (!downscroll) {
				rating.y = FlxG.height - rating.height;
			}
			
		}
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(ratingImage);
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		var msTiming = HelperFunctions.truncateFloat(noteDiffSigned, 3);
		if (FlxG.save.data.botplay)
			msTiming = 0;
		timeShown = 0;
		if (currentTimingShown != null)
			remove(currentTimingShown);

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
		switch (daRating)
		{
			case 'miss':
				currentTimingShown.color = FlxColor.MAGENTA;
			case 'shit' | 'bad' | 'wayoff':
				currentTimingShown.color = FlxColor.RED;
			case 'good':
				currentTimingShown.color = FlxColor.GREEN;
			case 'sick':
				currentTimingShown.color = FlxColor.CYAN;
		}
		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 1;
		currentTimingShown.borderColor = FlxColor.BLACK;
		currentTimingShown.text = msTiming + "ms";
		currentTimingShown.size = 20;


		if (currentTimingShown.alpha != 1)
			currentTimingShown.alpha = 1;

		if (!demoMode && useTimings)
			add(currentTimingShown);
		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		currentTimingShown.screenCenter();
		currentTimingShown.x = comboSpr.x + 100;
		currentTimingShown.y = rating.y + 100;
		currentTimingShown.acceleration.y = 600;
		currentTimingShown.velocity.y -= 150;
		var daLoop:Int = 0;
		for (i in seperatedScore) {
			var numImage:BitmapData;
			if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + Std.int(i) + pixelShitPart2 + ".png"))
				numImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + Std.int(i) + pixelShitPart2 + ".png");
			else
				numImage = FNFAssets.getBitmapData('assets/images/num' + Std.int(i) + '.png');
			var numScore:FlxSprite = new FlxSprite().loadGraphic(numImage);
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!pixelUI)
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		currentTimingShown.cameras = [camHUD];
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween)
			{
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			},
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
				if (currentTimingShown != null && timeShown >= 20)
				{
					remove(currentTimingShown);
					currentTimingShown = null;
				}
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
		if (daNote.nukeNote && daRating != 'miss') {
			if (!playerOne)
				health = 69;
			else
				health = -69;
		}
	}
	function updateAccuracy() {
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		setAllHaxeVar('accuracy', accuracy);
	}
	var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;
		var l1Hold:Bool = false;
		var uHold:Bool = false;
		var r1Hold:Bool = false;
		var l2Hold:Bool = false;
		var dHold:Bool = false;
		var r2Hold:Bool = false;
	
		var n0Hold:Bool = false;
		var n1Hold:Bool = false;
		var n2Hold:Bool = false;
		var n3Hold:Bool = false;
		var n4Hold:Bool = false;
		var n5Hold:Bool = false;
		var n6Hold:Bool = false;
		var n7Hold:Bool = false;
		var n8Hold:Bool = false;
		// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)
	private function keyShit(?playerOne:Bool = true):Void {
		// HOLDING
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var up = coolControls.UP;
		var right = coolControls.RIGHT;
		var down = coolControls.DOWN;
		var left = coolControls.LEFT;
		var holdArray = [left, down, up, right];
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		
		var upR = coolControls.UP_R;
		var rightR = coolControls.RIGHT_R;
		var downR = coolControls.DOWN_R;
		var leftR = coolControls.LEFT_R;
		var releaseArray = [leftR, downR, upR, rightR];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var pressArray = controlArray;
		// FlxG.watch.addQuick('asdfa', upP);
		var actingOn:Character = playerOne ? boyfriend : dad;
		// <3 easy way of doing it
		// control arrays, order L D R U
				switch(maniaToChange)
				{
					case 0: 
						//hold = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
						press = [
							controls.LEFT_P,
							controls.DOWN_P,
							controls.UP_P,
							controls.RIGHT_P
						];
						release = [
							controls.LEFT_R,
							controls.DOWN_R,
							controls.UP_R,
							controls.RIGHT_R
						];
					case 1: 
						//hold = [controls.L1, controls.U1, controls.R1, controls.L2, controls.D1, controls.R2];
						press = [
							controls.L1_P,
							controls.U1_P,
							controls.R1_P,
							controls.L2_P,
							controls.D1_P,
							controls.R2_P
						];
						release = [
							controls.L1_R,
							controls.U1_R,
							controls.R1_R,
							controls.L2_R,
							controls.D1_R,
							controls.R2_R
						];
					case 2: 
						//hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N4, controls.N5, controls.N6, controls.N7, controls.N8];
						press = [
							controls.N0_P,
							controls.N1_P,
							controls.N2_P,
							controls.N3_P,
							controls.N4_P,
							controls.N5_P,
							controls.N6_P,
							controls.N7_P,
							controls.N8_P
						];
						release = [
							controls.N0_R,
							controls.N1_R,
							controls.N2_R,
							controls.N3_R,
							controls.N4_R,
							controls.N5_R,
							controls.N6_R,
							controls.N7_R,
							controls.N8_R
						];
					case 3: 
						//hold = [controls.LEFT, controls.DOWN, controls.N4, controls.UP, controls.RIGHT];
						press = [
							controls.LEFT_P,
							controls.DOWN_P,
							controls.N4_P,
							controls.UP_P,
							controls.RIGHT_P
						];
						release = [
							controls.LEFT_R,
							controls.DOWN_R,
							controls.N4_R,
							controls.UP_R,
							controls.RIGHT_R
						];
					case 4: 
						//hold = [controls.L1, controls.U1, controls.R1, controls.N4, controls.L2, controls.D1, controls.R2];
						press = [
							controls.L1_P,
							controls.U1_P,
							controls.R1_P,
							controls.N4_P,
							controls.L2_P,
							controls.D1_P,
							controls.R2_P
						];
						release = [
							controls.L1_R,
							controls.U1_R,
							controls.R1_R,
							controls.N4_R,
							controls.L2_R,
							controls.D1_R,
							controls.R2_R
						];
					case 5: 
						//hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N5, controls.N6, controls.N7, controls.N8];
						press = [
							controls.N0_P,
							controls.N1_P,
							controls.N2_P,
							controls.N3_P,
							controls.N5_P,
							controls.N6_P,
							controls.N7_P,
							controls.N8_P
						];
						release = [
							controls.N0_R,
							controls.N1_R,
							controls.N2_R,
							controls.N3_R,
							controls.N5_R,
							controls.N6_R,
							controls.N7_R,
							controls.N8_R
						];
					case 6: 
						//hold = [controls.N4];
						press = [
							controls.N4_P
						];
						release = [
							controls.N4_R
						];
					case 7: 
					//	hold = [controls.LEFT, controls.RIGHT];
						press = [
							controls.LEFT_P,
							controls.RIGHT_P
						];
						release = [
							controls.LEFT_R,
							controls.RIGHT_R
						];
					case 8: 
						//hold = [controls.LEFT, controls.N4, controls.RIGHT];
						press = [
							controls.LEFT_P,
							controls.N4_P,
							controls.RIGHT_P
						];
						release = [
							controls.LEFT_R,
							controls.N4_R,
							controls.RIGHT_R
						];
					case 10: //changing mid song (mania + 10, seemed like the best way to make it change without creating more switch statements)
						press = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P,false,false,false,false,false];
						release = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R,false,false,false,false,false];
					case 11: 
						press = [controls.L1_P, controls.D1_P, controls.U1_P, controls.R1_P, false, controls.L2_P, false, false, controls.R2_P];
						release = [controls.L1_R, controls.D1_R, controls.U1_R, controls.R1_R, false, controls.L2_R, false, false, controls.R2_R];
					case 12: 
						press = [controls.N0_P, controls.N1_P, controls.N2_P, controls.N3_P, controls.N4_P, controls.N5_P, controls.N6_P, controls.N7_P, controls.N8_P];
						release = [controls.N0_R, controls.N1_R, controls.N2_R, controls.N3_R, controls.N4_R, controls.N5_R, controls.N6_R, controls.N7_R, controls.N8_R];
					case 13: 
						press = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P, controls.N4_P,false,false,false,false];
						release = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R, controls.N4_R,false,false,false,false];
					case 14: 
						press = [controls.L1_P, controls.D1_P, controls.U1_P, controls.R1_P, controls.N4_P, controls.L2_P, false, false, controls.R2_P];
						release = [controls.L1_R, controls.D1_R, controls.U1_R, controls.R1_R, controls.N4_R, controls.L2_R, false, false, controls.R2_R];
					case 15:
						press = [controls.N0_P, controls.N1_P, controls.N2_P, controls.N3_P, false, controls.N5_P, controls.N6_P, controls.N7_P, controls.N8_P];
						release = [controls.N0_R, controls.N1_R, controls.N2_R, controls.N3_R, false, controls.N5_R, controls.N6_R, controls.N7_R, controls.N8_R];
					case 16: 
						press = [false, false, false, false, controls.N4_P, false, false, false, false];
						release = [false, false, false, false, controls.N4, false, false, false, false];
					case 17: 
						press = [controls.LEFT_P, false, false, controls.RIGHT_P, false, false, false, false, false];
						release = [controls.LEFT_R, false, false, controls.RIGHT_R, false, false, false, false, false];
					case 18: 
						press = [controls.LEFT_P, false, false, controls.RIGHT_P, controls.N4_P, false, false, false, false];
						release = [controls.LEFT_R, false, false, controls.RIGHT_R, controls.N4_R, false, false, false, false];
				}
				var holdArray:Array<Bool> = hold;
				var pressArray:Array<Bool> = press;
				var releaseArray:Array<Bool> = release;

				if(demoMode)
				{
					holdArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
					pressArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
					releaseArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
				} 

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
						goodNoteHit(daNote, playerOne);
				});
			} //gt hero input shit, using old code because i can
		if (controlArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isLiftNote)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else  {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}

				}
			});
			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...pressArray.length)
			{
				if (pressArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck)
			{
				var daNote = possibleNotes[0];

				if (!OptionsHandler.options.useCustomInput) {
					for (shit in 0...pressArray.length)
					{ // if a direction is hit that shouldn't be
						if (pressArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				
				// Jump notes
				for (coolNote in possibleNotes)
				{
					// even though IT SHOULD BE ABLE TO BE HIT we do this terrible ness
					if (pressArray[coolNote.noteData] && coolNote.canBeHit && !coolNote.tooLate)
					{
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote, playerOne);
					}
				}

			}
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, playerOne);
			}
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode) {
				if (mashViolations > 4)
				{
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				}
				else
					mashViolations++;
			}
		}
		// lift notes :)
		if (releaseArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.isLiftNote)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});
			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck)
			{
				var daNote = possibleNotes[0];
				/*
				if (!OptionsHandler.options.useCustomInput)
				{
					for (shit in 0...releaseArray.length)
					{ // if a direction is hit that shouldn't be
						if (releaseArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				*/
				//	 Jump notes
				for (coolNote in possibleNotes)
				{
					if (releaseArray[coolNote.noteData])
					{
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote, playerOne);
					}
				}
			}
			/*
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...releaseArray.length)
					if (releaseArray[shit])
						noteMiss(shit, playerOne);
			}
			*/
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode)
			{
				if (mashViolations > 4)
				{
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				}
				else
					mashViolations++;
			}
		}
		if (holdArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				var daRating = Ratings.CalculateRating(Math.abs(daNote.strumTime - Conductor.songPosition));
				// make sustain notes act
				// changing it to sick :blush:
				if (daNote.canBeHit && coolShouldPress && daNote.isSustainNote && ( daRating == 'sick'))
				{
					if (holdArray[daNote.noteData])
						goodNoteHit(daNote, playerOne);
				}
			});
		}
		if (actingOn.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			if (actingOn.animation.curAnim.name.startsWith('sing') && !actingOn.animation.curAnim.name.endsWith('miss'))
			{
				actingOn.dance();
				trace("idle from non miss sing");
			}
		}
		var strums = playerOne ? playerStrums : enemyStrums;
		strums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed', false);
			if (!keys[spr.ID])
				spr.animation.play('static', false);

			if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				switch(maniaToChange)
				{
					case 0: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 1: 
						spr.offset.x -= 16;
						spr.offset.y -= 16;
					case 2: 
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 3: 
						spr.offset.x -= 15;
						spr.offset.y -= 15;
					case 4: 
						spr.offset.x -= 18;
						spr.offset.y -= 18;
					case 5: 
						spr.offset.x -= 20;
						spr.offset.y -= 20;
					case 6: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 7: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 8:
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 10: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 11: 
						spr.offset.x -= 16;
						spr.offset.y -= 16;
					case 12: 
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 13: 
						spr.offset.x -= 15;
						spr.offset.y -= 15;
					case 14: 
						spr.offset.x -= 18;
						spr.offset.y -= 18;
					case 15: 
						spr.offset.x -= 20;
						spr.offset.y -= 20;
					case 16: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 17: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 18:
						spr.offset.x -= 13;
						spr.offset.y -= 13;
				}
			}
			else
				spr.centerOffsets();
		});
		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || demoMode || duoMode && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}
	var mashing:Int = 0;
	var mashViolations:Int = 0;
	function noteMiss(direction:Int = 1, playerOne:Bool, ?note:Null<Note>, ?playMissSound:Bool = true):Void
	{
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		var singArray = playerOne ? bfsDir : sDir;
		var opArray = !playerOne ? bfsDir : sDir;
		if (!actingOn.stunned)
		{
			misses += 1;
			setAllHaxeVar("misses", misses);
			if (note.noteMiss != null) {
				callHscript(note.noteMiss, [], "modchart");
			}
			var healthBonus = -0.04 * healthLossMultiplier;
			if (note != null) {
				healthBonus = note.getHealth('miss');
			}
			if (playerOne)
				health += healthBonus;
			else
				health -= healthBonus;
			if (combo > 5 && gf.gfEpicLevel >= EpicLevel.Level_Sadness) {
				gf.playAnim('sad');
			}
			updateAccuracy();
			combo = 0;
			setAllHaxeVar("combo", combo);
			if (!practiceMode) {
				songScore -= 5;
			}
			setAllHaxeVar('songScore', songScore);
			trueScore -= 5;
			if (playMissSound)
				FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			actingOn.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				actingOn.stunned = false;
			});
			if (note == null || note.shouldBeSung) {
				actingOn.singBetter('sing' + singArray[direction], true);
				if (note != null && note.oppntSing != null) {
					onActing.singBetter('sing' + opArray[direction], note.oppntSing.miss, note.oppntSing.alt);
				}
			}
				
			if (playerOne) {
				callAllHScript("playerOneMiss", []);
			} else {
				callAllHScript("playerTwoMiss", []);
			}
		}
	}

	function badNoteCheck(?playerOne:Bool=true)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		if (leftP)
			noteMiss(0, playerOne);
		if (downP)
			noteMiss(1, playerOne);
		if (upP)
			noteMiss(2,playerOne);
		if (rightP)
			noteMiss(3,playerOne);
	}

	function noteCheck(keyP:Bool, note:Note, playerOne:Bool):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);
		if (keyP)
			goodNoteHit(note,playerOne);
		else
		{
			badNoteCheck(playerOne);
		}
	}

	function goodNoteHit(note:Note, playerOne:Bool):Void
	{
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		var singArray = playerOne ? bfsDir : sDir;
		var opArray = !playerOne ? bfsDir : sDir;
		if (!note.canBeHit || note.tooLate)
			return;
		if (!note.isSustainNote)
			notesHitArray.push(Date.now());
		if (!note.wasGoodHit)
		{
			trace("<3 was good hit");
			actingOn.altAnim = "";
			actingOn.altNum = 0;
			
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (( SONG.notes[Math.floor(curStep / 16)].altAnimNum != null && SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0)
					|| SONG.notes[Math.floor(curStep / 16)].altAnim)
					// backwards compatibility shit
					if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1
						|| SONG.notes[Math.floor(curStep / 16)].altAnim)
						actingOn.altNum = 1;
					else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum > 1)
						actingOn.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
			}
			if (note.altNote)
				actingOn.altNum = 1;
			actingOn.altNum = note.altNum;
			if (actingOn.altNum == 1)
			{
				actingOn.altAnim = '-alt';
			}
			else if (actingOn.altNum > 1)
			{
				actingOn.altAnim = '-' + actingOn.altNum + 'alt';
			}
			// We pop it up even for sustains, just to update score. We don't actually show anything.
			trace("<3 pop up score");
			if (!note.dontCountNote)
				notesPassing += 1;
			popUpScore(note.strumTime, note, playerOne);
			if (!note.isSustainNote) {
				combo += 1;
				setAllHaxeVar("combo", combo);
			}

			/*
			if (note.noteData >= 0)
				health += 0.01 * healthGainMultiplier;
			else
				health += 0.005 * healthGainMultiplier;
			*/
			if (note.shouldBeSung) {
				actingOn.singBetter('sing' + singArray[note.noteData], false, actingOn.altNum);
				// callAllHScript("noteHit", [playerOne, note, goodhit]);
				
				if (OptionsHandler.options.hitSounds && !note.isSustainNote){
					FlxG.sound.play(FNFAssets.getSound("assets/sounds/hitSound.ogg"));
				}
				if (playerOne)
					callAllHScript("playerOneSing", []);
				else
					callAllHScript("playerTwoSing", []);
				var strums = playerOne ? playerStrums : enemyStrums;
				strums.forEach(function(spr:FlxSprite) {
					if (Math.abs(note.noteData) == spr.ID) {
						spr.animation.play('confirm', true);
					}
				});
				if (note.oppntSing != null) {
					onActing.singBetter('sing' + opArray[note.noteData], note.oppntSing.miss, note.oppntSing.alt);
				}
			}

			note.wasGoodHit = true;
			var goodhit = note.wasGoodHit;
			vocals.volume = 1;
			if (playerOne)
				player1GoodHitSignal.trigger(note);
			else
				player2GoodHitSignal.trigger(note);
			callAllHScript("noteHit", [playerOne, note, goodhit]);
			if (note.noteHit != null) {
				callHscript(note.noteHit, [], "modchart");
			}
			if (note.noteStrum != null && ((note.y < getHaxeActor('0').y - 20 && !downscroll) || (note.y > getHaxeActor('0').y + 20 && downscroll))) {
				callHscript(note.noteStrum, [], "modchart");
				note.noteStrum = null;
			}
			note.kill();
			notes.remove(note, true);
			note.destroy();

			grace = true;
			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				grace = false;
			});
		}
	}


	override function stepHit()
	{
		super.stepHit();
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		setAllHaxeVar("curStep", curStep);
		callAllHScript("stepHit", [curStep]);

		songLength = FlxG.sound.music.length;

		/*if (useSongBar && songPosBar.max == 69695969) {
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0)
			{
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
			
		}*/
		#if windows
		// Song duration in a float, useful for the time left feature
		

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,true,
			songLength
			- Conductor.songPosition, playingAsRpc);
		#end
	}


	override function beatHit()
	{
		super.beatHit();
		
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
			
			// Dad doesnt interupt his own notes
			if (!dad.animation.curAnim.name.startsWith("sing") && ((!duoMode && !opponentPlayer) || demoMode))
				dad.dance();
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && (opponentPlayer || demoMode))
				boyfriend.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		
		if (!endingSong && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		practiceDieIcon.setGraphicSize(Std.int(practiceDieIcon.width + 30));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		practiceDieIcon.updateHitbox();
		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !opponentPlayer && !demoMode)
		{
			boyfriend.dance();
		}
		if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing") && (duoMode || opponentPlayer) && !demoMode) {
			dad.dance();
		}
		if (curBeat % 8 == 7 && SONG.isHey)
		{
			boyfriend.playAnim('hey', true);
		}
		if (curBeat % 8 == 7 && SONG.isCheer && dad.gfEpicLevel >= Character.EpicLevel.Level_Sing)
		{
			dad.playAnim('cheer', true);
		}
		// gf should also cheer?
		if (curBeat % 8 == 7 && SONG.isCheer && gf.gfEpicLevel >= Character.EpicLevel.Level_Sing)
		{
			gf.playAnim('cheer', true);
		}

		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}
	function updatePrecence() {
		#if windows
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

}
