fs = require('fs')
WAD = require('../src/wad.js')
MapEdit = require("../src/map.js")

w = WAD.read(fs.readFileSync('test.wad'))

QUnit.test('WAD reading', (assert) ->
    assert.strictEqual(w.ptype, "PWAD", "PWAD/IWAD detection")
    assert.strictEqual(w.lumps[0].name.toString('ascii'), "TESTNAME", "lumpname reading")
    assert.strictEqual(w.lumps[0].data.length, 12, "lump data reading: offsets and length")
    assert.strictEqual(w.lumps[0].data.toString('ascii'), "Hello World!", "lump data reading: content")
)

QUnit.test('WAD writing', (assert) ->
    if w? and w.write?
        assert.strictEqual(w.write().toString('hex'), fs.readFileSync('test.wad', { encoding: 'hex' }), "WAD serializing")
)

QUnit.test('Map writing', (assert) ->
    ed = new MapEdit("MAP01")
    w2 = new WAD(true)

    ed.buildSector([
        [0, 0]
        [0, 128]
        [128, 128]
        [128, 0]
    ], {
        floorTex: "FLAT5_4"
        lighting: 192
    }, {
        lowTex: "BROWN144"
    })

    ed.addThing(64, 96, 1, 270, 0b111)

    assert.strictEqual(ed.sectors.length, 1, "sector count")
    assert.strictEqual(ed.linedefs.length, 4, "linedef count")
    assert.strictEqual(ed.sidedefs.length, 4, "sidedef count")
    assert.strictEqual(ed.vertexes.length, 4, "vertex count")
    assert.strictEqual(ed.sectors[0].floorTex, "FLAT5_4", "sector data application 1/2")
    assert.strictEqual(ed.sectors[0].floorHeight, 0, "sector data application 2/2")
    assert.strictEqual(ed.sidedefs[0].midtex, "STARTAN2", "line data application 1/2")
    assert.strictEqual(ed.sidedefs[0].lowtex, "BROWN144", "line data application 2/2")

    ed.toLumps(w2)
    assert.strictEqual(w2.lumps.length, 6, "map lumpcount")
    assert.strictEqual(w2.lumps[0].name, "MAP01", "mapname")

    assert.strictEqual(w2.write().toString("hex"), fs.readFileSync("test2.wad", "hex"), "map exporting")
    fs.writeFileSync("test2out.wad", w2.write())
)