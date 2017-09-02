# node-wad

is a Node.JS parser and writer for Doom .WAD files, that will include a map editor (with linedefs, sectors, etc).

## Implemented API
    . WAD (the main structure)
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
    

## Target API
The API desired for this library is the following (in a shallow sketch):

    . WAD (the main structure)
    +-+ MapEdit
    | +-- Vertex
    | +-- Linedef
    | +-- Sector
    | +-- Thing
    |
    +-+ Directory
      +-- Lump
     
This is an incomplete sketch and may be extended in the future; especially for manipulating other kinds of lumps.
