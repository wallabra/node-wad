fs = require("fs")
WHeader = require("./header.js")
WDirectory = require("./directory.js")
WLump = require("./lump.js")
BufferReader = require("buffer-utils").BufferReader
BufferWriter = require("buffer-utils").BufferWriter

class WAD
    constructor: (@bPWAD, @numLumps) ->
        @lumps = []
        @_header = new WHeader(@)
        @_directory = new WDirectory(@)
        @ptype = null

    @read: (buf) ->
        r = new BufferReader(buf)

        if r._buffer.length < 12
            throw new Error("Invalid or corrupt WAD file: insufficient length for a full header!")

        ptype = r._buffer.slice(0, 4).toString('ascii')

        r.readUInt32LE() # offset pass

        w = new WAD(ptype is "PWAD") # buffer-utils limitations...
        w.ptype = ptype

        numLumps = r.readUInt32LE()
        doff = r.readUInt32LE() - 12

        data = buf.slice(11)

        if data.length < doff
            throw new Error("Corrupt or incorrect WAD directory offset!")

        lumpData = data.slice(0, doff + 1)
        dirdata = data.slice(doff + 1)

        i = 0

        while i * 16 < dirdata.length
            dirRead = new BufferReader(
                dirdata.slice(i * 16, i * 16 + 16)
            )

            loff = dirRead.readUInt32LE() - 11
            llen = dirRead.readUInt32LE()

            lump = new WLump(
                @

                lumpData.slice(
                    loff
                    loff + llen
                ).toString()

                dirdata
                    .slice(i * 16 + 8, i * 16 + 16)
                    .toString()
            )

            w.lumps.push(lump)

            i++

        return w

    write: =>
        bw = new BufferWriter()

        @_header.write(bw)

        for l in @lumps
            l.write(bw)

        @_directory.write(bw)

        return bw.getContents()

    addLump: (name, data) =>
        @lumps.push(new WLump(
            @
            data
            name
        ))

module.exports = WAD