package;

import openfl.display.Sprite;
import flixel.FlxGame;

class Main extends Sprite
{
    var gameWidth:Int = 320;
    var gameHeight:Int = 240;

    var initialState:Class<flixel.FlxState> = PlayState;

    var framerate:Int = #if desktop 60 #elseif mobile 30 #end;
    var skipSplash:Bool = true;
    var startFullscreen:Bool = false;

    public function new()
    {
        super();
        addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));
    }
}