import os
import random
import math
import time

sizeX : int = 36
sizeY : int = 36
amount : int = 1000


density : float = 1
size : float = 20
n : int = 6
s : float =  0.4
w : float = -0.05


posXArray : list = []
posYArray : list = []
renderArray : list = []

centerX : int = sizeX/2
centerY : int = sizeY/2


def getmptyArray(sizeX: int, sizeY) -> None:
    insert : list = []
    list : list = []
    for i in range(sizeX):
        insert.append(' ')
    for i in range(sizeY):
        list.append(insert.copy())
    return list

def clearConsole() -> None:
    os.system('cls' if os.name == 'nt' else 'clear')

def renderFromArray(array : list) -> None:
    clearConsole()
    for i in range(sizeY):
        for j in range(sizeX-1):
            #print(f"j:{j},i:{i}")
            print(array[i][j], end='')
        print(array[i][sizeX-1])


def renderGalaxy() -> None:
    for ball in range(amount):
        u : float = random.uniform(0,1)
        v : float = random.uniform(0.0,0.4)
        k : int = random.randrange(0,n-1)

        r : float = size * (u**density)
        o : float = (2*math.pi*k)/n + s * (r/size) * (2*math.pi) + v


        posX : int = (r * math.cos(o))
        posY : int = (r * math.sin(o))

        

        posX = posX+centerX
        posY = posY+centerY

        posX = posX
        posY = posY

        posXArray.append(posX)
        posYArray.append(posY)


def physics() -> None:
    o = math.radians(3)
    cosO = math.cos(o)
    sinO = math.sin(o)
    for i in range(amount):
        
        posX = posXArray[i]
        posY = posYArray[i]
        newX = (posX-centerX)*cosO - (posY-centerY)*sinO
        newY = (posX-centerX)*sinO + (posY-centerY)*cosO

        posXArray[i] = newX + centerX
        posYArray[i] = newY + centerY


def updatedRenderArray() -> list:
    renderLocArray = getmptyArray(sizeX, sizeY)
    for i in range(amount):
        y = math.ceil(posYArray[i])
        x = math.ceil(posXArray[i])
        
        if y > sizeY-1:
            y = sizeY-1
        elif y < 0:
            y = 0

        if x > sizeX-1:
            x = sizeX-1
        elif x < 0:
            x = 0

        
        renderLocArray[y][x] = '■'
    return renderLocArray


renderArray = getmptyArray(sizeX, sizeY)
renderGalaxy()
renderArray = updatedRenderArray()
renderFromArray(renderArray)



print ('Hello in galaxy Simulation!')
print('-----------------------------')

def setup() -> None:
    global n
    global s
    n = int(input('enter n (standard:5): '))+1
    if 0 < n:
        print(f"n set to {n-1}")
    else:
        print('cannot')
    s = float(input('enter s (standard:0.4): '))
    print(f"s set to {s}")

    global posXArray
    global posYArray

    posXArray = []
    posYArray = []

    renderArray = getmptyArray(sizeX, sizeY)
    renderGalaxy()
    renderArray = updatedRenderArray()
    renderFromArray(renderArray)

    inp = input('this is your galaxtic, are you want to round it? y/n')
    if inp == 'y':
        for i in range(500):
            time.sleep(0.05)
            physics()
            renderArray = updatedRenderArray()
            renderFromArray(renderArray)
    else:
        setup()
# o mój boże wiem że robienie setup() i wywoływanie go w setup() nie jest najlepsze ale życie
setup()
