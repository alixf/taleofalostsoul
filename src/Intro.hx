import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import openfl.Assets;
import motion.Actuate;
import flash.Lib;
import flash.events.MouseEvent;
import flash.geom.Point;

class Intro extends Sprite
{
	public function new()
	{
		super();
		addChild(new Bitmap(new BitmapData(1280, 720, false, 0x000000)));

		soul = new Bitmap(Assets.getBitmapData("assets/intro/soul.png"));
		soul.x = 950+25;
		soul.y = 140+25;
		addChild(soul);

		soulHover = new Bitmap(Assets.getBitmapData("assets/intro/soulHover.png"));
		soulHover.x = 950+25;
		soulHover.y = 140+25;
		soulHover.alpha = 0;
		addChild(soulHover);

		title = new Bitmap(Assets.getBitmapData("assets/intro/title.png"));
		title.x = 100+25;
		title.y = 250+25;
		addChild(title);

		titleHover = new Bitmap(Assets.getBitmapData("assets/intro/titleHover.png"));
		titleHover.x = 90+25;
		titleHover.y = 240+25;
		Actuate.tween(titleHover, 2.00, {alpha : 0}).ease(motion.easing.Linear.easeNone).repeat().reflect();
		addChild(titleHover);

		alpha = 0;
		Actuate.tween(this, 1, {alpha : 1});

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		Lib.current.stage.addEventListener(MouseEvent.CLICK , mouseClick);
		hover = false;
	}

	public function mouseMove(event : MouseEvent)
	{
		if(Point.distance(new Point(1056, 313), new Point(event.stageX, event.stageY)) <= 50)
		{
			if(!hover)
			{
				hover = true;
				Actuate.apply(soul, {alpha : soul.alpha});
				Actuate.apply(soulHover, {alpha : soulHover.alpha});
				Actuate.tween(soul, 2.5, {alpha : 0});
				Actuate.tween(soulHover, 2.5, {alpha : 1});
			}
		}
		else
		{
			if(hover)
			{
				hover = false;
				Actuate.apply(soul, {alpha : soul.alpha});
				Actuate.apply(soulHover, {alpha : soulHover.alpha});
				Actuate.tween(soul, 2.5, {alpha : 1});
				Actuate.tween(soulHover, 2.5, {alpha : 0});
			}
		}
	}

	public function mouseClick(event : MouseEvent)
	{
		if(Point.distance(new Point(1056, 313), new Point(event.stageX, event.stageY)) <= 50)
		{
			if(onExit != null)
			{
				Actuate.apply(soul, {alpha : soul.alpha});
				Actuate.apply(soulHover, {alpha : soulHover.alpha});
				Actuate.apply(title, {alpha : title.alpha});
				Actuate.apply(titleHover, {alpha : titleHover.alpha});
				Actuate.tween(soul, 0.5, {alpha : 0}).onComplete(onExit);
				Actuate.tween(soulHover, 0.5, {alpha : 0});
				Actuate.tween(title, 0.5, {alpha : 0});
				Actuate.tween(titleHover, 0.5, {alpha : 0});
			}
		}
	}

	var hover : Bool;
	var soul : Bitmap;
	var soulHover : Bitmap;
	var title : Bitmap;
	var titleHover : Bitmap;
	public var onExit : Void -> Void;
}