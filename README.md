# GalaxiesSimulator
Przepraszam że po polsku to pisze ale tak wygodniej :P

To miał być poboczny szybki projekcik na weekend ale wciągnałem się tak że przepisałem z godota na pyhona consolowego.

w folderze \python\ znajduje się kod do pythona
a (jeśli kiedyś dodam) w \godot\ kod do symulacji w 3d

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
