function SpeakerControl(keyRec, speakersList, audioPath)
  local spInt = require("SpeakerInterface")
  spInt:setSpeakersList(speakersList)
  spInt:setAudio(audioPath)

  local isPaused = true
  local chunkNum = 0
  local volume = 16
  local lastChunkNum = spInt:getLastChunkNum()

  local isRepeat = false

  -- Function to communicate with User
  local CheckUserActions = function()
    -- Only if User does/did something (or video paused). Otherwise function does nothing.
    if keyRec:isSomethingPressed()
       or keyRec:isKeysHeld({ keys.up, keys.left, keys.down, keys.right })
       or isPaused then
      local chunkNumOffset = 0
      local wasPausePressed = false
      
      -- Handle all User actions, after continue program.
      while keyRec:isSomethingPressed()
        or keyRec:isKeysHeld({ keys.up, keys.left, keys.down, keys.right })
        or isPaused
      do
        -- Handle complete keystrokes
        if keyRec:isSomethingPressed() then
          local pressedKeysCombination = keyRec:getKeysCombination()

          -- Handle combinations with only one key. (f.e. Shift, not Alt+Shift)
          if #pressedKeysCombination == 1 then
            local pressedKey = pressedKeysCombination[1]

            -- Handle "Space": Pause/play video
            if pressedKey == keys.space then
              spInt:stopSpeakers()
              wasPausePressed = true
              isPaused = not isPaused

            -- Handle "Arrow Left"/"Arrow Right": Rewind/Fast forward video to 5 chunks
            elseif pressedKey == keys.left or pressedKey == keys.right then
              spInt:stopSpeakers()
              if pressedKey == keys.left then
                chunkNumOffset = chunkNumOffset - 5
              else
                chunkNumOffset = chunkNumOffset + 5
              end

            -- Handle "Arrow Up"/"Arrow Down": Volume up/down
            elseif pressedKey == keys.up or pressedKey == keys.down then
              isPaused = true
              wasPausePressed = true
              if pressedKey == keys.up then
                volume = volume + 1
              else
                volume = volume - 1
              end
              if volume > 32 then
                volume = 32
              elseif volume < 0 then
                volume = 0
              end
              spInt:stopSpeakers()
              spInt:playTestSample(volume)

            -- Handle "R": Turn on/off repeat
            elseif pressedKey == keys.r then
                isRepeat = not isRepeat
            end
          end
        end

        -- Handle ongoing keystrokes
        if keyRec:isKeysHeld({ keys.up, keys.left, keys.down, keys.right }) then

          -- Handle "Arrow Left"/"Arrow Right": Rewind/Fast forward video to 5 chunks
          if keyRec:isKeysHeld({ keys.left, keys.right }) then
            spInt:stopSpeakers()
            if keyRec:isKeysHeld({ keys.left }) then
              chunkNumOffset = chunkNumOffset - 5
            else
              chunkNumOffset = chunkNumOffset + 5
            end

          -- Handle "Arrow Up"/"Arrow Down": Volume up/down
          elseif keyRec:isKeysHeld({ keys.up, keys.down }) then
            isPaused = true
            wasPausePressed = true
            if keyRec:isKeysHeld({ keys.up }) then
              volume = volume + 1
            else
              volume = volume - 1
            end
            spInt:stopSpeakers()
            spInt:playTestSample(volume)
          end

          sleep(0.2)
        end

        -- Sleep, if video is paused and User does nothing. Otherwise no need for os.sleep(0)
        if isPaused then
          while not keyRec:isSomethingPressed()
            and not keyRec:isKeysHeld({ keys.up, keys.left, keys.down, keys.right })
          do
            os.sleep(0)
          end
        end
      end

      if wasPausePressed and chunkNumOffset == 0 then
        chunkNumOffset = chunkNumOffset - 2
      end

      chunkNum = chunkNum + chunkNumOffset
      if chunkNum < 0 then
        chunkNum = 0
      elseif chunkNum > lastChunkNum then
        chunkNum = lastChunkNum
      end
    end
  end

  CheckUserActions()

	repeat
		while chunkNum <= lastChunkNum do
			term.clear()
			term.setCursorPos(1, 1)
			print("Now playing:", chunkNum, "chunk, Volume:", volume)
			spInt:playChunk(chunkNum)
			os.pullEvent("chunk_is_played")
			chunkNum = chunkNum + 1
			CheckUserActions()
		end
    chunkNum = 0
	until isRepeat == false

end

local speakersList = { peripheral.find("speaker") }
local currentPath = "/"
while true do
  local audioPath
  local isAudioFound = false
  while not isAudioFound do
    term.clear()
    term.setCursorPos(1, 1)
    local pathOptions = fs.list(currentPath)
    for i, v in pairs(pathOptions) do
      print(i, "|", v)
    end
    print()
    print("Enter your choice.")
    local userChoice = read()
    if fs.exists(currentPath .. userChoice) then
      print("exists")
      if fs.isDir(currentPath .. userChoice) then
        print("isDir")
        currentPath = currentPath .. userChoice .. "/"
      else
        print("notDir")
        if string.find(userChoice, ".dfpwm") ~= nil then
          print("audioFound")
          isAudioFound = true
          audioPath = currentPath .. userChoice
        end
      end
    end
  end

  term.clear()
  term.setCursorPos(1, 1)
  print("Press Space")
  local keyboardReceiver = require("KeyboardReceiver")
  parallel.waitForAny(function() SpeakerControl(keyboardReceiver, speakersList, audioPath) end,
    function() keyboardReceiver:startReceiving() end)
  keyboardReceiver:stopReceiving()
end
