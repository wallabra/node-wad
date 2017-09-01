# node-wad

is a Node.JS parser and writer for Doom .WAD files, that includes a map editor (with linedefs, sectors, etc).

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
