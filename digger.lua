utils = require("utils")

-- TODO: Add refueling using the first Slot

movementOffset = {L = 0, W = 0, H = 0}
currentDirection = utils.Directions.NORTH

startDirection = utils.Directions.NORTH

width = 0
length = 0
depth = -1
yPos = -1

function setup()
  utils.refreshTerm()
  turtle.select(1)

  local key = utils.getValidatedUserInput(
                  "Do you want to enter the current Y-Coordinate? (y/n)",
                  {"y", "n", "Y", "N"})

  if key == "y" or key == "Y" then
    yPos = tonumber(utils.getUserInput("Y-Coordinate",
                                       utils.ValidationTypes.POSITIVE))
  end

  width = tonumber(utils.getUserInput("Width", utils.ValidationTypes.POSITIVE))

  length =
      tonumber(utils.getUserInput("Length", utils.ValidationTypes.POSITIVE))

  depth = tonumber(utils.getUserInput("Depth (-1 = forever)",
                                      utils.ValidationTypes.NUMERIC))

  local continue = true

  if yPos >= 0 then
    -- We inputted something
    local combinedEndOffset = yPos - 3

    if width % 2 == 1 then
      -- Odd, therefor not at same width offset
      combinedEndOffset = combinedEndOffset + width - 1
    end

    if length % 2 == 1 then
      combinedEndOffset = combinedEndOffset + length - 1
    end

    local movementSteps = ((width * length) - 1) * (yPos - 3) +
                              combinedEndOffset

    if movementSteps > utils.getRemainingFuel() then
      utils.printError(
          "We might not have enough fuel to do this.\nPlease Refuel or make sure that the first Slot contains coal")

      local key = utils.getValidatedUserInputNoRefresh(
                      "Do you wish to continue? (y/n)", {"y", "n", "Y", "N"})

      if key == "n" or key == "N" then
        print("Awww :(")
        sleep(1)
        ---@diagnostic disable-next-line: undefined-field
        os.reboot()
      end
    end

    utils.refreshTerm()
    term.setTextColor(colors.gray)
    print("Excavating...")

  end

  -- event, p1 = os.pullEvent()

  -- for i, arg in ipairs(args) do
  --   if not tonumber(arg) then
  --     utils.printError("Argument #" .. i .. " is not a number!")
  --     return
  --   end
  -- end

  -- if table.getn(args) == 2 then
  --   width, length = tonumber(args[1]), tonumber(args[2])
  -- else
  --   width, length = tonumber(args[1]), tonumber(args[1])
  -- end

  -- print("Width: " .. width)
  -- print("Length: " .. length)
end

function excavate()
  if yPos == -1 then yPos = 1000 end
  if depth == -1 then depth = 1000 end

  -- yPos = 64
  -- depth = 4
  -- yPos - depth = 60

  for h = yPos, yPos - depth + 1, -1 do
    for w = 1, width, 1 do
      for l = 1, length - 1, 1 do
        digDown()
        forward()
      end

      digDown()
      if w ~= width then
        if movementOffset.W % 2 == 0 then
          turnRight()
          forward()
          turnRight()
        else
          turnLeft()
          forward()
          turnLeft()
        end
      end
    end
    if h ~= 1 then
      local able = down()
      if able == false then return end
      turnLeft()
      turnLeft()
    end
  end
end

function digDown()
  turtle.digDown()

  if turtle.getItemCount(16) > 0 then
    term.setTextColor(colors.red)
    print("Inventory full. Returning home...")
    -- Inventory Full, we should drop stuff off

    local savedW = movementOffset.W
    local savedL = movementOffset.L
    local savedH = movementOffset.H
    local savedDirection = currentDirection

    moveTo(0, 0, 0)

    emptyInventory()
    print("Going back...")

    moveTo(savedW, savedL, savedH)
    turnToDirection(savedDirection)
  end
end

function emptyInventory()
  turnToDirection(utils.Directions.SOUTH)
  term.setTextColor(colors.gray)
  print("Emptying...")
  for i = 2, 16, 1 do
    turtle.select(i)
    turtle.drop()
  end
  turtle.select(1)
end

function forward()
  turtle.forward()
  applyOffset()
  utils.updateHeader()
end

function turnToDirection(direction)
  utils.turnToDirection(direction, currentDirection)
  currentDirection = direction
end

function up()
  turtle.up()
  movementOffset.H = movementOffset.H + 1
  utils.updateHeader()
end

function down()
  movementOffset.H = movementOffset.H - 1
  utils.updateHeader()
  return turtle.down()
end

function turnLeft()
  turtle.turnLeft()
  currentDirection = utils.clamp(currentDirection - 1, 1, 4)
end

function turnRight()
  turtle.turnRight()
  currentDirection = utils.clamp(currentDirection + 1, 1, 4)
end

function applyOffset()
  if currentDirection == utils.Directions.NORTH then
    movementOffset.L = movementOffset.L + 1
  elseif currentDirection == utils.Directions.SOUTH then
    movementOffset.L = movementOffset.L - 1
  elseif currentDirection == utils.Directions.EAST then
    movementOffset.W = movementOffset.W + 1
  elseif currentDirection == utils.Directions.WEST then
    movementOffset.W = movementOffset.W - 1
  end
end

function returnHome()
  moveTo(0, 0, 0)

  emptyInventory()
  turnToDirection(utils.Directions.NORTH)

  term.setTextColor(colors.green)
  print("Done.")
end

function moveTo(w, l, h)

  if movementOffset.W > w then
    turnToDirection(utils.Directions.WEST)
  elseif movementOffset.W < w then
    turnToDirection(utils.Directions.EAST)
  end

  while movementOffset.W ~= w do forward() end

  if movementOffset.L > l then
    turnToDirection(utils.Directions.SOUTH)
  elseif movementOffset.L < l then
    turnToDirection(utils.Directions.NORTH)
  end

  while movementOffset.L ~= l do forward() end

  if movementOffset.H < h then
    while movementOffset.H ~= h do up() end
  elseif movementOffset.H > h then
    while movementOffset.H ~= h do down() end
  end
end

setup()
excavate()
returnHome()
