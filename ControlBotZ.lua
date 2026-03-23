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
local LocalPLR = game.Players.LocalPlayer

Username = getgenv().Username
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

if LocalPLR.Name ~= Username then
    local logChat = getgenv().logChat
    webhook = getgenv().webhook
    Prefix = getgenv().Prefix
    local bots = getgenv().Bots
    local whitelist = {}
    local admins = {}
    local index

    function getIndex()
        for i, bot in pairs(bots) do
            if LocalPLR.DisplayName == bot then
                index = i
                break
            end
        end
    end
    getIndex()

    function chat(msg)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
        else
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end

    chat("ControlBotZ Running!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Thank You",
        Text = "thank you for using ControlBotZ!",
        Time = 6
    })

    -- Changed to your fork
    local latestVersion = request({
        Url = "https://raw.githubusercontent.com/ssedsaaes-design/ControlBot/refs/heads/main/ControlBotZ%20Version",
        Method = "GET"
    }).Body:match("^%s*(.-)%s*$")

    if latestVersion ~= "1.1.4" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Old Version!",
            Text = "Looks like you are using old version. Get the newest one from the discord server!",
            Time = 8
        })
    end

    function showDefaultGui(enabled, text)
        if enabled == true then
            for _, child in pairs(game:GetService("CoreGui"):GetChildren()) do
                if child.Name == "bruhIDK" then
                    child:Destroy()
                end
            end
            screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
            screenGui.Name = "bruhIDK"
            screenGui.IgnoreGuiInset = true
            local mainFrame = Instance.new("Frame", screenGui)
            mainFrame.Size = UDim2.new(1, 0, 1, 0)
            mainFrame.BackgroundColor3 = Color3.fromRGB(0, 205, 216)
            local textLabel = Instance.new("TextLabel", mainFrame)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = text
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 40
            textLabel.TextScaled = true
            textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        elseif enabled == false then
            if screenGui then screenGui:Destroy() end
        end
    end

    function sendToWebhook(msg, username)
        if index ~= 1 then return end
        local data = { content = msg, username = username }
        local requestData = {
            Url = webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        }
        request(requestData)
    end

    function specifyBots(sub, callback)
        local botArgs = getArgs(sub)
        if next(botArgs) ~= nil then
            for _, arg in ipairs(botArgs) do
                if index == tonumber(arg) then callback() end
            end
        else
            callback()
        end
    end

    function specifyBots2(argTable, tableStartIndex, callback)
        local botArgs = {}
        for i = tableStartIndex, #argTable do
            table.insert(botArgs, argTable[i])
        end
        if #botArgs == 0 then
            callback()
        else
            for _, botArg in ipairs(botArgs) do
                if index == tonumber(botArg) then callback() end
            end
        end
    end

    function getArgs(command)
        local args = {}
        for arg in command:match("^%s*(.-)%s*$"):gmatch("%S+") do
            table.insert(args, arg)
        end
        return args
    end

    function isR15(returnValTrue, returnValFalse)
        if LocalPLR.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
            return returnValTrue or true
        elseif LocalPLR.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            return returnValFalse or false
        end
    end

    function isWhitelisted(name)
        if name == Username then return true end
        for _, adminUser in pairs(admins) do if name == adminUser then return true end end
        for _, whitelistedUser in pairs(whitelist) do if name == whitelistedUser then return true end end
        return false
    end

    function isAdmin(name)
        for _, adminUser in pairs(admins) do if name == adminUser then return true end end
        return false
    end

    local normalGravity = 196.2

    function commands(player, message)
        local msg = message:lower()
        if not isWhitelisted(player.Name) then return end

        function getFullPlayerName(typedName)
            if typedName == "me" then return player.Name end
            for _, plr in pairs(game.Players:GetPlayers()) do
                if string.find(plr.Name, typedName) then return plr.Name end
            end
        end

        -- WHITELIST / ADMIN / BOTREMOVE / PRINTCMDS (unchanged except printcmds link)

        if msg:sub(1, 10) == Prefix .. "printcmds" then
            -- Changed to your fork
            print("\n---------- CONTROLBOTZ CMDS ----------\n" .. request({
                Url = "https://raw.githubusercontent.com/ssedsaaes-design/ControlBot/refs/heads/main/ControlBotZ%20Cmds.txt",
                Method = "GET"
            }).Body)
            if index == 1 then chat("Printed commands to the console!") end
        end

        -- ... (all other command logic remains the same: rejoin, reset, goon, orbit, bang, etc.)

        -- Only showing the changed parts above — the rest of the commands (goon/ungoon, orbit, bang, etc.) stay identical to previous version

        if msg:sub(1, 5) == Prefix .. "cmds" then
            local page = msg:sub(7)
            if index == 1 then
                if page == "1" then
                    chat("rejoin, jump, reset, sit, chat (message), shutdown, orbit (username) (speed)/unorbit, bang (username) (speed)/unbang, walkto (username), speed (number), bring, clearchat, privacymode (enable/disable)")
                    wait(0.2)
                    chat("spin (number)/unspin, lineup (direction), 3drender (enable/disable), dance (emote), fling (username)/unfling, follow (username)/unfollow, lookat (username)/unlookat, stack (username)/unstack, quit")
                    wait(0.2)
                    chat("goto (username), carpet (username)/uncarpet, linefollow (username)/unlinefollow, riz (username), facebang (username) (speed)/unfbang, announce (message), rocket (height), antibang, 2orbit (username)")
                elseif page == "2" then
                    chat("surround (username) (spacing), partsrain (username) (height)/unpartsrain, hug (username)/unhug, worm (username)/unworm, index, logchat (enable/disable), 4k (username), whitelist+ (username)/")
                    wait(0.2)
                    chat("whitelist- (username), admin+ (username)/admin- (username), goon (speed)/ungoon, frontflip/backflip, freeze/unfreeze, antiafk (enable/disable), version, botremove (index), printcmds, fpscap (num)")
                    wait(0.2)
                    chat("2stack (username)/unstack, 2bang (username)/unbang, fullbox (username)/unfullbox, stairs (username)/unstairs, gravity (number), 2facebang (username)/unfbang, wings (username)/unwings, bridge (username)")
                elseif page == "3" then
                    chat("unbridge, copychat (username)/uncopychat, validate, robot (username), unrobot")
                else
                    chat("Please select a page 1, 2 or 3!")
                end
            end
        end
    end

    -- Player chat listeners (unchanged)
    for _, player in pairs(game.Players:GetPlayers()) do
        player.Chatted:Connect(function(message)
            if not runScript then return end
            commands(player, message)
            if logChat then sendToWebhook("```" .. message .. "```", player.Name) end
            if copychat and player.Name == copychatUsername then chat(message) end
        end)
    end

    game.Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            if not runScript then return end
            commands(player, message)
            if logChat then sendToWebhook("```" .. message .. "```", player.Name) end
            if copychat and player.Name == copychatUsername then chat(message) end
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        if not runScript then return end
        for i, bot in pairs(bots) do
            if player.Name == bot then
                table.remove(bots, i)
                getIndex()
                if index == 1 then chat("Bot " .. i .. " left the game!") end
            end
        end
    end)
end
