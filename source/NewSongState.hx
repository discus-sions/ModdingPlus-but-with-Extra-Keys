package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.ui.FlxSpriteButton;
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;

#end
import lime.ui.FileDialog;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
import Song.SwagSong;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.ui.FileDialogType;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
using StringTools;
typedef TDifficulty = {
	var offset:Int;
	var anim:String;
	var name:String;
}
typedef TDifficulties = {
	var difficulties:Array<TDifficulty>;
	var defaultDiff:Int;
}
class NewSongState extends MusicBeatState
{
	var addCharUi:FlxUI;
	var nameText:FlxUIInputText;
	var diffButtons:FlxTypedSpriteGroup<FlxUIButton>;
	var instButton:FlxUIButton;
	var voiceButton:FlxUIButton;
	var dialogButton:FlxUIButton;
	var modchartButton:FlxUIButton;
	var infoButton:FlxUIButton;
	var coolDiffFiles:Array<String> = [];
	var instPath:String;
	var voicePath:String;
	var dialogPath:String;
	var modchartPath:String;
	var p1Text:FlxUIInputText;
	var p2Text:FlxUIInputText;
	var gfText:FlxUIInputText;
	var stageText:FlxUIInputText;
	var stageID:FlxUINumericStepper;
	var cutsceneText:FlxUIInputText;
	var uiText:FlxUIInputText;
	var isHey:FlxUICheckBox;
	var isCheer:FlxUICheckBox;
	var isMoody:FlxUICheckBox;
	var isSpooky:FlxUICheckBox;
	var categoryText:FlxUIInputText;
	var weekText:FlxUIInputText;
	var charText:FlxUIInputText;
	var displayText:FlxUIInputText;
	var importText:FlxUIInputText;
	var importButton:FlxUIButton;
	var finishButton:FlxButton;
	var cancelButton:FlxUIButton;
	var coolFile:FileReference;
	var coolData:ByteArray;
	var epicFiles:Dynamic;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		addCharUi = new FlxUI();
		FlxG.mouse.visible = true;
		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGBlue.png');
		add(bg);
		diffButtons = new FlxTypedSpriteGroup<FlxUIButton>(0,0);
		var diffJson:TDifficulties = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_difficulties/difficulties"));
		nameText = new FlxUIInputText(100,10,70,"bopeebo");
		p1Text = new FlxUIInputText(100, 50, 70,"bf");
		p2Text = new FlxUIInputText(100,90,70,"dad");
		gfText = new FlxUIInputText(100,130,70,"gf");
		stageText = new FlxUIInputText(100,180,70,"stage");
		stageID = new FlxUINumericStepper(100,195,1,0,0,10);
		cutsceneText = new FlxUIInputText(100,220,70,"none");
		uiText = new FlxUIInputText(100,260,70,"normal");
		categoryText = new FlxUIInputText(100,290,70,"Base Game");
		isHey = new FlxUICheckBox(100,340, null, null, "Do HEY! Poses");
		isCheer = new FlxUICheckBox(100,390, null, null, "Do Cheer Pose");
		isMoody = new FlxUICheckBox(100,440,null,null, "Girls Scared");
		isSpooky = new FlxUICheckBox(100,490,null,null,"Background Trail");
		weekText = new FlxUIInputText(280,10,70,"0");
		charText = new FlxUIInputText(280,50,70,"null");
		displayText = new FlxUIInputText(280,90,70,"null");

		importText = new FlxUIInputText(400,10,70,"Ugh");
		importButton = new FlxUIButton(400,50, "Import Song", function():Void {
			var basePath:String = "assets/module/import/songs/" + importText.text;
			if (FileSystem.exists(basePath)) {
				instPath = basePath + '/Inst.ogg';
				
				if (FileSystem.exists(basePath + '/Voices.ogg'))
					voicePath = basePath + '/Voices.ogg';
				
				if (FileSystem.exists(basePath + '/dialog.txt'))
					dialogPath = basePath + '/dialog.txt';
				
				if (FileSystem.exists(basePath + '/modchart.hscript'))
					modchartPath = basePath + '/modchart.hscript';
				
				var daInfo:String = basePath + '/info.txt';
				getInfo(daInfo);
				
				for (i in 0...diffJson.difficulties.length) {
					if (FileSystem.exists(basePath + '/' + diffJson.difficulties[i].name + '.json'))
						coolDiffFiles[i] = basePath + '/' + diffJson.difficulties[i].name + '.json';
				}
			}
		});

