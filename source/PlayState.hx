package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;

#if mobile
import flixel.ui.FlxVirtualPad;
#end

class PlayState extends FlxState
{
    public var kris:Player;

    #if mobile
    public static var virtualPad:FlxVirtualPad;
    #end

    override public function create()
    {
        super.create();
        var background = FlxGridOverlay.create(16, 16, 1280, 720, true, 0xff1d1d24, 0xff282832);
        add(background);

        kris = new Player(FlxG.width / 2, FlxG.height / 2);
        add(kris);

        FlxG.camera.follow(kris, TOPDOWN, 1);
        FlxG.camera.focusOn(kris.getPosition());

        #if mobile
        virtualPad = new FlxVirtualPad(FULL, NONE);
        virtualPad.alpha = 0.5;
        add(virtualPad);
        #end
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}