package;
import flixel.FlxSprite;
import DynamicSprite.DynamicAtlasFrames;
import flixel.FlxG;
import Judgement.TUI;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite 
{
    public static var colors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'darkblue'];
	var colorsThatDontChange:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'darkblue', 'orange', 'darkred'];

    public function new(xPos:Float,yPos:Float,?c:Int) 
    {//no offense, but this code kinda sucks
        if (c == null) c = 0;
        x = xPos;
		y = yPos;
		super(x, y);
        var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
		frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/else/Splash.png',
        'assets/images/custom_ui/ui_packs/${curUiType.uses}/else/Splash.xml');
		for (i in 0...colorsThatDontChange.length)
		{
			animation.addByPrefix(colorsThatDontChange[i] + ' splash', "splash " + colorsThatDontChange[i], 24, false);
		}
		antialiasing = true;
		updateHitbox();
		setupNoteSplash(xPos, yPos, c);
    }

    public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int) {
        if (c == null) c = 0;
        makeSplash(xPos, yPos, c);
        //setPosition(xPos, yPos);
       // alpha = 0.6;
       // animation.play("note"+c+"-"+FlxG.random.int(0,1), true);
		///animation.curAnim.frameRate += FlxG.random.int(-2, 2);
      //  updateHitbox();
      //  offset.set(0.3 * width, 0.3 * height);
    }

    public function makeSplash(nX:Float, nY:Float, color:Int) 
    {
        setPosition(nX - 105, nY - 110);
      try {
        angle = FlxG.random.int(0, 360);
        alpha = 0.6;
        animation.play(colors[color] + ' splash', true);
        animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
        //offset.set(500, 200);
        updateHitbox();
      } catch (e) {trace(e.message); }
    }

    override public function update(elapsed) 
    {
        if (animation.curAnim.finished) {
            // club pengiun is
            kill();
        }
        super.update(elapsed);
    }
}