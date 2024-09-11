local ScanPoints = {}
ScanPoint = {}
ScanPoint.__index = ScanPoint

ScanPoint.register = function(id, data)
  local self = setmetatable(data, ScanPoint)
  self.id = id

  if not self:__init() then 
    return false 
  end

  ScanPoints[id] = self
  return self
end

exports('registerPoint', ScanPoint.register)

ScanPoint.get = function(id)
  return ScanPoints[id]
end

exports('getPoint', ScanPoint.get)

ScanPoint.getClosest = function(coords)
  local closest_id, closest_distance = nil, nil
  for id, scan_point in pairs(ScanPoints) do
    local distance = #(scan_point.pos.xyz - coords.xyz)
    if not closest_distance or distance < closest_distance then
      closest_id = id
      closest_distance = distance
    end
  end
  return closest_id, closest_distance
end

exports('getClosestPoint', ScanPoint.getClosest)

ScanPoint.destroy = function(id)
  local scan_point = ScanPoint.get(id)
  if not scan_point then return false end
  ScanPoints[id] = nil
end

exports('destroyPoint', ScanPoint.destroy)


function ScanPoint:__init()
  assert(self.pos, 'ScanPoint must have a pos')
  self.radius = self.radius or 1.0 
  return true
end

function ScanPoint:isFacing()
  local ply_pos = GetEntityCoords(cache.ped)
  local ply_heading = GetEntityHeading(cache.ped)
  local x = self.pos.x - ply_pos.x
  local y = self.pos.y - ply_pos.y

  local target_heading = GetHeadingFromVector_2d(x, y)
  return math.abs(ply_heading - target_heading) < 20
end


