--[[
██████╗ ██╗ ██╗ ███████╗██╗██╗ ██╗██████╗ ███████╗███╗ ██╗███╗ ██╗██╗ ██╗ ███████╗ ██████╗ ██╗ ██╗██╗ ██╗
██╔══██╗╚██╗ ██╔╝ ██╔════╝██║╚██╗██╔╝██╔══██╗██╔════╝████╗ ██║████╗ ██║╚██╗ ██╔╝ ██╔════╝██╔═══██╗╚██╗██╔╝██║ ██║
██████╔╝ ╚████╔╝ ███████╗██║ ╚███╔╝ ██████╔╝█████╗ ██╔██╗ ██║██╔██╗ ██║ ╚████╔╝ █████╗ ██║ ██║ ╚███╔╝ ███████║
██╔══██╗ ╚██╔╝ ╚════██║██║ ██╔██╗ ██╔═══╝ ██╔══╝ ██║╚██╗██║██║╚██╗██║ ╚██╔╝ ██╔══╝ ██║ ██║ ██╔██╗ ╚════██║
██████╔╝ ██║ ███████║██║██╔╝ ██╗██║ ███████╗██║ ╚████║██║ ╚████║ ██║███████╗██║ ╚██████╔╝██╔╝ ██╗ ██║
╚═════╝ ╚═╝ ╚══════╝╚═╝╚═╝ ╚═╝╚═╝ ╚══════╝╚═╝ ╚═══╝╚═╝ ╚═══╝ ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝ ╚═╝ ╚═╝
]]

local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VU = game:GetService("VirtualUser")
local Players = game:GetService("Players")

local LocalPLR = Players.LocalPlayer
Username = getgenv().Username or LocalPLR.Name

local runScript = true
local copychat = false
local copychatUsername = ""

if getgenv().cbzloaded == true then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Already Running",
        Text = "ControlBotZ is already running!",
        Time = 6
    })
    return
end
getgenv().cbzloaded = true

-- ──────────────────────────────────────────────────────────────
--  Safe character access – prevents most nil index errors
-- ──────────────────────────────────────────────────────────────
local characterConnections = {}  -- to clean up on death

local function safeGetCharacter()
    local char = LocalPLR.Character
    if not char then return nil end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return nil end
    return char, hum, root
end

local function disconnectAllOnDeath()
    for _, conn in ipairs(characterConnections) do
        pcall(function() conn:Disconnect() end)
    end
    characterConnections = {}
end

-- Clean up old connections when character dies / respawns
LocalPLR.CharacterRemoving:Connect(disconnectAllOnDeath)

