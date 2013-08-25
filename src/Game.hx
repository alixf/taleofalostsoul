import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import openfl.Assets;
import motion.Actuate;
import flash.filters.BlurFilter;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.text.TextField;
import flash.text.Font;
import flash.text.TextFormat;

class Game extends Sprite
{
	public static var LEVELCOUNT = 16;

	static function main()
	{
		var background = new Bitmap(new BitmapData(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 0x000000));
		Lib.current.stage.addChild(background);
		goToIntro();
	}

	static public function goToIntro()
	{
		var intro = new Intro();
		Lib.current.stage.addChild(intro);
		intro.onExit = function()
		{
			Lib.current.stage.removeChild(intro);
			goToGame();
		}
	}

	static public function goToGame()
	{
		var game = new Game();
		Lib.current.stage.addChild(game);
		game.onExit = function(hell : Bool)
		{
			for (i in 1...game.numChildren)
				Actuate.tween(game.getChildAt(i), 1.5, {alpha : 0});
			Actuate.tween(game.getChildAt(0), 1.5, {alpha : (hell) ? 1 : 0}).onComplete(function()
			{
				//Lib.current.stage.removeChild(game);
				goToEnd(hell);
			});
		}
	}

	static public function goToEnd(hell : Bool)
	{
		var background = new Bitmap(new BitmapData(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 0x0000FF));
		var graphics = new Bitmap(Assets.getBitmapData("assets/end"+(hell ? "Hell" : "Heaven")+".png"));
		graphics.x = (background.width-graphics.width)/2;
		graphics.y = (background.height-graphics.height)/2;
		Lib.current.stage.addChild(background);
		Lib.current.stage.addChild(graphics);
	}

	public function new()
	{
		// Sprite properties
		super();
		scrollRect = new Rectangle(0,0,Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

		// Background
		background = new Bitmap(new BitmapData(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, false, 0x000000));
		addChild(background);

		running = false;
		lockCamera = false;
		level = 1;
		preLevelIndex = 0;
		lastMouseEvent = null;
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);

		startLevel();
	}

	public function startLevel()
	{
		// Map
		if(map != null)
			removeChild(map);
		map = new IsoMap("assets/levels/level"+level+".png");

		if(title != null)
			removeChild(title);
		title = new Bitmap(Assets.getBitmapData("assets/levels/titles/"+level+".png"));
		
		if(pressSpace != null)
			removeChild(pressSpace);
		pressSpace = new Bitmap(Assets.getBitmapData("assets/pressSpace.png"));

		// HUD
		if(hud != null)
			removeChild(hud);
		hud = new HUDTimer();
		hud.onTimeout = timeout;
		hud.filters = [new flash.filters.GlowFilter(0xFFFFFF, 1, 30, 30)];

		// Soul
		if(soul != null)
			removeChild(soul);
		soul = new Soul();
		soul.onMove = onSoulMove;

		//Shadow
		if(shadow != null)
			for(i in 0...5)
				removeChild(shadow[i]);
		shadow = new Array();
		for(i in 0...5)
		{
			shadow.push(new Soul());
			shadow[i].alpha = 0.05;
		}

		// Enemies
		if(enemies != null)
			for(enemy in enemies)
				removeChild(enemy);
		generateEnemies();

		if(musicChannel != null)
			musicChannel.stop();
		music = Assets.getSound("assets/music/level"+level+".mp3");
		musicChannel = music.play();

		// Set start position
		soul.setPosition(cast map.startTile.x, cast map.startTile.y);

		for(i in 0...5)
		{
			shadow[i].x = soul.x;	
			shadow[i].y = soul.y;	
		}
		soul.target = {x : soul.x, y : soul.y};

		title.x = 40 + scrollRect.x;
		title.y = Lib.current.stage.stageHeight - 40 - title.height + scrollRect.y;
		pressSpace.x = Lib.current.stage.stageWidth - 40 - pressSpace.width + scrollRect.x;
		pressSpace.y = Lib.current.stage.stageHeight - 40 - pressSpace.height + scrollRect.y;

		// Add children
		addChild(map);
		for(i in 0...5)
			addChild(shadow[5-1-i]);
		addChild(soul);
		if(enemies != null)
			for(enemy in enemies)
				addChild(enemy);
		addChild(hud);
		addChild(title);
		addChild(pressSpace);

		// Prelevel
		if(level != preLevelIndex)
		{
			preLevel();
			preLevelIndex = level;
		}

		// Animation
		Actuate.apply(soul, {alpha : 0});
		Actuate.apply(hud, {alpha : 0});
		Actuate.apply(title, {alpha : 0});
		Actuate.apply(pressSpace, {alpha : 0});
		Actuate.tween(soul, 2.5, {alpha : 1});
		Actuate.tween(hud, 2.5, {alpha : 1});
		Actuate.tween(title, 2.5, {alpha : 1});
		Actuate.tween(pressSpace, 2.5, {alpha : 1});
	}

