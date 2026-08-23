package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
#if mobile
import flixel.ui.FlxVirtualPad;
#end

class OptionsState extends FlxState {

    private var selectedIndex:Int = 0;
    private final MAX_OPTIONS:Int = 3;

    public static var showFps:Bool = true;

    private var optionBoxes:Array<FlxSprite> = [];
    private var optionTexts:Array<FlxText> = [];

    #if mobile
    private var virtualPad:FlxVirtualPad;
    #end

    override public function create() {
        super.create();
        trace("Entering OptionsState.create()...");

        // Load or initialize options save data
        if (FlxG.save.data.options == null) {
            FlxG.save.data.options = {
                fpsEnabled: true,
                controlType: 0
            };
            FlxG.save.flush();
        } else {
            showFps = FlxG.save.data.options.fpsEnabled;
        }

        var bg = new FlxSprite(0, 0);
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFF141428);
        add(bg);

        for (i in 0...MAX_OPTIONS) {
            var box = new FlxSprite(40, 50 + (i * 50));
            box.makeGraphic(240, 40, 0xFF222244);
            add(box);
            optionBoxes.push(box);

            var label = getOptionText(i);
            var textObj = new FlxText(50, 58 + (i * 50), 0, label, 16);
            textObj.color = 0xFFFFFFFF;
            add(textObj);
            optionTexts.push(textObj);
        }

        #if mobile
        virtualPad = new FlxVirtualPad(UP_DOWN, A_B);
        add(virtualPad);
        #end

        updateVisualSelection();
        trace("OptionsState loaded.");
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        var changed = false;

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
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = MAX_OPTIONS - 1;
            changed = true;
        }
        
        if (downPressed) {
            selectedIndex++;
            if (selectedIndex >= MAX_OPTIONS) selectedIndex = 0;
            changed = true;
        }

        if (changed) {
            updateVisualSelection();
        }

        if (acceptPressed) {
            executeOptionAction(selectedIndex);
            refreshOptionTexts();
        }

        if (backPressed) {
            trace("Exiting Options Menu...");
            FlxG.switchState(new MainMenuState());
        }
    }

    private function getOptionText(index:Int):String {
        switch (index) {
            case 0: return 'FPS Counter: ${showFps ? "ON" : "OFF"}';
            case 1: return 'Controls: ${FlxG.save.data.options.controlType == 0 ? "Default" : "Alt"}';
            case 2: return "Back to Main Menu";
            default: return "";
        }
    }

    private function refreshOptionTexts() {
        for (i in 0...optionTexts.length) {
            optionTexts[i].text = getOptionText(i);
        }
    }

    private function updateVisualSelection() {
        for (i in 0...optionBoxes.length) {
            if (i == selectedIndex) {
                optionBoxes[i].makeGraphic(240, 40, 0xFF444488);
            } else {
                optionBoxes[i].makeGraphic(240, 40, 0xFF222244);
            }
        }
    }

    private function executeOptionAction(index:Int) {
        switch (index) {
            case 0:
                showFps = !showFps;
                FlxG.save.data.options.fpsEnabled = showFps;
                FlxG.save.flush();

                if (Main.fpsVar != null) {
                    Main.fpsVar.visible = showFps;
                }
            case 1:
                var currentType:Int = FlxG.save.data.options.controlType;
                currentType = (currentType == 0) ? 1 : 0;
                FlxG.save.data.options.controlType = currentType;
                FlxG.save.flush();
            case 2:
                FlxG.switchState(new MainMenuState());
        }
    }

    override public function destroy() {
        super.destroy();
    }
}
