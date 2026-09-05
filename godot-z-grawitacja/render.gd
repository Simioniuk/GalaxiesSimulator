extends MultiMeshInstance3D


@export_category("Kulki")
@export var amountPerGalaxy: int = 600
@export var ball_radius: float = 0.05
@export var min_scale: float = 0.5
@export var max_scale: float = 2.5

@export_category("Rozmieszczenie")
@export var density : float = 0.9
@export var size : float = 10
@export var N : int = 6
@export var S : float = 0.3
@export var randomMin : float = 0.0
@export var randomMax : float = 0.4
@export var z : float = 0.4

@export_category("Świecenie")
@export var emission_energy: float = 2.0

var stop : bool = false

var w = 0.04
var gravity = 0.5
var eSquared = 0.1**2
var mass = 40
var amountOfGalaxies : int = 2
var posArray : PackedVector3Array
var velArray : PackedVector3Array
var sizeArray : PackedFloat32Array
var temperatureArray : PackedColorArray


var amountOfBlackHoles : int = 2
var startedBlackHolePos : PackedVector3Array = [Vector3(-26,2,8), Vector3(26,-1,-8)]
var startedBlackHoleVel : PackedVector3Array = [Vector3(0.55,0,0.055), Vector3(-0.55,0,0)]
var blackHolePos : PackedVector3Array = [Vector3(-26,2,8), Vector3(26,-1,-8)]
var blackHoleVel : PackedVector3Array = [Vector3(0.55,0,0.055), Vector3(-0.55,0,0)]



func _ready() -> void:
	initMultimesh()
	createGalaxyAt(amountPerGalaxy, Vector3(-26,2,8),0)
	createGalaxyAt(amountPerGalaxy, Vector3(26,-1,-8),1)
	#createGalaxyAt(amountPerGalaxy, Vector3(19,0,10))
	createBlackHoles()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("startstop"):
		if stop:
			stop = false
			
		else:
			stop = true
	
	
func _physics_process(delta: float) -> void:
	if !stop:
		print(density)
		updatePhysicStars(delta)
		updatePhysicHoles(delta)
		drawGalaxiesFromArray()
		drawBlackHolesFromArray()

func initNewGalaxy(pos : Vector3, vel : Vector3) -> void:
	posArray = []
	sizeArray = []
	velArray = []
	temperatureArray = []
	startedBlackHolePos.append(pos)
	startedBlackHoleVel.append(pos)
	amountOfBlackHoles += 1
	amountOfGalaxies += 1
	blackHolePos = startedBlackHolePos
	blackHoleVel = startedBlackHoleVel
	initMultimesh()
	
	for i in range(blackHolePos.size()):
		createGalaxyAt(amountPerGalaxy,blackHolePos[i],i)
	createBlackHoles()

func createBlackHoles() -> void:
	for i in range(blackHolePos.size()):

		var basis := Basis.IDENTITY.scaled(
			Vector3.ONE * 6
		)


		var transform := Transform3D(
			basis,
			blackHolePos[i]
		)


		multimesh.set_instance_transform(
			amountPerGalaxy*amountOfGalaxies+i,
			transform
		)
		

		
		multimesh.set_instance_color(amountPerGalaxy*amountOfGalaxies+i,Color.AQUAMARINE)
		

func createStarAt(temperature : float, pos : Vector3, scaledValue : float, index : int, GPos : Vector3) -> void:
	var basis := Basis.IDENTITY.scaled(
		Vector3.ONE * scaledValue
	)
	var transform := Transform3D(
		basis,
		pos
	)
	
	var temperatureColor : Color = temperatureToColor(temperature)
	
	multimesh.set_instance_transform(
		index,
		transform
	)
	multimesh.set_instance_color(index,temperatureColor)
	
	
	#OBLICZANIE PRĘDKOŚCI ORBITALNEJ
	var distToNearestBlackHole : float = INF
	var indexOfBlackHole : int
	for i in range(blackHolePos.size()):
		var dist = blackHolePos[i].distance_squared_to(pos)
		if dist < distToNearestBlackHole:
			distToNearestBlackHole = dist
			indexOfBlackHole = i
	
	distToNearestBlackHole = sqrt(distToNearestBlackHole)
	
	var orbitalVel : float = sqrt((gravity*mass)/(distToNearestBlackHole))
	
	var vectorOrbit : Vector3 = (blackHolePos[indexOfBlackHole]-pos)
	var vectorToOrbit : Vector3 = vectorOrbit.cross(Vector3.UP).normalized()
	var blackHoleVector : Vector3 = blackHoleVel[blackHolePos.find(GPos)]
	
	
	velArray.append(orbitalVel*vectorToOrbit+blackHoleVector)
	sizeArray.append(scaledValue)
	posArray.append(pos)
	temperatureArray.append(temperatureColor)

