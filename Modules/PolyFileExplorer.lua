local PolyFileExplorer = {}

function PolyFileExplorer:PrepairComputer(computerType_arg, modems_arg, drives_arg, inventories_arg, isTurtleInventory_arg)
  local allPeripheral = function()
    local allPeripheral = {}
    for _, v in pairs(peripheral.getNames()) do
      table.insert(allPeripheral, peripheral.wrap(v))
    end
    return allPeripheral
  end

  local updateComputerType = function ()
    term.clear()
    term.setCursorPos(1, 1)
    print [[Choose type of this computer:
    1. Host
    Requires peripheral:
    - Any modem (can be turtle's addon)
    - Drive, that Host will be shared with Operator
    2. Operator
    Must be turtle. Requires peripheral:
    - Any modem (can be turtle's addon)
    - Drive, that Operator will be shared with Host
    - Inventory (can use turtle inventory)]]
    local userInput
    repeat
      print "Input 1/2"
      userInput = read()
    until userInput ~= "1" and userInput ~= "2"
    if userInput == "1" then
      return "host"
    else
      return "operator"
    end
  end

  local updateModems = function (modems)
    modems = {}
      for _, v in pairs(allPeripheral()) do
        if peripheral.hasType(v, "modem") then
          term.clear()
          term.setCursorPos(1, 1)
          print([[Choose modem(s) to interact with.
                   Should we use this modem?
                   Name:]], peripheral.getName(v),
            "Type:", peripheral.getType(v))
          local userInput
          repeat
            print("Input Y/N")
            userInput = read()
          until userInput ~= "Y" and userInput ~= "N"
          if userInput == "Y" then
            table.insert(modems, v)
          end
        end
      end
  end

  local updateDrives = function (drives)
    drives = {}
    for _, v in pairs(allPeripheral()) do
      if peripheral.hasType(v, "drive") then
        term.clear()
        term.setCursorPos(1, 1)
        print([[Choose drive(s) to interact with.
                 Should we use this drive?
                 Name:]], peripheral.getName(v),
          "Type:", peripheral.getType(v))
        local userInput
        repeat
          print("Input Y/N")
          userInput = read()
        until userInput ~= "Y" and userInput ~= "N"
        if userInput == "Y" then
          table.insert(drives, v)
        end
      end
    end

  end

  local updateInventories = function (inventories)
    inventories = {}
      for _, v in pairs(allPeripheral()) do
        if peripheral.hasType(v, "inventory") then
          term.clear()
          term.setCursorPos(1, 1)
          print([[Choose inventory(s) to interact with.
                   Should we use this inventory?
                   Name:]], peripheral.getName(v),
            "Type:", peripheral.getType(v))
          local userInput
          repeat
            print("Input Y/N")
            userInput = read()
          until userInput ~= "Y" and userInput ~= "N"
          if userInput == "Y" then
            table.insert(inventories, v)
          end
        end
      end
  end

  local updateIsTurtleInventory = function ()
    term.clear()
      term.setCursorPos(1,1)
      print("Should we use turtle's inventory as an additional space for disks?")
      local userInput
      repeat
        print("Input Y/N")
        userInput = read()
      until userInput ~= "Y" and userInput ~= "N"
      if userInput == "Y" then
        return true
      else
        return false
      end
  end

  local computerType = computerType_arg
  if computerType ~= "host" and computerType ~= "operator" then
    computerType = updateComputerType()
  end

  if computerType == "host" then
    local modems = modems_arg
    if modems == nil then
      updateModems(modems)
    end

    local drives = drives_arg
    if drives == nil then
      updateDrives(drives)
    end

    for _, modem in pairs(modems) do
      rednet.open(modem)
    end

    rednet.host("PolyFile", "Host_" .. tostring(os.computerID()))

  elseif computerType == "operator" then
    local modems = modems_arg
    if modems == nil then
      updateModems(modems)
    end

    local drives = drives_arg
    if drives == nil then
      updateDrives(drives)
    end

    local inventories = inventories_arg
    if inventories == nil then
      updateInventories(inventories)
    end

    local isTurtleInventory = isTurtleInventory_arg
    if isTurtleInventory == nil then
      isTurtleInventory = updateIsTurtleInventory()
    end
  end
  
  return PolyFileExplorer
end
