package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class DialogueBox extends FlxSpriteGroup
{
    var boxBg:FlxSprite;
    var boxBorder:FlxSprite;
    public var portrait:FlxSprite;
    var textDisplay:FlxText;

    var fullText:String = "";
    var currentText:String = "";
    var charIndex:Int = 0;
    var typeTimer:FlxTimer;
    
    public var isFinished:Bool = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        boxBorder = new FlxSprite(0, 0).makeGraphic(280, 68, FlxColor.WHITE);
        add(boxBorder);

        boxBg = new FlxSprite(3, 3).makeGraphic(274, 62, FlxColor.BLACK);
        add(boxBg);

        portrait = new FlxSprite(8, 6);
        portrait.visible = false;
        add(portrait);

        textDisplay = new FlxText(15, 10, 250, "", 10);
        textDisplay.color = FlxColor.WHITE;
        add(textDisplay);

        scrollFactor.set(0, 0);
        forEach(function(spr:FlxSprite) {
            spr.scrollFactor.set(0, 0);
        });

        visible = false;
    }

    /**
     * Start a dialogue line.
     * @param text The dialogue text to print
     * @param faceAtlas Atlas image name (e.g. "noelle_face")
     * @param expressionFrame Specific XML SubTexture name (e.g. "spr_face_n_matome_00000")
     * @param style "light" or "dark" world box style
     */
    public function startDialogue(text:String, faceAtlas:String = null, expressionFrame:String = null, style:String = "light")
    {
        boxBorder.makeGraphic(280, 68, (style == "dark") ? 0xFF000080 : FlxColor.WHITE);

        fullText = text;
        currentText = "";
        charIndex = 0;
        isFinished = false;
        visible = true;

        if (faceAtlas != null && expressionFrame != null)
        {
            // Load atlas from assets
            portrait.frames = FlxAtlasFrames.fromSparrow(
                'assets/images/${faceAtlas}.png', 
                'assets/images/${faceAtlas}.xml'
            );

            portrait.animation.addByPrefix("expression", expressionFrame, 0, false);
            portrait.animation.play("expression");

            portrait.visible = true;
            
            portrait.setGraphicSize(54, 54);
            portrait.updateHitbox();

            textDisplay.x = x + 68;
            textDisplay.fieldWidth = 200;
        }
        else
        {
            portrait.visible = false;
            textDisplay.x = x + 15;
            textDisplay.fieldWidth = 250;
        }

        textDisplay.text = "";

        if (typeTimer != null) typeTimer.cancel();
        typeTimer = new FlxTimer().start(0.03, onTypeLetter, 0);
    }

    private function onTypeLetter(timer:FlxTimer)
    {
        if (charIndex < fullText.length)
        {
            var char = fullText.charAt(charIndex);
            currentText += char;
            textDisplay.text = currentText;

            if (char != " " && char != "\n")
            {
                FlxG.sound.play("assets/sounds/snd_txtnoe.wav", 0.6);
            }

            charIndex++;
        }
        else
        {
            isFinished = true;
            timer.cancel();
        }
    }

    public function skipTyping()
    {
        if (typeTimer != null) typeTimer.cancel();
        currentText = fullText;
        textDisplay.text = currentText;
        isFinished = true;
    }
}