local mod = RegisterMod('Dice Shenanigans', 1)
local game = Game()

mod.handleFloorDice = false
mod.rngShiftIdx = 35

if REPENTOGON then
  mod.useIconsOnCopy = false
  mod.logToFileOnCopy = false
  
  function mod:onRender()
    mod:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
    mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
    mod:setupImGui()
  end
  
  function mod:getStringsForCmb(tbl)
    local strings = {}
    for _, v in ipairs(tbl) do
      table.insert(strings, table.concat(v, ' '))
    end
    return strings
  end
  
  function mod:removeProgressBars(progressBars)
    for i, v in ipairs(progressBars) do
      ImGui.RemoveElement(v)
      progressBars[i] = nil
    end
  end
  
  -- http://lua-users.org/wiki/SimpleRound
  function mod:round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end
  
  -- convert private chars to unicode chars
  -- for icons: prefer emoji chars if possible
  function mod:makeSafeToCopy(s, excludeStats)
    local tbl = {
      ['\u{f5b3}'] = { 'H', '\u{1f62d}' }, -- heads, loudly crying face
      ['\u{f2bd}'] = { 'H', '\u{1f642}' }, -- heads, slightly smiling face
      ['\u{f47e}'] = { 'H', '\u{1f642}' }, -- (24bd: circled latin capital letter h)
      ['\u{f0fd}'] = { 'H', '\u{1f642}' }, -- (1f137: squared latin capital letter h)
      ['\u{f111}'] = { 'T', '\u{26aa}' }, -- tails, white circle
      ['\u{f0c8}'] = { 'T', '\u{26aa}' },
      ['\u{f058}'] = { 'Y', '\u{2705}' }, -- yes, check mark button (2611: check box with check)
      ['\u{f14a}'] = { 'Y', '\u{2705}' },
      ['\u{f00c}'] = { 'Y', '\u{2714}' }, -- yes, check mark
      ['\u{f164}'] = { 'Y', '\u{1f44d}' }, -- yes, thumbs up
      ['\u{f057}'] = { 'N', '\u{274e}' }, -- no, cross mark button
      ['\u{f2d3}'] = { 'N', '\u{274e}' },
      ['\u{f00d}'] = { 'N', '\u{274c}' }, -- no, cross mark
      ['\u{f165}'] = { 'N', '\u{1f44e}' }, -- no, thumbs down
      ['\u{f0a8}'] = { 'L', '\u{2b05}' }, -- left, left arrow
      ['\u{f359}'] = { 'L', '\u{2b05}' },
      ['\u{f137}'] = { 'L', '\u{2b05}' },
      ['\u{f191}'] = { 'L', '\u{2b05}' },
      ['\u{f0d9}'] = { 'L', '\u{2b05}' },
      ['\u{f060}'] = { 'L', '\u{2b05}' },
      ['\u{f177}'] = { 'L', '\u{2b05}' },
      ['\u{f30a}'] = { 'L', '\u{2b05}' },
      ['\u{f0a5}'] = { 'L', '\u{1f448}' }, -- left, backhand index pointing left
      ['\u{f0a9}'] = { 'R', '\u{27a1}' }, -- right, right arrow
      ['\u{f35a}'] = { 'R', '\u{27a1}' },
      ['\u{f138}'] = { 'R', '\u{27a1}' },
      ['\u{f152}'] = { 'R', '\u{27a1}' },
      ['\u{f0da}'] = { 'R', '\u{27a1}' },
      ['\u{f061}'] = { 'R', '\u{27a1}' },
      ['\u{f178}'] = { 'R', '\u{27a1}' },
      ['\u{f30b}'] = { 'R', '\u{27a1}' },
      ['\u{f0a4}'] = { 'R', '\u{1f449}' }, -- right, backhand index pointing right
      ['\u{f0aa}'] = { 'U', '\u{2b06}' }, -- up, up arrow
      ['\u{f35b}'] = { 'U', '\u{2b06}' },
      ['\u{f139}'] = { 'U', '\u{2b06}' },
      ['\u{f151}'] = { 'U', '\u{2b06}' },
      ['\u{f0d8}'] = { 'U', '\u{2b06}' },
      ['\u{f062}'] = { 'U', '\u{2b06}' },
      ['\u{f176}'] = { 'U', '\u{2b06}' },
      ['\u{f30c}'] = { 'U', '\u{2b06}' },
      ['\u{f0a6}'] = { 'U', '\u{1f446}' }, -- up, backhand index pointing up
      ['\u{f0ab}'] = { 'D', '\u{2b07}' }, -- down, down arrow
      ['\u{f358}'] = { 'D', '\u{2b07}' },
      ['\u{f13a}'] = { 'D', '\u{2b07}' },
      ['\u{f150}'] = { 'D', '\u{2b07}' },
      ['\u{f0d7}'] = { 'D', '\u{2b07}' },
      ['\u{f063}'] = { 'D', '\u{2b07}' },
      ['\u{f175}'] = { 'D', '\u{2b07}' },
      ['\u{f309}'] = { 'D', '\u{2b07}' },
      ['\u{f0a7}'] = { 'D', '\u{1f447}' }, -- down, backhand index pointing down
      ['\u{f525}'] = { '1', '\u{2680}' }, -- d6, die face 1
      ['\u{f528}'] = { '2', '\u{2681}' }, -- d6, die face 2
      ['\u{f527}'] = { '3', '\u{2682}' }, -- d6, die face 3
      ['\u{f524}'] = { '4', '\u{2683}' }, -- d6, die face 4
      ['\u{f523}'] = { '5', '\u{2684}' }, -- d6, die face 5
      ['\u{f526}'] = { '6', '\u{2685}' }, -- d6, die face 6
      ['\u{f443}'] = { 'P', '\u{2659}' }, -- pawn, white chess pawn (265f: black chess pawn, only chess emoji)
      ['\u{f441}'] = { 'N', '\u{2658}' }, -- knight, white chess knight (265e: black chess knight)
      ['\u{f43a}'] = { 'B', '\u{2657}' }, -- bishop, white chess bishop (265d: black chess bishop)
      ['\u{f447}'] = { 'R', '\u{2656}' }, -- rook, white chess rook (265c: black chess rook)
      ['\u{f445}'] = { 'Q', '\u{2655}' }, -- queen, white chess queen (265b: black chess queen)
      ['\u{f43f}'] = { 'K', '\u{2654}' }, -- king, white chess king (265a: black chess king)
      ['\u{f654}'] = { 'C', '\u{271d}' }, -- christianity, latin cross
      ['\u{f647}'] = { 'C', '\u{271d}' },
      ['\u{f69a}'] = { 'J', '\u{2721}' }, -- judaism, star of david (1f54e: menorah)
      ['\u{f827}'] = { 'J', '\u{2721}' },
      ['\u{f699}'] = { 'I', '\u{262a}' }, -- islam, star and crescent
      ['\u{f687}'] = { 'I', '\u{262a}' },
      ['\u{f669}'] = { 'W', '\u{2734}' }, -- whills (jedi), eight pointed star
      ['\u{f66a}'] = { 'W', '\u{2734}' },
      ['\u{f655}'] = { 'B', '\u{2638}' }, -- buddhism, wheel of dharma
      ['\u{f67b}'] = { 'A', '\u{1f47e}' }, -- atheism, alien monster (1f35d: spaghetti, 269b: atom)
    }
    
    if excludeStats then
      for v in string.gmatch(s, '[^\n]+') do
        s = v
        break
      end
    end
    
    for k, v in pairs(tbl) do
      s = string.gsub(s, k, v[mod.useIconsOnCopy and 2 or 1])
    end
    
    if mod.logToFileOnCopy then
      Isaac.DebugString(s)
    end
    
    return s
  end
  
  function mod:setupImGui()
    if not ImGui.ElementExists('shenanigansMenu') then
      ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
    end
    ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItemDice', ImGuiElement.MenuItem, '\u{f522} Dice Shenanigans')
    ImGui.CreateWindow('shenanigansWindowDice', 'Dice Shenanigans')
    ImGui.LinkWindowToElement('shenanigansWindowDice', 'shenanigansMenuItemDice')
    
    ImGui.AddTabBar('shenanigansWindowDice', 'shenanigansTabBarDice')
    ImGui.AddTab('shenanigansTabBarDice', 'shenanigansTabDiceCoinFlip', '\u{f5b3}')
    ImGui.AddTab('shenanigansTabBarDice', 'shenanigansTabDiceDirection', '\u{f047}')
    ImGui.AddTab('shenanigansTabBarDice', 'shenanigansTabDiceD6', '\u{f522}')
    ImGui.AddTab('shenanigansTabBarDice', 'shenanigansTabDiceAdvanced', '\u{f6cf}')
    ImGui.AddTab('shenanigansTabBarDice', 'shenanigansTabDiceSettings', '\u{f085}')
    
    local coinFlipStyles = {
      { '\u{f5b3}', '\u{f111}' }, -- cry face / circle
      { '\u{f2bd}', '\u{f111}' }, -- circle user / circle
      { '\u{f47e}', '\u{f111}' }, -- circle h / circle (circle t isn't available in the free font pack)
      { '\u{f0fd}', '\u{f0c8}' }, -- square h / square
      { 'H', 'T' },
      { '\u{f058}', '\u{f057}' }, -- circle check / xmark
      { '\u{f14a}', '\u{f2d3}' }, -- square check / xmark
      { '\u{f00c}', '\u{f00d}' }, -- check / xmark
      { '\u{f164}', '\u{f165}' }, -- thumbs up / down
      { 'Y', 'N' },
      { '\u{f654}', '\u{f67b}' }, -- cross / flying spaghetti monster
    }
    mod:doBasicTab(coinFlipStyles, 'shenanigansTabDiceCoinFlip', 'shenanigansCmbDiceCoinFlipStyle', 'shenanigansIntDiceCoinFlipNum', 'Num coin flips', 'shenanigansBtnDiceCoinFlip', 'Flip Coin', 'shenanigansBtnDiceCoinFlipCopy', 'shenanigansBtnDiceCoinFlipClear', 'shenanigansTxtDiceCoinFlipResults', 'shenanigansTreeNodeDiceCoinFlipStats', 'shenanigansProgDiceCoinFlipStat')
    
    -- only 2 of the 4 card suits are available in the free font pack
    local directionStyles = {
      { '\u{f0a8}', '\u{f0a9}', '\u{f0aa}', '\u{f0ab}' }, -- circle arrows
      { '\u{f359}', '\u{f35a}', '\u{f35b}', '\u{f358}' }, -- circle directions
      { '\u{f137}', '\u{f138}', '\u{f139}', '\u{f13a}' }, -- circle chevrons
      { '\u{f191}', '\u{f152}', '\u{f151}', '\u{f150}' }, -- square carets
      { '\u{f0d9}', '\u{f0da}', '\u{f0d8}', '\u{f0d7}' }, -- carets
      { '\u{f060}', '\u{f061}', '\u{f062}', '\u{f063}' }, -- arrows
      { '\u{f177}', '\u{f178}', '\u{f176}', '\u{f175}' }, -- long arrows
      { '\u{f30a}', '\u{f30b}', '\u{f30c}', '\u{f309}' }, -- directions
      { '\u{f0a5}', '\u{f0a4}', '\u{f0a6}', '\u{f0a7}' }, -- hand pointing
      { 'L', 'R', 'U', 'D' },
      { '\u{f647}', '\u{f827}', '\u{f687}', '\u{f66a}' }, -- bible / tanakh / quran / journal of the whills
    }
    mod:doBasicTab(directionStyles, 'shenanigansTabDiceDirection', 'shenanigansCmbDiceDirectionStyle', 'shenanigansIntDiceDirectionNum', 'Num directions', 'shenanigansBtnDiceDirection', 'Get Direction', 'shenanigansBtnDiceDirectionCopy', 'shenanigansBtnDiceDirectionClear', 'shenanigansTxtDiceDirectionResults', 'shenanigansTreeNodeDiceDirectionStats', 'shenanigansProgDiceDirectionStat')
    
    local d6Styles = {
      { '\u{f525}', '\u{f528}', '\u{f527}', '\u{f524}', '\u{f523}', '\u{f526}' }, -- d6
      { '1', '2', '3', '4', '5', '6' },
      { '\u{f443}', '\u{f441}', '\u{f43a}', '\u{f447}', '\u{f445}', '\u{f43f}' }, -- chess
      { '\u{f654}', '\u{f69a}', '\u{f699}', '\u{f655}', '\u{f669}', '\u{f67b}' }, -- christianity / judaism / islam / buddhism / jedi / atheism
    }
    mod:doBasicTab(d6Styles, 'shenanigansTabDiceD6', 'shenanigansCmbDiceD6Style', 'shenanigansIntDiceD6Num', 'Num rolls', 'shenanigansBtnDiceD6', 'Roll D6', 'shenanigansBtnDiceD6Copy', 'shenanigansBtnDiceD6Clear', 'shenanigansTxtDiceD6Results', 'shenanigansTreeNodeDiceD6Stats', 'shenanigansProgDiceD6Stat')
    
    mod:doAdvancedTab('shenanigansTabDiceAdvanced', 'shenanigansCmbDiceAdvancedStartAt', 'shenanigansIntDiceAdvancedSides', 'shenanigansIntDiceAdvancedNum', 'shenanigansBtnDiceAdvanced', 'shenanigansBtnDiceAdvancedCopy', 'shenanigansBtnDiceAdvancedClear', 'shenanigansTxtDiceAdvancedResults', 'shenanigansTreeNodeDiceAdvancedStats', 'shenanigansProgDiceAdvancedStat')
    
    mod:doSettingsTab('shenanigansTabDiceSettings', 'shenanigansCmbDiceSettingsCopy', 'shenanigansCmbDiceSettingsLog', 'shenanigansPlotDiceSettingsRand', 'shenanigansBtnDiceSettingsCopy')
  end
  
  function mod:doBasicTab(styles, tab, cmbStyleId, intNumId, intNumLabel, btnId, btnLabel, btnCopyId, btnClearId, txtResultsId, treeStatsId, progStatIdPrefix)
    local style = 1
    local num = 1
    local results = ''
    local statsVisible = false
    local progressBars = {}
    
    ImGui.AddCombobox(tab, cmbStyleId, 'Style', function(i)
      style = i + 1
    end, mod:getStringsForCmb(styles), style - 1, true)
    ImGui.AddSliderInteger(tab, intNumId, intNumLabel, function(i)
      num = i
    end, num, 1, 100)
    ImGui.AddButton(tab, btnId, btnLabel, function()
      local rand = Random()
      local rng = RNG(rand <= 0 and 1 or rand, mod.rngShiftIdx)
      local tempResults = {}
      local tempStats = {}
      local statMax = 0
      local statSum = 0
      
      for i = 1, num do
        local tempResult = styles[style][rng:RandomInt(#styles[style]) + 1]
        table.insert(tempResults, tempResult)
        
        if tempStats[tempResult] then
          tempStats[tempResult] = tempStats[tempResult] + 1
        else
          tempStats[tempResult] = 1
        end
      end
      
      results = table.concat(tempResults, ' ')
      ImGui.UpdateText(txtResultsId, results)
      results = results .. '\n'
      
      for _, v in ipairs(styles[style]) do
        if tempStats[v] then
          if tempStats[v] > statMax then
            statMax = tempStats[v]
          end
          statSum = statSum + tempStats[v]
        end
      end
      
      mod:removeProgressBars(progressBars)
      for i, v in ipairs(styles[style]) do
        local stat = tempStats[v] or 0
        local percent = stat / statSum * 100
        local progStatId = progStatIdPrefix .. i
        
        results = results .. '\n' .. string.format('%s x%d (%.2f%%)', v, stat, percent)
        ImGui.AddProgressBar(treeStatsId, progStatId, v, stat / statMax, string.format('x%d (%.2f%%)', stat, percent))
        table.insert(progressBars, progStatId)
      end
    end, false)
    ImGui.AddElement(tab, '', ImGuiElement.SameLine, '')
    ImGui.AddButton(tab, btnCopyId, 'Copy', function()
      if results and results ~= '' then
        if Isaac.SetClipboard(mod:makeSafeToCopy(results, not statsVisible)) then
          ImGui.PushNotification('Copied results to clipboard', ImGuiNotificationType.INFO, 5000)
        end
      end
    end, false)
    ImGui.AddElement(tab, '', ImGuiElement.SameLine, '')
    ImGui.AddButton(tab, btnClearId, 'Clear', function()
      results = ''
      ImGui.UpdateText(txtResultsId, results)
      mod:removeProgressBars(progressBars)
    end, false)
    if tab == 'shenanigansTabDiceD6' then
      ImGui.AddElement(tab, '', ImGuiElement.SameLine, '')
      ImGui.AddButton(tab, btnId .. 'Floor', '\u{f11b}', function()
        if Isaac.IsInGame() then
          local rand = Random()
          local roomConfig = RoomConfigHolder.GetRandomRoom(rand <= 0 and 1 or rand, false, StbType.SPECIAL_ROOMS, RoomType.ROOM_DICE, RoomShape.ROOMSHAPE_1x1, 0, -1, 0, 10, 0, -1, -1)
          if roomConfig then
            if Isaac.ExecuteCommand('goto s.dice.' .. roomConfig.Variant) == 'Changed room.' then
              mod.handleFloorDice = true
              ImGui.Hide()
            else
              ImGui.PushNotification('Unable to move to dice room', ImGuiNotificationType.ERROR, 5000)
            end
          else
            ImGui.PushNotification('No dice rooms found in the current game mode', ImGuiNotificationType.ERROR, 5000)
          end
        else
          ImGui.PushNotification('Start a run to access dice rooms', ImGuiNotificationType.ERROR, 5000)
        end
      end, false)
      ImGui.SetTooltip(btnId .. 'Floor', 'Roll floor dice (must be in a run)')
    end
    ImGui.AddText(tab, '', true, txtResultsId)
    ImGui.AddElement(tab, treeStatsId, ImGuiElement.TreeNode, 'Stats')
    ImGui.AddCallback(treeStatsId, ImGuiCallback.Render, function() -- ToggledOpen exists, but there's no ToggledClose
      statsVisible = false
    end)
    ImGui.AddCallback(treeStatsId, ImGuiCallback.Visible, function() -- edge case: shrink the window so the stats are off-screen
      statsVisible = true
    end)
  end
  
  function mod:doAdvancedTab(tab, cmbStartAtId, intSidesId, intNumId, btnId, btnCopyId, btnClearId, txtResultsId, treeStatsId, progStatIdPrefix)
    local startAtZero = false
    local sides = 20
    local num = 1
    local results = ''
    local statsVisible = false
    local progressBars = {}
    
    ImGui.AddCombobox(tab, cmbStartAtId, '', function(i)
      startAtZero = i == 0
    end, { 'Start at 0', 'Start at 1' }, startAtZero and 0 or 1, true)
    ImGui.AddSliderInteger(tab, intSidesId, 'Sides (D' .. sides .. ')', nil, sides, 1, 100) -- D100
    ImGui.AddCallback(intSidesId, ImGuiCallback.DeactivatedAfterEdit, function(i) -- Edited
      sides = i
      ImGui.UpdateData(intSidesId, ImGuiData.Label, 'Sides (D' .. sides .. ')')
    end)
    ImGui.AddSliderInteger(tab, intNumId, 'Num rolls', function(i)
      num = i
    end, num, 1, 100)
    ImGui.AddButton(tab, btnId, 'Roll Dice', function()
      local rand = Random()
      local rng = RNG(rand <= 0 and 1 or rand, mod.rngShiftIdx)
      local tempResults = {}
      local tempStats = {}
      local statMax = 0
      local statSum = 0
      
      for i = 1, num do
        local tempResult = rng:RandomInt(sides) + (startAtZero and 0 or 1)
        table.insert(tempResults, tempResult)
        
        if tempStats[tempResult] then
          tempStats[tempResult] = tempStats[tempResult] + 1
        else
          tempStats[tempResult] = 1
        end
      end
      
      results = table.concat(tempResults, ' ')
      ImGui.UpdateText(txtResultsId, results)
      results = results .. '\n'
      
      for i = startAtZero and 0 or 1, startAtZero and sides - 1 or sides do
        if tempStats[i] then
          if tempStats[i] > statMax then
            statMax = tempStats[i]
          end
          statSum = statSum + tempStats[i]
        end
      end
      
      mod:removeProgressBars(progressBars)
      for i = startAtZero and 0 or 1, startAtZero and sides - 1 or sides do
        local stat = tempStats[i] or 0
        local percent = stat / statSum * 100
        local progStatId = progStatIdPrefix .. i
        
        results = results .. '\n' .. string.format('%d x%d (%.2f%%)', i, stat, percent)
        ImGui.AddProgressBar(treeStatsId, progStatId, i, stat / statMax, string.format('x%d (%.2f%%)', stat, percent))
        table.insert(progressBars, progStatId)
      end
    end, false)
    ImGui.AddElement(tab, '', ImGuiElement.SameLine, '')
    ImGui.AddButton(tab, btnCopyId, 'Copy', function()
      if results and results ~= '' then
        if Isaac.SetClipboard(mod:makeSafeToCopy(results, not statsVisible)) then
          ImGui.PushNotification('Copied results to clipboard', ImGuiNotificationType.INFO, 5000)
        end
      end
    end, false)
    ImGui.AddElement(tab, '', ImGuiElement.SameLine, '')
    ImGui.AddButton(tab, btnClearId, 'Clear', function()
      results = ''
      ImGui.UpdateText(txtResultsId, results)
      mod:removeProgressBars(progressBars)
    end, false)
    ImGui.AddText(tab, '', true, txtResultsId)
    ImGui.AddElement(tab, treeStatsId, ImGuiElement.TreeNode, 'Stats')
    ImGui.AddCallback(treeStatsId, ImGuiCallback.Render, function()
      statsVisible = false
    end)
    ImGui.AddCallback(treeStatsId, ImGuiCallback.Visible, function()
      statsVisible = true
    end)
  end
  
  function mod:doSettingsTab(tab, cmbCopyId, cmbLogId, plotRandId, btnCopyId)
    ImGui.AddCombobox(tab, cmbCopyId, 'Copy', function(i)
      mod.useIconsOnCopy = i == 1
    end, { 'Simple', 'Icons' }, mod.useIconsOnCopy and 1 or 0, true)
    ImGui.SetHelpmarker(cmbCopyId, 'On copy: simple will use ascii characters that are supported everywhere, icons will use unicode characters that require utf-8 and font support')
    ImGui.AddCombobox(tab, cmbLogId, 'Log', function(i)
      mod.logToFileOnCopy = i == 1
    end, { 'Off', 'On' }, mod.logToFileOnCopy and 1 or 0, true)
    ImGui.SetHelpmarker(cmbLogId, 'On copy: also log to file')
    
    local isDecimal = false
    local isPaused = false
    local rand = Random()
    local rng = RNG(rand <= 0 and 1 or rand, mod.rngShiftIdx)
    local randomVals = {}
    for i = 1, 100 do
      -- the plot control rounds to 4 digits, keep it consistent
      table.insert(randomVals, isDecimal and mod:round(rng:RandomFloat(), 4) or (rng:RandomFloat() < 0.5 and 0 or 1))
    end
    ImGui.AddPlotLines(tab, plotRandId, isDecimal and 'Decimal' or 'Binary', randomVals, '', 0, 1, nil) -- 40
    ImGui.AddCallback(plotRandId, ImGuiCallback.Clicked, function()
      isDecimal = not isDecimal
      ImGui.UpdateData(plotRandId, ImGuiData.Label, isDecimal and 'Decimal' or 'Binary')
    end)
    ImGui.AddCallback(plotRandId, ImGuiCallback.Render, function()
      isPaused = false
    end)
    ImGui.AddCallback(plotRandId, ImGuiCallback.Hovered, function()
      isPaused = true
    end)
    ImGui.AddCallback(plotRandId, ImGuiCallback.Visible, function()
      if not isPaused then -- Isaac.GetFrameCount() % 2 == 0
        table.remove(randomVals, 1)
        table.insert(randomVals, isDecimal and mod:round(rng:RandomFloat(), 4) or (rng:RandomFloat() < 0.5 and 0 or 1))
        ImGui.UpdateData(plotRandId, ImGuiData.ListValues, randomVals)
      end
    end)
    ImGui.SetHelpmarker(plotRandId, 'On click: binary <-> decimal\nOn hover: pause scroll')
    ImGui.AddElement(tab, '', ImGuiElement.SameLine, '')
    ImGui.AddButton(tab, btnCopyId, '\u{f0c5}', function()
      if Isaac.SetClipboard(mod:makeSafeToCopy(table.concat(randomVals, ' '))) then
        ImGui.PushNotification('Copied results to clipboard', ImGuiNotificationType.INFO, 5000)
      end
    end, false)
    ImGui.SetTooltip(btnCopyId, 'Copy')
  end
  
  mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
  
  Console.RegisterCommand('dice-shenanigans', 'Wrapper for goto, use with s.dice', 'Wrapper for goto, use with s.dice', false, AutocompleteType.GOTO)
end

function mod:onGameExit()
  mod.handleFloorDice = false
end

function mod:onPreSpawnAward()
  local level = game:GetLevel()
  local room = level:GetCurrentRoom()
  local roomDesc = level:GetCurrentRoomDesc()
  
  if room:GetType() == RoomType.ROOM_DICE and roomDesc.GridIndex == GridRooms.ROOM_DEBUG_IDX then
    for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DICE_FLOOR, -1, false, false)) do
      if v.SubType >= 1000 and v.SubType <= 1005 then
        return true -- stop spawn after removing entities that can shut doors
      end
    end
  end
end

-- filtered to DICE_FLOOR
function mod:onEffectUpdate(effect)
  local level = game:GetLevel()
  local room = level:GetCurrentRoom()
  local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex(), -1) -- read/write
  
  if room:GetType() == RoomType.ROOM_DICE and roomDesc.GridIndex == GridRooms.ROOM_DEBUG_IDX then
    if mod.handleFloorDice then
      if effect.SubType >= 0 and effect.SubType <= 5 then
        effect.SubType = effect.SubType + 1000 -- arbitrary addition so the game doesn't trigger the normal effect
        mod:hideInfoFromSprite(effect:GetSprite())
        mod:removeEntitiesFromRoom()
      end
    elseif effect.SubType >= 1000 and effect.SubType <= 1005 then
      if game:GetScreenShakeCountdown() > 0 then -- GetDarknessModifier
        if game:GetScreenShakeCountdown() % 4 == 0 then -- effect.FrameCount
          local rand = Random()
          local rng = RNG()
          rng:SetSeed(rand <= 0 and 1 or rand, mod.rngShiftIdx)
          local subType = rng:RandomInt(6) -- 0-5
          local sprite = effect:GetSprite()
          effect.SubType = subType + 1000
          sprite:Play(tostring(subType + 1), true)
          mod:hideInfoFromSprite(sprite)
        end
      elseif roomDesc.Flags & RoomDescriptor.FLAG_SACRIFICE_DONE == RoomDescriptor.FLAG_SACRIFICE_DONE and
             #Isaac.FindInRadius(room:GetCenterPos(), 100, EntityPartition.PLAYER) <= 0 -- or touching grid idx: 36-38, 51-53, 66-68, 81-83
      then
        roomDesc.Flags = roomDesc.Flags & ~RoomDescriptor.FLAG_SACRIFICE_DONE -- allow the dice to be rolled again
      end
    end
  end
  
  mod.handleFloorDice = false
