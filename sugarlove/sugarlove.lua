sugar = {}
sugar.S = {}

local events = require("sugarlove/sugar_events")

local active_canvas, active_color
local old_love = love
local set_love = setmetatable({}, {__index = old_love})

local _debug = debug

local function arrange_call(v, before, after)
  return function(...)
    -- wrap before
    if active_canvas then
      old_love.graphics.setCanvas(active_canvas)
      old_love.graphics.setColor(active_color or {1, 1, 1, 1})
    end
    
    if before then before(...) end
    
    local r
    if v then
      r = {xpcall(v, _debug.traceback, ...)}
    else
      r = {true}
    end
    
    if after then after(...) end
    
    active_color = {old_love.graphics.getColor()}
    active_canvas = old_love.graphics.getCanvas()
    old_love.graphics.setCanvas()
    
    if r[1] then
      return r[2]
    else
      sugar.debug.r_log(r[2])
      error(r[2], 0)
    end
  end
end

if SUGAR_SERVER_MODE then
  arrange_call = function(v, before, after)
    return function(...)
      -- wrap before
      
      if before then before(...) end
      
      local r
      if v then
        r = {xpcall(v, _debug.traceback, ...)}
      else
        r = {true}
      end
      
      if after then after(...) end

      if r[1] then
        return r[2]
      else
        sugar.debug.r_log(r[2])
        error(r[2], 0)
      end
    end
  end
end

love = setmetatable({}, {
  __index = set_love,
  __newindex = function(t, k, v)
    if type(v) == "function" or v == nil then
      if k == "draw" and not SUGAR_SERVER_MODE then
        old_love[k] = arrange_call(v, nil, sugar.gfx.half_flip)
        
      elseif k == "update" then
        old_love[k] = arrange_call(v, sugar.sugar_step, nil)
        
      elseif events[k] then
        old_love[k] = arrange_call(v, events[k], nil)
      
      else
        old_love[k] = arrange_call(v)
      end
      
      set_love[k] = v
    else
      old_love[k] = v
      set_love[k] = v
    end
  end
})

local _dont_arrange = {
  getVersion           = true,
  hasDeprecationOutput = true,
  isVersionCompatible  = true,
  setDeprecationOutput = true,
  run                  = true,
  errorhandler         = true
}
local _prev_exist = {}

for k,v in pairs(old_love) do
  if type(v) == "function" and not _dont_arrange[k] then
    _prev_exist[k] = v
  end
end

require("sugarlove/utility")
require("sugarlove/debug")
require("sugarlove/maths")
require("sugarlove/gfx")
require("sugarlove/sprite")
require("sugarlove/text")
require("sugarlove/time")
require("sugarlove/input")
require("sugarlove/audio")
require("sugarlove/core")


for k,v in pairs(_prev_exist) do
  love[k] = v
end

local function quit()
  sugar.shutdown_sugar()
end

love.quit = quit
events.quit = quit


if SUGAR_SERVER_MODE then
  local forbid = {
    "gfx",
    "audio",
    "input"
  }
  
  for _, k in pairs(forbid) do
    for name, foo in pairs(sugar[k]) do
      sugar[k][name] = function(...)
        sugar.debug.w_log("Using forbidden "..k.." function '"..name.."'.")
        foo(...)
      end
      
      sugar.S[name] = sugar[k][name]
    end
  end
end
