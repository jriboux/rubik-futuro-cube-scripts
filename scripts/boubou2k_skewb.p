/*
boubou2k_skewb.p

*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,0,
    cORANGE,cORANGE,cPURPLE,
    cORANGE,cPURPLE,cPURPLE,
    cPURPLE,cPURPLE,cPURPLE,
    '''','''']
new palette[]=[
    cORANGE, cPURPLE, cRED, cBLUE, cGREEN, cMAGENTA
    ]

new savedgame[] = [VAR_MAGIC1, VAR_MAGIC2, ''boubou2k_skewb'']

new const corners[8][27] = [
        [ 0, 20, 42,
          1,  3, 23, 19, 39, 43,
          2,  4,  6, 26, 22, 18, 36, 40, 44,
         27,  5,  7, 45, 25, 21, 11, 37, 41],
        [ 2, 44, 27,
          5,  1, 43, 41, 28, 30,
          8,  4,  0, 42, 40, 38, 29, 31, 33,
          9, 32, 34, 47,  7,  3, 20, 39, 37],
        [ 8, 33, 47,
          7,  5, 30, 34, 50, 46,
          6,  4,  2, 27, 31, 35, 53, 49, 45,
         26,  3,  1, 44, 28, 32, 15, 52, 48],
        [ 6, 45, 26,
          3,  7, 46, 48, 25, 23,
          0,  4,  8, 47, 49, 51, 24, 22, 20,
         42,  1,  5, 33, 50, 52, 17, 21, 19],
        [ 9, 29, 38,
         10, 12, 32, 28, 41, 37,
         11, 13, 15, 35, 31, 27, 44, 40, 36,
         18, 14, 16, 53, 34, 30,  2, 43, 39],
        [11, 36, 18,
         14, 10, 37, 39, 19, 21,
         17, 13,  9, 38, 40, 42, 20, 22, 24,
         51, 16, 12, 29, 41, 43,  0, 23, 25],
        [17, 24, 51,
         16, 14, 21, 25, 48, 52,
         15, 13, 11, 18, 22, 26, 45, 49, 53,
         35, 12, 10, 36, 19, 23,  6, 46, 50],
        [15, 53, 35,
         12, 16, 52, 50, 34, 32,
          9, 13, 17, 51, 49, 47, 33, 31, 29,
         38, 10, 14, 24, 48, 46,  8, 30, 28]
    ]

new const ANIM_DELAY = 72

new cube[54]

/* Initialize game */
init() {
    ICON(icon)
    SetIntensity(256)
    RegisterVariable(savedgame)
    RegAllSideTaps()
    PaletteFromArray(palette)
}

/* Intro animation */
intro() {
    new i
    for (i=0; i<6*9; i++)
        cube[i] = i/9+1
    refresh()
}

loadgame() {
    if(IsGameResetRequest() || !LoadVariable(''boubou2k_skewb'', cube)) {
        return 0
    } else {
        refresh()
        return 1
    }
}
savegame() {
    StoreVariable(''boubou2k_skewb'', cube)
}

/* Wait for tab before start */
tapToStart() {
    new motion = 0

    Play("_g_TAPFORSHUFFLE")
    for (;;) {
        Sleep()
        motion=Motion()
        if (motion) {
            AckMotion()
            break
        }
    }
    Play("kap")
    Delay(100)
}

generate() {
    new i
    for (i=0; i<6*9; i++) {
        cube[i] = i/9+1
    }
    refresh()
}

shuffle() {
    new i, corner

    Play("_g_SHUFFLING")
    generate()

    for (i=0; i<200; i++) {
        corner = GetRnd(8)
        rotate(corner, 1)
    }

    Quiet()
}

rotate(corner, delay=0) {
    rotate30(corner, 1, 0)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate30(corner, 1, 1)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate30(corner, 0, 0)
    refresh()
}
rotate30(corner, layer1=0, layer2=0) { //TODO
    new i, temp1, temp2

    temp1 = cube[corners[corner][9]]
    temp2 = cube[corners[corner][18]]
    for (i=10; i<18; i++) {
        cube[corners[corner][i-1]] = cube[corners[corner][i]]
        cube[corners[corner][i-1+9]] = cube[corners[corner][i+9]]
    }
    cube[corners[corner][17]] = temp1
    cube[corners[corner][26]] = temp2

    if (layer1) {
        temp1 = cube[corners[corner][3]]
        for (i=4; i<9; i++)
            cube[corners[corner][i-1]] = cube[corners[corner][i]]
        cube[corners[corner][8]] = temp1
    }

    if (layer2) {
        temp1 = cube[corners[corner][0]]
        for (i=1; i<3; i++)
            cube[corners[corner][i-1]] = cube[corners[corner][i]]
        cube[corners[corner][2]] = temp1
    }
}

refresh() {
    ClearCanvas()
    DrawArray(cube)
    PrintCanvas()
}

findCorner(cursor) {
    new i, idx = _i(cursor)
    for (i=0; i<8; i++)
        if (idx == corners[i][0] || idx == corners[i][1] || idx == corners[i][2])
            return i
    return -1
}

highlightCorner(corner) {
    new i
    if (corner >= 0) {
        ClearCanvas()
        DrawArray(cube)
        for (i=0; i<27; i++) {
            SetColor(cube[corners[corner][i]])
            DrawFlicker(corners[corner][i], 20, FLICK_STD, 0)
        }
        PrintCanvas()
    } else {
        ClearCanvas()
        DrawArray(cube)
        PrintCanvas()
    }
}

success() {
    Play("clapping")
    Delay(2000)
}

checkSuccess() {
    new i
    for (i=0; i<54; i++)
        if (cube[i] != cube[i-i%9])
            return 0
    return 1
}

main() {
    init()
    if (!loadgame()) {
        intro()
        tapToStart()
        shuffle()
    }

    new corner

    for (;;) {
        Sleep()

        corner = findCorner(GetCursor())
        highlightCorner(corner)

        if (Motion()) {
            if (eTapSideOK() && corner >= 0) {
                Vibrate(50)
                rotate(corner)
                savegame()
            }
            AckMotion()
        }

        if (checkSuccess()) {
            success()
            tapToStart()
            shuffle()
        }
    }
}
