package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ChoiceBox extends FlxSpriteGroup
{
    var boxBg:FlxSprite;
    var boxBorder:FlxSprite;
    var soulCursor:FlxSprite;
    
    var optionYes:FlxText;
    var optionNo:FlxText;

    public var selectedIndex:Int = 0;
    public var isActive:Bool = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        boxBorder = new FlxSprite(0, 0).makeGraphic(120, 50, FlxColor.WHITE);
        add(boxBorder);

        boxBg = new FlxSprite(3, 3).makeGraphic(114, 44, FlxColor.BLACK);
        add(boxBg);

        soulCursor = new FlxSprite(12, 12).makeGraphic(8, 8, FlxColor.RED);
        add(soulCursor);

        optionYes = new FlxText(25, 10, 80, "YES", 10);
        optionNo = new FlxText(25, 26, 80, "NO", 10);
        add(optionYes);
        add(optionNo);

        scrollFactor.set(0, 0);
        forEach(function(spr:FlxSprite) {
            spr.scrollFactor.set(0, 0);
        });

        visible = false;
    }

    public function open()
    {
        selectedIndex = 0;
        updateCursorPosition();
        isActive = true;
        visible = true;
    }

    public function close()
    {
        isActive = false;
        visible = false;
    }

    public function navigate(up:Bool, down:Bool)
    {
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
        soulCursor.y = y + (selectedIndex == 0 ? 12 : 28);
    }
}