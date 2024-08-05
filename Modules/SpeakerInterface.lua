local SpeakersInterface = { speakersList = {}, audio = nil, chunkSize = 6000, volume = 1.0 }


function SpeakersInterface:setSpeakersList(newSpeakersList)
	self.speakersList = newSpeakersList
end

function SpeakersInterface:setAudio(audioPath)
	if self.audio ~= nil then
		self.audio:close()
	end
	self.audio = assert(io.open(audioPath), "No such audiofile")
end

function SpeakersInterface:setChunkSize(newChunkSize)
	self.chunkSize = newChunkSize
end


function SpeakersInterface:playTestSample(volume)
	for _, speaker in pairs(self.speakersList) do
		speaker.playNote("cow_bell", volume * 3 / 32)
	end
end

function SpeakersInterface:getLastChunkNum()
	local lastChunkNum = -1
	if self.audio == nil then
		return lastChunkNum
	else
		local endOfAudio = self.audio:seek("end")
		while endOfAudio > 0 do
			lastChunkNum = lastChunkNum + 1
			endOfAudio = endOfAudio - self.chunkSize
		end
		return lastChunkNum
	end
end

function SpeakersInterface:playChunk(chunkNum, volume)
	local decoder = require("cc.audio.dfpwm").make_decoder()
	self.audio:seek("set", chunkNum * self.chunkSize)
	local chunk = self.audio:read(self.chunkSize)
	for _, speaker in pairs(self.speakersList) do
		speaker.playAudio(decoder(chunk), volume)
	end
	local timerID = os.startTimer(1.15)
	parallel.waitForAny(function()
			for _, _ in pairs(self.speakersList) do
				os.pullEvent("speaker_audio_empty")
			end
		end,

		function()
			repeat
				local _, eventID = os.pullEvent("timer")
			until eventID == timerID
		end)
	os.queueEvent("chunk_is_played")
end

function SpeakersInterface:stopSpeakers()
	for _, speaker in pairs(self.speakersList) do
		speaker.stop()
	end
end

return SpeakersInterface
