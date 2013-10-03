/*
boubou2k_edgeturning_2.p

This is an edge turning puzzle, like helicopter cube, but when you rotate an edge, centers rotate too.
The only difference with edge turning 1 is that the corners around the edge are swapped too.
Tap to shuffle.
Tap on side to flip top edge.
The goal is to put each colors on its own side, like rubik's cube.
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

new savedgame[] = [VAR_MAGIC1, VAR_MAGIC2, ''boubou2k_edgeturning_2'']

new const edges[12][10] = [
        [ 0,  4,  2, 27,  44, 40, 42, 20,   1, 43],
        [ 6,  4,  0, 42,  20, 22, 26, 45,   3, 23],
        [ 2,  4,  8, 47,  33, 31, 27, 44,   5, 30],
        [ 8,  4,  6, 26,  45, 49, 47, 33,   7, 46],
        [ 9, 13, 11, 18,  36, 40, 38, 29,  10, 37],
        [15, 13,  9, 38,  29, 31, 35, 53,  12, 32],
        [11, 13, 17, 51,  24, 22, 18, 36,  14, 21],
        [17, 13, 15, 35,  53, 49, 51, 24,  16, 52],
        [18, 22, 20,  0,  42, 40, 36, 11,  19, 39],
        [26, 22, 24, 17,  51, 49, 45,  6,  25, 48],
        [27, 31, 29,  9,  38, 40, 44,  2,  28, 41],
        [35, 31, 33,  8,  47, 49, 53, 15,  34, 50]
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
    if(IsGameResetRequest() || !LoadVariable(''boubou2k_edgeturning_2'', cube)) {
        return 0
    } else {
        refresh()
        return 1
    }
}
savegame() {
    StoreVariable(''boubou2k_edgeturning_2'', cube)
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
    rotate25(edge, 0)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate25(edge, 0)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate25(edge, 1)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate25(edge, 0)
    refresh()
}
rotate25(edge, center=0) { //TODO
    new i, temp

    temp = cube[edges[edge][0]]
    for (i=1; i<8; i++)
        cube[edges[edge][i-1]] = cube[edges[edge][i]]
    cube[edges[edge][7]] = temp

    if (center) {
        temp = cube[edges[edge][9]]
        cube[edges[edge][9]] = cube[edges[edge][8]]
        cube[edges[edge][8]] = temp
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
