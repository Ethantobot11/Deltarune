package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if mobile
import flixel.ui.FlxVirtualPad;
#end

class SaveMenuSubState extends FlxSubState
{
    var background:FlxSprite;
    var titleText:FlxText;
    var slotTexts:Array<FlxText> = [];
    var selectedSlot:Int = 0;
    
    var soulCursor:FlxSprite;

    #if mobile
    var virtualPad:FlxVirtualPad;
    #end

    override public function create()
    {
        super.create();

        background = new FlxSprite(40, 30);
        background.makeGraphic(320, 180, 0xDD000000);
        add(background);

        titleText = new FlxText(60, 40, 0, "=== SAVE MENU ===", 16);
        titleText.color = 0xFFFF00; // Yellow
        add(titleText);

        if (FlxG.save.data.slots == null) {
            FlxG.save.data.slots = [
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" }
            ];
            FlxG.save.flush();
        }

        for (i in 0...3) {
            var slotData = FlxG.save.data.slots[i];
            var displayString = slotData.created ? 'Slot ${i + 1}: ${slotData.name}' : 'Slot ${i + 1}: EMPTY';
            
            var t = new FlxText(80, 90 + (i * 35), 0, displayString, 16);
            t.color = 0xFFFFFFFF;
            slotTexts.push(t);
            add(t);
        }

        soulCursor = new FlxSprite(60, 98);
        soulCursor.loadGraphic("soul/iconOG");
        add(soulCursor);

        #if mobile
        virtualPad = new FlxVirtualPad(UP_DOWN, A_B);
        add(virtualPad);
        #end

        updateSlotSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var upPressed = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
        var downPressed = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S;
        var acceptPressed = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Z;
        var backPressed = FlxG.keys.justPressed.X || FlxG.keys.justPressed.ESCAPE;

        #if mobile
        if (virtualPad != null) {
            if (virtualPad.buttonUp.justPressed) upPressed = true;
            if (virtualPad.buttonDown.justPressed) downPressed = true;
            if (virtualPad.buttonA.justPressed) acceptPressed = true;
            if (virtualPad.buttonB.justPressed) backPressed = true;
        }
        #end

        if (upPressed) {
            FlxG.sound.play('assets/sounds/snd_select.ogg');
            selectedSlot--;
            if (selectedSlot < 0) selectedSlot = 2;
            updateSlotSelection();
        }
        else if (downPressed) {
            FlxG.sound.play('assets/sounds/snd_select.ogg');
            selectedSlot++;
            if (selectedSlot > 2) selectedSlot = 0;
            updateSlotSelection();
        }

        if (acceptPressed) {
            FlxG.sound.play('assets/sounds/snd_save.ogg');
            FlxG.save.data.slots[selectedSlot] = {
                created: true,
                name: "KRIS",
                playTime: 100,
                room: "room_save"
            };
            FlxG.save.flush();
            
            slotTexts[selectedSlot].text = 'Slot ${selectedSlot + 1}: KRIS';
        }

        if (backPressed) {
            close();
        }
    }

    private function updateSlotSelection()
    {
        for (i in 0...slotTexts.length) {
            slotTexts[i].color = (i == selectedSlot) ? 0xFF00FF00 : 0xFFFFFFFF; // Green if selected, White otherwise
        }

        var targetY = 98 + (selectedSlot * 35);
        FlxTween.cancelTweensOf(soulCursor);
        FlxTween.tween(soulCursor, {y: targetY}, 0.1, {ease: FlxEase.quadOut});
    }
}
