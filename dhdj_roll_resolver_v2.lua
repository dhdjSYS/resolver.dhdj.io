local entity, base64, http, websockets, inspect, vector, ffi, cast, typeof, new, __thiscall, table_copy, vtable_bind, interface_ptr, vtable_entry, vtable_thunk, nativeGetClientEntity, HOST_ADDR, MAX_CYCLE, server, connecting, packet_sent, last_sent_tick, last_received_msg, last_received_tick, last_tick_delay, connected, congested, nl_resolve_ref, fs_resolve_ref, log, clamp, angleNormalize, handleMessage, connectToServer, ws_callbacks, MAGI, MELCHIOR_1, BALTHASAR_2, CASPER_3, player_eye_angles, player_override, resolve_neverlose_roll, majority_vote, player_roll, on_net_update_start, on_net_update_end, on_paint, aim_miss
entity = require("gamesense/entity")
base64 = require("gamesense/base64")
http = require("gamesense/http")
websockets = require("gamesense/websockets")
inspect = require("gamesense/inspect")
vector = require("vector")
ffi = require("ffi")
do
  local _obj_0 = ffi
  cast, typeof, new = _obj_0.cast, _obj_0.typeof, _obj_0.new
end
ffi.cdef([[    typedef struct{
        float x;
        float y;
        float z;
    } vec3_t;

    typedef struct
    {
        char pad[0x117D0];
        float pitch;
        float yaw;
        float roll;
    } player;
]])
__thiscall = function(func, this)
  return function(...)
    return func(this, ...)
  end
end
table_copy = function(t)
  local _tbl_0 = { }
  for k, v in pairs(t) do
    _tbl_0[k] = v
  end
  return _tbl_0
end
vtable_bind = function(module, interface, index, typedef)
  local addr = cast("void***", client.create_interface(module, interface)) or error(interface .. " is nil.")
  return __thiscall(cast(typedef, addr[0][index]), addr)
end
interface_ptr = typeof("void***")
vtable_entry = function(instance, i, ct)
  return cast(ct, cast(interface_ptr, instance)[0][i])
end
vtable_thunk = function(i, ct)
  local t = typeof(ct)
  return function(instance, ...)
    return vtable_entry(instance, i, t)(instance, ...)
  end
end
nativeGetClientEntity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'player*(__thiscall*)(void*, int)')
HOST_ADDR = "ws://43.138.147.94:1741"
MAX_CYCLE = 16
server = nil
connecting = true
packet_sent = 0
last_sent_tick = 0
last_received_msg = ""
last_received_tick = 0
last_tick_delay = 0
connected = false
congested = false
nl_resolve_ref = ui.new_checkbox("RAGE", "Other", "Resolver neverlose roll (EXPERIMENTAL)")
fs_resolve_ref = ui.new_checkbox("RAGE", "Other", "Resolver freestanding (EXPERIMENTAL)")
log = function(...)
  return print("[Agapornis]", ...)
end
clamp = function(val, min_val, max_val)
  return math.max(min_val, math.min(max_val, val))
end
angleNormalize = function(angle)
  while angle > 180 do
    angle = angle - 360
  end
  while angle < -180 do
    angle = angle + 360
  end
  return clamp(tonumber(('%.3f'):format(angle / 361)) + 0.5, 0.001, 0.999)
end
handleMessage = function(ws, data)
  packet_sent = 0
  last_received_msg = ""
  data = json.parse(data)
  local tick = data['tick']
  last_received_tick = tick
  last_tick_delay = globals.tickcount() - last_received_tick
  local enemies = entity.get_players(true)
  for i, enemy in ipairs(enemies) do
    if data[tostring(enemy:get_entindex())] ~= nil then
      local roll = math.min(math.max(-1, data[tostring(enemy:get_entindex())]), 1)
      last_received_msg = last_received_msg .. enemy:get_player_name() .. ": " .. tostring(roll * 75) .. ", "
      MELCHIOR_1.angles[enemy:get_entindex()] = roll
      MELCHIOR_1.update_tick[enemy:get_entindex()] = last_received_tick
    end
  end
