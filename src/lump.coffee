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
        if @data.length == 0
            return

        for i in [0..@data.length - 1]
            bf.writeUInt8(@data.slice(i, i + 1).readUInt8())

module.exports = WLump