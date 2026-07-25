package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;

class Noelle extends FlxSprite
{
    public var moveSpeed:Float = 115;
    public var isFollowing:Bool = false;
    public var target:Player;
    public var followDistance:Float = 28;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow("assets/images/noelle_light.png", "assets/images/noelle_light.xml");

        animation.addByPrefix("walk_down", "spr_noelle_walk_down_lw_", 6, true);
        animation.addByPrefix("walk_up", "spr_noelle_walk_up_lw_", 6, true);
        animation.addByPrefix("walk_left", "spr_noelle_walk_left_lw_", 6, true);
        animation.addByPrefix("walk_right", "spr_noelle_walk_right_lw_", 6, true);

        animation.addByPrefix("idle_down", "spr_noelle_walk_down_lw_00000", 0, false);
        animation.addByPrefix("idle_up", "spr_noelle_walk_up_lw_00000", 0, false);
        animation.addByPrefix("idle_left", "spr_noelle_walk_left_lw_00000", 0, false);
        animation.addByPrefix("idle_right", "spr_noelle_walk_right_lw_00000", 0, false);

        animation.play("idle_down");

        immovable = true;
        setSize(23, 47);
        offset.set(23, 47);
    }

    override public function update(elapsed:Float)
    {
        if (isFollowing && target != null)
        {
            followTarget();
        }
        super.update(elapsed);
    }

    private function followTarget()
    {
        var dist = FlxMath.distanceBetween(this, target);

        if (dist > followDistance)
        {
            var dx = target.x - x;
            var dy = target.y - y;

            velocity.set(0, 0);

            if (Math.abs(dx) > Math.abs(dy))
            {
                if (dx > 0)
                {
                    velocity.x = moveSpeed;
                    animation.play("walk_right");
                }
                else
                {
                    velocity.x = -moveSpeed;
                    animation.play("walk_left");
                }
            }
            else
            {
                if (dy > 0)
                {
                    velocity.y = moveSpeed;
                    animation.play("walk_down");
                }
                else
                {
                    velocity.y = -moveSpeed;
                    animation.play("walk_up");
                }
            }
        }
        else
        {
            velocity.set(0, 0);
            if (animation.curAnim != null)
            {
                var curName = animation.curAnim.name;
                if (curName.indexOf("up") != -1) animation.play("idle_up");
                else if (curName.indexOf("down") != -1) animation.play("idle_down");
                else if (curName.indexOf("left") != -1) animation.play("idle_left");
                else if (curName.indexOf("right") != -1) animation.play("idle_right");
            }
        }
    }
}