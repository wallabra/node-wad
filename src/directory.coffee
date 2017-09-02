add = (a, b) -> a + b

class WDirectory
    constructor: (@wad) ->
    
    write: (bf) =>
        i = 0

        for entry in @wad.lumps
            namecode = (entry.name + "\x00".repeat(
                Math.max(0, 8 - entry.name.length)
            )).slice(0, 8)

            # only ASCII lumpnames are supported by the old WAD format.

            bf
                .writeUInt32LE(@wad.lumps
                    .slice(0, i)
                    .map((x) -> x.getSize())
                    .reduce(add, 0) + 12)

                .writeUInt32LE(entry.getSize())
            
            for c in namecode
                bf.writeUInt8((new Buffer(c, 'ascii')).readUInt8())

            i++

module.exports = WDirectory