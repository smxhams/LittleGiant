package arm;
import iron.object.Object;
import kha.audio1.AudioChannel;

class InitGame extends iron.Trait {

	//Game libraries
	public var hexTilesObjects = new List<Object>();
	public var hexTileCelestials = new List<Object>();
	public var hexTilesData = new Array<Dynamic>();
	public var homeIndex:Int;
	public var totalTiles:Int;
	public var currentHover:Int;
	

	public var difficulty:String;
	public var mapRadius:Int;


	public var camDistance:Float = 10.0;



	//Sound
	public var music1:AudioChannel;
	public var music2:AudioChannel;
	public var sfx1:AudioChannel;
	public var sfx2:AudioChannel;
	public var ambience:AudioChannel;

	public var hexObjTypes:Map<String, Int> = [
		'Dust' => 1,
		'Gas' => 1000,
		'Rock' => 8000,
		'Asteroid' => 15000,
		'SmallPlanet' => 40000,
		'LargePlanet' => 100000,
		'RedDwarf' => 200000,
		'Supergiant' => 500000,
		'Neutron' => 1000000,
		'Blackhole' => 5000000
	];

	public static var inst:InitGame = null;

	public function new() {
		super();
		inst = this;

		notifyOnInit(function() {
			// Set world irradiance
			var world = iron.Scene.active.world;
			world.probe.irradiance[0] = 0.3;
			world.probe.irradiance[1] = 0.8;
			world.probe.irradiance[2] = 1.0;
			world.probe.raw.strength = 1.0;
		});

		notifyOnUpdate(function() {
			object.remove();
		});

		notifyOnRemove(function() {
			iron.Scene.active.spawnObject('contMainMenu', null, function(o:Object) {});
		});
	}
}
