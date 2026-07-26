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

    public var soulCursor:FlxSprite;
    var optionYesText:FlxText;
    var optionNoText:FlxText;

    var fullText:String = "";
    var currentText:String = "";
    var charIndex:Int = 0;
    var typeTimer:FlxTimer;
    var soundAsset:String = "snd_txtnoe.wav";

    public var isFinished:Bool = false;
    public var hasChoices:Bool = false;
    public var isChoosing:Bool = false;
    public var selectedIndex:Int = 0;

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

        soulCursor = new FlxSprite(0, 0);
        if (openfl.utils.Assets.exists("soul/iconOG.png"))
        {
            soulCursor.loadGraphic("soul/iconOG.png");
            soulCursor.setGraphicSize(16, 16);
            soulCursor.updateHitbox();
        }
        else if (openfl.utils.Assets.exists("soul/iconOG.png"))
        {
            soulCursor.loadGraphic("soul/iconOG.png");
            soulCursor.setGraphicSize(16, 16);
            soulCursor.updateHitbox();
        }
        else
        {
            soulCursor.makeGraphic(8, 8, FlxColor.RED);
        }
        soulCursor.visible = false;
        add(soulCursor);

        optionYesText = new FlxText(210, 18, 50, "YES", 10);
        optionYesText.color = FlxColor.WHITE;
        optionYesText.visible = false;
        add(optionYesText);

        optionNoText = new FlxText(210, 36, 50, "NO", 10);
        optionNoText.color = FlxColor.WHITE;
        optionNoText.visible = false;
        add(optionNoText);

        scrollFactor.set(0, 0);
        forEach(function(spr:FlxSprite) {
            spr.scrollFactor.set(0, 0);
        });

        visible = false;
    }

    public function startDialogue(text:String, faceAtlas:String = null, expressionFrame:String = null, style:String = "light", withChoices:Bool = false, snd:String = "snd_txtnoe.wav")
    {
        boxBorder.makeGraphic(280, 68, (style == "dark") ? 0xFF000080 : FlxColor.WHITE);

        fullText = text;
        currentText = "";
        charIndex = 0;
        isFinished = false;
        hasChoices = withChoices;
        isChoosing = false;
        soundAsset = snd;
        visible = true;

        soulCursor.visible = false;
        optionYesText.visible = false;
        optionNoText.visible = false;

        if (faceAtlas != null && expressionFrame != null)
        {
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
            textDisplay.fieldWidth = withChoices ? 130 : 200;
        }
        else
        {
            portrait.visible = false;
            textDisplay.x = x + 15;
            textDisplay.fieldWidth = withChoices ? 180 : 250;
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
                FlxG.sound.play('assets/sounds/${soundAsset}', 0.6);
            }

            charIndex++;
        }
        else
        {
            onDialogueFinished();
            timer.cancel();
        }
    }

    public function skipTyping()
    {
        if (typeTimer != null) typeTimer.cancel();
        currentText = fullText;
        textDisplay.text = currentText;
        onDialogueFinished();
    }

    private function onDialogueFinished()
    {
        isFinished = true;

        if (hasChoices)
        {
            showChoices();
        }
    }

    private function showChoices()
    {
        isChoosing = true;
        selectedIndex = 0;

        optionYesText.visible = true;
        optionNoText.visible = true;
        soulCursor.visible = true;

        updateCursorPosition();
    }

    public function navigateChoices(up:Bool, down:Bool)
    {
        if (!isChoosing) return;

        if (up && selectedIndex > 0)
        {
            selectedIndex = 0;
            FlxG.sound.play("assets/sounds/snd_text.wav", 0.5);
            updateCursorPosition();
        }
        else if (down && selectedIndex < 1)
        {
            selectedIndex = 1;
            FlxG.sound.play("assets/sounds/snd_text.wav", 0.5);
            updateCursorPosition();
        }
    }

    private function updateCursorPosition()
    {
        soulCursor.x = x + 196;
        soulCursor.y = y + (selectedIndex == 0 ? 20 : 38);
    }
}