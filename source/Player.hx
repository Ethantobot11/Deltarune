package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Player extends FlxSprite
{
    public var moveSpeed:Float = 120;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow(
            "assets/images/chars/Kris_Light.png", 
            "assets/images/chars/Kris_Light.xml"
        );

        animation.addByPrefix("walk_down", "spr_krisd_", 6, true);
        animation.addByPrefix("walk_left", "spr_krisl_", 6, true);
        animation.addByPrefix("walk_right", "spr_krisr_", 6, true);
        animation.addByPrefix("walk_up", "spr_krisu_", 6, true);

        animation.addByPrefix("idle_down", "spr_krisd_00000", 0, false);
        animation.addByPrefix("idle_left", "spr_krisl_00000", 0, false);
        animation.addByPrefix("idle_right", "spr_krisr_00000", 0, false);
        animation.addByPrefix("idle_up", "spr_krisu_00000", 0, false);

        animation.play("idle_down");

        setSize(18, 38);
        offset.set(18, 38);
    }

    override public function update(elapsed:Float)
    {
        handleMovement();
        super.update(elapsed);
    }

    private function handleMovement()
    {
        var up:Bool = false;
        var down:Bool = false;
        var left:Bool = false;
        var right:Bool = false;

        #if mobile
        if (PlayState.virtualPad != null)
        {
            up = PlayState.virtualPad.buttonUp.pressed;
            down = PlayState.virtualPad.buttonDown.pressed;
            left = PlayState.virtualPad.buttonLeft.pressed;
            right = PlayState.virtualPad.buttonRight.pressed;
        }
        #else
        up = FlxG.keys.anyPressed([UP, W]);
        down = FlxG.keys.anyPressed([DOWN, S]);
        left = FlxG.keys.anyPressed([LEFT, A]);
        right = FlxG.keys.anyPressed([RIGHT, D]);
        #end

        if (up && down) up = down = false;
        if (left && right) left = right = false;

        velocity.set(0, 0);

        if (up || down || left || right)
        {
            if (up) velocity.y = -moveSpeed;
            else if (down) velocity.y = moveSpeed;

            if (left) velocity.x = -moveSpeed;
            else if (right) velocity.x = moveSpeed;

            velocity.truncate(moveSpeed);

            if (up) animation.play("walk_up");
            else if (down) animation.play("walk_down");
            else if (left) animation.play("walk_left");
            else if (right) animation.play("walk_right");
        }
        else
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