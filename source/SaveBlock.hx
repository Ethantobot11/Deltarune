import flixel.FlxSprite;

class SaveBlock extends FlxSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        makeGraphic(32, 32, 0xFF222244);
        solid = true;
        immovable = true;
    }
}
