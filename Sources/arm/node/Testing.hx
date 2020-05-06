package arm.node;

@:keep class Testing extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "Testing";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _Keyboard = new armory.logicnode.MergedKeyboardNode(this);
		_Keyboard.property0 = "Started";
		_Keyboard.property1 = "space";
		_Keyboard.addOutputs([new armory.logicnode.NullNode(this)]);
		_Keyboard.addOutputs([new armory.logicnode.BooleanNode(this, false)]);
		var _Mouse = new armory.logicnode.MergedMouseNode(this);
		_Mouse.property0 = "Down";
		_Mouse.property1 = "middle";
		_Mouse.addOutputs([new armory.logicnode.NullNode(this)]);
		_Mouse.addOutputs([new armory.logicnode.BooleanNode(this, false)]);
		var _OnMouse = new armory.logicnode.OnMouseNode(this);
		_OnMouse.property0 = "Down";
		_OnMouse.property1 = "middle";
		_OnMouse.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}