	public function startTimer(event : KeyboardEvent)
	{
		if(event.charCode == 32)
		{
			if(!running)
			{
				running = true;
				hud.start();
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, soul.enableMove);
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, soul.disableMove);
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, setSoulTarget);

				/*
					title.filters = [ new BlurFilter () ];
					Actuate.effects(title, 2.5).filter(BlurFilter, { blurX: 0, blurY: 0 });
				*/

				Actuate.apply(title, {alpha : 1});
				Actuate.apply(pressSpace, {alpha : 1});
				Actuate.tween(title, 2.5, {alpha : 0});
				Actuate.tween(pressSpace, 2.5, {alpha : 0});
			}
		}
	}

	public function endTimer()
	{
		if(running)
		{
			running = false;
			hud.stop();
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, soul.enableMove);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, soul.disableMove);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, setSoulTarget);
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, startTimer);
		}
	}

	public function update(event : Event)
	{
		if(running == true)
			soul.update();
		if(running == true)
		{
			hud.update();
			for(enemy in enemies)
				enemy.update(this, map, soul);
		}
	}

	public function onSoulMove(x : Int, y : Int)
	{
		shadow[0].x = x;
		shadow[0].y = y;
		for(i in 1...5)
		{
			shadow[5-i].x = shadow[5-i-1].x;
			shadow[5-i].y = shadow[5-i-1].y;
		}

		updateCamera(x, y);
		activateTile(x, y);
	}

	public function updateCamera(x : Int, y : Int)
	{
		if(!lockCamera)
		{
			scrollRect = new Rectangle(x - scrollRect.width / 2, y - scrollRect.height / 2, scrollRect.width, scrollRect.height);
			background.x = scrollRect.x;
			background.y = scrollRect.y;
			hud.x = scrollRect.x;
			hud.y = scrollRect.y;
			if(lastMouseEvent != null)
				setSoulTarget(lastMouseEvent);
		}
	}

	public function setSoulTarget(event : MouseEvent)
	{
		if(running)
		{
			soul.setTarget(cast (event.stageX + scrollRect.x), cast (event.stageY + scrollRect.y));
			lastMouseEvent = event;
		}
	}

	public function activateTile(x : Int, y : Int)
	{
		var tilePos = map.screenToIso(x, y);
		var tile = map.getTile(tilePos.x, tilePos.y);
		if(tile != null)
		{
			switch(tile.type)
			{
			case EXIT, HEAVENEXIT, HELLEXIT :
				Assets.getSound("assets/sounds/exit.wav").play();
				endTimer();
				for(i in 0...5)
				{
					Actuate.tween(shadow[i], 1, {x : tile.x, y : tile.y});
					Actuate.tween(shadow[i], 0.5, {scaleX : 3, scaleY : 3, alpha : 0.33});
				}
				Actuate.tween(soul, 1, {x : tile.x, y : tile.y});
				Actuate.tween(soul, 0.5, {scaleX : 3, scaleY : 3, alpha : 0.33})
					.onComplete(function()
					{
						for(i in 0...5)
							Actuate.tween(shadow[i], 0.5, {scaleX : 0, scaleY : 0, alpha : 1});
						Actuate.tween(soul, 0.5, {scaleX : 0, scaleY : 0, alpha : 1})
						.onComplete(function()
							{
								Actuate.apply(map, {alpha : map.alpha});
								Actuate.apply(hud, {alpha : hud.alpha});
								for(enemy in enemies)
									Actuate.tween(enemy, 1, {alpha : 0});
								Actuate.tween(map, 1, {alpha : 0});
								Actuate.tween(hud, 1, {alpha : 0})
								.onComplete(function()
									{
										defineNewLevel(level, tile);
										startLevel();
									});
							});
					});

			case SPEED, HEAVENSPEED, HELLSPEED :
				soul.boostSpeed(2, 3.0);
				tile.type = GROUND;
				Actuate.tween(tile.getChildAt(1), 1, {alpha : 0, y : -250});
				Actuate.tween(tile.getChildAt(2), 1, {alpha : 0, y : -250});
				Assets.getSound("assets/sounds/speed.wav").play();
			
			case TIME, HEAVENTIME, HELLTIME :
				hud.addTime(3.0);
				tile.type = GROUND;
				Actuate.tween(tile.getChildAt(1), 1, {alpha : 0, y : -250});
				Actuate.tween(tile.getChildAt(2), 1, {alpha : 0, y : -250});
				Assets.getSound("assets/sounds/time.wav").play();
			
			case SHIELD, HEAVENSHIELD, HELLSHIELD :
				soul.giveShield(3.0);
				tile.type = GROUND;
				Actuate.tween(tile.getChildAt(1), 1, {alpha : 0, y : -250});
				Actuate.tween(tile.getChildAt(2), 1, {alpha : 0, y : -250});
				Assets.getSound("assets/sounds/shield.wav").play();

			case VOID :
				endTimer();
				Actuate.apply(map, {alpha : map.alpha});
				Actuate.apply(hud, {alpha : hud.alpha});
				Actuate.tween(map, 1, {alpha : 0}).onComplete(startLevel);
				Actuate.tween(hud, 1, {alpha : 0});
				for(enemy in enemies)
					Actuate.tween(enemy, 1, {alpha : 0});
				for(i in 0...5)
					Actuate.tween(shadow[i], 0.5, {y : soul.y+100, alpha : 0, scaleX : 0.5, scaleY : 0.5});
				Actuate.tween(soul, 0.5, {y : soul.y+100, alpha : 0, scaleX : 0.5, scaleY : 0.5});

			default :
			}
		}
		else
		{
			endTimer();
			for(i in 0...5)
				Actuate.tween(shadow[i], 0.5, {y : soul.y+100, alpha : 0, scaleX : 0.5, scaleY : 0.5});
			Actuate.tween(soul, 0.5, {y : soul.y+100, alpha : 0, scaleX : 0.5, scaleY : 0.5});
			Actuate.apply(map, {alpha : map.alpha});
			Actuate.apply(hud, {alpha : hud.alpha});
			for(enemy in enemies)
				Actuate.tween(enemy, 1, {alpha : 0});
			Actuate.tween(map, 1, {alpha : 0}).onComplete(startLevel);
			Actuate.tween(hud, 1, {alpha : 0});
		}
	}

	public function defineNewLevel(currentLevel : Int, tile : Tile)
	{
		if(currentLevel == 4)
		{
			if(tile == map.exitTiles[0])
				level = 5;
			else if(tile == map.exitTiles[1])
				level = 11;
		}
		else if(currentLevel < LEVELCOUNT)
			level++;
	}

	public function preLevel()
	{
		switch(level)
		{
		case 1 :
			openWindow("Here you are, my little soul...
						You were hard to find, you know that ?
						Come with me now, I'll guide you to your destination.

						...
						Hm, you seem to be pretty weak, you won't be able to survive more than 10 seconds here ... We'd better hurry.

						(Use your mouse to move on the map and go to the exit)");

		case 2 :
			openWindow("It looks like it's going to be a long way to the exit this time.

						Let's try to find something to go there a bit ... faster.");

		case 3 :
			openWindow("You really can't survive a long time in this place my little soul.

						I know this place, there might be something that will give you a little bit more time.");

		case 4 :
			openWindow("We all have to make a choice one day.

						It's your time now ...

						Be quick, or you will disappear.");

		case 5 :
			openWindow("So you chose this path.

						Let's hope this light did not make you blind.

						Anyway, welcome to the gate.");

		case 6 :
			openWindow("Watch out for the towers !

						The will fire at you and predict your movements so be extra careful.");

		case 7 :
			openWindow("What strange animal is that ...

						I have never seen anything of this kind before.

						I'll let you handle that.");

		case 8 :
			openWindow("Oh, there's a cleansing fire

						Your soul is currently too weak to go through that ...");

		case 9 :
			openWindow("It sounds like we fall down in a maze.

						I hope there is an exit at least ...");

		case 10 :
			openWindow("So you managed to come this far...
						Congratulations my little soul.
						As you must have guessed, there was a reason for you to come here.

						This place ... is what we call \"Heaven\"
						And now begins your true mission ...





						CRUSH THEM !!!");

		case 11 :
			openWindow("So you chose this path.

						Let's hope your heart is not as dark as this ground.

						Anyway, welcome to the gate.");
		
		case 12 :
			openWindow("No impure spirit shall go further...

						But I guess we don't have time for that.");

		case 13 :
			openWindow("It looks like this place is under heavy protection.

						We have no choice but to go through, my little soul.");
		
		case 14 :
			openWindow("Those tower will be an hindrance.

						Let's get past them quickly !");

		case 15 :
			openWindow("Now that's an amazing maze.

						I hope you like this kind of thing, cause I don't.");

		case 16 :
			openWindow("So you managed to come this far... Congratulations my little soul.
						As you must have guessed, there was a reason for you to come here.

						This place ... is what we call \"Hell\"
						And now begins your true mission ...





						SAVE US !!!");

		default :
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, startTimer);
		}
	}

	public function openWindow(text : String)
	{
		text = StringTools.replace(text, String.fromCharCode(9), "");
		text = StringTools.replace(text, String.fromCharCode(13), "");
		var speechBackground = new Bitmap(Assets.getBitmapData("assets/speechBackground.png"));

		var font = Assets.getFont("assets/fonts/constan.ttf");
		var textField = new TextField();

		var format = new TextFormat(font.fontName, 30.0, 0xFFFFFF);
		textField.defaultTextFormat = format;
		
		textField.embedFonts = true;
		textField.width = speechBackground.width - 40;
		textField.height = speechBackground.height - 40;
		textField.selectable = false;
		textField.text = text;
		textField.x = 20;
		textField.y = 20;
		textField.wordWrap = true;

		speechWindow = new Sprite();
		speechWindow.addChild(speechBackground);
		speechWindow.addChild(textField);
		speechWindow.x = (Lib.current.stage.stageWidth-speechBackground.width)/2 + scrollRect.x;
		speechWindow.y = (Lib.current.stage.stageHeight-speechBackground.height)/2 + scrollRect.y;
		addChild(speechWindow);

		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, closeWindow);
	}

	public function closeWindow(event : KeyboardEvent)
	{
		if(event.charCode == 32)
		{
			Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, closeWindow);
			Actuate.tween(speechWindow, 0.75, {y : speechWindow.y + 100, alpha : 0}).onComplete(function()
				{
					removeChild(speechWindow);
					Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, startTimer);
				});

			if(level == 10 || level == 16)
			{
				if(onExit != null)
					onExit(level == 16);
			}
		}
	}

	public function timeout()
	{
		endTimer();
		for(i in 0...5)
			Actuate.tween(shadow[i], 0.5, {alpha : 0, scaleY : 5});
		Actuate.tween(soul, 0.5, {alpha : 0, scaleY : 5});
		Actuate.apply(map, {alpha : map.alpha});
		Actuate.apply(hud, {alpha : hud.alpha});
		Actuate.tween(map, 1, {alpha : 0}).onComplete(startLevel);
		Actuate.tween(hud, 1, {alpha : 0});
		for(enemy in enemies)
			Actuate.tween(enemy, 1, {alpha : 0});
	}

	public function generateEnemies()
	{
		enemies = new Array();
		switch(level)
		{
		case 6 :
			var pos = map.isoToScreen(13, 1);
			var tower = new Tower();
			tower.x = pos.x;
			tower.y = pos.y;
			enemies.push(tower);
			pos = map.isoToScreen(7, 5);
			tower = new Tower();
			tower.x = pos.x;
			tower.y = pos.y;
			enemies.push(tower);

		case 7 :
			var pos = map.isoToScreen(12,5);
			var hedgehog = new Hedgehog(false);
			hedgehog.x = pos.x;
			hedgehog.y = pos.y;
			enemies.push(hedgehog);
			pos = map.isoToScreen(19,1);
			hedgehog = new Hedgehog(false);
			hedgehog.x = pos.x;
			hedgehog.y = pos.y;
			enemies.push(hedgehog);

		case 8 :
			var pos = map.isoToScreen(7,3);
			var fire = new Fire();
			fire.x = pos.x;
			fire.y = pos.y;
			enemies.push(fire);

		case 12 :
			var pos = map.isoToScreen(4,6);
			var fire = new Fire();
			fire.x = pos.x;
			fire.y = pos.y;
			enemies.push(fire);
			pos = map.isoToScreen(4,4);
			fire = new Fire();
			fire.x = pos.x;
			fire.y = pos.y;
			enemies.push(fire);
			pos = map.isoToScreen(4,2);
			fire = new Fire();
			fire.x = pos.x;
			fire.y = pos.y;
			enemies.push(fire);

		case 13 :
			var pos = map.isoToScreen(7,2);
			var hedgehog = new Hedgehog(true);
			hedgehog.x = pos.x;
			hedgehog.y = pos.y;
			enemies.push(hedgehog);
			pos = map.isoToScreen(7,3);
			hedgehog = new Hedgehog(true);
			hedgehog.x = pos.x;
			hedgehog.y = pos.y;
			enemies.push(hedgehog);
			pos = map.isoToScreen(7,4);
			hedgehog = new Hedgehog(true);
			hedgehog.x = pos.x;
			hedgehog.y = pos.y;
			enemies.push(hedgehog);

		case 14 :
			var pos = map.isoToScreen(2, 5);
			var tower = new Tower();
			tower.x = pos.x;
			tower.y = pos.y;
			enemies.push(tower);
			pos = map.isoToScreen(5, 5);
			tower = new Tower();
			tower.x = pos.x;
			tower.y = pos.y;
			enemies.push(tower);


		default :
		}
	}

	var running : Bool;
	var lockCamera : Bool;
	var background : Bitmap;
	var map : IsoMap;
	var title : Bitmap;
	var music : Sound;
	var musicChannel : SoundChannel;
	var pressSpace : Bitmap;
	var soul : Soul;
	var hud : HUDTimer;
	var lastMouseEvent : MouseEvent;
	var level : Int;
	var shadow : Array<Soul>;
	var preLevelIndex : Int;
	var enemies : Array<Enemy>;
	var speechWindow : Sprite;
	var onExit : Bool -> Void;
}
