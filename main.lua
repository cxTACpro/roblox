local PETS_FOLDER = workspace:WaitForChild("PetsPhysical")
local COOLDOWN_TIME = 58
local catTimers = {}
local function getBBgui(catModel)
    local head = catModel:FindFirstChild("Head")
    if not head then return end

    -- Avoid duplicate GUIs
    local existingGui = head:FindFirstChild("scsad")
    if existingGui then
        return existingGui.TextLabel
    end

    local billboard = Instance.new("BillboardGui",head)
    billboard.Name = "scsad"
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)

    local textLabel = Instance.new("TextLabel",billboard)
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    textLabel.Parent = billboard
    billboard.Parent = head

    return textLabel
end

local function highlightPet(petModel)
    if petModel:FindFirstChild("sdafasfasfw") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "sdafasfasfw"
    highlight.Adornee = petModel
    highlight.FillColor = Color3.fromRGB(183, 255, 15)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
	highlight.FillTransparency = 0.9
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = petModel
end
local function scanNappingCats()
    for _, petMover in pairs(PETS_FOLDER:GetChildren()) do
        if petMover then
            local cat = petMover:FindFirstChild("Cat")
            if cat and cat:IsA("Model") then
                local animator = cat:FindFirstChild("Animator",true)
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if tostring(track):lower():find("nap") then
							local label = getBBgui(cat)
                            if label then
                                highlightPet(petMover)

                                local startTime = tick()

                                catTimers[cat] = coroutine.create(function(textLabel)
                                    while true do
                                        local elapsed = tick() - startTime
                                        local s = math.floor(COOLDOWN_TIME-elapsed)
					local ms = math.floor((COOLDOWN_TIME-elapsed) * 1000) - (s * 1000)
					textLabel.Text = string.format("%s:%03d", tostring(s), tostring(ms))
                                        task.wait()
					if elapsed > COOLDOWN_TIME then
					return
					end
                                    end
                                end)
				return coroutine.resume(catTimers[cat],label)
                            end
			end
                    end
                end
            end
        end
    end
end

local catTimerClock=game:GetService("RunService").RenderStepped:Connect(scanNappingCats)
getgenv().catTimer = catTimerClock
