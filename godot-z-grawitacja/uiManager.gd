extends CanvasModulate

@onready var mesh = get_parent().get_node('MultiMeshInstance3D')

@onready var posX = $posX
@onready var posY = $posY
@onready var posZ = $posZ
@onready var velX = $velX
@onready var velY = $velY
@onready var velZ = $velZ





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_generate_pressed() -> void:
	mesh.initNewGalaxy(Vector3(posX.value,posY.value,posZ.value),Vector3(velX.value,velY.value,velZ.value))


func _on_visibility_toggled(toggled_on: bool) -> void:
	posX.visible = toggled_on
	posY.visible = toggled_on
	posZ.visible = toggled_on
	velX.visible = toggled_on
	velY.visible = toggled_on
	velZ.visible = toggled_on
	$generate.visible = toggled_on
	$posLabel.visible = toggled_on
	$velLabel.visible = toggled_on
	$instr.visible = toggled_on
