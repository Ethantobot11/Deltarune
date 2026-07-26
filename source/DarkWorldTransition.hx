package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class DarkWorldTransition extends FlxSprite
{
    var player:Player;
    var door:DarkDoor;
    var statePhase:Int = 0;
    var timer:Float = 0;
    
    var bgOverlay:FlxSprite;
    var lineSpawnTimer:Float = 0;
    
    var targetLandingY:Float;

    public var onComplete:Void->Void;

    public function new(player:Player, door:DarkDoor = null)
    {
        super(player.x, player.y);
        this.player = player;
        this.door = door;

        this.targetLandingY = player.y + 650;

        frames = FlxAtlasFrames.fromSparrow("assets/images/trans/kris_dark_trans.png", "assets/images/trans/kris_dark_trans.xml");

        animation.addByPrefix("run_up", "spr_krisu_run_", 8, true);
        animation.addByPrefix("fall_lw", "spr_krisu_fall_lw_", 8, true);
        animation.addByPrefix("turnaround", "spr_kris_fall_turnaround_", 8, false);
        animation.addByPrefix("fall_down_lw", "spr_kris_fall_d_lw_", 8, true);
        
        animation.addByPrefix("fall_down_white", "spr_kris_fall_d_white_", 8, true);
        
        animation.addByPrefix("fall_down_dw", "spr_kris_fall_d_dw_", 8, true);
        animation.addByPrefix("smear", "spr_kris_fall_smear_", 12, false);
        animation.addByPrefix("ball", "spr_kris_fall_ball_", 12, true);
        animation.addByPrefix("landed", "spr_kris_dw_landed_", 8, false);

        player.visible = false;
        player.isBusy = true;

        FlxG.camera.follow(this, TOPDOWN, 1);

        startTransition();
    }

    function startTransition()
    {
        statePhase = 1; 
        animation.play("run_up");
        velocity.y = -80; 
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        timer += elapsed;

        if (statePhase >= 3 && statePhase <= 7)
        {
            lineSpawnTimer += elapsed;
            if (lineSpawnTimer >= 0.04) 
            {
                lineSpawnTimer = 0;
                var line = new DarkTransitionLine(x, y + 200);
                FlxG.state.insert(FlxG.state.members.indexOf(this), line);
            }
        }

        switch (statePhase)
        {
            case 1:
                if (timer >= 0.4)
                {
                    if (door != null)
                        door.setDoorState(DarkDoor.STATE_OPEN_FRAME);

                    velocity.y = -100;
                    animation.play("fall_lw");
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                if (timer >= 0.4)
                {
                    if (door != null)
                        door.setDoorState(DarkDoor.STATE_DARK_VOID);

                    bgOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 8, 0xFF000000);
                    bgOverlay.scrollFactor.set(0, 0); 
                    FlxG.state.insert(FlxG.state.members.indexOf(this), bgOverlay);

                    velocity.y = 0;
                    animation.play("turnaround");
                    statePhase = 3;
                    timer = 0;
                }

            case 3:
                if (timer >= 0.6)
                {
                    velocity.y = 120;
                    animation.play("fall_down_lw");
                    statePhase = 4;
                    timer = 0;
                }

            case 4:
                if (timer >= 0.7)
                {
                    animation.play("fall_down_white");
                    velocity.y = 160;
                    statePhase = 5;
                    timer = 0;
                }

            case 5:
                if (timer >= 0.3)
                {
                    animation.play("fall_down_dw");
                    velocity.y = 220;
                    statePhase = 6;
                    timer = 0;
                }

            case 6:
                if (timer >= 0.8)
                {
                    velocity.y = 420;
                    animation.play("smear");
                    statePhase = 7;
                    timer = 0;
                }

            case 7:
                if (animation.curAnim != null && animation.curAnim.name == "smear" && animation.curAnim.finished)
                {
                    animation.play("ball");
                }

                if (y >= targetLandingY) 
                {
                    y = targetLandingY;
                    velocity.y = 0;
                    animation.play("landed");
                    FlxG.camera.shake(0.02, 0.2);
                    statePhase = 8;
                    timer = 0;
                }

            case 8:
                if (animation.curAnim != null && animation.curAnim.name == "landed" && animation.curAnim.finished)
                {
                    player.x = x;
                    player.y = y;
                    player.visible = true;
                    player.isBusy = false;

                    FlxG.camera.follow(player, TOPDOWN, 1);

                    if (bgOverlay != null)
                        bgOverlay.destroy();

                    if (onComplete != null)
                        onComplete();

                    destroy();
                }
        }
    }
}