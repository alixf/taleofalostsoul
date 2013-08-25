import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.Assets;
import flash.Lib;
import motion.Actuate;

class IsoMap extends Sprite
{
	public function new(file : String)
	{
		super();
		tileWidth = 128;
		tileHeight = 64;
		loadFromFile(file);
	}

	public function loadFromFile(filePath : String)
	{
		var data = Assets.getBitmapData(filePath);
		tiles = new Array();
		exitTiles = new Array();

		// Create tiles
		for(x in 0...data.width)
		{
			tiles.push(new Array());
			for(y in 0...data.height)
			{
				var type : TileType;
				type = switch(data.getPixel(x, y))
				{
					case 0xFFFFFF : GROUND;
					case 0x99CC00 : START;
					case 0xFF0000 : EXIT;
					case 0xFF99CC : SHIELD;
					case 0xFFFF00 : TIME;
					case 0x00CCFF : SPEED;
					case 0xFFFFE4 : HEAVENGROUND;
					case 0xB4D929 : HEAVENSTART;
					case 0xFF4629 : HEAVENEXIT;
					case 0xFFB4BF : HEAVENSHIELD;
					case 0xFFFF29 : HEAVENTIME;
					case 0x46D9E4 : HEAVENSPEED;
					case 0x800000 : HELLGROUND;
					case 0x939500 : HELLSTART;
					case 0xDD0000 : HELLEXIT;
					case 0xDD7095 : HELLSHIELD;
					case 0xDDB900 : HELLTIME;
					case 0x2395B9 : HELLSPEED;
					case _ : VOID;
				};

				var tile = Tile.fromType(type);
				var position = isoToScreen(x, y);
				tile.x = position.x;
				tile.y = position.y;
				tiles[x].push(tile);

				if(tile.type == START || tile.type == HELLSTART || tile.type == HEAVENSTART)
					startTile = tile;
				if(tile.type == EXIT || tile.type == HELLEXIT || tile.type == HEAVENEXIT)
					exitTiles.push(tile);
			}
		}

		// Add tiles to the display tree
		for(y in 0...data.height)
		{
			for(x in 0...data.width)
			{
				var tile = tiles[data.width-1-x][y];
				addChild(tile);
			}
		}
	}

	public function getTile(x : Int, y : Int)
	{
		if(x >= 0 && x < tiles.length && y >= 0 && y < tiles[0].length)
			return tiles[x][y];
		else
			return null;
	}

	public function screenToIso(x : Int, y : Int)
	{
		x += Math.floor(tileWidth*0.5);
		return {
			x : Math.floor((x / tileWidth) - (y / tileHeight)),
			y : Math.floor((x / tileWidth) + (y / tileHeight))
		};
	}

	public function isoToScreen(x : Int, y : Int)
	{
		return {
			x : Math.floor((y + x) * tileWidth / 2),
			y : Math.floor((y - x) * tileHeight / 2)
		};
	}

	private var tileWidth : Int;
	private var tileHeight : Int;
	public var startTile : Tile;
	public var exitTiles : Array<Tile>;
	private var tiles : Array<Array<Tile>>;
}