end

-- usage: dice-shenanigans s.dice
-- usage: dice-shenanigans s.dice.0
function mod:onExecuteCmd(cmd, parameters)
  cmd = string.lower(cmd)
  
  if cmd == 'dice-shenanigans' then
    local output = Isaac.ExecuteCommand('goto ' .. parameters)
    if output == 'Changed room.' then
      local paramPrefix = string.sub(parameters, 1, 6)
      if paramPrefix == 's.dice' or paramPrefix == 'x.dice' then
        mod.handleFloorDice = true
      end
    end
    print(output)
  end
end

function mod:hideInfoFromSprite(sprite)
  if REPENTOGON then
    for _, v in ipairs({ 'Info', 'Info2', 'Info3' }) do
      local layer = sprite:GetLayer(v)
      if layer then
        layer:SetVisible(false)
      end
    end
  end
end

function mod:removeEntitiesFromRoom()
  for _, v in ipairs(Isaac.GetRoomEntities()) do
    if v.Type == EntityType.ENTITY_PICKUP or v:CanShutDoors() then -- IsEnemy
      v:Remove()
    end
  end
end

function mod:setupEid()
  EID:addDescriptionModifier(mod.Name, function(descObj)
    local level = game:GetLevel()
    local room = level:GetCurrentRoom()
    local roomDesc = level:GetCurrentRoomDesc()
    return room:GetType() == RoomType.ROOM_DICE and roomDesc.GridIndex == GridRooms.ROOM_DEBUG_IDX and
           descObj.ObjType == EntityType.ENTITY_EFFECT and descObj.ObjVariant == EffectVariant.DICE_FLOOR and
           descObj.ObjSubType >= 1001 and descObj.ObjSubType <= 1006 -- +1
  end, function(descObj)
    descObj = EID:getDescriptionObj(descObj.ObjType, descObj.ObjVariant, descObj.ObjSubType - 1000, descObj.Entity)
    descObj.Description = '#No floor effect'
    return descObj
  end)
