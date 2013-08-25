import flash.display.Sprite;
import motion.Actuate;
import motion.easing.Linear;
import flash.geom.Point;

class Fire extends Enemy
{
	public function new()
	{
		super();
		burn = true;

		for(i in 0...33)
		{
			var sprite = new Sprite();
			sprite.graphics.beginFill((0xFF << 16) + (Std.random(0xFF) << 8));
			sprite.graphics.drawCircle(0,0,10+Math.random()*10);
			sprite.x = (Math.random() * 50) - 25;
			sprite.y = (Math.random() * 30) - 15;
			Actuate.tween(sprite, 0.5, {y : sprite.y-15, scaleX : 0, scaleY : 0}).ease(Linear.easeNone).delay(Math.random()*0.5).repeat();
			addChild(sprite);
		}

		filters = [new flash.filters.BlurFilter(3, 20)];
	}

	override public function update(game : Game, map : IsoMap, soul : Soul)
	{
		if(Point.distance(new Point(x, y), new Point(soul.x, soul.y)) < 64 && burn)
		{
			if(soul.shield)
			{
				burn = false;
				Actuate.tween(this, 0.5, {alpha : 0});
			}
			else
				game.timeout();
		}
	}

	var burn : Bool;
}