end
connectToServer = function()
  log("Attempting to connect to MELCHIOR_1")
  websockets.connect(HOST_ADDR, ws_callbacks)
  connecting = true
end
ws_callbacks = {
  open = function(ws)
    log(("Connected to MELCHIOR_1 %s"):format(ws.url))
    server = ws
    connecting = false
  end,
  message = function(ws, data)
    handleMessage(ws, data)
    connecting = false
  end,
  close = function(ws, code, reason, was_clean)
    log(("Connection closed: code=%s reason = %s was_clean = %s"):format(code, reason, was_clean))
    server = nil
    connecting = false
  end,
  error = function(ws, err)
    log(("Connection error: %s"):format(err))
    server = nil
    connecting = false
  end
}
do
  local _class_0
  local _base_0 = {
    get = function(self, index)
      return 0
    end,
    update = function(self)
      return false
    end,
    init = function(self)
      return false
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "MAGI"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  MAGI = _class_0
end
do
  local _class_0
  local _parent_0 = MAGI
  local _base_0 = {
    angles = { },
    update_tick = { },
    invert = { },
    cycle_history = {
      ["Example"] = { }
    },
    cycle_last_update_ticks = {
      ["Example"] = 0
    },
    generate_data_packet = function(self, player, fill)
      local index = player:get_entindex()
      local tickcount = globals.tickcount()
      if self.cycle_last_update_ticks[index] == nil then
        self.cycle_last_update_ticks[index] = tickcount - 1
      end
      if self.cycle_history[index] == nil or self.cycle_last_update_ticks[index] ~= tickcount - 1 then
        self.cycle_history[index] = { }
      end
      self.cycle_last_update_ticks[index] = tickcount
      local animstate = player:get_anim_state()
      local frame = {
        animstate.on_ground and 1 or 0,
        animstate.feet_cycle,
        animstate.feet_yaw_rate,
        animstate.clamped_velocity,
        animstate.run_amount,
        animstate.landing_duck_amount,
        animstate.jump_fall_velocity,
        animstate.head_from_ground_distance_standing,
        animstate.duck_amount,
        animstate.hit_in_ground_animation and 1 or 0,
        angleNormalize(animstate.eye_angles_x),
        angleNormalize(animstate.eye_angles_y),
        angleNormalize(animstate.last_move_yaw),
        angleNormalize(animstate.torso_yaw),
        angleNormalize(animstate.lean_amount),
        angleNormalize(animstate.current_feet_yaw),
        angleNormalize(animstate.goal_feet_yaw)
      }
      for i = 3, 6 do
        local animlayer = player:get_anim_overlay(i)
        table.insert(frame, animlayer.weight)
        table.insert(frame, animlayer.cycle)
        table.insert(frame, animlayer.prev_cycle)
        table.insert(frame, animlayer.weight_delta_rate)
        table.insert(frame, animlayer.playback_rate)
      end
      table.insert(self.cycle_history[index], frame)
      if #self.cycle_history[index] < MAX_CYCLE then
        if not fill then
          return 
        end
        while #self.cycle_history[index] < MAX_CYCLE do
          table.insert(self.cycle_history[index], frame)
        end
      end
      if #self.cycle_history[index] > MAX_CYCLE then
        table.remove(self.cycle_history[index], 1)
      end
      local packet = { }
      for i, frame in pairs(self.cycle_history[index]) do
        for i, v in pairs(frame) do
          table.insert(packet, v)
        end
      end
      return packet
    end,
    upload_enemy_information = function(self)
      if packet_sent > 2 then
        congested = true
        return 
      else
        congested = false
      end
      local upload_batch = {
        ['tick'] = globals.tickcount()
      }
      local enemies = entity.get_players(true)
      local upload = false
      for i, enemy in ipairs(enemies) do
        local upload_packet = self:generate_data_packet(enemy, true)
        if upload_packet then
          upload_batch[tostring(enemy:get_entindex())] = upload_packet
          upload = true
        end
      end
      if not upload then
        return 
      end
      last_sent_tick = globals.tickcount()
      packet_sent = packet_sent + 1
      return server:send(json.stringify(upload_batch))
    end,
    init = function(self)
      return connectToServer()
    end,
    update = function(self)
      connected = (server ~= nil)
      if not connected then
        if not connecting then
          connectToServer()
        end
        return 
      end
      return self:upload_enemy_information()
    end,
    get = function(self, index)
      if self.angles[index] == nil then
        return 0
      end
      return self.angles[index]
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "MELCHIOR_1",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  MELCHIOR_1 = _class_0
end
do
  local _class_0
  local _parent_0 = MAGI
  local _base_0 = {
    angles = { },
    update_tick = { },
    invert = { },
    normalize = function(self, angle)
      angle = (angle % 360 + 360) % 360
      return angle > 180 and angle - 360 or angle
    end,
    get_angle = function(self, vector)
      return math.atan2(vector.y, vector.x) * (180 / math.pi)
    end,
    degree_to_radian = function(self, degree)
      return (math.pi / 180) * degree
    end,
    angle_to_vector = function(self, angle)
      local pitch = self:degree_to_radian(angle.x)
      local yaw = self:degree_to_radian(angle.y)
      return vector(math.cos(pitch) * math.cos(yaw), math.cos(pitch) * math.sin(yaw), -math.sin(pitch))
    end,
    get_wall_fraction_with_origin = function(self, player, angle, origin)
      local vec = self:angle_to_vector(angle) * 8192
      local impact = origin + vec
      return client.trace_line(player:get_entindex(), origin.x, origin.y, origin.z, impact.x, impact.y, impact.z)
    end,
    get_distance_to_wall_with_origin = function(self, player, angle, origin)
      local fraction, index = self:get_wall_fraction_with_origin(player, angle, origin)
      return fraction * 8192
    end,
    get_angle_to_local = function(self, player)
      local local_player = entity.get_local_player()
      local lo = vector(local_player:get_origin())
      local eo = vector(player:get_origin())
      local no = self:get_angle(vector(eo.x - lo.x, eo.y - lo.y, eo.z - lo.z))
      local ea = player:get_prop("m_angEyeAngles[1]")
      if ea == nil then
        return 0
      end
      local d = self:normalize(ea - no)
      return d
    end,
    get_angle_to_local_opposite = function(self, player)
      local local_player = entity.get_local_player()
      local lo = vector(local_player:get_origin())
      local eo = vector(player:get_origin())
      local no = self:get_angle(vector(eo.x - lo.x, eo.y - lo.y, eo.z - lo.z))
      return self:normalize(no)
    end,
    is_sideways = function(self, player)
      local d = self:get_angle_to_local(player)
      return ((d >= 45 and d <= 135) or (d <= -45 and d >= -135))
    end,
    resolve_freestand = function(self, p)
      local enemy_eye_pos = vector(p:get_origin())
      enemy_eye_pos.z = enemy_eye_pos.z + 64
      local ang_to_local = (p:get_prop("m_angEyeAngles[0]") > 80) and self:get_angle_to_local_opposite(p) or p:get_prop("m_angEyeAngles[1]")
      local enemy_eye_angle = vector(0, self:normalize(ang_to_local), 0)
      local eye_left = vector(0, self:normalize(ang_to_local + 45), 0)
      local eye_right = vector(0, self:normalize(ang_to_local - 45), 0)
      local distance_middle = self:get_distance_to_wall_with_origin(p, enemy_eye_angle, enemy_eye_pos)
      local distance_left = self:get_distance_to_wall_with_origin(p, eye_left, enemy_eye_pos)
      local distance_right = self:get_distance_to_wall_with_origin(p, eye_right, enemy_eye_pos)
      local out_of_range = false
      if distance_middle > 100 then
        out_of_range = true
      end
      local ang = self:get_angle_to_local(p)
      local retval = distance_left > distance_right and 1 or -1
      if math.abs(ang) > 90 then
        retval = -retval
      end
      return retval, out_of_range
    end,
    get = function(self, index)
      if self.angles[index] == nil then
        return 0
      end
      return self.angles[index]
    end,
    update = function(self)
      local enemies = entity.get_players(true)
      local total = #enemies
      if total == 0 then
        return 
      end
      local enemy = enemies[(globals.tickcount() % total) + 1]
      local index = enemy:get_entindex()
      local anim = enemy:get_anim_state()
      local retval, out_of_range = self:resolve_freestand(enemy)
      self.angles[index] = retval
      self.update_tick[index] = globals.tickcount()
      if ui.get(fs_resolve_ref) then
        local velocity = anim.clamped_velocity
        if velocity < 0.3 and not out_of_range then
          plist.set(index, "Force body yaw value", (self.angles[index] > 0 and -60 or 60) * (BALTHASAR_2.invert[index] and -1 or 1))
          return plist.set(index, "Force body yaw", true)
        else
          return plist.set(index, "Force body yaw", false)
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "BALTHASAR_2",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BALTHASAR_2 = _class_0
end
do
  local _class_0
  local _parent_0 = MAGI
  local _base_0 = {
    angles = { },
    update_tick = { },
    invert = { },
    normalize = function(self, angle)
      angle = (angle % 360 + 360) % 360
      return angle > 180 and angle - 360 or angle
    end,
    get_desync_exact = function(self, player)
      local anim = player:get_anim_state()
      return self:normalize(anim.goal_feet_yaw - anim.eye_angles_y)
    end,
    update = function(self)
      local enemies = entity.get_players(true)
      for i, enemy in ipairs(enemies) do
        local desync = self:get_desync_exact(enemy)
        if math.abs(desync) < 15 then
          self.angles[enemy:get_entindex()] = 0
        else
          self.angles[enemy:get_entindex()] = desync > 0 and -1 or 1
        end
        self.update_tick[enemy:get_entindex()] = globals.tickcount()
      end
    end,
    get = function(self, index)
      if self.angles[index] == nil then
        return 0
      end
      return self.angles[index]
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "CASPER_3",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CASPER_3 = _class_0
end
MELCHIOR_1:init()
BALTHASAR_2:init()
CASPER_3:init()
player_eye_angles = { }
player_override = { }
resolve_neverlose_roll = function()
  local enemies = entity.get_players(true)
  for i, enemy in ipairs(enemies) do
    local index = enemy:get_entindex()
    local anim = enemy:get_anim_state()
    local cur_eye_angles = anim.eye_angles_y
    if player_eye_angles[index] ~= nil then
      local angDifference = CASPER_3:normalize(cur_eye_angles - player_eye_angles[index])
      if math.abs(angDifference) > 60 then
        plist.set(index, "Force body yaw value", angDifference > 0 and -60 or 60)
        player_override[index] = 32
      end
    end
    if player_override[index] == nil then
      player_override[index] = 0
    end
    if player_override[index] > 0 then
      player_override[index] = player_override[index] - 1
    end
    plist.set(index, "Force body yaw", (player_override[index] ~= nil and player_override[index] ~= 0) and true or false)
    player_eye_angles[index] = cur_eye_angles
  end
end
majority_vote = function(pred1, pred2, pred3)
  local left = 0
  local right = 0
  local middle = 0
  if pred1 == 1 then
    right = right + 1
  elseif pred1 == 0 then
    middle = middle + 1
  else
    left = left + 1
  end
  if pred2 == 1 then
    right = right + 1
  elseif pred2 == 0 then
    middle = middle + 1
  else
    left = left + 1
  end
  if pred3 == 1 then
    right = right + 1
  elseif pred3 == 0 then
    middle = middle + 1
  else
    left = left + 1
  end
  if left == middle and middle == right then
    return 0, 1
  end
  if left < right then
    return 75, right
  else
    return -75, left
  end
end
player_roll = { }
on_net_update_start = function()
  local enemies = entity.get_players(true)
  for i, enemy in ipairs(enemies) do
    local index = enemy:get_entindex()
    local ent_ptr = nativeGetClientEntity(index)
    player_roll[index] = {
      majority_vote(MELCHIOR_1:get(index), BALTHASAR_2:get(index), CASPER_3:get(index))
    }
    player_roll[index][1] = player_roll[index][1] * (math.max(0, math.abs(CASPER_3:get_desync_exact(enemy)) - 20) / 36)
    ent_ptr.roll = player_roll[index][1]
  end
end
on_net_update_end = function()
  MELCHIOR_1:update()
  BALTHASAR_2:update()
  CASPER_3:update()
  if ui.get(nl_resolve_ref) then
    return resolve_neverlose_roll()
  end
end
on_paint = function()
  renderer.blur(490, 70, 170, 110)
  renderer.rectangle(490, 70, 170, 110, 0, 0, 0, 50)
  renderer.gradient(490, 65, 170, 5, 255, 255, 255, 0, 255, 255, 255, 255, false)
  renderer.text(500, 80, 255, 255, 255, 255, "d-", 0, "[resolver] network debug")
  renderer.text(500, 95, 255, 255, 255, 255, "d-", 0, "last sent tick: " .. last_sent_tick)
  renderer.text(500, 110, 255, 255, 255, 255, "d-", 0, "last received tick: " .. last_received_tick)
  renderer.text(500, 125, last_tick_delay < 3 and 0 or 255, last_tick_delay < 3 and 255 or 0, 255, 255, "d-", 0, "last delay (tick): " .. last_tick_delay)
  renderer.text(500, 140, congested and 255 or 0, congested and 0 or 255, 50, 255, "d-", 0, "congested: " .. tostring(congested))
  renderer.text(500, 155, connected and 150 or 255, connected and 255 or 150, 150, 255, "d-", 0, "connected: " .. tostring(connected))
  local enemies = entity.get_players(true)
  for i, enemy in ipairs(enemies) do
    local index = enemy:get_entindex()
    if enemy:is_alive() and player_roll[index] ~= nil then
      local x1, y1, x2, y2, alpha_multiplier = enemy:get_bounding_box()
      if alpha_multiplier ~= 0 then
        local agreed = player_roll[index][2]
        renderer.text(x1 - 10, y1, 255, 255, 255, 255, "dr-", 0, ("ROLL: %.2f°"):format(player_roll[index][1]))
        if agreed == -1 then
          renderer.text(x1 - 10, y1 + 12, 0, 255, 255, 255, "dr-", 0, ("MAGI: %d / 3"):format(agreed))
        elseif agreed < 3 then
          renderer.text(x1 - 10, y1 + 12, 255, agreed * (255 / 3), agreed * (255 / 3), 255, "dr-", 0, ("MAGI: %d / 3"):format(agreed))
        else
          renderer.text(x1 - 10, y1 + 12, 0, 255, 100, 255, "dr-", 0, ("MAGI: %d / 3"):format(agreed))
        end
      end
    end
  end
end
client.set_event_callback("net_update_start", on_net_update_start)
client.set_event_callback("net_update_end", on_net_update_start)
client.set_event_callback("net_update_end", on_net_update_end)
client.set_event_callback("paint", on_paint)
aim_miss = function(e)
  if e.reason == "?" and plist.get(e.target, "Force body yaw") then
    if BALTHASAR_2.invert[e.target] == nil then
      BALTHASAR_2.invert[e.target] = true
    else
      BALTHASAR_2.invert[e.target] = not BALTHASAR_2.invert[e.target]
    end
  end
end
return client.set_event_callback('aim_miss', aim_miss)
