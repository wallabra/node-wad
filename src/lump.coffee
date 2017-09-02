class WLump
    constructor: (@wad, data, name) ->
        @data = new Buffer(data)
        @name = name.toString('ascii')

        while @name.endsWith("\x00")
            @name = @name.slice(0, -1)

        # For console.dir purposes:
        @strData = @data.toString('utf-8')
    
    getSize: =>
        return @data.length

    write: (bf) =>
        for c in @data.toString('ascii')
            bf.writeUInt8((new Buffer(c, 'ascii')).readUInt8())

module.exports = WLump