extends CanvasModulate

@onready var mesh = get_parent().get_node('MultiMeshInstance3D')

@onready var density = $density
@onready var size = $size
@onready var n = $n
@onready var s = $s
@onready var randomMax = $randomMax
@onready var randomMin = $randomMin
@onready var z = $z
@onready var amount = $amount
@onready var amountNoise = $amountNoise

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_generate_pressed() -> void:
	mesh.density = density.value
	mesh.size = size.value
	mesh.N = n.value
	mesh.S = s.value
	mesh.randomMax = randomMax.value
	mesh.randomMin = randomMin.value
	mesh.z = z.value
	mesh.amount = amount.value
	mesh.noiseAmount = amountNoise.value
	
	mesh.render()


func _on_visibility_toggled(toggled_on: bool) -> void:
	density.visible = toggled_on
	size.visible = toggled_on
	n.visible = toggled_on
	s.visible = toggled_on
	randomMax.visible = toggled_on
	randomMin.visible = toggled_on
	z.visible = toggled_on
	$instr.visible = toggled_on
	$generate.visible = toggled_on
	amount.visible = toggled_on
	amountNoise.visible = toggled_on
