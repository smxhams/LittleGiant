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
		var _GetMesh = new armory.logicnode.GetMeshNode(this);
		_GetMesh.addInput(new armory.logicnode.ObjectNode(this, ""), 0);
		_GetMesh.addOutputs([new armory.logicnode.NullNode(this)]);
		var _LookAt = new armory.logicnode.LookAtNode(this);
		_LookAt.property0 = "Z";
		_LookAt.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0), 0);
		_LookAt.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0), 0);
		_LookAt.addOutputs([new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0)]);
		var _SetRotation = new armory.logicnode.SetRotationNode(this);
		_SetRotation.property0 = "Euler Angles";
		_SetRotation.addInput(new armory.logicnode.NullNode(this), 0);
		_SetRotation.addInput(new armory.logicnode.ObjectNode(this, ""), 0);
		_SetRotation.addInput(new armory.logicnode.VectorNode(this, 0.0, 0.0, 0.0), 0);
		_SetRotation.addInput(new armory.logicnode.FloatNode(this, 0.0), 0);
		_SetRotation.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}