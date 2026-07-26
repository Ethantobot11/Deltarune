package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Noelle extends FlxSprite
{
    public var isFollowing:Bool = false;
    public var target:Player;
    
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow("assets/images/chars/noelle_light.png", "assets/images/chars/noelle_light.xml");

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
        updateHitbox();
    }

    override public function update(elapsed:Float)
    {
        if (isFollowing && target != null)
        {
            followPathTrail();
        }
        super.update(elapsed);
    }

    private function followPathTrail()
    {
        if (target.pathHistory.length >= trailDelay)
        {
            var targetFrame = target.pathHistory[trailDelay - 1];

            if (x != targetFrame.x || y != targetFrame.y)
            {
                x = targetFrame.x;
                y = targetFrame.y;

                if (targetFrame.anim.indexOf("up") != -1) animation.play("walk_up");
                else if (targetFrame.anim.indexOf("down") != -1) animation.play("walk_down");
                else if (targetFrame.anim.indexOf("left") != -1) animation.play("walk_left");
                else if (targetFrame.anim.indexOf("right") != -1) animation.play("walk_right");
            }
        }

        if (target.velocity.x == 0 && target.velocity.y == 0)
        {
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