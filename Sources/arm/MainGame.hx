package arm;
import iron.math.Vec4;
import iron.Scene;
import iron.system.Input;
import armory.trait.physics.PhysicsWorld;
import iron.object.Object;
import armory.trait.internal.CanvasScript;
import iron.App;

class MainGame extends iron.Trait {
	var keyboard:Keyboard;
	var mouse:Mouse;
	var canvas:CanvasScript;

	var lastHover:Int;
	//Cam
	var camSpeed:Float = 0.5;
	var camX:Float;
	var camY:Float;

	var v = new Vec4();

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
			

		});

		// notifyOnRemove(function() {
		// });
	}

	function camControl() {
		var camera = Scene.active.getChild("Camera");
		//Cam control
		//Arrow keys move
		if (keyboard.down("right")) {
			camX += camSpeed;
		}
		if (keyboard.down("left")) {
			camX -= camSpeed;
		}
		if (keyboard.down("up")) {
			camY += camSpeed;
		}
		if (keyboard.down("down")) {
			camY -= camSpeed;
		}

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
				var hexValues = canvas.getElement('contHexValues');
				var cam = Scene.active.camera;
				v.setFrom(hoverHex.transform.loc);
				v.applyproj(cam.V);
				v.applyproj(cam.P);
				hexValues.x = (v.x + 1) * App.w()/2;
				hexValues.y = ((-v.y + 1) * App.h()/2);
				hexValues.visible = true;
				trace(InitGame.inst.hexTilesData[lastHover][0].n);
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
}
