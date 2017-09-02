# node-wad

is a Node.JS parser and writer for Doom .WAD files, that will include a map editor (with linedefs, sectors, etc).

## Implemented API
    . WAD (the main WAD structure)
    +-+ lumps (list : WLump)
    | +-+ WLump
    |   +-- name (String)
    |   +-- data (Buffer)
    |   +-- strData (String)
    |   
    +-- bPWAD
    +-- numLumps
    +-- read (class-method : Buffer -> WAD instance)
    +-- write (instance-method : void -> Buffer instance)

    . MapEdit (a class that edits maps and exports them to WAD)
    +-- mapName
    +-+ vertexes (list : WVertex)
    | +-+ WVertex
    |   +-- x
    |   +-- y
    |   +-- index
    |
    +-+ linedefs (list : WLinedef)
    | +-+ WLinedef
    |   +-- begin
    |   +-- end
    |   +-- flags
    |   +-- linetype
    |   +-- tag
    |   +-- frontSidedef
    |   +-- backSidedef
    |   +-- index
    |
    +-+ sidedefs (list : WSidedef)
    | +-+ WSidedef
    |   +-- xoffs
    |   +-- yoffs
    |   +-- uptex
    |   +-- midtex
    |   +-- lowtex
    |   +-- frontSector
    |   +-- index
    |
    +-+ things (list : WThing)
    | +-+ WThing
    |   +-- xpos
    |   +-- ypos
    |   +-- angle
    |   +-- type
    |   +-- flags
    |
    +-+ sectors (list : WSector)
    | +-+ WSector
    |   +-- floorHeight
    |   +-- ceilHeight
    |   +-- floorTex
    |   +-- ceilTex
    |   +-- lighting
    |   +-- special
    |   +-- tag
    |   +-- index
    |
    +-- read (UPCOMING) (class-method : Buffer -> MapEdit)
    +-- toLumps (instance-method : WAD -> MapEdit chaining)
    +-- addVertex (instance-method : Number x, Number y -> MapEdit chaining)
    +-- addThing (instance-method : Number xpos, Number ypos, Number type, Number angle, Number index -> MapEdit chaining)
    +-- buildSector (instance-method : list[list[Number, Number]] positions, Object{Number floorHeight, Number ceilHeight, String floorTex, String ceilTex, Number light, Number special, Number tag} sectorData, Object{Number xOff, Number yOff, String upTex, String midTex, String lowTex, Number flags, Number lineType, Number tag} lineData -> MapEdit chaining)