local isReplay = import("/lua/ui/game/gamemain.lua").GetReplayState()
local sessionInfo = SessionGetScenarioInfo()

local armiesFormattedTable

function GetSmallFactionIcon(factionIndex)
    return import('/lua/factions.lua').Factions[factionIndex + 1].SmallIcon
end

function GetArmiesFormattedTable()
    if not armiesFormattedTable then
        armiesFormattedTable = {}
        -- if isReplay then

        -- else
        local focusArmy = GetFocusArmy()
        for armyIndex, armyData in GetArmiesTable().armiesTable do
            if not armyData.civilian and armyData.showScore then
                local nickname = armyData.nickname
                local clanTag  = sessionInfo.Options.ClanTags[nickname] or ""
                local name     = nickname
                if clanTag ~= "" then
                    name = string.format("[%s] %s", clanTag, nickname)
                end
                local data = {
                    faction = armyData.faction,
                    name = name,
                    nickname = armyData.nickname,
                    color = armyData.color,
                    isAlly = not IsObserver() and IsAlly(focusArmy, armyIndex),
                    id = armyIndex,
                    rating = sessionInfo.Options.Ratings[nickname] or 0
                }
                table.insert(armiesFormattedTable, data)
            end
        end

        local teams = {}
        for _, armyData in armiesFormattedTable do
            if table.empty(teams) then
                armyData.teamColor = armyData.color
                armyData.teamId = armyData.id
                table.insert(teams, { armyData })
            else
                for _, team in teams do
                    if IsAlly(team[1].id, armyData.id) then
                        armyData.teamColor = team[1].teamColor
                        armyData.teamId = team[1].teamId
                        table.insert(team, armyData)
                        break
                    end
                end
                if not armyData.teamColor then
                    armyData.teamColor = armyData.color
                    armyData.teamId = armyData.id
                    table.insert(teams, { armyData })
                end
            end
        end
        --end
    end
    return armiesFormattedTable
end

function FormatNumber(n)
    if (math.abs(n) < 1000) then
        return string.format("%01.0f", n)
    elseif (math.abs(n) < 10000) then
        return string.format("%01.1fk", n / 1000)
    elseif (math.abs(n) < 1000000) then
        return string.format("%01.0fk", n / 1000)
    else
        return string.format("%01.1fm", n / 1000000)
    end
end