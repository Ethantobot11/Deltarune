package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

enum BattlePhase
{
    MENU;
    TARGET_SELECT;
    PLAYER_ATTACK;
    ENEMY_TURN;
    VICTORY;
}

class BattleState extends FlxSubState
{
    var currentPhase:BattlePhase = MENU;
    
    var selectedOption:Int = 0;
    var menuOptions:Array<String> = ["FIGHT", "ACT", "ITEM", "MERCY", "DEFEND"];
    var menuTextGroup:FlxTypedGroup<FlxText>;
    var infoText:FlxText;

    var arenaBox:FlxSprite;
    var soul:FlxSprite;

    var enemy:Rudinn;
    var enemyTurnTimer:Float = 0;
    var attackTimerStarted:Bool = false;

    // Mobile touch drag tracking
    var isDraggingSoul:Bool = false;

    public function new(enemy:Rudinn)
    {
        super(0x99000000);
        this.enemy = enemy;
    }

    override public function create():Void
    {
        super.create();

        arenaBox = new FlxSprite(FlxG.width / 2 - 80, FlxG.height / 2 - 40);
        arenaBox.makeGraphic(160, 100, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawRect(arenaBox, 0, 0, 160, 100, FlxColor.TRANSPARENT, {color: FlxColor.WHITE, thickness: 3});
        arenaBox.scrollFactor.set(0, 0);
        add(arenaBox);

        soul = new FlxSprite(arenaBox.x + 76, arenaBox.y + 46);
        soul.makeGraphic(8, 8, FlxColor.RED);
        soul.visible = false;
        soul.scrollFactor.set(0, 0);
        add(soul);

        infoText = new FlxText(30, FlxG.height - 110, 0, "* Rudinn drew near!", 16);
        infoText.scrollFactor.set(0, 0);
        add(infoText);

        menuTextGroup = new FlxTypedGroup<FlxText>();
        add(menuTextGroup);

        var startX:Float = 30;
        var spacingX:Float = 110;
        for (i in 0...menuOptions.length)
        {
            var optionText = new FlxText(startX + (i * spacingX), FlxG.height - 50, 0, menuOptions[i], 16);
            optionText.scrollFactor.set(0, 0);
            menuTextGroup.add(optionText);
        }

        updateMenuText();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        switch (currentPhase)
        {
            case MENU:
                handleMenuInput();

            case TARGET_SELECT:
                infoText.text = "* Select target: Rudinn (Tap screen)";
                
                var justTapped:Bool = FlxG.mouse.justPressed;
                #if FLX_TOUCH
                for (touch in FlxG.touches.list)
                {
                    if (touch.justPressed) justTapped = true;
                }
                #end

                if (FlxG.keys.anyJustPressed([Z, ENTER]) || justTapped)
                {
                    currentPhase = PLAYER_ATTACK;
                    attackTimerStarted = false;
                }
                else if (FlxG.keys.anyJustPressed([X, SHIFT, BACKSPACE]))
                {
                    currentPhase = MENU;
                    infoText.text = "* Choose an action.";
                    setMenuVisible(true);
                }

            case PLAYER_ATTACK:
                infoText.text = "* You attacked Rudinn!";
                if (!attackTimerStarted)
                {
                    attackTimerStarted = true;
                    FlxTimer.wait(1.0, function() {
                        startEnemyTurn();
                    });
                }

            case ENEMY_TURN:
                handleSoulMovement();
                enemyTurnTimer += elapsed;

                if (enemyTurnTimer >= 4.0)
                {
                    endEnemyTurn();
                }

            case VICTORY:
                var justTapped:Bool = FlxG.mouse.justPressed;
                #if FLX_TOUCH
                for (touch in FlxG.touches.list)
                {
                    if (touch.justPressed) justTapped = true;
                }
                #end

                if (FlxG.keys.anyJustPressed([Z, ENTER]) || justTapped)
                {
                    close();
                }
        }
    }

    function handleMenuInput():Void
    {
        // Keyboard Input
        var leftPressed = FlxG.keys.anyJustPressed([LEFT, A]);
        var rightPressed = FlxG.keys.anyJustPressed([RIGHT, D]);
        var confirmPressed = FlxG.keys.anyJustPressed([Z, ENTER]);

        if (leftPressed)
        {
            selectedOption = (selectedOption - 1 + menuOptions.length) % menuOptions.length;
            updateMenuText();
        }
        else if (rightPressed)
        {
            selectedOption = (selectedOption + 1) % menuOptions.length;
            updateMenuText();
        }

        for (i in 0...menuTextGroup.members.length)
        {
            var btn = menuTextGroup.members[i];
            
            if (FlxG.mouse.overlaps(btn))
            {
                if (selectedOption != i)
                {
                    selectedOption = i;
                    updateMenuText();
                }
                if (FlxG.mouse.justPressed)
                {
                    confirmPressed = true;
                }
            }

            #if FLX_TOUCH
            for (touch in FlxG.touches.list)
            {
                if (touch.overlaps(btn))
                {
                    if (selectedOption != i)
                    {
                        selectedOption = i;
                        updateMenuText();
                    }
                    if (touch.justPressed)
                    {
                        confirmPressed = true;
                    }
                }
            }
            #end
        }

        if (confirmPressed)
        {
            executeMenuOption(menuOptions[selectedOption]);
        }
    }

    function executeMenuOption(option:String):Void
    {
        switch (option)
        {
            case "FIGHT":
                setMenuVisible(false);
                currentPhase = TARGET_SELECT;
            case "ACT":
                infoText.text = "* Rudinn seems docile.";
            case "ITEM":
                infoText.text = "* You don't have any items.";
            case "MERCY":
                setMenuVisible(false);
                infoText.text = "* You spared Rudinn!";
                currentPhase = VICTORY;
            case "DEFEND":
                setMenuVisible(false);
                infoText.text = "* You took a defensive stance.";
                startEnemyTurn();
        }
    }

    function updateMenuText():Void
    {
        for (i in 0...menuTextGroup.members.length)
        {
            var textObj = menuTextGroup.members[i];
            if (i == selectedOption)
            {
                textObj.color = FlxColor.YELLOW;
                textObj.text = "> " + menuOptions[i];
            }
            else
            {
                textObj.color = FlxColor.WHITE;
                textObj.text = menuOptions[i];
            }
        }
    }

    function setMenuVisible(visible:Bool):Void
    {
        menuTextGroup.visible = visible;
    }

    function startEnemyTurn():Void
    {
        setMenuVisible(false);
        currentPhase = ENEMY_TURN;
        enemyTurnTimer = 0;
        infoText.text = "* Rudinn attacks!";
        soul.visible = true;
    }

    function endEnemyTurn():Void
    {
        soul.visible = false;
        currentPhase = MENU;
        setMenuVisible(true);
        infoText.text = "* What will you do?";
        updateMenuText();
    }

    function handleSoulMovement():Void
    {
        var speed:Float = 140;
        soul.velocity.set(0, 0);

        if (FlxG.keys.anyPressed([UP, W])) soul.velocity.y = -speed;
        if (FlxG.keys.anyPressed([DOWN, S])) soul.velocity.y = speed;
        if (FlxG.keys.anyPressed([LEFT, A])) soul.velocity.x = -speed;
        if (FlxG.keys.anyPressed([RIGHT, D])) soul.velocity.x = speed;

        var touchX:Float = 0;
        var touchY:Float = 0;
        var isTouching:Bool = false;

        if (FlxG.mouse.pressed)
        {
            touchX = FlxG.mouse.x;
            touchY = FlxG.mouse.y;
            isTouching = true;
        }

        #if FLX_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (touch.pressed)
            {
                touchX = touch.x;
                touchY = touch.y;
                isTouching = true;
            }
        }
        #end

        if (isTouching)
        {
            soul.x = touchX - (soul.width / 2);
            soul.y = touchY - (soul.height / 2);
        }

        if (soul.x < arenaBox.x + 2) soul.x = arenaBox.x + 2;
        if (soul.x > arenaBox.x + arenaBox.width - 10) soul.x = arenaBox.x + arenaBox.width - 10;
        if (soul.y < arenaBox.y + 2) soul.y = arenaBox.y + 2;
        if (soul.y > arenaBox.y + arenaBox.height - 10) soul.y = arenaBox.y + arenaBox.height - 10;
    }
}