if LocalPLR.Name ~= Username then
    local logChat = getgenv().logChat
    webhook = getgenv().webhook
    Prefix = getgenv().Prefix or "."
    local bots = getgenv().Bots or {}
    local whitelist = {}
    local admins = {}
    local index

    local function getIndex()
        for i, bot in ipairs(bots) do
            if LocalPLR.DisplayName == bot or LocalPLR.Name == bot then
                index = i
                break
            end
        end
    end
    getIndex()

    local function chat(msg)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then channel:SendAsync(msg) end
        else
            pcall(function()
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
    end

    chat("ControlBotZ Running!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Thank You",
        Text = "thank you for using ControlBotZ!",
        Time = 6
    })

    local latestVersion = request({
        Url = "https://raw.githubusercontent.com/ssedsaaes-design/ControlBot/refs/heads/main/ControlBotZ%20Version",
        Method = "GET"
    }).Body:match("^%s*(.-)%s*$") or "unknown"

    if latestVersion ~= "1.1.4" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Old Version!",
            Text = "Get the newest version from discord!",
            Time = 8
        })
    end

    -- (keep showDefaultGui, sendToWebhook, specifyBots, specifyBots2, getArgs, isR15, isWhitelisted, isAdmin as before)

    local normalGravity = 196.2

    local function commands(player, message)
        local msg = message:lower()
        if not isWhitelisted(player.Name) then return end

        local function getFullPlayerName(typedName)
            if typedName == "me" then return player.Name end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name:lower():find(typedName:lower(), 1, true) then
                    return plr.Name
                end
            end
        end

        -- WHITELIST / ADMIN / BOTREMOVE / PRINTCMDS (unchanged except printcmds link)

        if msg:sub(1, 10) == Prefix .. "printcmds" then
            print("\n---------- CONTROLBOTZ CMDS ----------\n" .. request({
                Url = "https://raw.githubusercontent.com/ssedsaaes-design/ControlBot/refs/heads/main/ControlBotZ%20Cmds.txt",
                Method = "GET"
            }).Body)
            if index == 1 then chat("Printed commands to console!") end
        end

        -- GOON example – fixed
        if msg:sub(1, 5) == Prefix .. "goon" then
            local args = getArgs(msg:sub(7))
            local speed = tonumber(args[1]) or 1
            specifyBots2(args, 2, function()
                local char, hum = safeGetCharacter()
                if not char or not hum then return end

                local goonAnim = Instance.new("Animation")
                goonAnim.AnimationId = "rbxassetid://99198989"
                local track = hum:LoadAnimation(goonAnim)
                track.Looped = true
                track:Play()
                track:AdjustSpeed(speed)

                local goonAnim2 = Instance.new("Animation")
                goonAnim2.AnimationId = "rbxassetid://168086975"
                local track2 = hum:LoadAnimation(goonAnim2)
                track2.Looped = true
                track2:Play()

                table.insert(characterConnections, track.Stopped:Connect(function() goonAnim:Destroy() end))
                table.insert(characterConnections, track2.Stopped:Connect(function() goonAnim2:Destroy() end))
            end)
        end

        if msg:sub(1, 7) == Prefix .. "ungoon" then
            specifyBots(msg:sub(9), function()
                local char, hum = safeGetCharacter()
                if not char or not hum then return end
                for _, animTrack in ipairs(hum:GetPlayingAnimationTracks()) do
                    if animTrack.Animation.AnimationId == "rbxassetid://99198989" or
                       animTrack.Animation.AnimationId == "rbxassetid://168086975" then
                        animTrack:Stop()
                    end
                end
            end)
        end

        -- Example for a loop command (orbit, bang, follow, stack, etc.)
        -- Replace ALL similar connections with this pattern:
        --[[
        if msg:sub(1, 6) == Prefix .. "orbit" then
            local args = getArgs(message:sub(8))
            local targetName = getFullPlayerName(args[1])
            if not targetName then return end
            local target = Players:FindFirstChild(targetName)
            if not target then return end

            specifyBots2(args, 4, function()
                local conn
                conn = RunService.Heartbeat:Connect(function(dt)
                    local myChar, _, myRoot = safeGetCharacter()
                    if not myChar or not myRoot then return end

                    local tgtChar = target.Character
                    if not tgtChar or not tgtChar:FindFirstChild("HumanoidRootPart") then return end

                    -- your orbit math here...
                end)
                table.insert(characterConnections, conn)
            end)
        end
        ]]

        -- Do the same pattern for:
        -- orbit, 2orbit, lineorbit, follow, linefollow, worm, partsrain,
        -- robot, stack, 2stack, lookat, fling, bang, facebang, 2facebang, etc.

        -- CMDS list (unchanged from previous goon version)
        if msg:sub(1, 5) == Prefix .. "cmds" then
            local page = msg:sub(7)
            if index == 1 then
                if page == "1" then
                    chat("rejoin, jump, reset, sit, chat (message), shutdown, orbit (...)/unorbit, bang (...)/unbang, walkto, speed, bring, clearchat, privacymode")
                    wait(0.2)
                    chat("spin/unspin, lineup, 3drender, dance, fling/unfling, follow/unfollow, lookat/unlookat, stack/unstack, quit")
                    wait(0.2)
                    chat("goto, carpet/uncarpet, linefollow/unlinefollow, riz, facebang/unfbang, announce, rocket, antibang, 2orbit")
                elseif page == "2" then
                    chat("surround, partsrain/unpartsrain, hug/unhug, worm/unworm, index, logchat, 4k, whitelist+/whitelist-")
                    wait(0.2)
                    chat("admin+/admin-, goon (speed)/ungoon, frontflip/backflip, freeze/unfreeze, antiafk, version, botremove, printcmds, fpscap")
                    wait(0.2)
                    chat("2stack/unstack, 2bang, fullbox/unfullbox, stairs/unstairs, gravity, 2facebang, wings/unwings, bridge")
                elseif page == "3" then
                    chat("unbridge, copychat/uncopychat, validate, robot, unrobot")
                else
                    chat("Page 1, 2 or 3")
                end
            end
        end

        -- ... add the rest of your commands with safeGetCharacter() checks
    end

    -- Chat listeners (unchanged)
    for _, plr in ipairs(Players:GetPlayers()) do
        plr.Chatted:Connect(function(msg)
            if not runScript then return end
            commands(plr, msg)
            if logChat then sendToWebhook("```"..msg.."```", plr.Name) end
            if copychat and plr.Name == copychatUsername then chat(msg) end
        end)
    end

    Players.PlayerAdded:Connect(function(plr)
        plr.Chatted:Connect(function(msg)
            if not runScript then return end
            commands(plr, msg)
            if logChat then sendToWebhook("```"..msg.."```", plr.Name) end
            if copychat and plr.Name == copychatUsername then chat(msg) end
        end)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if not runScript then return end
        for i, botName in ipairs(bots) do
            if plr.Name == botName then
                table.remove(bots, i)
                getIndex()
                if index == 1 then chat("Bot "..i.." left") end
                break
            end
        end
    end)
end
