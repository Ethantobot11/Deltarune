package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
#if mobile
import flixel.ui.FlxVirtualPad;
#end

class MainMenuState extends FlxState {
    
    private var selectedIndex:Int = 0;
    private final TOTAL_MENU_ITEMS:Int = 4;

    private var menuBackground:FlxSprite;
    
    private var slotUIElements:Array<FlxSprite> = [];
    private var slotTexts:Array<FlxText> = [];

    private var soulCursor:FlxSprite;

    #if mobile
    private var virtualPad:FlxVirtualPad;
    #end

    override public function create() {
        super.create();

        trace("Entering MainMenuState.create()...");

        FlxG.sound.play('assets/sounds/audiogroup_default/external/AUDIO_INTRONOISE.ogg');

        if (FlxG.save.data.slots == null) {
            FlxG.save.data.slots = [
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" }
            ];
            FlxG.save.flush();
        }

        menuBackground = new FlxSprite(0, 0);
        menuBackground.makeGraphic(FlxG.width, FlxG.height, 0xFF0A0A1E); 
        add(menuBackground);

        var slots:Array<Dynamic> = FlxG.save.data.slots;
        for (i in 0...3) {
            var slotBox = new FlxSprite(60, 40 + (i * 50));
            slotBox.makeGraphic(240, 40, 0xFF222244);
            add(slotBox);
            slotUIElements.push(slotBox);

            var slotData = slots[i];
            var displayText = slotData.created ? 'Slot ${i + 1}: ${slotData.name}' : 'Slot ${i + 1}: EMPTY';
            
            var textObj = new FlxText(80, 48 + (i * 50), 0, displayText, 16);
            textObj.color = 0xFFFFFFFF;
            add(textObj);
            slotTexts.push(textObj);
        }

        var optionsBox = new FlxSprite(60, 40 + (3 * 50));
        optionsBox.makeGraphic(240, 40, 0xFF222244);
        add(optionsBox);
        slotUIElements.push(optionsBox);

        var optionsText = new FlxText(80, 48 + (3 * 50), 0, "Options", 16);
        optionsText.color = 0xFFFFFFFF;
        add(optionsText);
        slotTexts.push(optionsText);

        soulCursor = new FlxSprite(40, 56);
        soulCursor.loadGraphic("soul/iconOG.png");
        add(soulCursor);

        #if mobile
        virtualPad = new FlxVirtualPad(UP_DOWN, A_B_C);
        add(virtualPad);
        #end

        updateVisualSelection();
        trace("MainMenuState loaded.");
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        var changed = false;

        var upPressed = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
        var downPressed = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S;
        var acceptPressed = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Z;
        var backPressed = FlxG.keys.justPressed.X;
        var erasePressed = FlxG.keys.justPressed.C;

        #if mobile
        if (virtualPad != null) {
            if (virtualPad.buttonUp.justPressed) upPressed = true;
            if (virtualPad.buttonDown.justPressed) downPressed = true;
            if (virtualPad.buttonA.justPressed) acceptPressed = true;
            if (virtualPad.buttonB.justPressed) backPressed = true;
            if (virtualPad.buttonC.justPressed) erasePressed = true;
        }
        #end

        if (upPressed) {
            FlxG.sound.play('assets/sounds/snd_select.ogg');
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = TOTAL_MENU_ITEMS - 1;
            changed = true;
        }
        
        if (downPressed) {
            FlxG.sound.play('assets/sounds/snd_select.ogg');
            selectedIndex++;
            if (selectedIndex >= TOTAL_MENU_ITEMS) selectedIndex = 0;
            changed = true;
        }

        if (changed) {
            updateSelectionLog();
            updateVisualSelection();
        }

        if (acceptPressed) {
            if (selectedIndex < 3) {
                selectSlot(selectedIndex);
            } else {
                trace("Opening Options Menu...");
                FlxG.switchState(new OptionsState());
            }
            FlxG.sound.play('assets/sounds/snd_shineselect.ogg');
        }

        if (backPressed) {
            FlxG.sound.play('assets/sounds/snd_error.ogg');
        }

        if (erasePressed && selectedIndex < 3) {
            eraseSlot(selectedIndex);
        }
    }

    private function updateVisualSelection() {
        for (i in 0...slotUIElements.length) {
            if (i == selectedIndex) {
                slotUIElements[i].makeGraphic(240, 40, 0xFF444488);
            } else {
                slotUIElements[i].makeGraphic(240, 40, 0xFF222244);
            }
        }

        var targetY = 56 + (selectedIndex * 50);
        FlxTween.cancelTweensOf(soulCursor);
        FlxTween.tween(soulCursor, {y: targetY}, 0.1, {ease: FlxEase.quadOut});
    }

    private function updateSelectionLog() {
        if (selectedIndex < 3) {
            trace('Selected: Save Slot ${selectedIndex + 1}');
        } else {
            trace('Selected: Options Menu');
        }
    }

    private function selectSlot(slotIndex:Int) {
        var slots:Array<Dynamic> = FlxG.save.data.slots;
        var currentSlotData = slots[slotIndex];

        FlxG.save.data.currentSlot = slotIndex;

        if (!currentSlotData.created) {
            currentSlotData.created = true;
            currentSlotData.name = "KRIS";
            currentSlotData.room = "room_clost";
            trace('Created new save data in Slot ${slotIndex + 1}');
        } else {
            trace('Loaded existing save data from Slot ${slotIndex + 1} (${currentSlotData.name})');
        }

        FlxG.save.flush();
        FlxG.switchState(new PlayState());
    }

    private function eraseSlot(slotIndex:Int) {
        var slots:Array<Dynamic> = FlxG.save.data.slots;
        slots[slotIndex] = { created: false, name: "EMPTY", playTime: 0, room: "R_START" };
        
        FlxG.save.flush();

        FlxG.sound.play('assets/sounds/snd_break1.ogg');

        new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            FlxG.sound.play('assets/sounds/snd_break2.ogg');
        });
        
        slotTexts[slotIndex].text = 'Slot ${slotIndex + 1}: EMPTY';
        
        trace('Erased Slot ${slotIndex + 1}');
    }

    override public function destroy() {
        super.destroy();
    }
}
