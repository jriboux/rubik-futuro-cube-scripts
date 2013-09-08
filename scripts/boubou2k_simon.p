/*
boubou2k_simon.p

This example shows simple implementation of rubik's cube with animated rotations.
Direction of rotation is determined by inclination of tapped side.
SolveDir function reads accelerometer data and compares them with threshold "ACC_THRESHOLD"
for direction. Also each move is stored into variable, so the progress is never lost.
Example of correct use of ICON() is demonstrated as well. Note that definition of icon[]
must be placed in global namespace!

*/

#include <futurocube>

#define TAP_RIGHT 3
#define TAP_FRONT 5
#define TAP_LEFT 2
#define TAP_BACK 4

#define COLOR_RED 1
#define COLOR_BLUE 2
#define COLOR_YELLOW 3
#define COLOR_GREEN 4
#define NB_COLORS 4

#define SEQ_SIZE 64 // 64 * 16 = 1024, should be enough ;)


new icon[]=[ICON_MAGIC1,ICON_MAGIC2,2,0, 0,0xFF000000,0,  0x00FF0000,0,0xFFFF0000,  0,0x0000FF00,0,  ''UFO'',''UFO'']
new palette[]=[0xFF000000,0x0000FF00,0xFFFF0000,0x00FF0000,0x04000000,0x00000400,0x04040000,0x00040000,0xFFFFFF00,0xFF000000,0x00FF0000]

new points[][]=[[5,27,30,33],[7,45,46,47],[3,20,23,26],[1,42,43,44]]
new notes[]=["_a1","_c2","_d2","_e2"]

new seq[SEQ_SIZE]
new seqLength = 0
new delay = 400

getSeqItem(index) {
    new arrayIndex = index/16
    new bitIndex = (index%16)*2
    return (seq[arrayIndex]>>bitIndex)&0x00000003
}
setSeqItem(index, value) {
    new arrayIndex = index/16
    new bitIndex = (index%16)*2
    new resetMask = 0xFFFFFFFF^(0x00000003<<bitIndex)
    seq[arrayIndex] = (seq[arrayIndex]&resetMask)|((value&0x00000003)<<bitIndex)
}
appendSeqItem(value) {
    setSeqItem(seqLength, value)
    seqLength += 1
}
getSeqLength() {
    return seqLength
}
resetSeq() {
    new i
    for (i=0; i<SEQ_SIZE; i++)
        seq[i] = 0x00000000
    seqLength = 0
}

/* Get color from side number, 0 if no color */
getColor(side) {
    switch (side) {
        case TAP_BACK:
            return COLOR_GREEN
        case TAP_RIGHT:
            return COLOR_RED
        case TAP_FRONT:
            return COLOR_BLUE
        case TAP_LEFT:
            return COLOR_YELLOW
    }
    return 0
}

/* Initialize game */
init() {
    ICON(icon)
    SetIntensity(256)
    RegAllSideTaps()
    PaletteFromArray(palette)
    resetSeq()
    delay = 300
}

/* Intro animation */
intro() {
    new color = 0
    for (color=0; color<=NB_COLORS; color++) {
        Delay(250)
        playColor(color)
        PrintCanvas()
    }
    Delay(500)
    playColor(0)
    PrintCanvas()
}

/* Wait for tab before start */
tapToStart() {
    new motion = 0

    Play("_g_TAPTOSTART")
    for (;;) {
        Sleep()
        motion=Motion()
        if (motion) {
            AckMotion()
            break
        }
    }
    Play("kap")
    Delay(500)
}

/* Display a color and play associated sound, color 0 resets display */
playColor(color) {
    new i
    new j

    /* erase previous colors */
    for (i=0; i<sizeof(points); i++) {
        SetColor(i+1+NB_COLORS)
        DrawPoint(points[i][0])
        SetColor(0)
        for (j=1; j<sizeof(points[]); j++) {
            DrawPoint(points[i][j])
        }
    }

    /* draw new color */
    if (color) {
        SetColor(color)
        for (i=0;i<sizeof(points[]); i++)
            DrawPoint(points[color-1][i])
        PrintCanvas()
        Play(notes[color-1])
    } else {
        PrintCanvas()
    }
}

playSeq() {
    new i
    Delay(250)
    for (i=0; i<getSeqLength(); i++) {
        Quiet()
        Delay(50)
        playColor(getSeqItem(i)+1)
        Delay(500)
    }
    playColor(0)
}

error() {
    new color
    new i

    Play("_g_CRASH2")

    SetColor(COLOR_RED)
    for (color=1; color<=NB_COLORS; color++) {
        for (i=0;i<sizeof(points[]); i++)
            DrawPoint(points[color-1][i])
    }
    PrintCanvas()
    Delay(1000)
    Quiet()

    SetColor(0)
    DrawCube()
    PrintCanvas()
}

success() {
    new color
    new i

    Play("cink3")

    /* draw new color */
    for (color=1; color<=NB_COLORS; color++) {
        SetColor(color)
        for (i=0;i<sizeof(points[]); i++)
            DrawPoint(points[color-1][i])
    }
    PrintCanvas()
    Delay(500)
    Quiet()

    SetColor(0)
    DrawCube()
    PrintCanvas()
}

userSeq() {
    new color
    new motion
    new currentNote
    new result

    currentNote = 0
    result = -1

    for (result=-1;result<0;) {
        Sleep()
        motion=Motion()
        if (motion) {
            if (eTapSideOK()) {
                color = getColor(eTapSide())
                if (color) {
                    playColor(color)
                    if (color == getSeqItem(currentNote) + 1) {
                        currentNote++
                        if (currentNote==seqLength) {
                            Delay(delay)
                            result = 1
                        }
                    } else {
                        result = 0
                    }
                }
            }
            AckMotion()
        }
    }

    return result
}

main() {
    init()
    intro()
    tapToStart()

    for (;;) {
        Sleep()
        appendSeqItem(GetRnd(NB_COLORS))
        playSeq()
        if (userSeq()) {
            success()
        } else {
            error()
            init()
            intro()
            tapToStart()
        }
    }
}
