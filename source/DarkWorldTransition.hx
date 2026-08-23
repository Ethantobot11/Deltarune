package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.sound.FlxSound;

class DarkWorldTransition extends FlxSprite
{
    var player:Player;
    var door:DarkDoor;
    
    var con:Int = 8;
    var timer:Int = 0;
    var index:Float = 0;
    
    var krisX:Float;
    var krisY:Float;
    var krisV:Float = 0;
    var krisF:Float = 0;
    
    var lineCon:Int = 0;
    var lineTimer:Int = 0;
    
    var rectDraw:Bool = false;
    var rectAmount:Int = 6;
    var rsize:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];
    var rs:Float = 0;
    var rx:Float = 0;
    var ry:Float = 0;
    var rh:Float = 0;
    var rw:Float = 0;
    
    var fakeScreenshake:Int = 0;
    var fakeShakeAmount:Float = 0;
    
    var radius:Float = 60;
    var krisXCurrent:Float = 0;
    
    var soundCon:Int = 0;
    var dronetimer:Int = 0;
    var dronepitch:Float = 0;
    var dronesfx:FlxSound;
    var soundtimer:Int = 0;
    var soundthreshold:Int = 6;
    var rectsound:Int = 0;
    
    var megablack:FlxSprite;
    var bgOverlay:FlxSprite;
    
    public var onComplete:Void->Void;

    public function new(player:Player, door:DarkDoor = null)
    {
        super(player.x, player.y);
        this.player = player;
        this.door = door;

        krisX = player.x;
        krisY = player.y;

        frames = FlxAtlasFrames.fromSparrow("assets/images/trans/kris_dark_trans.png", "assets/images/trans/kris_dark_trans.xml");

        animation.addByPrefix("run_up", "spr_krisu_run_", 8, true);
        animation.addByPrefix("fall_lw", "spr_krisu_fall_lw_", 8, true);
        animation.addByPrefix("turnaround", "spr_kris_fall_turnaround_", 10, false);
        animation.addByPrefix("fall_down_lw", "spr_kris_fall_d_lw_", 6, true);
        animation.addByNames("fall_down_white", [
            "spr_kris_fall_d_white_00000",
            "spr_kris_fall_d_white_10000",
            "spr_kris_fall_d_white_20000"
        ], 15, false);
        animation.addByPrefix("fall_down_dw", "spr_kris_fall_d_dw_", 6, true);
        animation.addByPrefix("smear", "spr_kris_fall_smear_", 15, false);
        animation.addByPrefix("ball", "spr_kris_fall_ball_", 12, true);
        animation.addByPrefix("landed", "spr_kris_dw_landed_", 8, false);

        player.visible = false;
        player.isBusy = true;

        FlxG.camera.follow(this, TOPDOWN, 1);
        updateHitbox();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        index += 1;
        x = krisX;
        y = krisY;

        // Keep the black background locked to the camera view during the fall so it never runs out
        if (bgOverlay != null)
        {
            bgOverlay.x = FlxG.camera.scroll.x - FlxG.width;
            bgOverlay.y = FlxG.camera.scroll.y - FlxG.height;
        }

        if (soundCon == 1)
        {
            dronesfx = FlxG.sound.play("assets/sounds/snd_dtrans_drone.ogg", 0, true);
            dronesfx.fadeIn(0.5);
            dronesfx.pitch = 0.1;
            dronetimer = 0;
            soundCon = 2;
        }

        if (soundCon == 2)
        {
            dronetimer++;
            dronepitch = dronetimer / 80;
            
            if (dronepitch >= 1)
            {
                dronepitch = 1;
                soundCon = 3;
            }
            
            if (dronesfx != null)
                dronesfx.pitch = dronepitch;
        }

        if (lineCon == 1)
        {
            lineTimer++;
            if (lineTimer >= 1)
            {
                var xrand = FlxG.random.float(0, 1.57079);
                var xrand2 = FlxG.random.float(0, 1.57079);
                var line1 = new DarkTransitionLine((70 - (Math.sin(xrand) * 70)) + FlxG.camera.scroll.x, -10 + FlxG.camera.scroll.y);
                var line2 = new DarkTransitionLine(250 + (Math.sin(xrand2) * 70) + FlxG.camera.scroll.x, -16 + FlxG.camera.scroll.y);
                FlxG.state.insert(FlxG.state.members.indexOf(this), line1);
                FlxG.state.insert(FlxG.state.members.indexOf(this), line2);
                
                var particle1 = new DarkTransitionParticle(x + FlxG.random.float(-100, 100), y + FlxG.random.float(-50, 50));
                var particle2 = new DarkTransitionParticle(x + FlxG.random.float(-100, 100), y + FlxG.random.float(-50, 50));
                FlxG.state.insert(FlxG.state.members.indexOf(this), particle1);
                FlxG.state.insert(FlxG.state.members.indexOf(this), particle2);
                
                lineTimer = 0;
            }
        }

        if (krisF != 0)
        {
            if (krisV > 0) { krisV -= krisF; if (krisV < 0) krisV = 0; }
            else if (krisV < 0) { krisV += krisF; if (krisV > 0) krisV = 0; }
        }
        if (krisV != 0)
        {
            krisY += krisV;
        }

        if (fakeScreenshake == 1)
        {
            if (fakeShakeAmount != 0)
            {
                if (fakeShakeAmount > 0) fakeShakeAmount -= 1;
                else if (fakeShakeAmount < 0) fakeShakeAmount += 1;
                fakeShakeAmount *= -1;
            }
            else
            {
                fakeScreenshake = 0;
            }
        }

        switch (con)
        {
            case 8:
                krisV = 1.2;
                timer = 0;
                con = 9;
                animation.play("run_up");

            case 9:
                timer++;
                if (timer < 30) index += 0.2;

                if (timer == 30)
                {
                    if (door != null) door.setDoorState(DarkDoor.STATE_OPEN_FRAME);
                    FlxG.sound.play("assets/sounds/snd_locker.ogg");
                    
                    krisV = 0;
                    krisX -= 4;
                    animation.play("run_up");
                }

                if (timer == 60)
                {
                    krisV = -5;
                    krisF = 0;
                }

                if (timer > 60 && timer < 68)
                {
                    krisY -= 1;
                }

                if (timer == 68)
                {
                    krisF = 0.15;
                    krisV = -4;
                    krisY -= 2;
                    animation.play("fall_lw");
                    con = 15;
                    soundtimer = 0;
                }

            case 15:
                rs = 0;
                rh = (118 - 64) / 100;
                rw = (182 - 138) / 100;
                rx = (138 + 182) / 2;
                ry = (64 + 118) / 2;
                for (i in 0...8) rsize[i] = 1 + (i * -2);
                rectAmount = 6;
                rectDraw = true;
                timer = 0;
                con = 16;
                soundtimer = 3;
                rectsound = 0;

            case 16:
                soundthreshold = 6;
                soundtimer++;
                
                if (soundtimer >= soundthreshold && rectsound < rectAmount)
                {
                    soundtimer = 0;
                    FlxG.sound.play("assets/sounds/snd_dtrans_square.ogg", 0.5);
                    rectsound++;
                }
                
                timer++;
                if (timer >= 80)
                {
                    timer = 0;
                    con = 17;
                }

            case 17:
                lineCon = 1;
                krisXCurrent = krisX;
                animation.play("turnaround");
                con = 18;
                timer = 0;
                soundCon = 1;

            case 18:
                timer++;
                krisX = krisXCurrent + (Math.sin((timer * 2.5) * (Math.PI / 180)) * radius);
                
                if (timer >= 35)
                {
                    animation.play("fall_down_lw");
                    con = 19;
                    timer = 0;
                }

            case 19:
                timer++;
                if (timer >= 8)
                {
                    con = 30;
                    timer = 0;
                }

            case 30:
                timer++;
                if (timer >= 15)
                {
                    con = 31;
                    timer = 0;
                    animation.play("fall_down_white");
                }

            case 31:
                timer++;
                
                if (animation.curAnim != null && animation.curAnim.name == "fall_down_white")
                {
                    var sweepProgress = timer / 30;
                    if (sweepProgress > 1) sweepProgress = 1;
                    
                    clipRect = new flixel.math.FlxRect(0, 0, frameWidth, Std.int(frameHeight * sweepProgress));
                }

                if (timer >= 130)
                {
                    timer = 0;
                    krisV = -0.2;
                    krisF = 0.01;
                    con = 32;
                    clipRect = null; 
                    animation.play("fall_down_dw");
                }

            case 32:
                if (timer == 0)
                {
                    // Create a massive overlay that tracks the camera cleanly
                    bgOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
                    FlxG.state.insert(FlxG.state.members.indexOf(this), bgOverlay);
                }
                timer++;
                if (timer >= 14)
                {
                    soundCon = 4;
                    if (dronesfx != null)
                        dronesfx.fadeOut(0.5);
                        
                    krisV = 13;
                    krisF = 0;
                    timer = 0;
                    con = 33;
                    rectDraw = false;
                    animation.play("ball");
                }

            case 33:
                timer++;
                if (timer == 14) lineCon = 0;
                
                if (timer == 39)
                    FlxG.sound.play("assets/sounds/snd_dtrans_flip.ogg");
                
                if (krisY >= player.y + 2000)
                {
                    con = 34;
                    timer = 0;
                    krisV = 0;
                    fakeScreenshake = 1;
                    fakeShakeAmount = 8;
                    animation.play("landed");
                    FlxG.camera.shake(0.03, 0.2);
                }

            case 34:
                if (dronesfx != null && dronesfx.playing)
                    dronesfx.stop();
                    
                timer++;
                
                if (timer == 27)
                {
                    FlxG.sound.play("assets/sounds/snd_him_quick.ogg");
                }
                
                if (animation.curAnim != null && animation.curAnim.name == "landed" && animation.curAnim.finished && timer >= 26)
                {
                    player.x = krisX;
                    player.y = krisY;
                    player.loadDarkWorld();
                    player.visible = true;
                    player.isBusy = false;
                    FlxG.camera.follow(player, TOPDOWN, 1);

                    if (bgOverlay != null) bgOverlay.destroy();
                    if (onComplete != null) onComplete();
                    destroy();
                }
        }
    }
}
