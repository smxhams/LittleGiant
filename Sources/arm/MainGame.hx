package arm;
import iron.math.Quat;
import iron.object.MeshObject;
import iron.math.Vec4;
import iron.Scene;
import iron.system.Input;
import armory.trait.physics.PhysicsWorld;
import iron.object.Object;
import armory.trait.internal.CanvasScript;
import iron.App;
import iron.system.Time;

class MainGame extends iron.Trait {
	var keyboard:Keyboard;
	var mouse:Mouse;
	var canvas:CanvasScript;
	var data = InitGame.inst.hexTilesData;

	var lastHover:Int;
	var clickStart:Int;
	var tempObj:Object;
	//Cam
	var camSpeed:Float = 0.3;
	var camX:Float;
	var camY:Float;

	var v = new Vec4();
	var v1 = new Vec4();
	var v2 = new Vec4();
	var q = new Quat();

	public function new() {
		super();

		notifyOnInit(function() {
			trace('Welcome to the main game');
			keyboard = Input.getKeyboard();
			mouse = Input.getMouse();
			canvas = Scene.active.getTrait(CanvasScript);

			var camera = Scene.active.getChild("Camera");
			camX = camera.transform.loc.x+0.245;
			camY = camera.transform.loc.y+0.245;

			iron.Scene.active.spawnObject('hoverHex', null, function(o:Object) {
				o.visible = false;
				o.transform.loc.z = 0.0;
				o.transform.buildMatrix();
			});
		});

		notifyOnUpdate(function() {
			camControl();
			mouseOver();
			massCalc();
			if (canvas.getElement('contHexValues').visible == true) hexValuePos();
			clickDrag();
			

		});

		// notifyOnRemove(function() {
		// });
	}

	function camControl() {
		var camera = Scene.active.getChild("Camera");
		//Cam control
		//Arrow keys move
		if (keyboard.down("right") || mouse.x >= App.w() - App.w()/20) {
			if (camX < 30) camX += camSpeed;
		}
		if (keyboard.down("left") || mouse.x <= App.w()/20) {
			if (camX > -30) camX -= camSpeed;
		}
		if (keyboard.down("up") || mouse.y <= App.h()/15) {
			if (camY < 30) camY += camSpeed;
		}
		if (keyboard.down("down") || mouse.y >= App.h() - App.h()/15) {
			if (camY > -80) camY -= camSpeed;
		}
		if (mouse.down('middle')) {
			if (camX > -30 && camX < 30) camX -= mouse.movementX/10*(InitGame.inst.camDistance/100);
			if (camY > -80 && camY < 30) camY -= -mouse.movementY/10*(InitGame.inst.camDistance/100);
		}
		if (camX < -30) camX = -29.9;
		if (camX > 30) camX = 29.9;
		if (camY < -80) camY = -79.9;
		if (camY > 30) camY = -29.9;
		//Scroll wheel zoom
		if (InitGame.inst.camDistance < 80.0) {
			if (mouse.wheelDelta == 1) {
				InitGame.inst.camDistance += 4;
				camY -= 3;
			}
		}
		if (InitGame.inst.camDistance > 4.0) {
			if (mouse.wheelDelta == -1) {
				InitGame.inst.camDistance -= 4;
				camY += 3;
			}
		}

		var curCamX = camera.transform.loc.x;
		var curCamY = camera.transform.loc.y;
		if (roundValue(InitGame.inst.camDistance, 2) != roundValue(camera.transform.loc.z, 2)) {
			camera.transform.loc.z += -(camera.transform.loc.z-InitGame.inst.camDistance)/10;
		}
		if (roundValue(curCamX, 2) != roundValue(camX, 2)) {
			camera.transform.loc.x += -(camera.transform.loc.x-camX)/10;
		}
		if (roundValue(curCamY, 2) != roundValue(camY, 2)) {
			camera.transform.loc.y += -(camera.transform.loc.y-camY)/10;
		}
		//trace(curCamX + ' : ' + curCamY + ' To go to: ' + camX + ' : ' + camY);
	}

