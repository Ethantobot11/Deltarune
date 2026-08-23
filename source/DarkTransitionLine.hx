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
        var lineLength:Int = 184; 
        makeGraphic(lineThickness, lineLength, 0xFFFFFFFF);

        scale.set(2, 4);
        updateHitbox();

        alpha = 0.5;
        velocity.y = -FlxG.random.float(960, 1200);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (y < FlxG.camera.scroll.y - 200 || y > FlxG.camera.scroll.y + FlxG.height + 200)
        {
            destroy();
        }
    }
}
