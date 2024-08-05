local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitor = peripheral.find("monitor")
monitor.scale = 10
monitor.setCursorPos(1,1)
monitor.write("KOLONOCHKA EBASHIT")


local decoder = dfpwm.make_decoder()
for chunk in io.lines("music/Kunteynir_NePretJazz", 16 * 1024) do
    local buffer = decoder(chunk)

    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end
