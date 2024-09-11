# FiveM Digiscanner 
Little rework of [Pengu Digi Scanner](https://github.com/PenguScript/pengu_digiscanner) with ability to register multiple points and slightly better handling of the scanner itself. Use the example below to get yourself started. 


```lua
-- Useage: 

-- Register a point
exports['clean-digiscanner']:registerPoint('random_id', {
  pos             = vector3(-397.26208496094, -107.16575622559, 38.683372497559), 
  find_radius     = 2.0,
  destroy_on_find = true,
  onFind = function()
    -- Stuff to do when found 
  end
})

-- Get the closest point
local nearest_id, nearest_dist = exports['clean-digiscanner']:getClosestPoint(GetEntityCoords(PlayerPedId()))

-- Destroy a point
exports['clean-digiscanner']:destroyPoint('random_id')

-- Get a point
local point = exports['clean-digiscanner']:getPoint('random_id')
```

