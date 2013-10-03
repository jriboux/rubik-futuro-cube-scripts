/*
boubou2k_gravity.p

Rubik's Futuro Cube Gravity game clone

*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,0,
    cORANGE,cPURPLE,cGREEN,
    cORANGE,cPURPLE,cGREEN,
    cORANGE,cPURPLE,cGREEN,
    '''','''']
new palette[]=[
    cORANGE, cPURPLE, cRED, cBLUE, cGREEN, cMAGENTA
    ]

new savedgame[] = [VAR_MAGIC1, VAR_MAGIC2, ''boubou2k_gravity'']

new const rotation45[9] = [3, 0, 1, 6, 4, 2, 7, 8, 5]

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
    if(IsGameResetRequest() || !LoadVariable(''boubou2k_gravity'', cube)) {
        return 0
    } else {
        refresh()
        return 1
    }
}
savegame() {
    StoreVariable(''boubou2k_gravity'', cube)
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
    new i, j, side, amount, move

    Play("_g_SHUFFLING")
    generate()

    for (i=0; i<100; i++) {
        side = GetRnd(6)
        amount = GetRnd(3)+1
        move = GetRnd(2)
        if (move) {
            for (j=1; j<=amount; j++) {
                rotate(side, 1)
            }
        } else {
            for (j=1; j<=amount; j++) {
                shift(findBelt(side), 1)
            }
        }
    }

    Quiet()
}

shift(belt, dir=1) {
    shift1(belt, dir)
    refresh()
}

shift1(belt, dir=1) {
    new temp, i, j, curbelt[12]

    for (j=0;j<3;j++) {
        curbelt = belts[belt][j]
        if (dir==1) {
            temp=cube[curbelt[0]]
            for (i=0;i<11;i++)
                cube[curbelt[i]]=cube[curbelt[i+1]]
            cube[curbelt[11]]=temp
        } else {
            temp=cube[curbelt[11]]
            for (i=11;i>0;i--)
                cube[curbelt[i]]=cube[curbelt[i-1]]
            cube[curbelt[0]]=temp
        }
    }
}

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
    for (i=0; i<9; i++)
        temp[i] = cube[side * 9 + rotation45[i]]
    for (i=0; i<9; i++)
        cube[side * 9 + i] = temp[i]
}

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
            if (eTapToTop()) {
                Vibrate(50)
                rotate(side)
                savegame()
            }
            if (eTapSideOK() && eTapToSide()) {
                Vibrate(50)
                shift(findBelt(side), findDir(side))
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
