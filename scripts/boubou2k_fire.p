/*
boubou2k_fire.p

Simple fire effect on cube sides.

*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,0, 0,0xFF000000,0,  0x00FF0000,0,0xFFFF0000,  0,0x0000FF00,0,  '''','''']
new palette[]=[0x1F000000,0xFF000000,0xFF1F0000,0xFF3F0000,0xFF5F0000,0xFF7F0000,0xFF7F0000,0xFF7F0000]

new base[][]=[[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0]]
new coords[][][]=[[[29,32,35],[28,31,34],[27,30,33]],[[53,52,51],[50,49,48],[47,46,45]],[[24,21,18],[25,22,19],[26,23,20]],[[36,37,38],[39,40,41],[42,43,44]]]

init() {
    ICON(icon)
    SetIntensity(256)
    RegAllSideTaps()
    PaletteFromArray(palette)
}

main() {
    new i, j

    init()

    for (;;) {
        Sleep(50)

        for (i=0; i<12; i++) {
            base[0][i]=GetRnd(8)*10
            SetColor(base[0][i])
            PrintCanvas()
        }

        for (j=1; j<4; j++) {
            for (i=0; i<12; i++) {
                base[j][i] = ( base[j-1][i]*9 + base[j][i] + base[j+1][i]*4 + base[j][(i+11)%12] + base[j][(i+1)%12] ) / 17
                SetColor(base[j][i]/10)
                DrawPoint(coords[i/3][j-1][i%3])
                PrintCanvas()
            }
        }

        if (Motion())
            AckMotion()

    }
}
