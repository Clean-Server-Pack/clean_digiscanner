

local DigiScanner = {
  SCALEFORM = RequestScaleformMovie('DIGISCANNER'),
  SF_POS = {
    x = 0.1,
    y = 0.24,
    width = 0.21,
    height = 0.51,
  },

  SF_COLORS = {
    red = {r = 255, g = 10, b = 10},
    yellow = {r = 255, g = 209, b = 67},
    lightblue = {r = 67, g = 200, b = 255},
    green = {r = 0, g = 255, b = 80}
  },

  SF_BARS = {
    {dist = 500, bars = 30.0, wait = 7000},
    {dist = 400, bars = 40.0, wait = 6000},
    {dist = 300, bars = 50.0, wait = 5000},
    {dist = 150, bars = 60.0, wait = 4000},
    {dist = 80, bars = 70.0, wait = 3000},
    {dist = 40, bars = 80.0, wait = 2000},
    {dist = 10, bars = 90.0, wait = 1000},
    {dist = 0, bars = 100.0, wait = 500},
  },
}

function DigiScanner:updateBars(nearest_id, nearest_dist)
  local point_info = ScanPoint.get(nearest_id) or {}
  if not nearest_id then nearest_dist = 1000.0 end
  for i = 1, #self.SF_BARS do 
    local bar = self.SF_BARS[i]
    if nearest_dist > bar.dist then 
      self:method('SET_DISTANCE', {bar.bars})
      self.BEEP_INTERVAL = bar.wait
      break
    end
  end


  if nearest_dist < (point_info.find_radius or 2.0) then
    self.BEEP_INTERVAL = 250
    self:setColor(self.SF_COLORS.green, self.SF_COLORS.green)
    self:method('flashOn')
    if point_info.onFind then 
      point_info:onFind()
    end

    if point_info.destroy_on_find then 
      ScanPoint.destroy(nearest_id)
    end
  end 
end 

function DigiScanner:method(name, data)
  BeginScaleformMovieMethod(self.SCALEFORM, name)
  if data then 
    for _,v in pairs(data) do 
      if name == 'SET_DISTANCE' then 
        PushScaleformMovieMethodParameterFloat(v)
      else
        PushScaleformMovieMethodParameterInt(v)
      end
    end
  end
  PopScaleformMovieFunctionVoid()
end 

function DigiScanner:getColorNameByRGB(r, g, b)
  for k,v in pairs(self.SF_COLORS) do 
    if v.r == r and v.g == g and v.b == b then 
      return k
    end
  end
  return 'unknown'
end

function DigiScanner:setColor(bar, dot)
  self:method('SET_COLOUR', {bar.r, bar.g, bar.b, dot.r, dot.g, dot.b})
end

function DigiScanner:initate()
  if self.ACTIVE then return false, 'Already Active' end
  self.ACTIVE = true
  
  local my_pos = GetEntityCoords(cache.ped)
  local nearest_id, nearest_dist = ScanPoint.getClosest(my_pos)
  if nearest_id then 
    local point = ScanPoint.get(nearest_id)
    if point:isFacing() then 
      self:setColor(self.SF_COLORS.lightblue, self.SF_COLORS.yellow)
    else  
      self:setColor(self.SF_COLORS.red, self.SF_COLORS.red)
    end 
  else 
    self:setColor(self.SF_COLORS.red, self.SF_COLORS.red)
  end 

  self:updateBars(nearest_id, nearest_dist)

  if not IsNamedRendertargetRegistered('digiscanner') then
    RegisterNamedRendertarget('digiscanner', 0)
  end
  LinkNamedRendertarget(GetWeapontypeModel(joaat('weapon_digiscanner')))

  if IsNamedRendertargetRegistered('digiscanner') then
    self.RENDER_TEXT_ID = GetNamedRendertargetRenderId('digiscanner')
  end

  local last_beep = GetGameTimer() - self.BEEP_INTERVAL
  CreateThread(function()
    while self.ACTIVE do 
      local wait_time = 1000
      SetTextRenderId(self.RENDER_TEXT_ID)
      DrawScaleformMovie(self.SCALEFORM, self.SF_POS.x, self.SF_POS.y, self.SF_POS.width, self.SF_POS.height, 100, 100, 100, 255, 0)
      SetTextRenderId(1)

      if IsPlayerFreeAiming(PlayerId()) then 
        local nearest_id, nearest_dist = ScanPoint.getClosest(GetEntityCoords(cache.ped))
        if nearest_id then 
          local point = ScanPoint.get(nearest_id)
          if point:isFacing() then 
            self:setColor(self.SF_COLORS.lightblue, self.SF_COLORS.yellow)
          else  
            self:setColor(self.SF_COLORS.red, self.SF_COLORS.red)
          end 
        else 
          self:setColor(self.SF_COLORS.red, self.SF_COLORS.red)
        end

        self:updateBars(nearest_id, nearest_dist)


        if GetGameTimer() - last_beep > self.BEEP_INTERVAL then 
          last_beep = GetGameTimer()
          PlaySoundFromEntity(-1, 'Beep_Red', cache.ped, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', 0, 0)
        end
      
      end 
      Wait(0)
    end 
  end)
end

function DigiScanner:destroy()
  self.ACTIVE = false
  EndScaleformMovieMethodReturn()
end

lib.onCache('weapon', function(new_value)
  if new_value == joaat('weapon_digiscanner') then 
    DigiScanner:initate()
  else 
    DigiScanner:destroy()
  end
end)

RegisterCommand('digiscanner', function()
  GiveWeaponToPed(cache.ped, GetHashKey('weapon_digiscanner'), 1, false, true)
end)

RegisterCommand('removeScanner', function()
  RemoveWeaponFromPed(cache.ped, GetHashKey('weapon_digiscanner'))
end)


ScanPoint.register('random', {
  pos           = vector4(-397.26208496094, -107.16575622559, 38.683372497559, 50.380081176758), 
  find_radius   = 2.0,
  destroy_on_find = true,
  onFind = function()
    lib.notify({
      title = 'Found Random Point',
      description = 'You found a random point',
      icon = 'map-marker',
    })
  end
})


