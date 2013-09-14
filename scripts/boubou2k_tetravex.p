/*
boubou2k_cuvex.p

Tetravex in a cube.
Tap to shuffle.
Tap on top to rotate the top side.
Tap on side to swap side and top.
The goal is to match colors accross all edges.

*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,0,
    0,0xFFBF0000,0,
    0xFFBF0000,0,0xFF00FF00,
    0,0x007FBF00,0,
    '''','''']
new palette[]=[
    0xFF000000,
    0xFF003F00,
    0xFF00FF00,
    0x00FF0000,
    0xFFBF0000,
    0xFF3F0000,
    0x0000FF00,
    0x007FBF00,
    0x00FF7F00,
    0xFFFFFF00
    ]

new const edges[12][2] = [
    [1, 43], [3, 23], [5, 30], [7, 46],
    [10, 37], [12, 32], [14, 21], [16, 52],
    [19, 39], [25, 48],
    [28, 41], [34, 50]
    ]

new const rotation45[9] = [3, 0, 1, 6, 4, 2, 7, 8, 5]
/*new const rotation90[9] = [6, 3, 0, 7, 4, 1, 8, 5, 2]*/

new const belts[3][3][12] = [[
        [0,1,2,27,28,29,9,10,11,18,19,20],
        [3,4,5,30,31,32,12,13,14,21,22,23],
        [6,7,8,33,34,35,15,16,17,24,25,26]],
       [[0,3,6,45,48,51,17,14,11,36,39,42],
        [1,4,7,46,49,52,16,13,10,37,40,43],
        [2,5,8,47,50,53,15,12,9,38,41,44]],
       [[27,30,33,47,46,45,26,23,20,42,43,44],
        [28,31,34,50,49,48,25,22,19,39,40,41],
        [29,32,35,53,52,51,24,21,18,36,37,38]
    ]]
new const posInBelt[3][6] = [
        [ 0, 2, 3, 1,-1,-1],
        [ 0, 2,-1,-1, 3, 1],
        [-1,-1, 2, 0, 3, 1]
    ]

new const ANIM_DELAY = 72
new const ACC_THRESHOLD = 150

new cube[54]

/* Initialize game */
init() {
    ICON(icon)
    SetIntensity(256)
    RegAllSideTaps()
    PaletteFromArray(palette)
}

/* Intro animation */
intro() {
    new i
    new color

    for (i=0; i<4; i++) {
        color = GetRnd(10)+1
        cube[edges[i][0]] = color
        cube[edges[i][1]] = color
    }
    refresh()
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
    new color

    for (i=0; i<12; i++) {
        color = GetRnd(10)+1
        cube[edges[i][0]] = color
        cube[edges[i][1]] = color
    }
}

shuffle() {
    new i
    new j
    new side
    new amount
    new move

    Play("_g_SHUFFLING")

    generate()

    for (i=0; i<(GetRnd(50)+50); i++) {
        side = GetRnd(6)
        amount = GetRnd(3)+1
        move = GetRnd(2)
        if (move) {
            for (j=1; j<=amount; j++) {
                rotate(side, 6)
            }
        } else {
            for (j=1; j<=amount; j++) {
                swap(findBelt(side), 1, side, 6)
            }
        }
    }

    Quiet()
}

swap(belt, dir, top, delay=0) {
    swap1(belt, dir, top)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)
    swap1(belt, dir, top)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)
    swap1(belt, dir, top)
    refresh()
}
swap1(belt, dir, top) {
    new temp
    new i
    new j
    new curbelt[12]
    new p = ((findPos(belt, top)-dir)*3)%12

    for (j=0;j<3;j++) {
        curbelt = belts[belt][j]
        if (dir==1) {
            temp=cube[curbelt[p%12]]
            for (i=0;i<5;i++)
                cube[curbelt[(i+p)%12]]=cube[curbelt[(i+1+p)%12]]
            cube[curbelt[(5+p)%12]]=temp
        } else {
            temp=cube[curbelt[(5+p)%12]]
            for (i=5;i>0;i--)
                cube[curbelt[(i+p)%12]]=cube[curbelt[(i-1+p)%12]]
            cube[curbelt[p]]=temp
        }
    }
}
/*swap3(belt, top, dir=1) {
    swap1(belt, top, dir)
    swap1(belt, top, dir)
    swap1(belt, top, dir)
}*/

rotate(side, delay=0) {
    rotate45(side)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)
    rotate45(side)
    refresh()
}
rotate45(side) {
    new i
    new temp[9]
    for (i=0; i<9; i++) temp[i] = cube[side * 9 + rotation45[i]]
    for (i=0; i<9; i++) cube[side * 9 + i] = temp[i]
}
/*rotate90(side) {
    new i
    new temp[9]
    for (i=0; i<9; i++) temp[i] = cube[side * 9 + rotation90[i]]
    for (i=0; i<9; i++) cube[side * 9 + i] = temp[i]
}*/

refresh() {
    ClearCanvas()
    DrawArray(cube)
    PrintCanvas()
}

findBelt(side) {
    new result = -1
    new top = findTop()
    switch (top) {
        case 0: result = (side==3||side==2)?0:1
        case 1: result = (side==3||side==2)?0:1
        case 2: result = (side==0||side==1)?0:2
        case 3: result = (side==0||side==1)?0:2
        case 4: result = (side==0||side==1)?1:2
        case 5: result = (side==0||side==1)?1:2
        default: result = -1
    }
    return result
}

findDir(side) {
    new result = -1
    new top = findTop()
    switch (top) {
        case 0: result = (side==3||side==5)?0:1
        case 1: result = (side==2||side==4)?0:1
        case 2: result = (side==0||side==4)?0:1
        case 3: result = (side==1||side==5)?0:1
        case 4: result = (side==0||side==3)?0:1
        case 5: result = (side==1||side==2)?0:1
        default: result = -1
    }
    return result
}

findTop() {
    return (GetCursor()&0x0000003F)/9
}

findPos(belt, top) {
    return posInBelt[belt][top]
}

success() {
    new i
    Play("clapping")
    Delay(2000)
}

checkSuccess() {
    new i
    for (i=0; i<12; i++)
        if (cube[edges[i][0]] != cube[edges[i][1]])
            return 0
    return 1
}

main() {
    init()
    intro()
    tapToStart()
    shuffle()

    new motion
    new side

    for (;;) {
        Sleep()
        motion = Motion()

        if (motion) {
            if (eTapToTop()) {
                side = eTapSide()
                rotate(side)
            }
            if (eTapSideOK() && eTapToSide()) {
                side = eTapSide()
                swap(findBelt(side), findDir(side), findTop())
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
