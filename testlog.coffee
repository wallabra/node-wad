fs = require('fs')
WAD = require('./src/wad.js')

w = WAD.read(fs.readFileSync(process.argv[2]))

console.dir(w)