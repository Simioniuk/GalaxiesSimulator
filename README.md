# GalaxiesSimulator
Przepraszam że po polsku to pisze ale tak wygodniej :P  

To miał być poboczny szybki projekcik na weekend ale wciągnałem się tak że przepisałem z godota na pyhona consolowego.  

w folderze \python\ znajduje się kod do pythona   
  
w folderach \godot\, \godot-z-grawitacja\ i \godot-tapeta\ jest kod źródłowy symulacji 3D  

w folderze \compiled\ są wersje skompilowane gotowe do uruchomienia  
  
(jeśli się nie uruchamia godot to coś pewnie z cameraController jest rozwalone)   
  
**#WZÓR**    
galaktyki są renderowane bardzo prosto za pomocą wzoru:   
x = r * cos(o),  
y = r * sin(o)  

dla o = (2PI * k) / N + S * ( r / size) * 2PI + v  
k to idRamiona (losowe od 0 do n-1)  
S to zakręcanie ramiona  
n to lczba ramion  
size to rozmiar galaktyki  

r = size * (u**density)  
u to losowa liczba od 0 do 1  
density to gęstość galaktyki  

wzór na przyspieszenie dla wersji z grawitacją:  
a = (-((stałaGrawitacyjna * masa) / ((dystansDoKwadratu + 0.1**2)**1.5))) * vector  
vector = mojaPozycja - pozycjaCzarnejDziury  
  
**#JAK UŻYWAĆ TAPETY**  
z \compiled\godot-tapeta\ pobierz galaxy-tapet.exe i galaxy-tapet.pck  
potem wrzuć to do lively wallpaper i gotowe :P  
masz interaktywną symulacje galaktyki na tapecie (spokojnie zużywa tylko ok. 30MB ramu)  
  
**#DALSZE INFO**  
(niedułgo spróbuje dodać neurosymulacje)  
utworzono 3.09.2026 o 22.07
