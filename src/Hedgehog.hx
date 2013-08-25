import flash.display.Sprite;
import flash.display.Bitmap;
import openfl.Assets;
import motion.Actuate;
import motion.easing.Linear;
import flash.geom.Point;

class Hedgehog extends Enemy
{
	public function new(hell : Bool)
	{
		super();
		var bitmap = new Bitmap(Assets.getBitmapData("assets/"+(hell ? "hell" : "heaven")+"HH.png"));
		bitmap.x = -bitmap.width/2;
		bitmap.y = -bitmap.height;
		addChild(bitmap);
		Actuate.tween(bitmap, 1, {y : bitmap.y-10}).ease(Linear.easeNone).repeat().reflect();
		clock = new Clock();
		reloading = false;
		balls = new Array();
	}

	override public function update(game : Game, map : IsoMap, soul : Soul)
	{
		if(reloading && clock.getTime() > 2)
			reloading = false;
		
		if(!reloading)
		{
			var ballBitmap = new Bitmap(Assets.getBitmapData("assets/hedgeBall.png"));
			ballBitmap.x = -ballBitmap.width/2;
			ballBitmap.y = -ballBitmap.height;

			var ball = new Sprite();
			ball.x = x;
			ball.y = y;
			ball.addChild(ballBitmap);
			
			var channel = Assets.getSound("assets/sounds/hedgeBall.wav").play().soundTransform = new flash.media.SoundTransform(0.33);

			game.addChild(ball);
			Actuate.tween(ball, 1, {x : ball.x - 400, y : ball.y + 200}).ease(Linear.easeNone).onComplete(function()
				{
					balls.remove(ball);
					Actuate.tween(ball, 0.125, {x : ball.x - 50, y : ball.y + 25, alpha : 0}).ease(Linear.easeNone).onComplete(function()
						{
							game.removeChild(ball);
						});
				});
			balls.push(ball);

			reloading = true;
			clock.reset();
		}

		for(ball in balls)
		{
			if(Point.distance(new Point(ball.x, ball.y), new Point(soul.x, soul.y)) < 30)
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
		}
	}

	var clock : Clock;
	var reloading : Bool;
	var balls : Array<Sprite>;
}