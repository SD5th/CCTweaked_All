local KeyboardReceiver = {queueHead = 0, queueTail = -1, currentlyPressed = {}, currentlyHeld = {}, isOn = false}

function KeyboardReceiver:addKeysCombination(keysCombination)
    local newQueueTail = self.queueTail + 1
    self.queueTail = newQueueTail
    self[newQueueTail] = keysCombination
end

function KeyboardReceiver:getKeysCombination()
    if self.queueHead > self.queueTail then return {} end
    local prevQueueHead = self.queueHead
    self.queueHead = prevQueueHead + 1
    local key = self[prevQueueHead]
    self[prevQueueHead] = nil        -- to allow garbage collection
    return key
end

function KeyboardReceiver:startReceiving()
    self.isOn = true
    while self.isOn do
        local eventName, eventKey, eventIsHeld = os.pullEvent()
        if eventName == "key" then
            if eventIsHeld then
                self.currentlyHeld[eventKey] = true
            else
                self.currentlyPressed[eventKey] = true
            end
        elseif eventName == "key_up" then
            self.currentlyHeld[eventKey] = nil
            self.currentlyPressed[eventKey] = nil
            local keysCombination = {}
            local i = 1
            for key, _ in pairs(self.currentlyPressed) do
                keysCombination[i] = key
                i = i + 1
            end
            keysCombination[i] = eventKey
            self:addKeysCombination(keysCombination)
        end
    end
end

function KeyboardReceiver:stopReceiving()
    self.isOn = false
end

function KeyboardReceiver:isSomethingPressed()
    if self.queueHead <= self.queueTail then
        return true
    end
    return false
end

function KeyboardReceiver:isSomethingHeld()
    local amountOfKeysCurrentlyHeld = 0
    for _, _ in pairs (self.currentlyHeld) do
        amountOfKeysCurrentlyHeld = amountOfKeysCurrentlyHeld + 1
    end
    if amountOfKeysCurrentlyHeld == 0 then
        return false
    end
    return true
end

function KeyboardReceiver:isKeysHeld(keys)
    for _, key in pairs(keys) do
        if self.currentlyHeld[key] then
            return true
        end
    end
    return false 
end

return KeyboardReceiver