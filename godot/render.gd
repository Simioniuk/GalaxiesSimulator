extends MultiMeshInstance3D


@export_category("Kulki")
@export var noiseAmount : int = 500
@export var amount: int = 600
@export var ball_radius: float = 0.05
@export var min_scale: float = 0.34
@export var max_scale: float = 1.0

@export_category("Rozmieszczenie")
@export var seed: int = 12345
@export var density : float = 1
@export var size : float = 10
@export var N : int = 6
@export var S : float = 0.3
@export var randomMin : float = 0.0
@export var randomMax : float = 0.4
@export var z : float = 0.4

@export_category("Świecenie")
@export var glow_color: Color = Color(1.0, 1.0, 1.0)
@export var emission_energy: float = 2.0

var w = -0.05

var pos : PackedVector3Array
var vel : PackedVector2Array
var sizeArray : PackedFloat32Array
var temperatureArray : PackedColorArray
var physicTimer : float = 0.0

func _ready() -> void:
	createGalaxy()

func _physics_process(delta: float) -> void:
	if physicTimer > 0 :
		physicTimer = 0
		updatePhysic(vel,pos,delta)
		#deleteGalaxy()
		drawGalaxyFromArray(pos,sizeArray,temperatureArray)
	physicTimer += 1.0

func render() -> void:
	deleteGalaxy()
	createGalaxy()

func deleteGalaxy() -> void:
	multimesh.instance_count = 0
	pos = []
	vel = []
	sizeArray = []
	temperatureArray = []

func createArms() -> void:


	for i in amount:
		
		
		var u : float = randf_range(0,1)
		var v : float = randf_range(randomMin,randomMax)
		
		var r = size * (u**density)
		var k = randi_range(0,N-1)
		var O : float = (2*PI*k)/N + S * (r/size) * (2*PI) + v
		
		
		var position := Vector3(r*cos(O),randf_range(-0.3,0.3),r*sin(O))
		
		var maxR : float = size*density

		var scale_value = (maxR - r) * (randf_range(min_scale,max_scale) / 10)+randf_range(0,0.2)


		var basis := Basis.IDENTITY.scaled(
			Vector3.ONE * scale_value
		)


		var transform := Transform3D(
			basis,
			position
		)


		multimesh.set_instance_transform(
			i,
			transform
		)
		
		var temperature : float = pow(randf(), 3.0)
		temperature = lerp(2400.0,30000.0,temperature) /100
		
		var temp : Color = temperatureToColor(temperature)
		
		multimesh.set_instance_color(i,temp)
		
		pos.append(position)
		sizeArray.append(scale_value)
		temperatureArray.append(temp)
		
		var distToCenter : float = sqrt(position.x*position.x + position.z * position.z)
		var vectorToOrbit : Vector2 = Vector2(-(position.z/distToCenter),(position.x/distToCenter)).normalized()
		
		#var orbitalSpeed : float = sqrt((gravity*mass)/distToCenter)
		
		#var ve = Vmax*(distToCenter/(sqrt((distToCenter**2)+(rC**2))))
		var ve = w*distToCenter
		
		vel.append(Vector2(vectorToOrbit[0]*ve,vectorToOrbit[1]*ve))
		
		
