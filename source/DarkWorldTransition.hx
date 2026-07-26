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

        this.targetLandingY = player.y + 2200;

        frames = FlxAtlasFrames.fromSparrow("assets/images/trans/kris_dark_trans.png", "assets/images/trans/kris_dark_trans.xml");

        animation.addByPrefix("run_up", "spr_krisu_run_", 8, true);
        animation.addByPrefix("fall_lw", "spr_krisu_fall_lw_", 8, true);
        animation.addByPrefix("turnaround", "spr_kris_fall_turnaround_", 10, false);
        
        animation.addByPrefix("fall_down_lw", "spr_kris_fall_d_lw_", 6, true);
        
        animation.addByNames("fall_down_white", [
            "spr_kris_fall_d_white_00000",
            "spr_kris_fall_d_white_10000",
            "spr_kris_fall_d_white_20000"
        ], 6, true);
        
        animation.addByPrefix("fall_down_dw", "spr_kris_fall_d_dw_", 6, true);
        animation.addByPrefix("smear", "spr_kris_fall_smear_", 15, false);
        animation.addByPrefix("ball", "spr_kris_fall_ball_", 12, true);
        animation.addByPrefix("landed", "spr_kris_dw_landed_", 8, false);

        player.visible = false;
        player.isBusy = true;

        FlxG.camera.follow(this, TOPDOWN, 1);

        updateHitbox();

        startTransition();
    }

    function startTransition()
    {
        statePhase = 1; 
        animation.play("run_up");
        velocity.y = -50; 
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        timer += elapsed;

        if (statePhase >= 3 && statePhase <= 7)
        {
            lineSpawnTimer += elapsed;
            if (lineSpawnTimer >= 0.035) 
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

                    velocity.y = -70;
                    animation.play("fall_lw");
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                if (timer >= 0.6)
                {
                    if (door != null)
                        door.setDoorState(DarkDoor.STATE_DARK_VOID);

                    bgOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 16, 0xFF000000);
                    bgOverlay.scrollFactor.set(0, 0); 
                    FlxG.state.insert(FlxG.state.members.indexOf(this), bgOverlay);

                    velocity.y = 0;
                    animation.play("turnaround");
                    statePhase = 3;
                    timer = 0;
                }

            case 3:
                if (timer >= 0.5 && velocity.y == 0)
                {
                    velocity.y = 90;
                    animation.play("fall_down_lw");
                }

                if (timer >= 2.0)
                {
                    statePhase = 4;
                    timer = 0;
                    velocity.y = 130;
                    animation.play("fall_down_white");
                }

            case 4:
                if (timer >= 1.2)
                {
                    statePhase = 5;
                    timer = 0;
                    velocity.y = 180;
                    animation.play("fall_down_dw");
                }

            case 5:
                if (timer >= 1.6)
                {
                    statePhase = 6;
                    timer = 0;
                    velocity.y = 380;
                    animation.play("smear");
                }

            case 6:
                if (timer >= 0.3)
                {
                    statePhase = 7;
                    timer = 0;
                    velocity.y = 650;
                    animation.play("ball");
                }

            case 7:
                if (y >= targetLandingY) 
                {
                    y = targetLandingY;
                    velocity.y = 0;
                    animation.play("landed");
                    FlxG.camera.shake(0.03, 0.2);
                    statePhase = 8;
                    timer = 0;
                }

            case 8:
                if (animation.curAnim != null && animation.curAnim.name == "landed" && animation.curAnim.finished)
                {
                    player.x = x;
                    player.y = y;
                    
                    player.loadDarkWorld();
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