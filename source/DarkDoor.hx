package;

import flixel.FlxSprite;

class DarkDoor extends FlxSprite
{
    public static inline var STATE_CLOSED:Int = 0;
    public static inline var STATE_OPEN_FRAME:Int = 1;
    public static inline var STATE_DARK_VOID:Int = 2;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        loadGraphic("assets/images/trans/spr_darkdoor_0.png");
        solid = true;
        immovable = true;
    }

    public function setDoorState(state:Int)
    {
        switch (state)
        {
            case STATE_CLOSED:
                loadGraphic("assets/images/trans/spr_darkdoor_0.png");
            case STATE_OPEN_FRAME:
                loadGraphic("assets/images/trans/spr_darkdoor_1.png");
            case STATE_DARK_VOID:
                loadGraphic("assets/images/trans/spr_darkdoor_2.png");
        }
    }
}