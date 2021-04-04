local utils = {}

function utils.clearScreen()
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
end

utils.Type = {COMPUTER = 1, TURTLE = 2}
utils.Version = {MASTER = 1, SLAVE = 2, MINER = 3}

utils.Directions = {NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4}

utils.ValidationTypes = {
  ALPHA = 1,
  NUMERIC = 2,
  ALPHANUMERIC = 3,
  POSITIVE = 4,
  NEGATIVE = 5
}

function utils.printOSInfo(version)
  local extension = utils.getOSVersion(version)

  term.clearLine()
  term.setTextColor(colors.yellow)
  term.write("ZericOS ")
  term.setTextColor(colors.lightGray)
  term.write(extension .. " - 1.0")

  term.setTextColor(colors.white)
end

function utils.printHeader(type, version)
  term.setCursorPos(1, 1)

  if type == utils.Type.COMPUTER then
    utils.printOSInfo(version)
    print()
  elseif type == utils.Type.TURTLE then
    utils.printOSInfo(version)
    utils.printCurrentBatteryInverse()
    print()
  end
end

function utils.printInput()
  term.setTextColor(colors.yellow)
  term.write("> ")
  term.setTextColor(colors.white)
end

function utils.getValidatedUserInput(text, validKeys)
  utils.refreshTerm()
  return utils.getValidatedUserInputNoRefresh(text, validKeys)
end

function utils.getValidatedUserInputNoRefresh(text, validKeys)
  local key = nil
  local invalid = true

  while invalid do
    term.setTextColor(colors.lightGray)
    print(text)
    utils.printInput()

    local inputKey = read()

    for i, k in ipairs(validKeys) do
      print("Checking: " .. k)
      if inputKey == k then
        key = k
        invalid = false
        break
      end
    end
    utils.refreshTerm()
  end

  return key
end

function utils.refreshTerm()
  term.clear()
  utils.printHeader(utils.Type.TURTLE, utils.Version.MINER)
end

function utils.getUserInput(text, validationType)
  local valid = false

  while not valid do
    utils.refreshTerm()
    term.setTextColor(colors.lightGray)
    print(text)
    utils.printInput()

    local input = read()

    if validationType == utils.ValidationTypes.ALPHA then
      if tonumber(input) == nil then return input end
    elseif validationType == utils.ValidationTypes.POSITIVE then
      local num = tonumber(input)
      if num ~= nil and num > 0 then return input end
    elseif validationType == utils.ValidationTypes.NEGATIVE then
      local num = tonumber(input)
      if num ~= nil and num < 0 then return input end
    elseif validationType == utils.ValidationTypes.NUMERIC then
      if tonumber(input) ~= nil then return input end
    end
  end
end

function utils.updateHeader(type, version)
  local x, y = term.getCursorPos()
  utils.printHeader(type, version)
  term.setCursorPos(x, y)
end

function utils.printError(message)
  term.setTextColor(colors.red)
  term.write("ERROR: ")
  term.setTextColor(colors.lightGray)
  print(message)
  term.setTextColor(colors.white)
end

function utils.turnToDirection(direction, currentDirection)
  if direction < 1 or direction > 4 then
    utils.printError("Direction is incorrect")
    return
  end

  if direction == currentDirection then return end

  -- NORTH -> WEST
  -- 1 -> 4
  -- turns = 1 - 4 = -3

  -- 3 -> 4
  -- 3 - 4 = -1
  -- turns = clamp(3 - 4, 1, 4)

  -- print("Turning From " .. currentDirection .. " to " .. direction)

  -- local turns = utils.clamp(currentDirection - direction, 1, 4)
  local turns = currentDirection - direction

  while turns ~= 0 do
    if turns > 0 then
      turtle.turnLeft()
      turns = turns - 1
    elseif turns < 0 then
      turtle.turnRight()
      turns = turns + 1
    end
  end
end

function utils.getDirection(direction)
  if direction == utils.Directions.NORTH then
    return "North"
  elseif direction == utils.Directions.EAST then
    return "East"
  elseif direction == utils.Directions.SOUTH then
    return "South"
  elseif direction == utils.Directions.WEST then
    return "West"
  else
    return "UNDIF"
  end
end

function utils.getOSVersion(version)
  if version == utils.Version.MASTER then
    return "Master"
  elseif version == utils.Version.SLAVE then
    return "Slave"
  elseif version == utils.Version.MINER then
    return "Miner"
  else
    return "UNDIF"
  end
end

function utils.printBattery(fuelLevelPercent)
  local batterycolor = colors.green

  local fuelLevelLen = string.len(tostring(fuelLevelPercent))

  local width, height = term.getSize()
  local x, y = term.getCursorPos()

  local textStart = width - 15 - fuelLevelLen
  term.setCursorPos(textStart + 1, y)

  -- [||||||||||]* 10%

  if fuelLevelPercent < 10 then
    batterycolor = colors.red
  elseif fuelLevelPercent < 40 then
    batterycolor = colors.yellow
  end

  local coloredStripeCount = math.ceil(fuelLevelPercent / 10)

  term.setTextColor(colors.lightGray)
  term.write("[")
  for i = 1, coloredStripeCount, 1 do
    term.blit("|", colors.toBlit(batterycolor), colors.toBlit(colors.black))
  end

  for i = coloredStripeCount + 1, 10, 1 do
    term.blit("|", colors.toBlit(colors.gray), colors.toBlit(colors.black))
  end
  term.write("]* ")
  term.setTextColor(batterycolor)
  term.write(tostring(fuelLevelPercent) .. "%")
  term.setTextColor(colors.white)
  print()
end

function utils.printBatteryInverse(fuelLevelPercent)
  local batterycolor = colors.green

  local fuelLevelLen = string.len(tostring(fuelLevelPercent))

  local width, height = term.getSize()
  local x, y = term.getCursorPos()

  local textStart = width - 15 - fuelLevelLen
  term.setCursorPos(textStart + 1, y)

  -- [||||||||||]* 10%

  if fuelLevelPercent < 10 then
    batterycolor = colors.red
  elseif fuelLevelPercent < 40 then
    batterycolor = colors.yellow
  end

  term.setTextColor(batterycolor)
  term.write(tostring(fuelLevelPercent) .. "%")
  term.setTextColor(colors.white)

  local coloredStripeCount = math.ceil(fuelLevelPercent / 10)

  term.setTextColor(colors.lightGray)
  term.write(" *[")
  for i = coloredStripeCount + 1, 10, 1 do
    term.blit("|", colors.toBlit(colors.gray), colors.toBlit(colors.black))
  end

  for i = 1, coloredStripeCount, 1 do
    term.blit("|", colors.toBlit(batterycolor), colors.toBlit(colors.black))
  end

  term.write("]")
  print()
end

function utils.clamp(val, lower, upper)
  if lower > upper then lower, upper = upper, lower end

  local diff = upper - lower

  return ((val - lower) % upper) + lower
end

function utils.printCurrentBattery()
  utils.printBattery(utils.getRemainingFuelPercent())
end

function utils.printCurrentBatteryInverse()
  utils.printBatteryInverse(utils.getRemainingFuelPercent())
end

function utils.getRemainingFuel() return turtle.getFuelLevel() end
function utils.getRemainingFuelPercent()
  local fuelLevel = turtle.getFuelLevel()
  local maxFuel = turtle.getFuelLimit()

  return math.floor(fuelLevel / maxFuel * 100)
end

return utils
