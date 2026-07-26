package;

import flixel.FlxG;
import flixel.FlxSprite;

class DarkTransitionLine extends FlxSprite
{
    var moveSpeed:Float;

    public function new(centerX:Float, spawnY:Float)
    {
        var spawnX = centerX + FlxG.random.float(-160, 160);
        super(spawnX, spawnY);

        var lineThickness:Int = 2;
        var lineLength:Int = FlxG.random.int(40, 80);
        makeGraphic(lineThickness, lineLength, 0xFFFFFFFF);

        alpha = FlxG.random.float(0.3, 0.6);
        
        moveSpeed = FlxG.random.float(350, 500);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        y -= moveSpeed * elapsed;

        if (y < FlxG.camera.scroll.y - 100 || y > FlxG.camera.scroll.y + FlxG.height + 100)
        {
            destroy();
        }
    }
}