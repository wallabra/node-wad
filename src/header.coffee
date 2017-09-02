class WHeader
    constructor: (@wad) ->
    
    write: (bf) =>
        for c in (if @wad.bPWAD then "PWAD" else "IWAD")
            bf.writeUInt8((new Buffer(c, 'ascii')).readUInt8())

        bf
            .writeUInt32LE(@wad.lumps.length)
            .writeUInt32LE((
                @wad.lumps
                    .map((l) -> l.getSize())
                    .reduce((a, b) -> a + b)
            ) + 12)

module.exports = WHeader