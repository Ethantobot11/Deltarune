package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Rudinn extends FlxSprite
{
    public var moveSpeed:Float = 40;
    public var startX:Float;
    public var patrolDistance:Float = 100;
    public var movingRight:Bool = true;

    public function new(x:Float, y:Float, patrolDistance:Float = 100)
    {
        super(x, y);

        this.startX = x;
        this.patrolDistance = patrolDistance;

        frames = FlxAtlasFrames.fromSparrow("assets/images/chars/Rudinn.png", "assets/images/chars/Rudinn.xml");

        animation.addByNames("idle", [
            "spr_diamondm_idle_00000",
            "spr_diamondm_idle_10000",
            "spr_diamondm_idle_20000",
            "spr_diamondm_idle_30000"
        ], 6, true);
        animation.play("idle");

        updateHitbox();
    }

    override public function update(elapsed:Float)
    {
        handlePatrol();
        super.update(elapsed);
    }

    function handlePatrol()
    {
        if (movingRight)
        {
            velocity.x = moveSpeed;
            flipX = true;

            if (x >= startX + patrolDistance)
            {
                x = startX + patrolDistance;
                movingRight = false;
            }
        }
        else
        {
            velocity.x = -moveSpeed;
            flipX = false;

            if (x <= startX)
            {
                x = startX;
                movingRight = true;
            }
        }
    }
}