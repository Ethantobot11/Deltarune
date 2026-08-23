package;

import flixel.FlxG;
import flixel.FlxSprite;

class DarkTransitionParticle extends FlxSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        makeGraphic(4, 4, 0xFFFFFFFF);
        scale.set(2, 2);
        updateHitbox();
        velocity.y = -120;
        velocity.x = (-1 + FlxG.random.float(0, 2)) * 60;
        drag.set(4.2, 4.2);

        alpha = 1.0;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        alpha -= 0.05 * (elapsed * 60);

        if (alpha <= 0)
        {
            destroy();
        }
    }
}