end

-- start ModConfigMenu --
function mod:setupModConfigMenu()
  local startAtZero = false
  local sides = 20
  local num = 1
  local results = { '', '', '', '', '' }
  for _, v in ipairs({ 'Dice', 'Floor' }) do
    ModConfigMenu.RemoveSubcategory(mod.Name, v)
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'Dice',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return startAtZero
      end,
      Display = function()
        return 'Start at: ' .. (startAtZero and 0 or 1)
      end,
      OnChange = function(b)
        startAtZero = b
      end,
      Info = { 'Start at 0 or 1' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Dice',
    {
      Type = ModConfigMenu.OptionType.NUMBER,
      CurrentSetting = function()
        return sides
      end,
      Minimum = 1,
      Maximum = 100,
      Display = function()
        return 'Sides: ' .. sides
      end,
      OnChange = function(n)
        sides = n
      end,
      Info = { 'D1 - D100' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Dice',
    {
      Type = ModConfigMenu.OptionType.NUMBER,
      CurrentSetting = function()
        return num
      end,
      Minimum = 1,
      Maximum = 50,
      Display = function()
        return 'Num rolls: ' .. num
      end,
      OnChange = function(n)
        num = n
      end,
      Info = { '1 - 50' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Dice',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Roll Dice'
      end,
      OnChange = function(b)
        local rand = Random()
        local rng = RNG()
        rng:SetSeed(rand <= 0 and 1 or rand, mod.rngShiftIdx)
        local tempResults = {}
        
        for i = 1, num do
          table.insert(tempResults, rng:RandomInt(sides) + (startAtZero and 0 or 1))
        end
        
        -- this doesn't word-wrap
        local perRow = 10
        for i = 1, 5 do
          local maxNum = i * perRow
          results[i] = table.concat({ table.unpack(tempResults, maxNum - (perRow - 1), maxNum) }, ' ')
        end
      end,
      Info = { ':)' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Dice',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Clear'
      end,
      OnChange = function(b)
        for i = 1, 5 do
          results[i] = ''
        end
      end,
      Info = { ':)' }
    }
  )
  for i = 1, 5 do
    ModConfigMenu.AddText(mod.Name, 'Dice', function()
      return results[i]
    end)
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'Floor',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Roll floor dice'
      end,
      OnChange = function(b)
        if REPENTOGON then
          local rand = Random()
          local roomConfig = RoomConfigHolder.GetRandomRoom(rand <= 0 and 1 or rand, false, StbType.SPECIAL_ROOMS, RoomType.ROOM_DICE, RoomShape.ROOMSHAPE_1x1, 0, -1, 0, 10, 0, -1, -1)
          if roomConfig then
            if Isaac.ExecuteCommand('goto s.dice.' .. roomConfig.Variant) == 'Changed room.' then
              mod.handleFloorDice = true
              ModConfigMenu.CloseConfigMenu()
            end
          end
        else -- this mod adds a dice room to greed mode
          if Isaac.ExecuteCommand('goto s.dice') == 'Changed room.' then
            mod.handleFloorDice = true
            ModConfigMenu.CloseConfigMenu()
          end
        end
      end,
      Info = { ':)' }
    }
  )
end
-- end ModConfigMenu --

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onGameExit)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.onPreSpawnAward)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onEffectUpdate, EffectVariant.DICE_FLOOR)
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onExecuteCmd)

if EID then
  mod:setupEid()
end
if ModConfigMenu then
  mod:setupModConfigMenu()
end