		for (i in 0...diffJson.difficulties.length) {
			var coolDiffButton = new FlxUIButton(10, 10 + (i * 50), diffJson.difficulties[i].name + " json", function():Void {
				var coolDialog = new FileDialog();
				coolDialog.browse(FileDialogType.OPEN);
				coolDialog.onSelect.add(function (path:String):Void {
					coolDiffFiles[i] = path;
				});
			});
			diffButtons.add(coolDiffButton);
		}
		add(nameText);
		add(p1Text);
		add(p2Text);
		add(gfText);
		add(stageText);
		add(cutsceneText);
		add(categoryText);
		add(uiText);
		add(isHey);
		add(isCheer);
		add(isMoody);
		add(isSpooky);
		add(weekText);
		add(charText);
		add(displayText);
		add(importText);
		add(importButton);
		add(stageID);
		add(diffButtons);
		finishButton = new FlxButton(FlxG.width - 170, FlxG.height - 50, "Finish", function():Void {
			writeCharacters();
			LoadingState.loadAndSwitchState(new SaveDataState());
		});
		instButton = new FlxUIButton(190, 10, "Instruments", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				instPath = path;
			});
		});
		voiceButton = new FlxUIButton(190, 60, "Vocals", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				voicePath = path;
			});
		});
		dialogButton = new FlxUIButton(190, 110, "Dialog", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				dialogPath = path;
			});
		});
		modchartButton = new FlxUIButton(190, 160, "Modchart", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				modchartPath = path;
			});
		});
		infoButton = new FlxUIButton(190, 210, "Song Info", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				getInfo(path);
			});
		});
		cancelButton = new FlxUIButton(FlxG.width - 300, FlxG.height - 50, "Cancel", function():Void {
			// go back
			LoadingState.loadAndSwitchState(new SaveDataState());
		});
		add(instButton);
		add(voiceButton);
		add(dialogButton);
		add(modchartButton);
		add(infoButton);
		add(finishButton);
		add(cancelButton);
		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
	function convertToBool(theInfo:String) { // im too lazy to find a built-in converter lol
		var daBool:Bool = false;
		switch(theInfo) {
			case 'false':
				daBool = false;
			case 'true':
				daBool = true;
		}
		return daBool;
	}
	function getInfo(infoPath:String) {
		var infoText:Array<String> = CoolUtil.coolTextFile(infoPath);
		for (i in 0...infoText.length) {
			var data:Array<String> = infoText[i].split(':');
			switch(data[0]) { // this is probably unnecessary
				case 'songname':
					nameText.text = data[1];
				case 'player1':
					p1Text.text = data[1];
				case 'player2':
					p2Text.text = data[1];
				case 'gf':
					gfText.text = data[1];
				case 'stage':
					stageText.text = data[1];
				case 'uiType':
					uiText.text = data[1];
				case 'cutsceneType':
					cutsceneText.text = data[1];
				case 'category':
					categoryText.text = data[1];
				case 'isHey':
					isHey.checked = convertToBool(data[1]);
				case 'isCheer':
					isCheer.checked = convertToBool(data[1]);
				case 'isMoody':
					isMoody.checked = convertToBool(data[1]);
				case 'isSpooky':
					isSpooky.checked = convertToBool(data[1]);
				case 'stageID':
					stageID.value = Std.parseFloat(data[1]);
				case 'week':
					weekText.text = data[1];
				case 'char':
					charText.text = data[1];
				case 'display':
					displayText.text = data[1];
			}
		}
	}
	function writeCharacters() {
		// check to see if directory exists
		#if sys
		if (!FileSystem.exists('assets/data/' + nameText.text.toLowerCase())) {
			FileSystem.createDirectory('assets/data/' + nameText.text.toLowerCase());
		}
		for (i in 0...coolDiffFiles.length) {
			if (coolDiffFiles[i] != null) {
				var coolSong:Dynamic = CoolUtil.parseJson(File.getContent(coolDiffFiles[i]));
				var coolSongSong:Dynamic = coolSong.song;
				coolSongSong.song = nameText.text;
				coolSongSong.player1 = p1Text.text;
				coolSongSong.player2 = p2Text.text;
				coolSongSong.gf = gfText.text;
				coolSongSong.stage = stageText.text;
				coolSongSong.stageID = Std.int(stageID.value);
				coolSongSong.uiType = uiText.text;
				coolSongSong.cutsceneType = cutsceneText.text;
				coolSongSong.isHey = isHey.checked;
				coolSongSong.isCheer = isCheer.checked;
				coolSongSong.isMoody = isMoody.checked;
				coolSongSong.isSpooky = isSpooky.checked;
				coolSong.song = coolSongSong;

				File.saveContent('assets/data/'+nameText.text.toLowerCase()+'/'+nameText.text.toLowerCase()+DifficultyIcons.getEndingFP(i)+'.json',CoolUtil.stringifyJson(coolSong));
			}
		}
		// probably breaks on non oggs haha weeeeeeeeeee
		if (!FileSystem.exists('assets/songs/' + nameText.text.toLowerCase())) {
			FileSystem.createDirectory('assets/songs/' + nameText.text.toLowerCase());
		}
		File.copy(instPath,'assets/songs/' + nameText.text.toLowerCase() + '/' + nameText.text + '_Inst.ogg');
		if (voicePath != null) {
			File.copy(voicePath,'assets/songs/' + nameText.text.toLowerCase() + '/' + nameText.text + '_Voices.ogg');
		}
		if (dialogPath != null) {
			File.copy(dialogPath,'assets/data/' + nameText.text.toLowerCase() + '/dialog.txt');
		}
		if (modchartPath != null) {
			File.copy(modchartPath,'assets/data/' + nameText.text.toLowerCase() + '/modchart.hscript');
		}
		if (charText.text == 'null')
			charText.text = p2Text.text;
		var coolSongListFile:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getJson('assets/data/freeplaySongJson'));
		var foundSomething:Bool = false;
		for (coolCategory in coolSongListFile) {
			if (coolCategory.name == categoryText.text) {
				foundSomething = true; 
				if (displayText.text == 'null')
					coolCategory.songs.push({"name": nameText.text, "character": charText.text, "week": Std.parseFloat(weekText.text)});
				else
					coolCategory.songs.push({"name": nameText.text, "character": charText.text, "week": Std.parseFloat(weekText.text), "display": displayText.text});
				break;
			}
		}
		if (!foundSomething) {
			// must be a new category
			if (displayText.text == 'null')
				coolSongListFile.push({"name": categoryText.text, "songs": [{"name": nameText.text, "character": charText.text, "week": Std.parseFloat(weekText.text)}]});
			else
				coolSongListFile.push({"name": categoryText.text, "songs": [{"name": nameText.text, "character": charText.text, "week": Std.parseFloat(weekText.text), "display": displayText.text}]});
		}
		File.saveContent('assets/data/freeplaySongJson.jsonc',CoolUtil.stringifyJson(coolSongListFile));
		#end
	}
}
