import flash.display.Sprite;
import flash.display.Bitmap;
import openfl.Assets;
import motion.Actuate;
import motion.easing.Linear;
import flash.geom.Point;

class Tower extends Enemy
{
	public function new()
	{
		super();
		var bitmap = new Bitmap(Assets.getBitmapData("assets/tower.png"));
		bitmap.x = -bitmap.width/2;
		bitmap.y = -bitmap.height*0.75;
		addChild(bitmap);
		Actuate.tween(bitmap, 1, {y : bitmap.y-10}).ease(Linear.easeNone).repeat().reflect();
		clock = new Clock();
		reloading = false;
	}

	override public function update(game : Game, map : IsoMap, soul : Soul)
	{
		if(reloading && clock.getTime() > 2)
			reloading = false;

		if(Point.distance(new Point(x, y), new Point(soul.x, soul.y-20)) < 200 && !reloading)
		{
			clock.reset();
			reloading = true;

			var aim = new Sprite();
			var bitmap = new Bitmap(Assets.getBitmapData("assets/aim.png"));
			bitmap.x = -bitmap.width/2;
			bitmap.y = -bitmap.height/2;
			aim.x = soul.x + Math.cos(soul.direction) * soul.speed * 0.75;
			aim.y = soul.y + Math.sin(soul.direction) * soul.speed * 0.75 - 20;
			aim.alpha = 0;

			aim.addChild(bitmap);
			game.addChild(aim);

			Assets.getSound("assets/sounds/aim.wav").play();

			Actuate.tween(aim, 0.75, {rotation : 90, alpha : 1}).ease(Linear.easeNone).onComplete(function()
				{
					if(Point.distance(new Point(aim.x, aim.y), new Point(soul.x, soul.y)) < 32)
					{
						if(soul.shield)
						{
							Assets.getSound("assets/sounds/fail.wav").play();
						}
						else
						{
							Assets.getSound("assets/sounds/hit.wav").play();
							game.timeout();
						}
					}
					Actuate.tween(aim, 0.25, {alpha : 0}).onComplete(function()
					{
						game.removeChild(aim);
					});
				});
		}
	}

	var clock : Clock;
	var reloading : Bool;
}