	function mouseOver() {
		if (!mouse.moved) return;
		var hoverHex = Scene.active.getChild('hoverHex');
		var rb = PhysicsWorld.active.pickClosest(mouse.x, mouse.y); //rb is active hover hex
		
		if (rb != null) { 
			var hex:Object = rb.object.parent;
			if (lastHover != hex.properties['id']) {
				lastHover = hex.properties['id'];
				InitGame.inst.currentHover = hex.properties['id'];
				//trace(hex.properties['id']);

				//Move hover hex to higlight active hex
				hoverHex.transform.loc.x = hex.transform.loc.x;
				hoverHex.transform.loc.y = hex.transform.loc.y;
				hoverHex.transform.buildMatrix();
				if (hoverHex.getChild('hoverHexBlue') != null) hoverHex.getChild('hoverHexBlue').visible = true;
				
				//Display values with UI
				var hexValues = canvas.getElement('hexValue1');
				var cam = Scene.active.camera;
				var data = InitGame.inst.hexTilesData;
				v.setFrom(hoverHex.transform.loc);
				v.applyproj(cam.V);
				v.applyproj(cam.P);
				hexValues.x = (v.x + 1) * App.w()/2;
				hexValues.y = ((-v.y + 1) * App.h()/2);
				hexValues.visible = true;
				canvas.getElement('contHexValues').visible = true;
				//trace(data[lastHover][0].n);
			}
		}
		else {
			if (lastHover != null) {
				lastHover = null;
				if (hoverHex.getChild('hoverHexBlue') != null) hoverHex.getChild('hoverHexBlue').visible = false;
				canvas.getElement('contHexValues').visible = false;
			}
		}
	}

	function roundValue(n:Float, prec:Int) {
		n = Math.round(n * Math.pow(10, prec));
		return n;
	}

	function hexValuePos() {
		var data = InitGame.inst.hexTilesData;
		var nNum = Std.int(data[lastHover][0].n.length+2);
		var cam = Scene.active.camera;
		for (i in 1...nNum) {
			if (i == 1) {
				if (canvas.getElement("hexValue1").text != Std.string(data[lastHover][0].v)) {
					canvas.getElement("hexValue1").text = Std.string(Std.int(data[lastHover][0].v));
				}
				v.setFrom(data[lastHover][0].o.transform.loc);
				v.applyproj(cam.V);
				v.applyproj(cam.P);
				canvas.getElement("hexValue1").x = (v.x + 1) * App.w()/2;
				canvas.getElement("hexValue1").y = ((-v.y + 1) * App.h()/2);

			}
			else {
				if (canvas.getElement("hexValue" + i).text != Std.string(data[data[lastHover][0].n[i-2]][0].v)) {
					canvas.getElement("hexValue" + i).text = Std.string(Std.int(data[data[lastHover][0].n[i-2]][0].v));
					canvas.getElement("hexValue" + i).visible = true;
				}

				v.setFrom(data[data[lastHover][0].n[i-2]][0].o.transform.loc);
				v.applyproj(cam.V);
				v.applyproj(cam.P);
				canvas.getElement("hexValue" + i).x = (v.x + 1) * App.w()/2;
				canvas.getElement("hexValue" + i).y = ((-v.y + 1) * App.h()/2);
			}

		}
		if (nNum == 5) {
			canvas.getElement("hexValue5").visible = false;
			canvas.getElement("hexValue6").visible = false;
			canvas.getElement("hexValue7").visible = false;
		}
		else if (nNum == 6) {
			canvas.getElement("hexValue6").visible = false;
			canvas.getElement("hexValue7").visible = false;
		}
	}

	function massCalc() {
		for (i in data) {
			if (i[0].out != null) {
				data[i[0].out][0].v += ((i[0].v)*InitGame.inst.massExchangeRate)*Time.delta;
			}
		}
	}

