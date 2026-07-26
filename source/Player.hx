package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef PositionFrame = {
    var x:Float;
    var y:Float;
    var anim:String;
}

class Player extends FlxSprite
{
    public var moveSpeed:Float = 120;
    public var facingDir:String = "down";
    public var isBusy:Bool = false;
    public var isDarkWorld:Bool = false;
    public var pathHistory:Array<PositionFrame> = [];

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadLightWorld();

        updateHitbox();
    }

    public function loadLightWorld():Void
    {
        isDarkWorld = false;
        frames = FlxAtlasFrames.fromSparrow("assets/images/chars/Kris_Light.png", "assets/images/chars/Kris_Light.xml");

        animation.addByPrefix("walk_down", "spr_krisd_", 6, true);
        animation.addByPrefix("walk_left", "spr_krisl_", 6, true);
        animation.addByPrefix("walk_right", "spr_krisr_", 6, true);
        animation.addByPrefix("walk_up", "spr_krisu_", 6, true);

        animation.addByPrefix("idle_down", "spr_krisd_00000", 0, false);
        animation.addByPrefix("idle_left", "spr_krisl_00000", 0, false);
        animation.addByPrefix("idle_right", "spr_krisr_00000", 0, false);
        animation.addByPrefix("idle_up", "spr_krisu_00000", 0, false);

        animation.play("idle_down");
    }

    public function loadDarkWorld():Void
    {
        isDarkWorld = true;
        
        frames = FlxAtlasFrames.fromSparrow("assets/images/chars/Kris_Dark.png", "assets/images/chars/Kris_Dark.xml");

        animation.addByNames("walk_down", [
            "spr_krisd_dark_00000", 
            "spr_krisd_dark_10000", 
            "spr_krisd_dark_20000", 
            "spr_krisd_dark_30000"
        ], 6, true);

        animation.addByNames("walk_left", [
            "spr_krisl_dark_00000", 
            "spr_krisl_dark_10000", 
            "spr_krisl_dark_20000", 
            "spr_krisl_dark_30000"
        ], 6, true);

        animation.addByNames("walk_right", [
            "spr_krisr_dark_00000", 
            "spr_krisr_dark_10000", 
            "spr_krisr_dark_20000", 
            "spr_krisr_dark_30000"
        ], 6, true);

        animation.addByNames("walk_up", [
            "spr_krisu_dark_00000", 
            "spr_krisu_dark_10000", 
            "spr_krisu_dark_20000", 
            "spr_krisu_dark_30000"
        ], 6, true);

        animation.addByNames("idle_down", ["spr_krisd_dark_00000"], 0, false);
        animation.addByNames("idle_left", ["spr_krisl_dark_00000"], 0, false);
        animation.addByNames("idle_right", ["spr_krisr_dark_00000"], 0, false);
        animation.addByNames("idle_up", ["spr_krisu_dark_00000"], 0, false);

        animation.play("idle_down");
    }

    override public function update(elapsed:Float)
    {
        var oldX = x;
        var oldY = y;

        if (!isBusy)
            handleMovement();
        else
            velocity.set(0, 0);

        super.update(elapsed);

        if (x != oldX || y != oldY)
        {
            var curAnimName = (animation.curAnim != null) ? animation.curAnim.name : "walk_down";
            pathHistory.unshift({x: x, y: y, anim: curAnimName});

            if (pathHistory.length > 100)
            {
                pathHistory.pop();
            }
        }
        else
        {
            if (facingDir == "up") animation.play("idle_up");
            else if (facingDir == "down") animation.play("idle_down");
            else if (facingDir == "left") animation.play("idle_left");
            else if (facingDir == "right") animation.play("idle_right");
        }
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
            if (up) { velocity.y = -moveSpeed; facingDir = "up"; }
            else if (down) { velocity.y = moveSpeed; facingDir = "down"; }

            if (left) { velocity.x = -moveSpeed; facingDir = "left"; }
            else if (right) { velocity.x = moveSpeed; facingDir = "right"; }

            velocity.truncate(moveSpeed);

            if (up) animation.play("walk_up");
            else if (down) animation.play("walk_down");
            else if (left) animation.play("walk_left");
            else if (right) animation.play("walk_right");
        }
        else
        {
            if (facingDir == "up") animation.play("idle_up");
            else if (facingDir == "down") animation.play("idle_down");
            else if (facingDir == "left") animation.play("idle_left");
            else if (facingDir == "right") animation.play("idle_right");
        }
    }
}