func createNoise() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	
	for i in range(noiseAmount):
		
		var O : float = randf_range(0,2*PI)
		var u : float = randf_range(0,1)
		var r = size*(u**density)
		
		var position := Vector3(r*cos(O),randf_range(-0.3,0.3),r*sin(O))
		
		var maxR : float = size*density
		
	
		var scale_value = (maxR - r) * (randf_range(min_scale,max_scale) / 10) +randf_range(0,0.2)
		
		var basis := Basis.IDENTITY.scaled(
			Vector3.ONE * scale_value
		)


		var transform := Transform3D(
			basis,
			position
		)
		
		multimesh.set_instance_transform(
			i+amount,
			transform
		)
		
		
		var temperature : float = pow(randf(),3.0)
		temperature = lerp(2400.0,30000.0,temperature) / 100
		
		var temp : Color = temperatureToColor(temperature)
		
		multimesh.set_instance_color(i+amount,temp)
		
		pos.append(position)
		sizeArray.append(scale_value)
		temperatureArray.append(temp)
		
		var distToCenter : float = sqrt(position.x*position.x + position.z * position.z)
		var vectorToOrbit : Vector2 = Vector2(-(position.z/distToCenter),(position.x/distToCenter)).normalized()
		
		#var orbitalSpeed : float = sqrt((gravity*mass)/distToCenter)
		
		#var v = Vmax*(distToCenter/(sqrt((distToCenter**2)+(rC**2))))
		var v = w*distToCenter
		vel.append(Vector2(vectorToOrbit[0]*v,vectorToOrbit[1]*v))
		
func createGalaxy() -> void:
	var sphere := SphereMesh.new()

	sphere.radius = ball_radius
	sphere.height = ball_radius * 2.0

	sphere.radial_segments = 8
	sphere.rings = 4

	var material := StandardMaterial3D.new()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	material.vertex_color_use_as_albedo = true

	material.emission_enabled = true
	material.emission_energy_multiplier = emission_energy

	sphere.material = material



	var mm := MultiMesh.new()

	mm.transform_format = MultiMesh.TRANSFORM_3D
	
	mm.use_colors = true
	mm.mesh = sphere
	mm.instance_count = amount+noiseAmount
	multimesh = mm
	
	createArms()
	createNoise()
	print((size*density - size*(0**density))* (max_scale/10))
	print((size*density - size*(1**density))* (min_scale/10))

	
func temperatureToColor(temperature : float) -> Color:
		var red : float = 255
		var green : float
		var blue : float = 0
		
		if 19.0 < temperature and temperature <= 66.0:
			blue = 138.5 * log(temperature-10) - 305.04
		elif temperature > 66.0:
			blue = 255.0
		
		if temperature > 66.0:
			red = 329.6 * ((temperature - 60)**-0.13)
			green = 288.1 * ((temperature-60)**-0.07)
		else:
			green = 99.5 * log(temperature) - 161.1
		red = clamp(red, 0.0, 255.0)
		blue = clamp(blue,0.0,255.0)
		green = clamp(green,0.0,255.0)
		
		return Color(red/255,green/255,blue/255,1)



func drawGalaxyFromArray(posit : PackedVector3Array, siz : PackedFloat32Array, temp : PackedColorArray) -> void:
	multimesh.instance_count = amount+noiseAmount
	for i in range(posit.size()):
		
		var basis := Basis.IDENTITY.scaled(
			Vector3.ONE * siz[i]
		)


		var transform := Transform3D(
			basis,
			posit[i]
		)
		
		
		multimesh.set_instance_transform(i,transform)
		multimesh.set_instance_color(i, temp[i])
		

func updatePhysic(velo : PackedVector2Array, posit : PackedVector3Array, delta : float) -> void:
	
	for i in range(posit.size()):
		var newPos : Vector3 = posit[i]
		var newVelo : Vector2 = velo[i]
		var newPosVec2 : Vector2 = Vector2(newPos[0],newPos[2])
		
		var r = sqrt((newPos.x**2)+(newPos.z**2))
		#var v = 2 * (r/sqrt((r**2)+4))
		#var a = -(((Vmax**2)/((r**2)+(rC**2)))*newPosVec2)
		var a = -w**2*newPosVec2
		
		
		
		#var a = Vector2(0,0)
		#if r > 0.001:
		#	a = -(((gravity*mass)/(r**3))*newPosVec2)
		
		
		newVelo = newVelo + a*delta
		
		
		newPos[0] = newPos[0] + newVelo[0]*delta
		newPos[2] = newPos[2] + newVelo[1]*delta
		
		posit[i] = newPos
		velo[i] = newVelo
		
		