	function clickDrag() {
		// Clicking and dragging to direct flow
		if (mouse.started('left') && lastHover != null && lastHover != InitGame.inst.homeIndex) {
			clickStart = lastHover;
			iron.Scene.active.spawnObject('contArrow', null, function(o:Object) {
				o.transform.loc.x = data[clickStart][0].o.transform.loc.x;
				o.transform.loc.y = data[clickStart][0].o.transform.loc.y;
				o.transform.loc.z = 0.0;
				o.transform.buildMatrix();
				tempObj = o;
			});
			
		}
		else if (mouse.down('left') && lastHover != null && clickStart != null) {
			if (data[clickStart][0].n.indexOf(lastHover) != -1 && lastHover != null) {
				if (tempObj.children[0]!=null) tempObj.children[0].visible = true;
				if (data[clickStart][0].outO != null) data[clickStart][0].outO.children[0].visible = false;
				v1.set(-1,0,0);
				v2.setFrom(data[lastHover][0].o.transform.loc).sub(tempObj.transform.loc).normalize();
				q.fromTo(v1,v2);
				tempObj.transform.rot = q;
				tempObj.transform.buildMatrix();
			}
			else if (tempObj.children[0]!=null) {
				tempObj.children[0].visible = false;
				if (data[clickStart][0].outO != null) data[clickStart][0].outO.children[0].visible = true;
			}
			//trace(mouse.x + " x " + mouse.y);
		}
		else if (mouse.released('left') && lastHover != null && clickStart != null) {
			if (data[clickStart][0].n.indexOf(lastHover) != -1 && lastHover != null) { //If neighbor, create link
				if (data[clickStart][0].outO != null) { // If reassinging a pre-existing link
					data[clickStart][0].outO.remove(); //Remove link
					var r:Array<Int> = data[data[clickStart][0].out][0].inI;
					r.remove(clickStart);
					data[data[clickStart][0].out][0].inI = r; //Removes input on old output
					//checkRings(clickStart); // Will take away blue rings if no longer leading home
				}
				data[clickStart][0].out = lastHover;
				data[clickStart][0].outO = tempObj;
				data[lastHover][0].inI.push(data[clickStart][0].i);



				// Check if route leads home.
				var homeRouteCheck = false;
				var out = data[clickStart][0].out;
				var startOut = data[clickStart][0].out;
				while (homeRouteCheck == false) {
					if (out == null) {
						homeRouteCheck = true;
						trace('Does not lead home');

						checkRings(clickStart);
						break;
					}
					
					if (out == InitGame.inst.homeIndex) {
						trace('Found Home');
						var addRingsForward = true;
						out = data[clickStart][0].i;
						while (addRingsForward == true) {
							if (data[out][0].i == InitGame.inst.homeIndex) {
								addRingsForward = false;
								break;
							}
							if (data[out][0].ringO == null || data[out][0].ringO.name != 'contHexBlue') {
								trace('Adding Rings forward');
								iron.Scene.active.spawnObject('contHexBlue', null, function(o:Object) {
									o.transform.loc.x = 1*(Math.sqrt(3)*data[out][0].x + Math.sqrt(3)/2*data[out][0].y);
									o.transform.loc.y = 1*(3/2*data[out][0].y);
									o.transform.loc.z = 0.0;
									o.transform.buildMatrix();
									InitGame.inst.hexTilesObjects.add(o);
									o.properties['id'] = data[out][0].i;
									data[out][0].ringO = o;
								});
							}
							else if (data[out][0].ringO != null && data[out][0].ringO.name == 'contHexBlue' && data[out][0].ringO.children[0].visible == false) data[out][0].ringO.children[0].visible = true;
							out = data[out][0].out;
						}
						addRingsBackward(data[clickStart][0].i);

						homeRouteCheck = true;
						break;
					}
					out = data[out][0].out;
					if (out == startOut){
						homeRouteCheck = true;
						trace('Loop detected');
						break;
					}
				}
			}
			else if (tempObj.children[0]!=null) tempObj.children[0].visible = false;
			clickStart = null;
			tempObj = null;
		}
	}

	function addRingsBackward(inHex:Int) {
		if (data[inHex][0].inI != []) {
			for (i in 0...data[inHex][0].inI.length) {
				var input = data[inHex][0].inI[i];
				if (data[input][0].ringO == null || data[input][0].ringO.name != 'contHexBlue') {
					trace('Adding rings backwards');
					iron.Scene.active.spawnObject('contHexBlue', null, function(o:Object) {
						o.transform.loc.x = 1*(Math.sqrt(3)*data[input][0].x + Math.sqrt(3)/2*data[input][0].y);
						o.transform.loc.y = 1*(3/2*data[input][0].y);
						o.transform.loc.z = 0.0;
						o.transform.buildMatrix();
						InitGame.inst.hexTilesObjects.add(o);
						o.properties['id'] = data[input][0].i;
						data[input][0].ringO = o;
					});
				}
				else if (data[input][0].ringO != null && data[input][0].ringO.name == 'contHexBlue' && data[input][0].ringO.children[0].visible == false) data[input][0].ringO.children[0].visible = true;
				
				if (data[input][0].inI != []) addRingsBackward(data[input][0].i);
			}
		}
	}

	function checkRings(hex:Int) {
		trace(hex);
		if (data[hex][0].ringO != null && data[hex][0].ringO.name == 'contHexBlue') {
			var rObj:Object = data[hex][0].ringO;
			trace(hex + 'I have a ring');
			if (data[hex][0].ringO.children[0]!= null) data[hex][0].ringO.children[0].visible = false;
			//data[hex][0].ringO = null;
		}
		if (data[hex][0].inI != []) {
			for (i in 0...data[hex][0].inI.length) {
				var input = data[hex][0].inI[i];
				if (data[input][0].inI != []) checkRings(data[input][0].i);
			}
			//trace(data[hex][0].inI);
		}
	}

}
