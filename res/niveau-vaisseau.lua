return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.4",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 12,
  height = 7,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 19,
  nextobjectid = 3,
  properties = {},
  tilesets = {
    {
      name = "vaisseau",
      firstgid = 1,
      filename = "./res/vaisseau.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      columns = 4,
      image = "vaisseau.png",
      imagewidth = 256,
      imageheight = 128,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 64,
        height = 64
      },
      properties = {},
      terrains = {},
      tilecount = 8,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 15,
      name = "Espace",
      x = 0,
      y = 0,
      width = 12,
      height = 7,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
      }
    },
    {
      type = "tilelayer",
      id = 16,
      name = "Sol",
      x = 0,
      y = 0,
      width = 12,
      height = 7,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 5, 5, 5, 0, 5, 5, 5,
        0, 0, 5, 5, 0, 5, 5, 5, 0, 5, 5, 5,
        8, 5, 5, 5, 5, 5, 5, 5, 0, 5, 5, 5,
        8, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        0, 0, 5, 5, 0, 5, 5, 5, 0, 5, 5, 5,
        0, 0, 0, 0, 0, 5, 5, 5, 0, 5, 5, 5
      }
    },
    {
      type = "tilelayer",
      id = 17,
      name = "Cloisons",
      x = 0,
      y = 0,
      width = 12,
      height = 7,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 2,
        0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 2, 0, 0, 2, 2, 4, 2, 2, 2, 4, 2,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 2, 4, 2, 0, 2, 4, 2,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 18,
      name = "Equipements",
      x = 0,
      y = 0,
      width = 12,
      height = 7,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
