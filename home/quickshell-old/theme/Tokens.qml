pragma Singleton
import QtQuick
import "."

QtObject {
    readonly property var color: PaletteNord

    readonly property QtObject radius: QtObject {
        readonly property int xs:   2
        readonly property int sm:   4
        readonly property int md:   5
        readonly property int lg:   7
        readonly property int xl:   9
        readonly property int xl2: 10
        readonly property int xl3: 12
        readonly property int xl4: 14
        readonly property int xl5: 16
        readonly property int xl6: 18
    }

    readonly property QtObject spacing: QtObject {
        readonly property int railPad:    14
        readonly property int railGap:     9
        readonly property int gaugeGap:   20
        readonly property int dockGap:     9
        readonly property int tileGap:     6
        readonly property int sepMargin:   8
    }

    readonly property QtObject font: QtObject {
        readonly property string sans: "Manrope"
        readonly property int label:   9
        readonly property int sub:     9
        readonly property int badge:   9
        readonly property int chip:   10
        readonly property int xs:     11
        readonly property int sm:     12
        readonly property int md:     13
        readonly property int base:   14
        readonly property int lg:     15
        readonly property int clock:  64
    }

    readonly property QtObject size: QtObject {
        readonly property int railW:      50
        readonly property int topbarH:    26
        readonly property int tile:       20
        readonly property int sepW:       26
        readonly property int gaugeBarW:  10
        readonly property int gaugeBarH:  36
        readonly property int battW:      18
        readonly property int battH:       9
        readonly property int iconSm:     12
        readonly property int iconMd:     14
        readonly property int iconLg:     16
        readonly property int iconXl:     18
        readonly property int iconXl2:    22
        readonly property int qsW:       360
    }
}
