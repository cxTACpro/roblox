---global constants
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
---function
local Settings = {}
Settings.autocast=false
Settings.autoshake=false
Settings.autoreel=false
Settings.shakediff=0 -- delay between shaking
Settings.reelmode="Blatant" -- 1)blatant 2)legit 3)normal 4)fail
local Connections = {}
Connections.autocast=nil
Connections.autoshake=nil
Connections.autoreel=nil
function SendKeyInput(keyCode,isRepeatedKey)
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true,keyCode,isRepeatedKey, nil)
        game:GetService("VirtualInputManager"):SendKeyEvent(false,keyCode,isRepeatedKey, nil)
    end)
end
function Select(guiobject)
    pcall(function()
        game:GetService("GuiService").SelectedObject=guiobject
    end)
end
--ui part
local Library = loadstring(game:HttpGet('https://pastebin.com/raw/f8Wm0CFj'))()() -- yun ui lib
local Window = Library:Load({name = "fisch", sizeX = 425, sizeY = 512, color = Color3.fromRGB(255, 255, 255)})
local Tab = Window:Tab("fishing")
local Section = Tab:Section{name = "Auto Fisch", column = 1}
Section:Toggle {
    Name = "Auto Cast",
    flag = "autocast", 
    callback = function(bool)
        Settings.autocast=bool
        if bool == false and Connections.autocast then 
            Connections.autocast:Disconnect()
            Connections.autocast=nil
        elseif bool == true then
            Connections.autocast = RunService.RenderStepped:Connect(function()
                if Settings.autocast == true then
                    local Character = LocalPlayer.Character
                    if Character then
                        local shakeconfirm = (PlayerGui:FindFirstChild("shakeui")==nil)
                        local reelconfirm = (PlayerGui:FindFirstChild("reel")==nil)
                        local bobberconfirm = (Rod:FindFirstChild("bobber")==nil)
                        local bobconfirm = (Rod:FindFirstChild("bob", true)==nil)
                        local Rod = (Character:FindFirstChild("rod/client",true) and Character:FindFirstChild("rod/client",true).Parent) or (LocalPlayer.Backpack:FindFirstChild("rod/client",true) and LocalPlayer.Backpack:FindFirstChild("rod/client",true).Parent)
                        if shakeconfirm and reelconfirm and bobberconfirm and bobconfirm and Rod:FindFirstChild("events") then
                            Rod:FindFirstChild("events"):FindFirstChild("cast"):FireServer(99,1)
                        end
                    end
                end
                if Settings.autocast == false then 
                    Connections.autocast:Disconnect()
                end
            end)
        end
    end
}
Section:Toggle {
    Name = "Auto Shake",
    flag = "autoshake", 
    callback = function(bool)
        Settings.autoshake=bool
        if bool == false and Connections.autoshake then 
            Connections.autoshake:Disconnect()
            Connections.autoshake=nil
        elseif bool == true then
            Connections.autoshake = RunService.RenderStepped:Connect(function()
                if Settings.autoshake == true then
                    local shakediffconfirm = (Settings.shakediff==0)
                    local shakeconfirm = (shakediffconfirm and PlayerGui:FindFirstChild("shakeui"))
                    local buttonconfirm = (shakeconfirm and shakeconfirm:FindFirstChild("safezone"):FindFirstChild("button"))
                    if shakediffconfirm and shakeconfirm and buttonconfirm then
                        Select(buttonconfirm)
                        SendKeyInput(Enum.KeyCode.Return, false)
                    end
                end
                if Settings.autoshake == false then 
                    Connections.autoshake:Disconnect()
                end
            end)
        end
    end
}
Section:Toggle {
    Name = "Auto Reel",
    flag = "autoreel", 
    callback = function(bool)
        Settings.autoreel=bool
        if bool == false and Connections.autoreel then 
            Connections.autoreel:Disconnect()
            Connections.autoreel=nil
        elseif bool == true then
            Connections.autoreel = RunService.RenderStepped:Connect(function()
                if Settings.autoreel == true then
                    local reelconfirm = (PlayerGui:FindFirstChild("reel"))
                    local reelfinishedevent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("reelfinished")
                    if reelconfirm then
                        if string.lower(Settings.reelmode or "blatant") == "blatant" then
                            reelfinishedevent:FireServer(100,true)
                        elseif string.lower(Settings.reelmode) == "legit" then
                            local fish=reelconfirm:WaitForChild("bar"):WaitForChild("fish")
                            local bar=reelconfirm:WaitForChild("bar"):WaitForChild("playerbar")
                            local left = bar.Size.X.Scale/2
                            local right = 1-bar.Size.X.Scale/2
                            if fish.Position.X.Scale<left then -- Fish.pos ~~ 0 , left = 0.15~ then 00
                                bar.Position=UDim2.new(left,0,0.5,0)
                            elseif fish.Position.X.Scale>right then
                                bar.Position=UDim2.new(right,0,0.5,0)
                            else
                                bar.Position=fish.Position
                            end
                        elseif string.lower(Settings.reelmode) == "normal" then
                            local fish=v:WaitForChild("bar"):WaitForChild("fish")
                            local bar=v:WaitForChild("bar"):WaitForChild("playerbar")
                            repeat wait()
                            bar.Position=UDim2.new(0.5,0,0.5,0)
                            bar.Size=UDim2.new(1,0,0,0)
                            until v.Parent~=PlayerGui
                        elseif string.lower(Settings.reelmode) == "fail" then
                            reelfinishedevent:FireServer(10,true)
                        end
                    end
                end
            end)
        end
    end
}
Section:Slider {
    Name = "Shake Delay",
    Default = 0,
    Min = 0,
    Max = 1,
    Decimals = 0.01,
    Flag = "shakediff",
    callback = function(value)
        Settings.shakediff=value
    end
}
local Section = Tab:Section{name = "Reel mode", column = 2}
Section:dropdown {
    name = "Mode",
    content = {"Blatant", "Legit", "Normal", "Fail"},
    multichoice = false,
    callback = function(value) --
        Settings.reelmode=value
    end
}
