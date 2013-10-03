/*
boubou2k_gravity.p

Rubik's Futuro Cube Gravity game clone

*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,0,
    cORANGE,cORANGE,cPURPLE,
    cORANGE,cPURPLE,cPURPLE,
    cORANGE,cORANGE,cPURPLE,
    '''','''']
new palette[]=[
    cORANGE, cPURPLE, cRED, cBLUE, cGREEN, cMAGENTA
    ]

new savedgame[] = [VAR_MAGIC1, VAR_MAGIC2, ''boubou2k_edgeturning'']

new const edges[12][8] = [
        [ 0,  4,  2,   44, 40, 42,    1, 43],
        [ 6,  4,  0,   20, 22, 26,    3, 23],
        [ 2,  4,  8,   33, 31, 27,    5, 30],
        [ 8,  4,  6,   45, 49, 47,    7, 46],
        [ 9, 13, 11,   36, 40, 38,   10, 37],
        [15, 13,  9,   29, 31, 35,   12, 32],
        [11, 13, 17,   24, 22, 18,   14, 21],
        [17, 13, 15,   53, 49, 51,   16, 52],
        [18, 22, 20,   42, 40, 36,   19, 39],
        [26, 22, 24,   51, 49, 45,   25, 48],
        [27, 31, 29,   38, 40, 44,   28, 41],
        [35, 31, 33,   47, 49, 53,   34, 50]
    ]

new const topAndSide2Edge[6][6] = [
        [-1, -1,  1,  2,  0,  3],
        [-1, -1,  6,  5,  4,  7],
        [ 1,  6, -1, -1,  8,  9],
        [ 2,  5, -1, -1, 10, 11],
        [ 0,  4,  8, 10, -1, -1],
        [ 3,  7,  9, 11, -1, -1]
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
    if(IsGameResetRequest() || !LoadVariable(''boubou2k_edgeturning'', cube)) {
        return 0
    } else {
        refresh()
        return 1
    }
}
savegame() {
    StoreVariable(''boubou2k_edgeturning'', cube)
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
    new i, edge

    Play("_g_SHUFFLING")
    generate()

    for (i=0; i<200; i++) {
        edge = GetRnd(12)
        rotate(edge, 1)
    }

    Quiet()
}

rotate(edge, delay=0) {
    rotate30(edge, 0)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate30(edge, 1)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate30(edge, 0)
    refresh()
}
rotate30(edge, center=0) { //TODO
    new i, temp

    temp = cube[edges[edge][0]]
    for (i=1; i<6; i++)
        cube[edges[edge][i-1]] = cube[edges[edge][i]]
    cube[edges[edge][5]] = temp

    if (center) {
        temp = cube[edges[edge][7]]
        cube[edges[edge][7]] = cube[edges[edge][6]]
        cube[edges[edge][6]] = temp
    }
}

refresh() {
    ClearCanvas()
    DrawArray(cube)
    PrintCanvas()
}

findTop() {
    return (GetCursor()&0x0000003F)/9
}

findEdge(side) {
    return topAndSide2Edge[findTop()][side]
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

    new side

    for (;;) {
        Sleep()

        if (Motion()) {
            side = eTapSide()
            if (eTapSideOK() && eTapToSide()) {
                Vibrate(50)
                rotate(findEdge(side))
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
