package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import FPSCounter;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

#if windows
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end

class Main extends Sprite
{
	var gameWidth:Int = 320; 
	var gameHeight:Int = 240; 
	var zoom:Float = 1; 
	var initialState:Class<FlxState> = MainMenuState;
	var framerate:Int = 60; 
	var skipSplash:Bool = true; 
	var startFullscreen:Bool = false;
	public static var fpsVar:FPSCounter;

	var showFps = (FlxG.save.data.options != null) ? FlxG.save.data.options.fpsEnabled : true;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		CrashHandler.init();
			
		#if windows
		untyped __cpp__("SetProcessDPIAware();");
		#end

		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void	
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		addChild(new FlxGame(
			gameWidth,
			gameHeight,
			initialState,
			framerate,
			framerate,
			skipSplash,
			startFullscreen
		));

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null) {
		    fpsVar.visible = showFps;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
}
