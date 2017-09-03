###
Doom map editing.

Does not support nodebuilding
yet.
###
BufferWriter = require("buffer-utils").BufferWriter
Bitfield = require("bitfield")

isClockwise = (positions) ->
    edges = []

    for i1 in [0..positions.length - 1]
        if i1 is positions.length - 1
            i2 = 0

        else
            i2 = i1 + 1

        edges.push( (positions[i2][0] - positions[i1][0]) * (positions[i2][1] + positions[i1][1]) )

    return edges.reduce((x, y) -> x + y) > 0

writeChars = (st, bw, cap, maxLen) ->
    if not cap? then cap = 0
    if not maxLen? then maxLen = st.toString('ascii').length

    if cap > 0
        padding = "\x00".repeat(cap - st.length)

    else
        padding = ""

    for c in st.slice(0, maxLen).toString() + padding
        data = (new Buffer(c, 'ascii'))
        bw.writeUInt8(data.readUInt8())

class WSector
    constructor: (@floorHeight, @ceilHeight, @floorTex, @ceilTex, @lighting, @special, @tag, @index) ->
        if not @floorHeight? then @floorHeight = 0
        if not @ceilHeight? then @ceilHeight = 128
        if not @floorTex? then @floorTex = "FLAT1" else @floorTex = @floorTex.toString('ascii')
        if not @ceilTex? then @ceilTex = "FLAT2" else @ceilTex = @ceilTex.toString('ascii')
        if not @lighting? then @lighting = 192
        if not @special? then @special = 0
        if not @tag? then @tag = 0

    write: (bw) =>
        bw
            .writeInt16LE(@floorHeight)
            .writeInt16LE(@ceilHeight)

        writeChars(@floorTex, bw, 8)
        writeChars(@ceilTex, bw, 8)

        bw
            .writeInt16LE(@lighting)
            .writeUInt16LE(@special)
            .writeUInt16LE(@tag)

        return @

defaultFlags = new Bitfield(16)
defaultFlags.set(0)
defaultFlags.set(1)
defaultFlags.set(2)
defaultFlags.set(8)
defaultFlags.set(9)
defaultFlags.set(10)

defaultFlags = defaultFlags.buffer.readUInt16LE()

class WThing
    constructor: (@xpos, @ypos, @angle, @type, @flags) ->
        if not @flags? then @flags = defaultFlags
        if not @angle? then @angle = 0

    write: (bw) =>
        bw
            .writeInt16LE(@xpos)
            .writeInt16LE(@ypos)
            .writeUInt16LE(@angle)
            .writeUInt16LE(@type)
            .writeUInt16LE(@flags)

        return @

class WSidedef
    constructor: (@xoffs, @yoffs, @uptex, @midtex, @lowtex, @frontSector, @index) ->
        if @frontSector instanceof WSector then @frontSector = @frontSector.index

        if not @midtex? then @midtex = "STARTAN2" # MWAHAHAHAHAHA
        if not @uptex? then @uptex = "-"
        if not @lowtex? then @lowtex = "-"
        if not @xoffs? then @xoffs = 0
        if not @yoffs? then @yoffs = 0

    write: (bw) =>
        bw
            .writeInt16LE(@xoffs)
            .writeInt16LE(@yoffs)

        writeChars(@uptex, bw, 8)
        writeChars(@lowtex, bw, 8)
        writeChars(@midtex, bw, 8)

        bw.writeUInt16LE(@frontSector)

        return @

class WLinedef
    constructor: (@begin, @end, @flags, @linetype, @tag, @frontSidedef, @backSidedef) ->
        if @begin instanceof WVertex then @begin = @begin.index
        if @end instanceof WVertex then @end = @end.index

        if @frontSidedef instanceof WSidedef then @frontSidedef = @frontSidedef.index
        if @backSidedef instanceof WSidedef then @backSidedef = @backSidedef.index

        if not @frontSidedef? then @frontSidedef = 0xFFFF
        if not @backSidedef? then @backSidedef = 0xFFFF

        if not @flags? then @flags = (if @backSidedef isnt 0xFFFF then 0b100 else 0b001)

    write: (bw) =>
        bw
            .writeUInt16LE(@begin)
            .writeUInt16LE(@end)
            .writeUInt16LE(@flags)
            .writeUInt16LE(@linetype)
            .writeUInt16LE(@tag)
            .writeUInt16LE(@frontSidedef)
            .writeUInt16LE(@backSidedef)

        return @
        
class WVertex
    constructor: (@x, @y, @index) ->

    write: (bw) =>
        bw
            .writeInt16LE(@x)
            .writeInt16LE(@y)

        return @

class MapEdit
    constructor: (@mapName) ->
        @vertexes = []
        @linedefs = []
        @sidedefs = []
        @things = []
        @sectors = []

    @read: (wad, pos) ->
        # wip

        m = new MapEdit(wad.lumps[pos].name)
        return m

    toLumps: (wad) =>
        wad.addLump(@mapName)

        vb = new BufferWriter()

        @things.forEach((s) -> s.write(vb))
        wad.addLump("THINGS", vb.getContents())

        @linedefs.forEach((l) -> l.write(vb))
        wad.addLump("LINEDEFS", vb.getContents())

        @sidedefs.forEach((s) -> s.write(vb))
        wad.addLump("SIDEDEFS", vb.getContents())

        @vertexes.forEach((v) -> v.write(vb))
        data = vb.getContents()
        wad.addLump("VERTEXES", data)

        @sectors.forEach((v) -> v.write(vb))
        wad.addLump("SECTORS", vb.getContents())

        return @ # for chaining

    addVertex: (x, y) =>
        @vertexes.push(new WVertex(x, y, @vertexes.length))

        return @ # for chaining

    addThing: (x, y, type, angle, flags) =>
        @things.push(new WThing(x, y, angle, type, flags))

        return @ # for chaining

    buildSector: (positions, sectorData, lineData) =>
        if not sectorData? then sectorData = {}
        if not lineData? then lineData = {}

        newv = []
        newlines = []
        newpos = @vertexes.length

        for p in positions
            if p in @vertexes.map((v) -> [v.x, v.y])
                v = @vertexes[@vertexes.map((v) -> [v.x, v.y]).indexOf(p)]

            else
                v = new WVertex(p[0], p[1], @vertexes.length)
                @vertexes.push(v)

            newv.push(v)
        
        vi = 0

        sector = new WSector(
            sectorData.floorHeight,
            sectorData.ceilHeight,
            sectorData.floorTex,
            sectorData.ceilTex,
            sectorData.light,
            sectorData.special,
            sectorData.tag,
            @sectors.index + 1
        )

        @sectors.push(sector)

        for v1 in newv
            v2 = newv[if vi < newv.length - 1 then vi + 1 else 0]

            side = new WSidedef(lineData.xOff, lineData.yOff, lineData.upTex, lineData.midTex, lineData.lowTex, sector, @sidedefs.length)
            @sidedefs.push(side)

            if v1.index >= newpos and v2.index >= newpos
                line = new WLinedef(v1, v2, lineData.flags, lineData.lineType, lineData.tag, side, null)
                @linedefs.push(line)

            else
                for l in @linedefs
                    if l.begin is v1.index and l.end is v2.index
                        line = l
                        break

                if line.backSidedef?
                    line.frontSidedef = side

                else
                    line.backSidedef = side

            vi++

        return @

module.exports = MapEdit