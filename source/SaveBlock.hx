import flixel.FlxSprite;

class SaveBlock extends FlxSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        makeGraphic(0, 0, 0xFF222244);
        solid = true;
        immovable = true;
    }
}
