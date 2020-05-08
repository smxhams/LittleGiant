package arm;
import iron.object.Object;
import iron.system.Time;
import iron.Scene;
import iron.math.Vec4;
import iron.system.Tween;

class GenerateGame extends iron.Trait {
	@prop 
	var speed:Float;
	var totalTicks:Int;
	@prop
	var totalTime:Float;
	var currentTick:Int = 0;
	var currentTime:Float = 0.0;
	var tickInterval:Float = 0.0;

	public function new() {
		super();

		notifyOnInit(function() {
			//Generates grid
			var radius = InitGame.inst.mapRadius; //Final radius is this minus 1
			var data = InitGame.inst.hexTilesData;
			var index = 0;
			var distance = 0;
			var temp:Array<{i:Int, x:Int, y:Int, z:Int, t:Int, v:Int, p:Int, o:Object, n:Array<Int>}> = [];
			for (q in -radius...radius+1) { //Iterates through all possible hexagon positions
				for (r in -radius...radius+1) {
					for (s in -radius...radius+1) {
						if (q+r+s == 0) { //Filters to only applicable hexagons
							if (q==0&&r==0&&s==0) {
								InitGame.inst.homeIndex = index;
								temp = [{i:index, x:q, y:r, z:s, t:-1, v:1000, p:1000, o:null, n:null}];
								data.push(temp);
							}
							else {
								distance = Std.int((Math.abs(q)+Math.abs(r)+Math.abs(s)) / 2);
								temp = [{i:index, x:q, y:r, z:s, t:Std.random(20), v:Std.int(1750*(Math.random()+0.5)), p:0, o:null, n:null}];
								data.push(temp);
							}
							index += 1;
						}
					}
				}
			}
			InitGame.inst.totalTiles = index;
			totalTicks = index*2;
			tickInterval = (totalTime/totalTicks) * speed;
			trace("Generating Game. Tick interval: " + tickInterval);
			trace('TotalTicks :' + totalTicks);
			trace('Total hexagons: ' + index);
			
		});

		notifyOnUpdate(function() {
			//Camera movement
			var camera = Scene.active.getChild("Camera");
			iron.system.Tween.to({
				target: camera.transform,
				props: {
					loc: new Vec4(0.0, -InitGame.inst.camDistance*0.75, InitGame.inst.camDistance),
					//scale:
					//rot:
				},
				duration: totalTime,
				done: function() {},
				ease: Ease.ExpoInOut
			});


			var data = InitGame.inst.hexTilesData;
			while ((currentTick <= totalTicks) && (currentTime > (currentTick*tickInterval))) {
				// First half place tiles
				if (currentTick < InitGame.inst.totalTiles) {// Spawning hexagon grid
					iron.Scene.active.spawnObject('contHex', null, function(o:Object) {
						o.transform.loc.x = 1*(Math.sqrt(3)*data[currentTick][0].x + Math.sqrt(3)/2*data[currentTick][0].y);
						o.transform.loc.y = 1*(3/2*data[currentTick][0].y);
						o.transform.loc.z = 0.0;
						o.transform.buildMatrix();
						InitGame.inst.hexTilesObjects.add(o);
						o.properties['id'] = data[currentTick][0].i;
					});
					if (currentTick == InitGame.inst.homeIndex) {
						iron.Scene.active.spawnObject('contHexGold', null, function(o:Object) {
							o.transform.loc.x = 1*(Math.sqrt(3)*data[currentTick][0].x + Math.sqrt(3)/2*data[currentTick][0].y);
							o.transform.loc.y = 1*(3/2*data[currentTick][0].y);
							o.transform.loc.z = 0.0;
							o.transform.buildMatrix();
							InitGame.inst.hexTilesObjects.add(o);
							o.properties['id'] = data[currentTick][0].i;
						});
					}
				}

				// Second half place type objects
				var tickOffset = currentTick - InitGame.inst.totalTiles - 1;
				if (currentTick > InitGame.inst.totalTiles) {
					var value = data[tickOffset][0].v;
					var prev = '';
					for (i in InitGame.inst.hexObjTypes.keys()) {
						if (value<InitGame.inst.hexObjTypes[i]) {
							//obj.getChild('cel'+prev).visible = true;
							break;
						}
						else prev = i;
					}
					iron.Scene.active.spawnObject('cont'+prev, null, function(o:Object) {
						o.transform.loc.x = 1*(Math.sqrt(3)*data[tickOffset][0].x + Math.sqrt(3)/2*data[tickOffset][0].y);
						o.transform.loc.y = 1*(3/2*data[tickOffset][0].y);
						o.transform.loc.z = 0.0;
						o.transform.buildMatrix();
						InitGame.inst.hexTileCelestials.add(o);
						o.properties['id'] = data[tickOffset][0].i;
						data[tickOffset][0].o = o;
					});
				}
				currentTick += 1;
			}
			currentTime += Time.delta;
			//trace(currentTime);
			if (currentTick > totalTicks) {object.remove();}
		});

		notifyOnRemove(function() {
			calcNeighbors();
			iron.Scene.active.spawnObject('contGame', null, function(o:Object) {});
		});
	}

	function calcNeighbors() {
		var directions:Array<Array<Int>> = [[1,0],[1,-1],[0,-1],[-1,0],[-1,1],[0,1]];
		var data = InitGame.inst.hexTilesData;
		for (d in data) {
			var nTemp:Array<Int> = [];
			for (n in data) {
				for (b in directions) {
					if (d[0].x == (n[0].x + b[0]) && d[0].y == (n[0].y + b[1])) {
						nTemp.push(n[0].i);
					}

				}
			}
			d[0].n = nTemp;
			//trace(d[0].n);
		}
	}
}
