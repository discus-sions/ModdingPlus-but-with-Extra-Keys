package twelvekey;

import flixel.FlxG;
import twelvekey.LeatherUtils;

class NoteVariables
{
    public static var Note_Count_Directions:Array<Array<String>>;
    public static var Default_Binds:Array<Array<String>>;
    public static var Other_Note_Anim_Stuff:Array<Array<String>>;
    public static var Character_Animation_Arrays:Array<Array<String>>;

    public static function init()
    {
        Note_Count_Directions = LeatherUtils.coolTextFileOfArrays(Paths.txt("leather_engine/mania data/maniaDirections"));
        Default_Binds = LeatherUtils.coolTextFileOfArrays(Paths.txt("leather_engine/mania data/defaultBinds"));
        Other_Note_Anim_Stuff = LeatherUtils.coolTextFileOfArrays(Paths.txt("leather_engine/mania data/maniaAnimationDirections"));
        Character_Animation_Arrays = LeatherUtils.coolTextFileOfArrays(Paths.txt("leather_engine/mania data/maniaCharacterAnimations"));

        if (FlxG.save.data.newPlayerKKK == null) 
        {
            FlxG.save.data.binds = Default_Binds; 
            FlxG.save.data.newPlayerKKK = false;
        }
    }
}