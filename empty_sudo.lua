--[[ ============================================
    Movement Script Pro - Complete Optimized Version
    Created: 2025-11-15
    Author: emptyzo0ne (Optimized)
    Fitur: Recording 240FPS, Smooth Replay, Graphics Optimization
    ============================================ ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Player & Character References
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ============= UTILITY MODULE =============
local Utils = {
    NotifyCache = {},
    _connections = {}
}

--- Notify Utility (Reduce Code Duplication)
function Utils:Notify(title, content, icon, duration)
    if not WindUI then return end
    WindUI:Notify({
        Title = title,
        Content = content,
        Icon = icon or "info",
        Duration = duration or 2
    })
end

--- Safe Connection Management
function Utils:SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end

--- Cleanup All Connections
function Utils:CleanupConnections()
    for _, conn in ipairs(self._connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    self._connections = {}
end

--- Validate Number Input
function Utils:ValidateNumber(value, min, max)
    local num = tonumber(value)
    return (num and num >= min and num <= max) and num or nil
end

-- ============= WIND UI SETUP =============
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI:AddTheme({
    Name = "Purple Premium Elegant",
    Accent = Color3.fromHex("#9d4edd"),
    Background = Color3.fromHex("#0a0015"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#c77dff"),
    Text = Color3.fromHex("#f8f9fa"),
    Placeholder = Color3.fromHex("#5a189a"),
    Button = Color3.fromHex("#5a189a"),
    Icon = Color3.fromHex("#b5a3ff"),
    Hover = Color3.fromHex("#c77dff"),
    WindowBackground = Color3.fromHex("#0a0015"),
    WindowShadow = Color3.fromHex("#000000"),
    DialogBackground = Color3.fromHex("#16213e"),
    DialogBackgroundTransparency = 0,
    DialogTitle = Color3.fromHex("#f8f9fa"),
    DialogContent = Color3.fromHex("#e0aaff"),
    DialogIcon = Color3.fromHex("#c77dff"),
    WindowTopbarButtonIcon = Color3.fromHex("#c77dff"),
    WindowTopbarTitle = Color3.fromHex("#f8f9fa"),
    WindowTopbarAuthor = Color3.fromHex("#b5a3ff"),
    WindowTopbarIcon = Color3.fromHex("#e0aaff"),
    TabBackground = Color3.fromHex("#3c096c"),
    TabTitle = Color3.fromHex("#f8f9fa"),
    TabIcon = Color3.fromHex("#c77dff"),
    ElementBackground = Color3.fromHex("#16213e"),
    ElementTitle = Color3.fromHex("#f8f9fa"),
    ElementDesc = Color3.fromHex("#c77dff"),
    ElementIcon = Color3.fromHex("#b5a3ff"),
    PopupBackground = Color3.fromHex("#0a0015"),
    PopupBackgroundTransparency = 0,
    PopupTitle = Color3.fromHex("#f8f9fa"),
    PopupContent = Color3.fromHex("#e0aaff"),
    PopupIcon = Color3.fromHex("#c77dff"),
})

local Window = WindUI:CreateWindow({
    Title = "Movement Script Pro",
    Author = "Script Creator By emptyzo0ne",
    Size = UDim2.fromOffset(480, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Purple Premium Elegant",
    DisableMobile = false,
    SaveFolder = "MovementScript_Config"
})

-- ============= FEATURE STATE MANAGER =============
local FeatureState = {
    -- Movement Features
    AirJumpEnabled = false,
    NoclipEnabled = false,
    AntiAFKEnabled = false,
    GodModeEnabled = false,
    WalkSpeedEnabled = false,
    JumpPowerEnabled = false,
    
    -- Values
    WalkSpeedValue = 16,
    JumpPowerValue = 50,
    
    -- Recording State
    IsRecording = false,
    IsReplaying = false,
    IsPaused = false,
    RecordingName = "",
    RecordingStartTime = 0,
    PauseStartTime = 0,
    TotalPausedTime = 0,
    
    -- Recording Data
    RecordingData = {},
    SavedRecordings = {},
    CurrentRecordingIndex = 1,
    
    -- Recording Config
    TargetFPS = 240,
    RecordInterval = 1 / 240,
    ReplayTargetFPS = 240,
    ReplayInterval = 1 / 240,
    UseAdvancedInterpolation = true,
    UseBezierCurve = true,
    SmoothnessLevel = 5,
    AntipationFactor = 0.15,
    
    -- Graphics
    PotatoGraphicsEnabled = false,
    OriginalProperties = {},
    
    -- God Mode
    OriginalHealth = nil,
}

-- Event Connections (Manage Cleanup)
local ActiveConnections = {
    Recording = nil,
    Replay = nil,
    NoclipStep = nil,
    ProtectSpeedHeartbeat = nil,
    GodModeHeartbeat = nil,
    HealthChanged = nil,
    AntiAFK = nil,
}

-- ============= CHARACTER SETUP =============
local function SetupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    wait(0.1)
    
    if Humanoid then
        Humanoid.UseJumpPower = true
    end
    
    ProtectSpeed()
    
    if FeatureState.GodModeEnabled then
        EnableGodMode()
    end
    
    if FeatureState.IsRecording then
        StopRecording()
    end
    
    if FeatureState.IsReplaying then
        StopReplay()
    end
end

Utils:SafeConnect(Player.CharacterAdded, SetupCharacter)

-- ============= MOVEMENT FEATURES =============

--- Get Animation State
local function GetAnimationState()
    if not Humanoid or not RootPart then return "Idle" end
    
    local state = Humanoid:GetState()
    local velocity = RootPart.AssemblyLinearVelocity
    local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local verticalVelocity = velocity.Y

    if state == Enum.HumanoidStateType.Climbing then
        return "Climbing"
    elseif state == Enum.HumanoidStateType.Swimming then
        return "Swimming"
    elseif state == Enum.HumanoidStateType.Jumping and verticalVelocity > 10 then
        return "Jumping"
    elseif state == Enum.HumanoidStateType.Freefall or (verticalVelocity < -10 and state ~= Enum.HumanoidStateType.Running) then
        return "Falling"
    elseif state == Enum.HumanoidStateType.Running then
        if speed > 16 then
            return "Running"
        elseif speed > 0.5 then
            return "Walking"
        else
            return "Idle"
        end
    else
        return "Idle"
    end
end

--- Protect Walk Speed & Jump Power (Prevent Server Reset)
function ProtectSpeed()
    if not Humanoid then return end
    
    if FeatureState.WalkSpeedEnabled then
        Humanoid.WalkSpeed = FeatureState.WalkSpeedValue
    end

    if FeatureState.JumpPowerEnabled then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = FeatureState.JumpPowerValue
    end

    if FeatureState.GodModeEnabled and Humanoid.Health ~= math.huge then
        Humanoid.Health = math.huge
    end
end

--- Enable God Mode
function EnableGodMode()
    if not Humanoid or not FeatureState.GodModeEnabled then return end
    
    FeatureState.OriginalHealth = Humanoid.MaxHealth
    Humanoid.MaxHealth = math.huge
    Humanoid.Health = math.huge

    if ActiveConnections.HealthChanged then
        pcall(function() ActiveConnections.HealthChanged:Disconnect() end)
    end

    ActiveConnections.HealthChanged = Humanoid.HealthChanged:Connect(function(health)
        if FeatureState.GodModeEnabled and health < math.huge and Humanoid then
            Humanoid.Health = math.huge
        end
    end)
end

--- Disable God Mode
function DisableGodMode()
    if not Humanoid then return end
    
    if ActiveConnections.HealthChanged then
        pcall(function() ActiveConnections.HealthChanged:Disconnect() end)
        ActiveConnections.HealthChanged = nil
    end

    local originalHealth = FeatureState.OriginalHealth or 100
    Humanoid.MaxHealth = originalHealth
    Humanoid.Health = originalHealth
    FeatureState.OriginalHealth = nil
end

-- ============= EASING FUNCTIONS =============

local function EaseInOutCubic(t)
    return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
end

local function EaseOutQuart(t)
    return 1 - math.pow(1 - t, 4)
end

local function CubicBezier(t, p0, p1, p2, p3)
    local mt = 1 - t
    return mt * mt * mt * p0 + 3 * mt * mt * t * p1 + 3 * mt * t * t * p2 + t * t * t * p3
end

local function BezierCFrame(t, cf0, cf1, cf2, cf3)
    local pos = Vector3.new(
        CubicBezier(t, cf0.Position.X, cf1.Position.X, cf2.Position.X, cf3.Position.X),
        CubicBezier(t, cf0.Position.Y, cf1.Position.Y, cf2.Position.Y, cf3.Position.Y),
        CubicBezier(t, cf0.Position.Z, cf1.Position.Z, cf2.Position.Z, cf3.Position.Z)
    )

    local rot = cf0.Rotation:Lerp(cf3.Rotation, EaseInOutCubic(t))
    return CFrame.new(pos) * rot
end

local function SmoothLerp(a, b, t, easingFunc)
    easingFunc = easingFunc or EaseInOutCubic
    local smoothT = easingFunc(t)
    return a:Lerp(b, smoothT)
end

-- ============= RECORDING SYSTEM =============

function StartRecording()
    if FeatureState.IsRecording then
        Utils:Notify("Recording Error", "Already recording!", "alert-circle", 3)
        return
    end

    if FeatureState.IsReplaying then
        Utils:Notify("Recording Error", "Stop replay first!", "alert-circle", 3)
        return
    end

    if FeatureState.RecordingName == "" then
        FeatureState.RecordingName = "Recording_" .. FeatureState.CurrentRecordingIndex
        FeatureState.CurrentRecordingIndex = FeatureState.CurrentRecordingIndex + 1
    end

    FeatureState.IsRecording = true
    FeatureState.IsPaused = false
    FeatureState.TotalPausedTime = 0
    FeatureState.RecordingData = {}
    FeatureState.RecordingStartTime = tick()

    Utils:Notify("Recording Started", "Recording at 240 FPS: " .. FeatureState.RecordingName, "circle", 3)

    local lastRecordTime = tick()
    local accumulatedDelta = 0

    if ActiveConnections.Recording then
        pcall(function() ActiveConnections.Recording:Disconnect() end)
    end

    ActiveConnections.Recording = RunService.Heartbeat:Connect(function()
        if not FeatureState.IsRecording then return end
        if FeatureState.IsPaused then return end

        local currentTick = tick()
        local deltaTime = currentTick - lastRecordTime
        accumulatedDelta = accumulatedDelta + deltaTime

        while accumulatedDelta >= FeatureState.RecordInterval do
            if Humanoid and RootPart then
                local currentTime = currentTick - FeatureState.RecordingStartTime - FeatureState.TotalPausedTime
                local animState = GetAnimationState()

                table.insert(FeatureState.RecordingData, {
                    time = currentTime,
                    deltaTime = FeatureState.RecordInterval,
                    position = RootPart.Position,
                    cframe = RootPart.CFrame,
                    velocity = RootPart.AssemblyLinearVelocity,
                    rotation = RootPart.CFrame.Rotation,
                    lookVector = RootPart.CFrame.LookVector,
                    animationState = animState,
                    humanoidState = Humanoid:GetState(),
                    isJumping = Humanoid.Jump,
                    jumpPower = Humanoid.JumpPower,
                    moveDirection = Humanoid.MoveDirection,
                    moveSpeed = RootPart.AssemblyLinearVelocity.Magnitude,
                    verticalVelocity = RootPart.AssemblyLinearVelocity.Y
                })
            end

            accumulatedDelta = accumulatedDelta - FeatureState.RecordInterval
        end

        lastRecordTime = currentTick
    end)
end

function StopRecording()
    if not FeatureState.IsRecording then
        Utils:Notify("Recording Error", "Not recording!", "alert-circle", 3)
        return
    end

    FeatureState.IsRecording = false
    FeatureState.IsPaused = false
    FeatureState.TotalPausedTime = 0

    if ActiveConnections.Recording then
        pcall(function() ActiveConnections.Recording:Disconnect() end)
        ActiveConnections.Recording = nil
    end

    if #FeatureState.RecordingData > 0 then
        local duration = tick() - FeatureState.RecordingStartTime - FeatureState.TotalPausedTime
        
        FeatureState.SavedRecordings[FeatureState.RecordingName] = {
            Data = FeatureState.RecordingData,
            Duration = duration,
            FrameCount = #FeatureState.RecordingData,
            CreatedAt = os.date("%X %x")
        }

        UpdateRecordingDropdown()

        Utils:Notify(
            "Recording Saved",
            string.format("%s saved! (%d frames, %.2fs)", FeatureState.RecordingName, 
                #FeatureState.RecordingData, duration),
            "save",
            4
        )

        FeatureState.RecordingName = ""
    else
        Utils:Notify("Recording Error", "No data recorded!", "alert-circle", 3)
    end

    FeatureState.RecordingData = {}
end

function PauseRecording()
    if not FeatureState.IsRecording or FeatureState.IsPaused then return end

    FeatureState.IsPaused = true
    FeatureState.PauseStartTime = tick()

    Utils:Notify(
        "Recording Paused",
        "Recording paused at " .. string.format("%.2f", tick() - FeatureState.RecordingStartTime) .. "s",
        "pause-circle",
        3
    )
end

function ResumeRecording()
    if not FeatureState.IsRecording or not FeatureState.IsPaused then return end

    local pauseDuration = tick() - FeatureState.PauseStartTime
    FeatureState.TotalPausedTime = FeatureState.TotalPausedTime + pauseDuration
    FeatureState.IsPaused = false

    Utils:Notify(
        "Recording Resumed",
        "Recording resumed (paused for " .. string.format("%.2f", pauseDuration) .. "s)",
        "play-circle",
        3
    )
end

-- ============= REPLAY SYSTEM =============

local function GetInterpolatedFrame(currentTime, smoothLevel)
    if #FeatureState.RecordingData < 4 then 
        return FeatureState.RecordingData[1] 
    end

    local frameIndex = 1
    for i = 1, #FeatureState.RecordingData do
        if FeatureState.RecordingData[i].time > currentTime then
            frameIndex = i - 1
            break
        end
        frameIndex = i
    end

    frameIndex = math.max(2, math.min(frameIndex, #FeatureState.RecordingData - 2))

    local f0 = FeatureState.RecordingData[frameIndex - 1]
    local f1 = FeatureState.RecordingData[frameIndex]
    local f2 = FeatureState.RecordingData[frameIndex + 1]
    local f3 = FeatureState.RecordingData[frameIndex + 2]

    if not (f0 and f1 and f2 and f3) then return f1 end

    local timeDiff = f2.time - f1.time
    if timeDiff <= 0 then return f1 end

    local t = math.clamp((currentTime - f1.time) / timeDiff, 0, 1)
    local smoothFactor = smoothLevel / 10
    t = EaseInOutCubic(t * (1 - smoothFactor) + smoothFactor * t)

    if FeatureState.AntipationFactor > 0 and t < 0.5 then
        t = t * (1 + FeatureState.AntipationFactor)
    end

    local result = {}

    if FeatureState.UseBezierCurve then
        result.cframe = BezierCFrame(t, f0.cframe, f1.cframe, f2.cframe, f3.cframe)
    else
        result.cframe = SmoothLerp(f1.cframe, f2.cframe, t, EaseInOutCubic)
    end

    local v1 = f1.velocity
    local v2 = f2.velocity
    local acceleration = (v2 - v1) / timeDiff
    result.velocity = v1 + acceleration * (currentTime - f1.time) * t

    result.animationState = f1.animationState
    result.humanoidState = f1.humanoidState
    result.moveDirection = f1.moveDirection:Lerp(f2.moveDirection, t)
    result.moveSpeed = f1.moveSpeed + (f2.moveSpeed - f1.moveSpeed) * EaseInOutCubic(t)
    result.verticalVelocity = f1.verticalVelocity + (f2.verticalVelocity - f1.verticalVelocity) * t
    result.jumpPower = f1.jumpPower

    return result
end

local function SetAnimationState(state, moveDir, speed, humanoidState, verticalVel)
    if not Humanoid then return end
    
    if state == "Walking" or state == "Running" then
        if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
            Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        local moveForce = moveDir * (speed / math.max(Humanoid.WalkSpeed, 1))
        Humanoid:Move(moveForce, true)
    elseif state == "Idle" then
        Humanoid:Move(Vector3.new(0, 0, 0), false)
    elseif state == "Jumping" then
        if verticalVel and verticalVel > 10 then
            if Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            RootPart.AssemblyLinearVelocity = Vector3.new(
                RootPart.AssemblyLinearVelocity.X,
                verticalVel,
                RootPart.AssemblyLinearVelocity.Z
            )
        end
    elseif state == "Falling" then
        if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    elseif state == "Swimming" then
        Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        Humanoid:Move(moveDir, true)
    elseif state == "Climbing" then
        Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
        Humanoid:Move(moveDir, true)
    end
end

function StartReplay(recordingName)
    if FeatureState.IsReplaying then
        Utils:Notify("Replay Error", "Already replaying!", "alert-circle", 3)
        return
    end

    if FeatureState.IsRecording then
        Utils:Notify("Replay Error", "Stop recording first!", "alert-circle", 3)
        return
    end

    local recording = FeatureState.SavedRecordings[recordingName]
    if not recording or not recording.Data then
        Utils:Notify("Replay Error", "No recording found!", "alert-circle", 3)
        return
    end

    FeatureState.IsReplaying = true
    FeatureState.IsPaused = false
    FeatureState.TotalPausedTime = 0
    FeatureState.RecordingData = recording.Data

    Utils:Notify("Replay Started", "Playing: " .. recordingName .. " (Ultra Smooth)", "play", 3)

    local startTime = tick()
    local lastFrame = nil
    local lastUpdateTime = tick()
    local pausedPosition = nil

    if ActiveConnections.Replay then
        pcall(function() ActiveConnections.Replay:Disconnect() end)
    end

    ActiveConnections.Replay = RunService.Heartbeat:Connect(function()
        if not FeatureState.IsReplaying or not RootPart then
            StopReplay()
            return
        end

        if FeatureState.IsPaused then
            if not pausedPosition then
                pausedPosition = RootPart.CFrame
            end
            RootPart.CFrame = pausedPosition
            RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            return
        else
            pausedPosition = nil
        end

        local currentTick = tick()
        local deltaTime = currentTick - lastUpdateTime
        lastUpdateTime = currentTick

        local currentTime = currentTick - startTime - FeatureState.TotalPausedTime
        local totalDuration = FeatureState.RecordingData[#FeatureState.RecordingData].time

        if currentTime >= totalDuration then
            StopReplay()
            Utils:Notify("Replay Completed", recordingName .. " finished!", "check-circle", 3)
            return
        end

        local frame = GetInterpolatedFrame(currentTime, FeatureState.SmoothnessLevel)

        if frame then
            if lastFrame then
                local blendFactor = math.clamp(deltaTime * FeatureState.ReplayTargetFPS * (FeatureState.SmoothnessLevel / 5), 0, 1)
                RootPart.CFrame = RootPart.CFrame:Lerp(frame.cframe, blendFactor)
            else
                RootPart.CFrame = frame.cframe
            end

            if frame.animationState == "Walking" or frame.animationState == "Running" or frame.animationState == "Idle" then
                RootPart.AssemblyLinearVelocity = Vector3.new(
                    frame.velocity.X,
                    RootPart.AssemblyLinearVelocity.Y,
                    frame.velocity.Z
                )
            else
                RootPart.AssemblyLinearVelocity = frame.velocity
            end

            SetAnimationState(frame.animationState, frame.moveDirection, frame.moveSpeed, 
                frame.humanoidState, frame.verticalVelocity)

            lastFrame = frame
        end
    end)
end

function StopReplay()
    if not FeatureState.IsReplaying then
        Utils:Notify("Replay Error", "Not replaying!", "alert-circle", 3)
        return
    end

    FeatureState.IsReplaying = false
    FeatureState.IsPaused = false
    FeatureState.TotalPausedTime = 0

    if ActiveConnections.Replay then
        pcall(function() ActiveConnections.Replay:Disconnect() end)
        ActiveConnections.Replay = nil
    end

    if Humanoid then
        Humanoid:Move(Vector3.new(0, 0, 0), false)
    end
    
    if RootPart then
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    Utils:Notify("Replay Stopped", "Replay stopped", "square", 2)
end

function PauseReplay()
    if not FeatureState.IsReplaying or FeatureState.IsPaused then return end

    FeatureState.IsPaused = true
    FeatureState.PauseStartTime = tick()

    if Humanoid then
        Humanoid:Move(Vector3.new(0, 0, 0), false)
    end

    Utils:Notify("Replay Paused", "Replay paused", "pause-circle", 2)
end

function ResumeReplay()
    if not FeatureState.IsReplaying or not FeatureState.IsPaused then return end

    local pauseDuration = tick() - FeatureState.PauseStartTime
    FeatureState.TotalPausedTime = FeatureState.TotalPausedTime + pauseDuration
    FeatureState.IsPaused = false

    Utils:Notify("Replay Resumed", "Replay resumed", "play-circle", 2)
end

-- ============= SAVE/LOAD SYSTEM =============

function SaveRecordingsToFile(filename)
    local success, result = pcall(function()
        if next(FeatureState.SavedRecordings) == nil then
            return false, "No recordings to save"
        end

        local dataToSave = {
            Version = "1.0",
            SaveDate = os.date("%Y-%m-%d %H:%M:%S"),
            RecordingCount = 0,
            Recordings = {}
        }

        local count = 0
        for name, recording in pairs(FeatureState.SavedRecordings) do
            count = count + 1
            
            local serializedData = {}
            for i, frame in ipairs(recording.Data) do
                table.insert(serializedData, {
                    time = frame.time,
                    deltaTime = frame.deltaTime,
                    position = { frame.position.X, frame.position.Y, frame.position.Z },
                    cframe = { frame.cframe:GetComponents() },
                    velocity = { frame.velocity.X, frame.velocity.Y, frame.velocity.Z },
                    rotation = { frame.rotation:ToEulerAnglesXYZ() },
                    lookVector = { frame.lookVector.X, frame.lookVector.Y, frame.lookVector.Z },
                    animationState = frame.animationState,
                    moveDirection = { frame.moveDirection.X, frame.moveDirection.Y, frame.moveDirection.Z },
                    moveSpeed = frame.moveSpeed,
                    verticalVelocity = frame.verticalVelocity,
                    jumpPower = frame.jumpPower
                })
            end

            dataToSave.Recordings[name] = {
                Duration = recording.Duration,
                FrameCount = recording.FrameCount,
                CreatedAt = recording.CreatedAt,
                Data = serializedData
            }
        end

        dataToSave.RecordingCount = count
        local jsonData = HttpService:JSONEncode(dataToSave)
        writefile(filename .. ".json", jsonData)

        return true, count
    end)

    if success then
        Utils:Notify("Save Successful", string.format("Saved %d recordings to %s.json", result, filename), 
            "check-circle", 4)
    else
        Utils:Notify("Save Failed", "Error: " .. tostring(result), "x-circle", 4)
    end
end

function LoadRecordingsFromFile(filename, merge)
    local success, result = pcall(function()
        if not isfile(filename .. ".json") then
            return false, "File not found"
        end

        local jsonData = readfile(filename .. ".json")
        local loadedData = HttpService:JSONDecode(jsonData)

        if not merge then
            FeatureState.SavedRecordings = {}
        end

        local count = 0

        local function convertFrame(frame)
            if not frame then return nil end

            local function toVector3(data)
                if type(data) == "table" then
                    return Vector3.new(data[1] or 0, data[2] or 0, data[3] or 0)
                end
                return Vector3.new(0, 0, 0)
            end

            local function toCFrame(data)
                if type(data) == "table" and #data >= 12 then
                    return CFrame.new(
                        data[1], data[2], data[3],
                        data[4], data[5], data[6],
                        data[7], data[8], data[9],
                        data[10], data[11], data[12]
                    )
                end
                return CFrame.new(0, 0, 0)
            end

            return {
                time = frame.time or 0,
                deltaTime = frame.deltaTime or 0,
                position = toVector3(frame.position),
                cframe = toCFrame(frame.cframe),
                velocity = toVector3(frame.velocity),
                rotation = CFrame.Angles(
                    frame.rotation and frame.rotation[1] or 0,
                    frame.rotation and frame.rotation[2] or 0,
                    frame.rotation and frame.rotation[3] or 0
                ),
                lookVector = toVector3(frame.lookVector),
                animationState = frame.animationState or "Idle",
                humanoidState = frame.humanoidState or Enum.HumanoidStateType.Running,
                isJumping = frame.isJumping or false,
                jumpPower = frame.jumpPower or 50,
                moveDirection = toVector3(frame.moveDirection),
                moveSpeed = frame.moveSpeed or 0,
                verticalVelocity = frame.verticalVelocity or 0
            }
        end

        if loadedData.RecordingName then
            local name = loadedData.RecordingName
            local convertedData = {}
            for i, frame in ipairs(loadedData.Data) do
                local converted = convertFrame(frame)
                if converted then
                    table.insert(convertedData, converted)
                end
            end

            if #convertedData > 0 then
                FeatureState.SavedRecordings[name] = {
                    Duration = loadedData.Duration,
                    FrameCount = loadedData.FrameCount,
                    CreatedAt = loadedData.CreatedAt,
                    Data = convertedData
                }
                count = 1
            end
        elseif loadedData.Recordings then
            for name, recording in pairs(loadedData.Recordings) do
                local convertedData = {}
                for i, frame in ipairs(recording.Data) do
                    local converted = convertFrame(frame)
                    if converted then
                        table.insert(convertedData, converted)
                    end
                end

                if #convertedData > 0 then
                    FeatureState.SavedRecordings[name] = {
                        Duration = recording.Duration,
                        FrameCount = recording.FrameCount,
                        CreatedAt = recording.CreatedAt,
                        Data = convertedData
                    }
                    count = count + 1
                end
            end
        end

        UpdateRecordingDropdown()
        return true, count
    end)

    if success then
        Utils:Notify("Load Successful", string.format("Loaded %d recordings from %s.json", result, filename), 
            "check-circle", 4)
    else
        Utils:Notify("Load Failed", "Error: " .. tostring(result), "x-circle", 4)
    end
end

-- ============= GRAPHICS OPTIMIZATION =============

function EnablePotatoGraphics()
    FeatureState.OriginalProperties = {}
    FeatureState.PotatoGraphicsEnabled = true

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not FeatureState.OriginalProperties[obj] then
                FeatureState.OriginalProperties[obj] = {
                    Material = obj.Material,
                    Color = obj.Color,
                    Reflectance = obj.Reflectance,
                    Transparency = obj.Transparency
                }
            end

            obj.Material = Enum.Material.Plastic
            obj.Color = Color3.fromRGB(128, 128, 128)
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if not FeatureState.OriginalProperties[obj] then
                FeatureState.OriginalProperties[obj] = {
                    Transparency = obj.Transparency
                }
            end
            obj.Transparency = 1
        elseif obj:IsA("SurfaceAppearance") then
            if not FeatureState.OriginalProperties[obj] then
                FeatureState.OriginalProperties[obj] = {
                    Parent = obj.Parent
                }
            end
            obj.Parent = nil
        end
    end

    if not FeatureState.OriginalProperties["Lighting"] then
        FeatureState.OriginalProperties["Lighting"] = {
            Brightness = Lighting.Brightness,
            GlobalShadows = Lighting.GlobalShadows,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Ambient = Lighting.Ambient
        }
    end

    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)

    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") then
            if not FeatureState.OriginalProperties[effect] then
                FeatureState.OriginalProperties[effect] = { Enabled = effect.Enabled or true }
            end
            effect.Enabled = false
        elseif effect:IsA("Sky") or effect:IsA("Clouds") then
            if not FeatureState.OriginalProperties[effect] then
                FeatureState.OriginalProperties[effect] = { Parent = Lighting }
            end
            effect.Parent = nil
        end
    end
end

function DisablePotatoGraphics()
    FeatureState.PotatoGraphicsEnabled = false

    for obj, props in pairs(FeatureState.OriginalProperties) do
        if obj == "Lighting" then
            Lighting.Brightness = props.Brightness
            Lighting.GlobalShadows = props.GlobalShadows
            Lighting.OutdoorAmbient = props.OutdoorAmbient
            Lighting.Ambient = props.Ambient
        elseif typeof(obj) == "Instance" then
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.Material = props.Material
                    obj.Color = props.Color
                    obj.Reflectance = props.Reflectance
                    obj.Transparency = props.Transparency
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = props.Transparency
                elseif obj:IsA("SurfaceAppearance") and props.Parent then
                    obj.Parent = props.Parent
                elseif (obj:IsA("PostEffect") or obj:IsA("Atmosphere")) and props.Enabled then
                    obj.Enabled = props.Enabled
                elseif (obj:IsA("Sky") or obj:IsA("Clouds")) and props.Parent then
                    obj.Parent = props.Parent
                end
            end)
        end
    end

    FeatureState.OriginalProperties = {}
end

function ApplyQuickFPSBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    Lighting.GlobalShadows = false

    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or
            effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or
            effect:IsA("ColorCorrectionEffect") then
            effect.Enabled = false
        end
    end

    pcall(function()
        workspace.Terrain.Decoration = false
    end)
end

function RemoveAllEffects()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
            obj:IsA("Beam") or obj:IsA("Fire") or
            obj:IsA("Smoke") or obj:IsA("Sparkles") then
            pcall(function() obj:Destroy() end)
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or
            obj:IsA("SurfaceLight") then
            obj.Enabled = false
        end
    end

    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
end

-- ============= MERGE RECORDINGS =============

function MergeRecordingsSequential(recordingNames, newName)
    local success, result = pcall(function()
        local mergedData = {}
        local totalDuration = 0
        local totalFrames = 0
        local currentTimeOffset = 0

        for _, name in ipairs(recordingNames) do
            local recording = FeatureState.SavedRecordings[name]
            if not recording then
                return false, "Recording '" .. name .. "' not found"
            end

            for _, frame in ipairs(recording.Data) do
                table.insert(mergedData, {
                    time = frame.time + currentTimeOffset,
                    deltaTime = frame.deltaTime,
                    position = frame.position,
                    cframe = frame.cframe,
                    velocity = frame.velocity,
                    rotation = frame.rotation,
                    lookVector = frame.lookVector,
                    animationState = frame.animationState,
                    humanoidState = frame.humanoidState,
                    isJumping = frame.isJumping,
                    jumpPower = frame.jumpPower,
                    moveDirection = frame.moveDirection,
                    moveSpeed = frame.moveSpeed,
                    verticalVelocity = frame.verticalVelocity
                })
                totalFrames = totalFrames + 1
            end

            currentTimeOffset = currentTimeOffset + recording.Duration
            totalDuration = totalDuration + recording.Duration
        end

        FeatureState.SavedRecordings[newName] = {
            Data = mergedData,
            Duration = totalDuration,
            FrameCount = totalFrames,
            CreatedAt = os.date("%X %x"),
            IsMerged = true,
            MergedFrom = recordingNames
        }

        UpdateRecordingDropdown()
        return true, totalFrames, totalDuration
    end)

    if success then
        local frames, duration = select(2, result), select(3, result)
        Utils:Notify("Merge Successful", 
            string.format("Created '%s'\n%d recordings merged\n%d frames, %.2fs total", 
                newName, #recordingNames, frames, duration),
            "check-circle", 5)
    else
        Utils:Notify("Merge Failed", "Error: " .. tostring(result), "x-circle", 4)
    end
end

function MergeRecordingsSmooth(recordingNames, newName)
    local success, result = pcall(function()
        local mergedData = {}
        local totalDuration = 0
        local totalFrames = 0
        local currentTimeOffset = 0
        local transitionFrames = 30

        for index, name in ipairs(recordingNames) do
            local recording = FeatureState.SavedRecordings[name]
            if not recording then
                return false, "Recording '" .. name .. "' not found"
            end

            local isLastRecording = (index == #recordingNames)

            for _, frame in ipairs(recording.Data) do
                table.insert(mergedData, {
                    time = frame.time + currentTimeOffset,
                    deltaTime = frame.deltaTime,
                    position = frame.position,
                    cframe = frame.cframe,
                    velocity = frame.velocity,
                    rotation = frame.rotation,
                    lookVector = frame.lookVector,
                    animationState = frame.animationState,
                    humanoidState = frame.humanoidState,
                    isJumping = frame.isJumping,
                    jumpPower = frame.jumpPower,
                    moveDirection = frame.moveDirection,
                    moveSpeed = frame.moveSpeed,
                    verticalVelocity = frame.verticalVelocity
                })
                totalFrames = totalFrames + 1
            end

            if not isLastRecording and index < #recordingNames then
                local nextRecording = FeatureState.SavedRecordings[recordingNames[index + 1]]
                if nextRecording and #nextRecording.Data > 0 then
                    local lastFrame = recording.Data[#recording.Data]
                    local firstNextFrame = nextRecording.Data[1]

                    for t = 1, transitionFrames do
                        local alpha = t / transitionFrames
                        local smoothAlpha = EaseInOutCubic(alpha)
                        local transitionTime = currentTimeOffset + recording.Duration + (t * FeatureState.RecordInterval)

                        table.insert(mergedData, {
                            time = transitionTime,
                            deltaTime = FeatureState.RecordInterval,
                            position = lastFrame.position:Lerp(firstNextFrame.position, smoothAlpha),
                            cframe = lastFrame.cframe:Lerp(firstNextFrame.cframe, smoothAlpha),
                            velocity = lastFrame.velocity:Lerp(firstNextFrame.velocity, smoothAlpha),
                            rotation = lastFrame.rotation:Lerp(firstNextFrame.rotation, smoothAlpha),
                            lookVector = lastFrame.lookVector:Lerp(firstNextFrame.lookVector, smoothAlpha),
                            animationState = alpha < 0.5 and lastFrame.animationState or firstNextFrame.animationState,
                            humanoidState = alpha < 0.5 and lastFrame.humanoidState or firstNextFrame.humanoidState,
                            isJumping = alpha < 0.5 and lastFrame.isJumping or firstNextFrame.isJumping,
                            jumpPower = lastFrame.jumpPower + (firstNextFrame.jumpPower - lastFrame.jumpPower) * smoothAlpha,
                            moveDirection = lastFrame.moveDirection:Lerp(firstNextFrame.moveDirection, smoothAlpha),
                            moveSpeed = lastFrame.moveSpeed + (firstNextFrame.moveSpeed - lastFrame.moveSpeed) * smoothAlpha,
                            verticalVelocity = lastFrame.verticalVelocity + (firstNextFrame.verticalVelocity - lastFrame.verticalVelocity) * smoothAlpha
                        })
                        totalFrames = totalFrames + 1
                    end

                    totalDuration = totalDuration + (transitionFrames * FeatureState.RecordInterval)
                end
            end

            currentTimeOffset = currentTimeOffset + recording.Duration + (isLastRecording and 0 or (transitionFrames * FeatureState.RecordInterval))
            totalDuration = totalDuration + recording.Duration
        end

        FeatureState.SavedRecordings[newName] = {
            Data = mergedData,
            Duration = totalDuration,
            FrameCount = totalFrames,
            CreatedAt = os.date("%X %x"),
            IsMerged = true,
            IsSmooth = true,
            MergedFrom = recordingNames
        }

        UpdateRecordingDropdown()
        return true, totalFrames, totalDuration
    end)

    if success then
        local frames, duration = select(2, result), select(3, result)
        Utils:Notify("Smooth Merge Successful", 
            string.format("Created '%s' (Smooth)\n%d recordings merged\n%d frames, %.2fs total", 
                newName, #recordingNames, frames, duration),
            "check-circle", 5)
    else
        Utils:Notify("Merge Failed", "Error: " .. tostring(result), "x-circle", 4)
    end
end

-- ============= UI DROPDOWN UPDATE =============

local RecordingDropdown = nil

function UpdateRecordingDropdown()
    local options = {}
    for name, _ in pairs(FeatureState.SavedRecordings) do
        table.insert(options, name)
    end
    
    if #options == 0 then
        options = { "No recordings yet" }
    end
    
    if RecordingDropdown then
        RecordingDropdown:Refresh(options)
    end
    
    return options
end

-- ============= UI TABS SETUP =============

local MovementTab = Window:Tab({ Title = "Movement", Icon = "gauge" })
local RecorderTab = Window:Tab({ Title = "Ultra Smooth Recorder", Icon = "video" })
local SaveLoadTab = Window:Tab({ Title = "Save/Load", Icon = "save" })
local PerformanceTab = Window:Tab({ Title = "Performance", Icon = "zap" })

-- ============= MOVEMENT TAB UI =============

local WalkSpeedSection = MovementTab:Section({ Title = "WalkSpeed Control" })

WalkSpeedSection:Toggle({
    Title = "Enable WalkSpeed",
    Description = "Toggle custom walk speed",
    Default = false,
    Callback = function(value)
        FeatureState.WalkSpeedEnabled = value
        if Humanoid then
            Humanoid.WalkSpeed = value and FeatureState.WalkSpeedValue or 16
        end
        Utils:Notify("WalkSpeed", value and "WalkSpeed Enabled" or "WalkSpeed Disabled", "gauge", 2)
    end
})

WalkSpeedSection:Input({
    Title = "WalkSpeed Value",
    Description = "Enter speed value (0-1000)",
    Default = "16",
    Placeholder = "Enter speed...",
    Callback = function(text)
        local value = Utils:ValidateNumber(text, 0, 1000)
        if value then
            FeatureState.WalkSpeedValue = value
            if FeatureState.WalkSpeedEnabled and Humanoid then
                Humanoid.WalkSpeed = value
            end
            Utils:Notify("WalkSpeed Updated", "Speed set to " .. value, "check", 2)
        else
            Utils:Notify("Invalid Input", "Enter a number between 0-1000", "alert-circle", 3)
        end
    end
})

local JumpPowerSection = MovementTab:Section({ Title = "JumpPower Control" })

JumpPowerSection:Toggle({
    Title = "Enable JumpPower",
    Description = "Toggle custom jump power",
    Default = false,
    Callback = function(value)
        FeatureState.JumpPowerEnabled = value
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = value and FeatureState.JumpPowerValue or 50
        end
        Utils:Notify("JumpPower", value and "JumpPower Enabled" or "JumpPower Disabled", "arrow-up", 2)
    end
})

JumpPowerSection:Input({
    Title = "JumpPower Value",
    Description = "Enter power value (0-1000)",
    Default = "50",
    Placeholder = "Enter power...",
    Callback = function(text)
        local value = Utils:ValidateNumber(text, 0, 1000)
        if value then
            FeatureState.JumpPowerValue = value
            if FeatureState.JumpPowerEnabled and Humanoid then
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = value
            end
            Utils:Notify("JumpPower Updated", "Power set to " .. value, "check", 2)
        else
            Utils:Notify("Invalid Input", "Enter a number between 0-1000", "alert-circle", 3)
        end
    end
})

local FeaturesSection = MovementTab:Section({ Title = "Special Features" })

FeaturesSection:Toggle({
    Title = "Air Jump",
    Description = "Infinite jump in the air",
    Icon = "wind",
    Default = false,
    Callback = function(value)
        FeatureState.AirJumpEnabled = value
        Utils:Notify("Air Jump", value and "Enabled" or "Disabled", "wind", 2)
    end
})

FeaturesSection:Toggle({
    Title = "Noclip",
    Description = "Walk through walls",
    Icon = "shield-off",
    Default = false,
    Callback = function(value)
        FeatureState.NoclipEnabled = value
        
        if value then
            if ActiveConnections.NoclipStep then
                pcall(function() ActiveConnections.NoclipStep:Disconnect() end)
            end
            ActiveConnections.NoclipStep = RunService.Stepped:Connect(function()
                if FeatureState.NoclipEnabled and Character then
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        elseif ActiveConnections.NoclipStep then
            pcall(function() ActiveConnections.NoclipStep:Disconnect() end)
            ActiveConnections.NoclipStep = nil
        end
        
        Utils:Notify("Noclip", value and "Enabled" or "Disabled", "shield-off", 2)
    end
})

FeaturesSection:Toggle({
    Title = "Anti AFK",
    Description = "Prevent AFK kick",
    Icon = "clock",
    Default = false,
    Callback = function(value)
        FeatureState.AntiAFKEnabled = value
        
        if value then
            if ActiveConnections.AntiAFK then
                pcall(function() ActiveConnections.AntiAFK:Disconnect() end)
            end
            ActiveConnections.AntiAFK = Player.Idled:Connect(function()
                if FeatureState.AntiAFKEnabled then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        elseif ActiveConnections.AntiAFK then
            pcall(function() ActiveConnections.AntiAFK:Disconnect() end)
            ActiveConnections.AntiAFK = nil
        end
        
        Utils:Notify("Anti AFK", value and "You won't be kicked" or "AFK detection active", "clock", 3)
    end
})

FeaturesSection:Toggle({
    Title = "God Mode",
    Description = "Immortal character",
    Icon = "shield",
    Default = false,
    Callback = function(value)
        FeatureState.GodModeEnabled = value
        if value then
            EnableGodMode()
        else
            DisableGodMode()
        end
        Utils:Notify("God Mode", value and "You are now immortal!" or "You can take damage now", "shield", 3)
    end
})

FeaturesSection:Divider()

FeaturesSection:Button({
    Title = "Reset Character",
    Description = "Respawn your character",
    Icon = "refresh-cw",
    Callback = function()
        if Character and Humanoid then
            Humanoid.Health = 0
            Utils:Notify("Character Reset", "Respawning...", "refresh-cw", 2)
        end
    end
})

-- ============= RECORDER TAB UI =============

local RecorderControlSection = RecorderTab:Section({ Title = "Recording Controls (240 FPS)" })

RecorderControlSection:Input({
    Title = "Recording Name",
    Description = "Enter name for this recording",
    Default = "Recording_1",
    Placeholder = "Enter name...",
    Callback = function(text)
        FeatureState.RecordingName = text
    end
})

RecorderControlSection:Button({
    Title = "Start Ultra Smooth Recording",
    Description = "Record at 240 FPS with all animations",
    Icon = "circle",
    Callback = function()
        StartRecording()
    end
})

RecorderControlSection:Button({
    Title = "Stop Recording",
    Description = "Stop and save recording",
    Icon = "square",
    Callback = function()
        StopRecording()
    end
})

RecorderControlSection:Button({
    Title = "Pause/Resume Recording",
    Description = "Pause or resume current recording",
    Icon = "pause-circle",
    Callback = function()
        if not FeatureState.IsRecording then
            Utils:Notify("Pause Error", "Not recording!", "alert-circle", 3)
            return
        end

        if FeatureState.IsPaused then
            ResumeRecording()
        else
            PauseRecording()
        end
    end
})

local ReplaySection = RecorderTab:Section({ Title = "Replay Controls (Ultra Smooth)" })

local RecordingDropdownOptions = { "No recordings yet" }
local SelectedRecording = nil

RecordingDropdown = ReplaySection:Dropdown({
    Title = "Select Recording",
    Description = "Choose recording to replay",
    Options = RecordingDropdownOptions,
    Default = RecordingDropdownOptions[1],
    Callback = function(option)
        if FeatureState.SavedRecordings[option] then
            SelectedRecording = option
            Utils:Notify("Recording Selected", option .. " selected", "check", 2)
        end
    end
})

ReplaySection:Button({
    Title = "Play Ultra Smooth Replay",
    Description = "Replay with advanced interpolation",
    Icon = "play",
    Callback = function()
        if not SelectedRecording or not FeatureState.SavedRecordings[SelectedRecording] then
            Utils:Notify("Replay Error", "No recording selected!", "alert-circle", 3)
            return
        end
        StartReplay(SelectedRecording)
    end
})

ReplaySection:Button({
    Title = "Stop Replay",
    Description = "Stop current replay",
    Icon = "square",
    Callback = function()
        StopReplay()
    end
})

ReplaySection:Button({
    Title = "Pause/Resume Replay",
    Description = "Pause or resume current replay",
    Icon = "pause-circle",
    Callback = function()
        if not FeatureState.IsReplaying then
            Utils:Notify("Pause Error", "Not replaying!", "alert-circle", 3)
            return
        end

        if FeatureState.IsPaused then
            ResumeReplay()
        else
            PauseReplay()
        end
    end
})

-- ============= RECORDING MANAGEMENT =============

local ManagementSection = RecorderTab:Section({ Title = "Recording Management" })

ManagementSection:Button({
    Title = "Delete Selected Recording",
    Description = "Delete the selected recording",
    Icon = "trash-2",
    Callback = function()
        if not SelectedRecording or not FeatureState.SavedRecordings[SelectedRecording] then
            Utils:Notify("Delete Error", "No recording selected!", "alert-circle", 3)
            return
        end

        FeatureState.SavedRecordings[SelectedRecording] = nil
        UpdateRecordingDropdown()
        SelectedRecording = nil

        Utils:Notify("Recording Deleted", "Recording deleted successfully", "trash-2", 2)
    end
})

ManagementSection:Button({
    Title = "Clear All Recordings",
    Description = "Delete all saved recordings",
    Icon = "x-circle",
    Callback = function()
        FeatureState.SavedRecordings = {}
        UpdateRecordingDropdown()
        SelectedRecording = nil

        Utils:Notify("All Cleared", "All recordings deleted", "x-circle", 2)
    end
})

-- ============= MERGE SECTION =============

local MergeSection = RecorderTab:Section({ Title = "Merge Multiple Recordings" })

local SelectedRecordingsForMerge = {}
local MergedRecordingName = ""

MergeSection:Input({
    Title = "Merged Recording Name",
    Description = "Enter name for merged recording",
    Default = "Merged_Recording",
    Placeholder = "Enter name...",
    Callback = function(text)
        MergedRecordingName = text
    end
})

local MergeDropdown = nil

local function UpdateMergeDropdown()
    local options = {}
    for name, _ in pairs(FeatureState.SavedRecordings) do
        table.insert(options, name)
    end
    
    if #options == 0 then
        options = { "No recordings yet" }
    end
    
    if MergeDropdown then
        MergeDropdown:Refresh(options)
    end
    
    return options
end

MergeDropdown = MergeSection:Dropdown({
    Title = "Select Recordings to Merge",
    Description = "Choose recordings (select multiple)",
    Options = UpdateMergeDropdown(),
    Default = "No recordings yet",
    Callback = function(option)
        if option == "No recordings yet" then return end
        
        if FeatureState.SavedRecordings[option] then
            if not table.find(SelectedRecordingsForMerge, option) then
                table.insert(SelectedRecordingsForMerge, option)
                Utils:Notify("Recording Added", option .. " added to merge list (" .. #SelectedRecordingsForMerge .. " total)", "plus", 2)
            else
                Utils:Notify("Already Added", option .. " is already in merge list", "alert-circle", 2)
            end
        end
    end
})

MergeSection:Button({
    Title = "Show Selected Recordings",
    Description = "Display recordings selected for merge",
    Icon = "list",
    Callback = function()
        if #SelectedRecordingsForMerge == 0 then
            Utils:Notify("No Recordings Selected", "Please select recordings to merge", "alert-circle", 3)
            return
        end

        local list = "Selected recordings (" .. #SelectedRecordingsForMerge .. "):\n"
        for i, name in ipairs(SelectedRecordingsForMerge) do
            local recording = FeatureState.SavedRecordings[name]
            if recording then
                list = list .. "\n" .. i .. ". " .. name .. " (" .. recording.FrameCount .. " frames, " .. 
                       string.format("%.2fs", recording.Duration) .. ")"
            end
        end

        Utils:Notify("Merge List", list, "list", 6)
    end
})

MergeSection:Button({
    Title = "Remove Last from List",
    Description = "Remove last selected recording",
    Icon = "minus",
    Callback = function()
        if #SelectedRecordingsForMerge == 0 then
            Utils:Notify("List Empty", "No recordings to remove", "alert-circle", 2)
            return
        end

        local removed = table.remove(SelectedRecordingsForMerge, #SelectedRecordingsForMerge)
        Utils:Notify("Recording Removed", removed .. " removed from list", "minus", 2)
    end
})
-- ============= SAVE/LOAD TAB UI =============

local SaveSection = SaveLoadTab:Section({ Title = "Save Recordings to File" })

local SaveFileName = ""

SaveSection:Input({
    Title = "File Name",
    Description = "Enter name for save file",
    Default = "MyRecordings",
    Placeholder = "Enter filename...",
    Callback = function(text)
        SaveFileName = text
    end
})

SaveSection:Button({
    Title = "Save All Recordings",
    Description = "Export all recordings to file",
    Icon = "download",
    Callback = function()
        if SaveFileName == "" then
            SaveFileName = "RecordingData_" .. os.date("%Y%m%d_%H%M%S")
        end

        if next(FeatureState.SavedRecordings) == nil then
            Utils:Notify("Save Error", "No recordings to save!", "alert-circle", 3)
            return
        end

        SaveRecordingsToFile(SaveFileName)
    end
})

SaveSection:Button({
    Title = "Save Selected Recording",
    Description = "Export only selected recording",
    Icon = "file-down",
    Callback = function()
        if not SelectedRecording or not FeatureState.SavedRecordings[SelectedRecording] then
            Utils:Notify("Save Error", "No recording selected!", "alert-circle", 3)
            return
        end

        if SaveFileName == "" then
            SaveFileName = SelectedRecording
        end

        SaveRecordingsToFile(SaveFileName)
    end
})

local LoadSection = SaveLoadTab:Section({ Title = "Load Recordings from File" })

local LoadFileName = ""

LoadSection:Input({
    Title = "File Name to Load",
    Description = "Enter name of file to load",
    Default = "",
    Placeholder = "Enter filename...",
    Callback = function(text)
        LoadFileName = text
    end
})

LoadSection:Button({
    Title = "Load Recordings",
    Description = "Import recordings from file",
    Icon = "upload",
    Callback = function()
        if LoadFileName == "" then
            Utils:Notify("Load Error", "Please enter a filename!", "alert-circle", 3)
            return
        end

        LoadRecordingsFromFile(LoadFileName)
    end
})

LoadSection:Button({
    Title = "Merge with Current",
    Description = "Load and merge with existing recordings",
    Icon = "git-merge",
    Callback = function()
        if LoadFileName == "" then
            Utils:Notify("Load Error", "Please enter a filename!", "alert-circle", 3)
            return
        end

        LoadRecordingsFromFile(LoadFileName, true)
    end
})

-- ============= PERFORMANCE TAB UI =============

local GraphicsSection = PerformanceTab:Section({ Title = "Graphics Optimization" })

GraphicsSection:Toggle({
    Title = "Potato Graphics Mode",
    Description = "Convert all textures to gray plastic for better FPS",
    Icon = "zap",
    Default = false,
    Callback = function(value)
        FeatureState.PotatoGraphicsEnabled = value
        if value then
            EnablePotatoGraphics()
        else
            DisablePotatoGraphics()
        end

        Utils:Notify("Potato Graphics", value and "Potato Mode Enabled - FPS Boost!" or "Graphics Restored", "zap", 3)
    end
})

GraphicsSection:Button({
    Title = "Quick FPS Boost",
    Description = "Optimize rendering settings instantly",
    Icon = "trending-up",
    Callback = function()
        ApplyQuickFPSBoost()
        Utils:Notify("FPS Boost Applied", "Rendering optimized for performance", "check-circle", 3)
    end
})

GraphicsSection:Button({
    Title = "Remove All Effects",
    Description = "Delete all visual effects (particles, lights, etc)",
    Icon = "x-circle",
    Callback = function()
        RemoveAllEffects()
        Utils:Notify("Effects Removed", "All visual effects deleted", "check-circle", 3)
    end
})

local InfoSection = PerformanceTab:Section({ Title = "Performance Info" })

InfoSection:Button({
    Title = "Show Current FPS",
    Description = "Display your current frame rate",
    Icon = "activity",
    Callback = function()
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        Utils:Notify("Current FPS", "FPS: " .. fps, "activity", 3)
    end
})

InfoSection:Button({
    Title = "Restore All Graphics",
    Description = "Reset all graphics to original state",
    Icon = "rotate-ccw",
    Callback = function()
        DisablePotatoGraphics()
        Utils:Notify("Graphics Restored", "All graphics reset to original", "check-circle", 3)
    end
})

-- ============= MERGE BUTTONS =============

MergeSection:Button({
    Title = "Clear Merge List",
    Description = "Clear all selected recordings",
    Icon = "x",
    Callback = function()
        SelectedRecordingsForMerge = {}
        Utils:Notify("List Cleared", "All selections cleared", "x", 2)
    end
})

MergeSection:Divider()

MergeSection:Button({
    Title = "Merge Recordings (Sequential)",
    Description = "Combine recordings one after another",
    Icon = "git-merge",
    Callback = function()
        if #SelectedRecordingsForMerge < 2 then
            Utils:Notify("Merge Error", "Select at least 2 recordings to merge!", "alert-circle", 3)
            return
        end

        if MergedRecordingName == "" then
            MergedRecordingName = "Merged_" .. os.date("%H%M%S")
        end

        MergeRecordingsSequential(SelectedRecordingsForMerge, MergedRecordingName)
        SelectedRecordingsForMerge = {}
        UpdateMergeDropdown()
    end
})

MergeSection:Button({
    Title = "Merge with Smooth Transition",
    Description = "Blend recordings with smooth interpolation",
    Icon = "trending-up",
    Callback = function()
        if #SelectedRecordingsForMerge < 2 then
            Utils:Notify("Merge Error", "Select at least 2 recordings to merge!", "alert-circle", 3)
            return
        end

        if MergedRecordingName == "" then
            MergedRecordingName = "Merged_Smooth_" .. os.date("%H%M%S")
        end

        MergeRecordingsSmooth(SelectedRecordingsForMerge, MergedRecordingName)
        SelectedRecordingsForMerge = {}
        UpdateMergeDropdown()
    end
})

-- ============= PROTECT SPEED HEARTBEAT =============

if ActiveConnections.ProtectSpeedHeartbeat then
    pcall(function() ActiveConnections.ProtectSpeedHeartbeat:Disconnect() end)
end

ActiveConnections.ProtectSpeedHeartbeat = RunService.Heartbeat:Connect(function()
    ProtectSpeed()
end)

-- ============= GOD MODE HEARTBEAT =============

if ActiveConnections.GodModeHeartbeat then
    pcall(function() ActiveConnections.GodModeHeartbeat:Disconnect() end)
end

ActiveConnections.GodModeHeartbeat = RunService.Heartbeat:Connect(function()
    if FeatureState.GodModeEnabled then
        if Humanoid and Humanoid.Health ~= math.huge then
            EnableGodMode()
        end
    end
end)

-- ============= AIR JUMP HANDLER =============

Utils:SafeConnect(UserInputService.JumpRequest, function()
    if FeatureState.AirJumpEnabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ============= SCRIPT INITIALIZATION =============

Utils:Notify(
    "Movement Script Pro Loaded",
    "✅ Ultra Smooth Recorder at 240 FPS Ready!\n\n" ..
    "📌 Press RightControl to toggle UI\n" ..
    "🎥 Record your movements smoothly\n" ..
    "⚡ 6 Movement Features Available",
    "check-circle",
    5
)