func createGalaxyAt(count : int, Lpos : Vector3, index: int) -> void:
	
	var GPos : Vector3 = Lpos
	
	for i in count:
		
		var u : float = randf_range(0,1)
		var v : float = randf_range(randomMin,randomMax)
		
		var r = size * (u**density)
		var k = randi_range(0,N-1)
		var O : float = (2*PI*k)/N + S * (r/size) * (2*PI) + v
		
		var y : float = randf_range(0,1)
		u = randi_range(-1,1)
		y = - log(1-y)
		y = y * u/ 3
		var pos := Vector3(r*cos(O),y,r*sin(O))+Lpos

		var scaleValue : float = randf_range(min_scale,max_scale)

		var temperature : float = pow(randf(), 3.0)
		temperature = lerp(2400.0,30000.0,temperature) /100
		
		createStarAt(temperature, pos, scaleValue, amountPerGalaxy*index+i, GPos)
		
		
func initMultimesh() -> void:
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
	mm.instance_count = amountPerGalaxy*amountOfGalaxies+amountOfBlackHoles
	multimesh = mm

	
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



func drawGalaxiesFromArray() -> void:
	#multimesh.instance_count = amountPerGalaxy*amountOfGalaxies+amountOfBlackHoles
	for i in range(posArray.size()):
		
		var basis := Basis.IDENTITY.scaled(
			Vector3.ONE * sizeArray[i]
		)


		var transform := Transform3D(
			basis,
			posArray[i]
		)
		
		
		multimesh.set_instance_transform(i,transform)
		multimesh.set_instance_color(i, temperatureArray[i])
		
		

func updatePhysicStars(delta : float) -> void:
	
	var gravityConst = gravity*mass
	
	for i in range(posArray.size()):
		var myPos : Vector3 = posArray[i]
		var newVelo : Vector3 = velArray[i]
		for j in range(blackHolePos.size()):
			var blackPos : Vector3 = blackHolePos[j]
					#var dist = myPos.distance_to(hisPos)
			var vector = myPos-blackPos
			var distSquared = myPos.distance_squared_to(blackPos)
					#- jeśli mają się przyciągać
			var a = (-((gravityConst) / ((distSquared + eSquared)**1.5))) * vector
			newVelo += a * delta
		#var aHole = (-((gravity*blackHoleMass) / ((distToBlackHoleSquared + eSquared)**1.5))) * vectorHole
		myPos += newVelo * delta
		
		velArray[i] = newVelo
		posArray[i] = myPos
		
		
func updatePhysicHoles(delta: float) -> void:
	var newVeloArray : PackedVector3Array
	var newPosArray : PackedVector3Array
	var gravityConst = gravity*mass
	for i in range(amountOfBlackHoles):
		var myPos : Vector3 = blackHolePos[i]
		var newVelo : Vector3 = blackHoleVel[i]
		for j in range(amountOfBlackHoles):
			if i == j:
				continue
			var hisPos : Vector3 = blackHolePos[j]
			
			var vector : Vector3 = myPos-hisPos
			var distSquared : float = myPos.distance_squared_to(hisPos)
			
			
			var a = (-((gravityConst) / ((distSquared + eSquared)**1.5))) * vector
			newVelo += a*delta
		myPos += newVelo * delta
		
		newVeloArray.append(newVelo)
		newPosArray.append(myPos)
	blackHolePos = newPosArray
	blackHoleVel = newVeloArray
func drawBlackHolesFromArray() ->void:
	for i in range(amountOfBlackHoles):
		
		var basis := Basis.IDENTITY.scaled(
			Vector3.ONE * 6
		)


		var transform := Transform3D(
			basis,
			blackHolePos[i]
		)
		
		
		multimesh.set_instance_transform(amountPerGalaxy*amountOfGalaxies+i,transform)
		multimesh.set_instance_color(amountPerGalaxy*amountOfGalaxies+i, Color.RED)
