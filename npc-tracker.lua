--------------------------------------
-- NPC cycle tracking for DPPt/HGSS --
-- Version 0.1
-- Author: minnowsr (github.com/minnowsr/npc-cycles)
-- Updated: 10/24/2023
--------------------------------------

-- Press 6 to switch between GUi display modes
-- Press 7 to reset null tracking

-- Sets the number of NPCs addresses to search for. Keep this number above 20.
local NPC_MAX = 30 

local state = 0

local zero_cycles = {}

function reset_cycles()
    for i=0, NPC_MAX, 1 do
        zero_cycles[i] = 0
    end
end

function main() 
    game = memory.readdword(0x23FFE0C)

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
        print("invalid game")
        return -1
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

        if tick == 0 or tick >= 63 then
            zero_cycles[i] = zero_cycles[i] + 1
        else
            zero_cycles[i] = 0 
        end

        if zero_cycles[i] <= 30 then
            -- don't print null memory
            if state == 1 then
                gui.text(110, active_npcs * 10, "NPC " .. (active_npcs + 1) .. ": " .. tick, "#FFFF00A0")
            else
                gui.text(110, active_npcs * 10, "NPC " .. (active_npcs + 1) .. ": " .. tick .. "\t(" .. bit.tohex(cycle_addr) .. ")", "#FFFF00A0")
            end
            active_npcs = active_npcs + 1
        end
    end

end

reset_cycles()
gui.register(main)
