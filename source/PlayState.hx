package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;

#if mobile
import flixel.ui.FlxVirtualPad;
#end

class PlayState extends FlxState
{
    public var kris:Player;
    public var noelle:Noelle;
    public var dialogueBox:DialogueBox;
    var closetDoor:DarkDoor;

    var dialogueStage:Int = 0;

    #if mobile
    public static var virtualPad:FlxVirtualPad;
    #end

    override public function create()
    {
        super.create();

        var background = FlxGridOverlay.create(16, 16, 1280, 720, true, 0xff1d1d24, 0xff282832);
        add(background);

        kris = new Player(FlxG.width / 2, FlxG.height / 2);
        add(kris);

        noelle = new Noelle(FlxG.width / 2 + 60, FlxG.height / 2);
        noelle.target = kris;
        add(noelle);

        FlxG.camera.follow(kris, TOPDOWN, 1);

        dialogueBox = new DialogueBox(20, FlxG.height - 70);
        add(dialogueBox);

        #if mobile
        virtualPad = new FlxVirtualPad(FULL, A);
        virtualPad.alpha = 0.5;
        add(virtualPad);
        #end

        closetDoor = new DarkDoor(300, 100);
        add(closetDoor);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!noelle.isFollowing)
        {
            FlxG.collide(kris, noelle);
        }

        var interactPressed = FlxG.keys.anyJustPressed([Z, ENTER, SPACE]);

        if (interactPressed && !kris.isBusy && FlxG.overlap(kris, closetDoor) && kris.facingDir == "up")
            {
                var transition = new DarkWorldTransition(kris, closetDoor);
                transition.onComplete = function() {
                    trace("Transition complete!");
                };
                add(transition);
            }

        handleInputs();
    }

    private function handleInputs()
    {
        var interactPressed:Bool = false;
        var upPressed:Bool = false;
        var downPressed:Bool = false;

        #if mobile
        if (virtualPad != null)
        {
            interactPressed = virtualPad.buttonA.justPressed;
            upPressed = virtualPad.buttonUp.justPressed;
            downPressed = virtualPad.buttonDown.justPressed;
        }
        #else
        interactPressed = FlxG.keys.anyJustPressed([Z, ENTER]);
        upPressed = FlxG.keys.anyJustPressed([UP, W]);
        downPressed = FlxG.keys.anyJustPressed([DOWN, S]);
        #end

        if (dialogueBox.isChoosing)
        {
            if (upPressed || downPressed)
            {
                dialogueBox.navigateChoices(upPressed, downPressed);
            }

            if (interactPressed)
            {
                if (dialogueBox.selectedIndex == 0)
                {
                    noelle.isFollowing = true;
                    dialogueBox.startDialogue("* Great! Let's go!", "noelle face", "spr_face_n_matome_00000", "light", false);
                    dialogueStage = 2;
                }
                else
                {
                    dialogueBox.startDialogue("* Oh... okay, maybe later!", "noelle face", "spr_face_n_matome_10000", "light", false);
                    dialogueStage = 2;
                }
            }
            return;
        }

        if (dialogueStage > 0 && interactPressed)
        {
            if (!dialogueBox.isFinished)
            {
                dialogueBox.skipTyping();
            }
            else if (dialogueStage == 2)
            {
                dialogueBox.visible = false;
                kris.isBusy = false;
                dialogueStage = 0;
            }
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingNoelle())
        {
            dialogueStage = 1;
            kris.isBusy = true;
            
            dialogueBox.startDialogue(
                "* Hi Kris!\n* Want me to come with you?", 
                "noelle_face", 
                "spr_face_n_matome_00000", 
                "light",
                true
            );
        }
    }

    private function isKrisFacingNoelle():Bool
    {
        var distance = FlxMath.distanceBetween(kris, noelle);
        if (distance > 35) return false;

        if (kris.facingDir == "right" && kris.x < noelle.x) return true;
        if (kris.facingDir == "left" && kris.x > noelle.x) return true;
        if (kris.facingDir == "up" && kris.y > noelle.y) return true;
        if (kris.facingDir == "down" && kris.y < noelle.y) return true;

        return false;
    }
}