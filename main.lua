local PETS_FOLDER = workspace:WaitForChild("PetsPhysical")
local COOLDOWN_TIME = 58.7

-- Create BillboardGui on the cat's Head (if it doesn't exist)
local function createCooldownBillboard(catModel)
    local head = catModel:FindFirstChild("Head")
    if not head then
        warn("Cat model missing Head part, can't attach billboard.")
        return nil
    end

    -- Avoid duplicate GUIs
    local existingGui = head:FindFirstChild("CooldownTimer")
    if existingGui then
        return existingGui.TextLabel
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CooldownTimer"
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = "Starting..."

    textLabel.Parent = billboard
    billboard.Parent = head

    return textLabel
end

local function highlightPet(petModel)
    if petModel:FindFirstChild("NapHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NapHighlight"
    highlight.Adornee = petModel
    highlight.FillColor = Color3.fromRGB(255, 200, 200)
    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = petModel
end

local function removeHighlightAndBillboard(catModel)
    local head = catModel:FindFirstChild("Head")
    if head then
        local gui = head:FindFirstChild("CooldownTimer")
        if gui then gui:Destroy() end
    end

    local hl = catModel:FindFirstChild("NapHighlight")
    if hl then hl:Destroy() end
end

local function scanNappingCats()
    for _, petMover in pairs(PETS_FOLDER:GetChildren()) do
        if petMover:IsA("Model") then
            local cat = petMover:FindFirstChild("Cat")
            if cat and cat:IsA("Model") then
                local animator = cat:FindFirstChildWhichIsA("Animator", true)
                if animator then
                    local isNapping = false
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if tostring(track):lower():find("nap") then
                            isNapping = true
                            break
                        end
                    end

                    if isNapping then
                        if not (cat.Head and cat.Head:FindFirstChild("CooldownTimer")) then
                            local label = createCooldownBillboard(cat)
                            if label then
                                highlightPet(petMover)

                                local startTime = tick()
                                task.spawn(function()
                                    while true do
                                        local elapsed = tick() - startTime
                                        if elapsed >= COOLDOWN_TIME then
                                            removeHighlightAndBillboard(cat)
                                            break
                                        end
                                        local secs = math.floor(remaining)
										local ms = math.floor((remaining - secs) * 1000)
										label.Text = string.format("%03d:%03d", secs, ms)
                                        task.wait(0.05)
                                    end
                                end)
                            end
                        end
                    else
                        -- If not napping, clean up UI if any exists
                        removeHighlightAndBillboard(cat)
                    end
                end
            end
        end
    end
end

local catTimerClock=game:GetService("RunService").RenderStepped:Connect(scanNappingCats)
getgenv().catTimer = catTimerClock
