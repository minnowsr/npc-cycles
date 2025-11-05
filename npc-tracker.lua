--------------------------------------
-- NPC cycle tracking for DPPt/HGSS/BW1/BW2 --
-- Version 0.4
-- Author: minnowsr (github.com/minnowsr/npc-cycles)
-- Updated: 11/5/2025
--------------------------------------


-- Press 6 to switch between GUi display modes
-- Press 7 to reset null tracking

local NPC_MAX = 100

local state = 0

local zero_cycles = {}
local previous_cycles = {}

local extra_address = 0

local framecount = emu.framecount()

function reset_cycles()
    for i=0, NPC_MAX, 1 do
        zero_cycles[i] = 0
        previous_cycles[i] = 0
    end
end

function main() 
    game = memory.readdword(0x23FFE0C)
    offset = 0

    if game == 0x45475049 or game == 0x454B5049 then -- hgss
        pointer = memory.readdword(0x0211186C)
        offset = 0x33092
        spacing = 300
    elseif game == 0x45555043 then -- platinum
        pointer = memory.readdword(0x02101D2C)
        offset = 0x30A5E
        spacing = 296
    elseif game == 0x45415041 or game == 0x45414441 then -- dp
        pointer = memory.readdword(0x02106FAC)
        offset = 0x31C36
        spacing = 296
    
    else
        game = memory.readbyte(0x02FFFE0E) -- gen 5
        if game == 0x44 or game == 0x45 then -- bw2
            pointer = 0x223C37A 
            spacing = 0x100
			extra_address = 0x0223E585
        elseif game == 0x41 or game == 0x42 then -- bw1
            pointer = 0x225227A
            spacing = 0x100
        else
            print("invalid game")
            return -1
        end
    end

    input_table = input.get()
    if input_table["6"] and not prev_table["6"] then
        state = state + 1
        if state > 2 then
            state = 0
        end
    end

    if input_table["7"] and not prev_table["7"] then
        reset_cycles()
    end
    prev_table = input_table

    if state == 2 then
        return 0
    end
   
    active_npcs = 0
    for i = 0, NPC_MAX-1, 1 do
        cycle_addr = pointer + offset + spacing * i
		
		tick = memory.readword(cycle_addr)

		-- Village Bridge backpacker hotfix. readbyte is intentional.
		if i == NPC_MAX-1 and extra_address ~= 0 then
			cycle_addr = extra_address 
			tick = memory.readbyte(cycle_addr)
		end

        if emu.framecount() ~= framecount then
            if tick == previous_cycles[i] or tick >= 63 then
               zero_cycles[i] = zero_cycles[i] + 1
            else
                zero_cycles[i] = 0 
            end
        end

        if zero_cycles[i] <= 80 then
            -- don't print null memory
            if state == 1 then
                gui.text(110, active_npcs * 10, "NPC " .. (active_npcs + 1) .. ": " .. tick, "#FFFF00A0")
            else
                gui.text(110, active_npcs * 10, "NPC " .. (active_npcs + 1) .. ": " .. tick .. "\t(" .. bit.tohex(cycle_addr) .. ")", "#FFFF00A0")
            end
            active_npcs = active_npcs + 1
        end
        previous_cycles[i] = tick
    end
    framecount = emu.framecount()

end

reset_cycles()
gui.register(main)

