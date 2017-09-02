fs = require('fs')
WAD = require('../src/wad.js')

w = WAD.read(fs.readFileSync('test.wad'))

QUnit.test('WAD reading', (assert) ->
    assert.strictEqual(w.ptype, "PWAD", "PWAD/IWAD detection")
    assert.strictEqual(w.lumps[0].name.toString('ascii'), "TESTNAME", "lumpname reading")
    assert.strictEqual(w.lumps[0].data.length, 12, "lump data reading: offsets and length")
    assert.strictEqual(w.lumps[0].data.toString('ascii'), "Hello World!", "lump data reading: content")
)

QUnit.test('WAD writing', (assert) ->
    if w? and w.write?
        assert.equal(w.write().toString('hex'), fs.readFileSync('test.wad', { encoding: 'hex' }), "WAD serializing")
)