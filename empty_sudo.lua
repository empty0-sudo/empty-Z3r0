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

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- Player Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Movement Features
local AirJumpEnabled = false
local NoclipEnabled = false
local AntiAFKEnabled = false
local GodModeEnabled = false
local WalkSpeedEnabled = false
local JumpPowerEnabled = false
local WalkSpeedValue = 16
local JumpPowerValue = 50

-- Recording Variables
local RecordingData = {}
local IsRecording = false
local IsReplaying = false
local RecordingName = ""
local RecordingStartTime = 0
local ReplayConnection = nil
local RecordConnection = nil
local SavedRecordings = {}
local CurrentRecordingIndex = 1

-- OPTIMIZED FPS SETTINGS (Turunkan untuk performa lebih baik)
local targetFPS = 60       -- DARI 240 → 60
local recordInterval = 1 / targetFPS
local replayTargetFPS = 60 -- DARI 240 → 60
local replayInterval = 1 / replayTargetFPS
local useAdvancedInterpolation = true
local useBezierCurve = false -- MATIKAN BEZIER
local smoothnessLevel = 3    -- DARI 5 → 3
local anticipationFactor = 0 -- MATIKAN ANTICIPATION

-- Pause Variables
local IsPaused = false
local PauseStartTime = 0
local TotalPausedTime = 0

-- Loop Replay Variables
local IsLoopEnabled = false
local LoopCount = 0
local MaxLoops = -1
local LoopTransitionEnabled = true
local LoopTransitionFrames = 15 -- KURANGI DARI 20 → 15
local CurrentLoopIteration = 0

-- Performance Variables
local PotatoGraphicsEnabled = false
local OriginalProperties = {}

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Movement Script Pro [OPTIMIZED]",
    Author = "Script Creator By emptyzo0ne",
    Size = UDim2.fromOffset(480, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Purple Premium Elegant",
    DisableMobile = false,
    SaveFolder = "MovementScript_Config"
})

-- Create Tabs
local MovementTab = Window:Tab({
    Title = "Movement",
    Icon = "gauge"
})

local RecorderTab = Window:Tab({
    Title = "Optimized Recorder",
    Icon = "video"
})

local SaveLoadTab = Window:Tab({
    Title = "Save/Load",
    Icon = "save"
})

local PerformanceTab = Window:Tab({
    Title = "Performance",
    Icon = "zap"
})

-- ==========================================
-- MOVEMENT TAB
-- ==========================================

local WalkSpeedSection = MovementTab:Section({
    Title = "WalkSpeed Control"
})

WalkSpeedSection:Toggle({
    Title = "Enable WalkSpeed",
    Description = "Toggle custom walk speed",
    Default = false,
    Callback = function(value)
        WalkSpeedEnabled = value
        if not value and Humanoid then
            Humanoid.WalkSpeed = 16
        elseif value and Humanoid then
            Humanoid.WalkSpeed = WalkSpeedValue
        end

        WindUI:Notify({
            Title = "WalkSpeed",
            Content = value and "WalkSpeed Enabled" or "WalkSpeed Disabled",
            Icon = "gauge",
            Duration = 2
        })
    end
})

WalkSpeedSection:Input({
    Title = "WalkSpeed Value",
    Description = "Enter speed value (0-1000)",
    Default = "16",
    Placeholder = "Enter speed...",
    Callback = function(text)
        local value = tonumber(text)
        if value and value >= 0 and value <= 1000 then
            WalkSpeedValue = value
            if WalkSpeedEnabled and Humanoid then
                Humanoid.WalkSpeed = value
            end

            WindUI:Notify({
                Title = "WalkSpeed Updated",
                Content = "Speed set to " .. value,
                Icon = "check",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Enter a number between 0-1000",
                Icon = "alert-circle",
                Duration = 3
            })
        end
    end
})

local JumpPowerSection = MovementTab:Section({
    Title = "JumpPower Control"
})

JumpPowerSection:Toggle({
    Title = "Enable JumpPower",
    Description = "Toggle custom jump power",
    Default = false,
    Callback = function(value)
        JumpPowerEnabled = value
        if not value and Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = 50
        elseif value and Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = JumpPowerValue
        end

        WindUI:Notify({
            Title = "JumpPower",
            Content = value and "JumpPower Enabled" or "JumpPower Disabled",
            Icon = "arrow-up",
            Duration = 2
        })
    end
})

JumpPowerSection:Input({
    Title = "JumpPower Value",
    Description = "Enter power value (0-1000)",
    Default = "50",
    Placeholder = "Enter power...",
    Callback = function(text)
        local value = tonumber(text)
        if value and value >= 0 and value <= 1000 then
            JumpPowerValue = value
            if JumpPowerEnabled and Humanoid then
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = value
            end

            WindUI:Notify({
                Title = "JumpPower Updated",
                Content = "Power set to " .. value,
                Icon = "check",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Enter a number between 0-1000",
                Icon = "alert-circle",
                Duration = 3
            })
        end
    end
})

local FeaturesSection = MovementTab:Section({
    Title = "Special Features"
})

FeaturesSection:Toggle({
    Title = "Air Jump",
    Description = "Infinite jump in the air",
    Icon = "wind",
    Default = false,
    Callback = function(value)
        AirJumpEnabled = value
        WindUI:Notify({
            Title = "Air Jump",
            Content = value and "Enabled" or "Disabled",
            Icon = "wind",
            Duration = 2
        })
    end
})

FeaturesSection:Toggle({
    Title = "Noclip",
    Description = "Walk through walls",
    Icon = "shield-off",
    Default = false,
    Callback = function(value)
        NoclipEnabled = value
        WindUI:Notify({
            Title = "Noclip",
            Content = value and "Enabled" or "Disabled",
            Icon = "shield-off",
            Duration = 2
        })
    end
})

FeaturesSection:Toggle({
    Title = "Anti AFK",
    Description = "Prevent AFK kick",
    Icon = "clock",
    Default = false,
    Callback = function(value)
        AntiAFKEnabled = value
        WindUI:Notify({
            Title = "Anti AFK",
            Content = value and "You won't be kicked" or "AFK detection active",
            Icon = "clock",
            Duration = 3
        })
    end
})

FeaturesSection:Toggle({
    Title = "God Mode",
    Description = "Immortal character",
    Icon = "shield",
    Default = false,
    Callback = function(value)
        GodModeEnabled = value
        if value then
            EnableGodMode()
        else
            DisableGodMode()
        end

        WindUI:Notify({
            Title = "God Mode",
            Content = value and "You are now immortal!" or "You can take damage now",
            Icon = "shield",
            Duration = 3
        })
    end
})

FeaturesSection:Divider()

FeaturesSection:Button({
    Title = "Reset Character",
    Description = "Respawn your character",
    Icon = "refresh-cw",
    Callback = function()
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = 0
            WindUI:Notify({
                Title = "Character Reset",
                Content = "Respawning...",
                Icon = "refresh-cw",
                Duration = 2
            })
        end
    end
})

-- ==========================================
-- RECORDER TAB
-- ==========================================

local RecorderControlSection = RecorderTab:Section({
    Title = "Recording Controls (60 FPS Optimized)"
})

RecorderControlSection:Input({
    Title = "Recording Name",
    Description = "Enter name for this recording",
    Default = "Recording_1",
    Placeholder = "Enter name...",
    Callback = function(text)
        RecordingName = text
    end
})

RecorderControlSection:Button({
    Title = "Start Recording",
    Description = "Record at 60 FPS",
    Icon = "circle",
    Callback = function()
        if IsRecording then
            WindUI:Notify({
                Title = "Recording Error",
                Content = "Already recording!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if IsReplaying then
            WindUI:Notify({
                Title = "Recording Error",
                Content = "Stop replay first!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if RecordingName == "" then
            RecordingName = "Recording_" .. CurrentRecordingIndex
            CurrentRecordingIndex = CurrentRecordingIndex + 1
        end

        StartRecording()
    end
})

RecorderControlSection:Button({
    Title = "Stop Recording",
    Description = "Stop and save recording",
    Icon = "square",
    Callback = function()
        if not IsRecording then
            WindUI:Notify({
                Title = "Recording Error",
                Content = "Not recording!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        StopRecording()
    end
})

RecorderControlSection:Button({
    Title = "Pause/Resume Recording",
    Description = "Pause or resume current recording",
    Icon = "pause-circle",
    Callback = function()
        if not IsRecording then
            WindUI:Notify({
                Title = "Pause Error",
                Content = "Not recording!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if IsPaused then
            ResumeRecording()
        else
            PauseRecording()
        end
    end
})

local ReplaySection = RecorderTab:Section({
    Title = "Replay Controls"
})

local RecordingDropdownOptions = { "No recordings yet" }
local SelectedRecording = nil

local RecordingDropdown = ReplaySection:Dropdown({
    Title = "Select Recording",
    Description = "Choose recording to replay",
    Options = RecordingDropdownOptions,
    Default = RecordingDropdownOptions[1],
    Callback = function(option)
        if SavedRecordings[option] then
            SelectedRecording = option
            WindUI:Notify({
                Title = "Recording Selected",
                Content = option .. " selected",
                Icon = "check",
                Duration = 2
            })
        end
    end
})

ReplaySection:Button({
    Title = "Play Replay",
    Description = "Replay with smooth interpolation",
    Icon = "play",
    Callback = function()
        if IsReplaying then
            WindUI:Notify({
                Title = "Replay Error",
                Content = "Already replaying!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if IsRecording then
            WindUI:Notify({
                Title = "Replay Error",
                Content = "Stop recording first!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if not SelectedRecording or not SavedRecordings[SelectedRecording] then
            WindUI:Notify({
                Title = "Replay Error",
                Content = "No recording selected!",
                Icon = "alert-circle",
                Duration = 3
            })
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
        if not IsReplaying then
            WindUI:Notify({
                Title = "Replay Error",
                Content = "Not replaying!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        StopReplay()
    end
})

ReplaySection:Button({
    Title = "Pause/Resume Replay",
    Description = "Pause or resume current replay",
    Icon = "pause-circle",
    Callback = function()
        if not IsReplaying then
            WindUI:Notify({
                Title = "Pause Error",
                Content = "Not replaying!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if IsPaused then
            ResumeReplay()
        else
            PauseReplay()
        end
    end
})

-- Loop Replay Section
local LoopSection = RecorderTab:Section({
    Title = "Loop Replay Controls"
})

LoopSection:Toggle({
    Title = "Enable Loop Replay",
    Description = "Replay will loop continuously",
    Icon = "repeat",
    Default = false,
    Callback = function(value)
        IsLoopEnabled = value

        WindUI:Notify({
            Title = "Loop Mode",
            Content = value and "Loop enabled" or "Loop disabled",
            Icon = "repeat",
            Duration = 2
        })
    end
})

LoopSection:Toggle({
    Title = "Smooth Loop Transition",
    Description = "Add smooth transition between loops",
    Icon = "activity",
    Default = true,
    Callback = function(value)
        LoopTransitionEnabled = value

        WindUI:Notify({
            Title = "Smooth Transition",
            Content = value and "Enabled" or "Instant restart",
            Icon = "activity",
            Duration = 2
        })
    end
})

LoopSection:Input({
    Title = "Max Loop Count",
    Description = "Number of loops (-1 for infinite)",
    Default = "-1",
    Placeholder = "Enter number...",
    Callback = function(text)
        local value = tonumber(text)
        if value and (value >= -1) then
            MaxLoops = value

            local content = value == -1 and "Infinite loops" or value .. " loops"
            WindUI:Notify({
                Title = "Max Loops Set",
                Content = content,
                Icon = "check",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Enter a number >= -1",
                Icon = "alert-circle",
                Duration = 3
            })
        end
    end
})

LoopSection:Input({
    Title = "Transition Frames",
    Description = "Frames for smooth loop (10-30)",
    Default = "15",
    Placeholder = "Enter frames...",
    Callback = function(text)
        local value = tonumber(text)
        if value and value >= 10 and value <= 30 then
            LoopTransitionFrames = value

            WindUI:Notify({
                Title = "Transition Updated",
                Content = value .. " frames",
                Icon = "check",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Enter 10-30",
                Icon = "alert-circle",
                Duration = 3
            })
        end
    end
})

LoopSection:Divider()

LoopSection:Button({
    Title = "Show Loop Status",
    Description = "Display current loop information",
    Icon = "info",
    Callback = function()
        if not IsReplaying then
            WindUI:Notify({
                Title = "Not Replaying",
                Content = "Start a replay first",
                Icon = "alert-circle",
                Duration = 2
            })
            return
        end

        local status = string.format(
            "Loop Status:\n\nEnabled: %s\nIteration: %d\nMax: %s\nSmooth: %s\nFrames: %d",
            IsLoopEnabled and "Yes" or "No",
            CurrentLoopIteration,
            MaxLoops == -1 and "∞" or tostring(MaxLoops),
            LoopTransitionEnabled and "Yes" or "No",
            LoopTransitionFrames
        )

        WindUI:Notify({
            Title = "Loop Info",
            Content = status,
            Icon = "info",
            Duration = 4
        })
    end
})

LoopSection:Button({
    Title = "Reset Loop Counter",
    Description = "Reset iteration count",
    Icon = "rotate-ccw",
    Callback = function()
        CurrentLoopIteration = 0

        WindUI:Notify({
            Title = "Counter Reset",
            Content = "Reset to 0",
            Icon = "rotate-ccw",
            Duration = 2
        })
    end
})

local ManagementSection = RecorderTab:Section({
    Title = "Recording Management"
})

ManagementSection:Button({
    Title = "Delete Selected Recording",
    Description = "Delete the selected recording",
    Icon = "trash-2",
    Callback = function()
        if not SelectedRecording or not SavedRecordings[SelectedRecording] then
            WindUI:Notify({
                Title = "Delete Error",
                Content = "No recording selected!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        SavedRecordings[SelectedRecording] = nil
        UpdateRecordingDropdown()
        SelectedRecording = nil

        WindUI:Notify({
            Title = "Recording Deleted",
            Content = "Deleted successfully",
            Icon = "trash-2",
            Duration = 2
        })
    end
})

ManagementSection:Button({
    Title = "Clear All Recordings",
    Description = "Delete all saved recordings",
    Icon = "x-circle",
    Callback = function()
        SavedRecordings = {}
        UpdateRecordingDropdown()
        SelectedRecording = nil

        WindUI:Notify({
            Title = "All Cleared",
            Content = "All recordings deleted",
            Icon = "x-circle",
            Duration = 2
        })
    end
})

-- Merge Section
local MergeSection = RecorderTab:Section({
    Title = "Merge Recordings"
})

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
    for name, _ in pairs(SavedRecordings) do
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

local MergeDropdownOptions = UpdateMergeDropdown()

MergeDropdown = MergeSection:Dropdown({
    Title = "Select Recordings",
    Description = "Choose recordings to merge",
    Options = MergeDropdownOptions,
    Default = MergeDropdownOptions[1],
    Callback = function(option)
        if option == "No recordings yet" then return end

        if SavedRecordings[option] then
            if not table.find(SelectedRecordingsForMerge, option) then
                table.insert(SelectedRecordingsForMerge, option)
                WindUI:Notify({
                    Title = "Added",
                    Content = option .. " (" .. #SelectedRecordingsForMerge .. " total)",
                    Icon = "plus",
                    Duration = 2
                })
            end
        end
    end
})

MergeSection:Button({
    Title = "Show Selected",
    Description = "Display recordings to merge",
    Icon = "list",
    Callback = function()
        if #SelectedRecordingsForMerge == 0 then
            WindUI:Notify({
                Title = "No Selection",
                Content = "Select recordings first",
                Icon = "alert-circle",
                Duration = 2
            })
            return
        end

        local list = #SelectedRecordingsForMerge .. " selected:\n"
        for i, name in ipairs(SelectedRecordingsForMerge) do
            list = list .. "\n" .. i .. ". " .. name
        end

        WindUI:Notify({
            Title = "Merge List",
            Content = list,
            Icon = "list",
            Duration = 5
        })
    end
})

MergeSection:Button({
    Title = "Clear List",
    Description = "Clear selections",
    Icon = "x",
    Callback = function()
        SelectedRecordingsForMerge = {}
        WindUI:Notify({
            Title = "Cleared",
            Content = "List cleared",
            Icon = "x",
            Duration = 2
        })
    end
})

MergeSection:Divider()

MergeSection:Button({
    Title = "Merge Sequential",
    Description = "Combine one after another",
    Icon = "git-merge",
    Callback = function()
        if #SelectedRecordingsForMerge < 2 then
            WindUI:Notify({
                Title = "Merge Error",
                Content = "Select at least 2!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if MergedRecordingName == "" then
            MergedRecordingName = "Merged_" .. os.date("%H%M%S")
        end

        MergeRecordingsSequential(SelectedRecordingsForMerge, MergedRecordingName)
    end
})

MergeSection:Button({
    Title = "Merge Smooth",
    Description = "Blend with transitions",
    Icon = "trending-up",
    Callback = function()
        if #SelectedRecordingsForMerge < 2 then
            WindUI:Notify({
                Title = "Merge Error",
                Content = "Select at least 2!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if MergedRecordingName == "" then
            MergedRecordingName = "Merged_Smooth_" .. os.date("%H%M%S")
        end

        MergeRecordingsSmooth(SelectedRecordingsForMerge, MergedRecordingName)
    end
})

-- ==========================================
-- SAVE/LOAD TAB
-- ==========================================

local SaveSection = SaveLoadTab:Section({
    Title = "Save Recordings"
})

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
    Description = "Export all to file",
    Icon = "download",
    Callback = function()
        if SaveFileName == "" then
            SaveFileName = "RecordingData_" .. os.date("%Y%m%d_%H%M%S")
        end

        if next(SavedRecordings) == nil then
            WindUI:Notify({
                Title = "Save Error",
                Content = "No recordings to save!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        SaveRecordingsToFile(SaveFileName)
    end
})

SaveSection:Button({
    Title = "Save Selected",
    Description = "Export only selected",
    Icon = "file-down",
    Callback = function()
        if not SelectedRecording or not SavedRecordings[SelectedRecording] then
            WindUI:Notify({
                Title = "Save Error",
                Content = "No recording selected!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        if SaveFileName == "" then
            SaveFileName = SelectedRecording
        end

        SaveSingleRecording(SaveFileName, SelectedRecording)
    end
})

local LoadSection = SaveLoadTab:Section({
    Title = "Load Recordings"
})

local LoadFileName = ""

LoadSection:Input({
    Title = "File Name to Load",
    Description = "Enter file name",
    Default = "",
    Placeholder = "Enter filename...",
    Callback = function(text)
        LoadFileName = text
    end
})

LoadSection:Button({
    Title = "Load Recordings",
    Description = "Import from file",
    Icon = "upload",
    Callback = function()
        if LoadFileName == "" then
            WindUI:Notify({
                Title = "Load Error",
                Content = "Enter a filename!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        LoadRecordingsFromFile(LoadFileName)
    end
})

LoadSection:Button({
    Title = "Merge with Current",
    Description = "Load and merge",
    Icon = "git-merge",
    Callback = function()
        if LoadFileName == "" then
            WindUI:Notify({
                Title = "Load Error",
                Content = "Enter a filename!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        LoadRecordingsFromFile(LoadFileName, true)
    end
})

local InfoSection = SaveLoadTab:Section({
    Title = "File Info"
})

InfoSection:Button({
    Title = "Show Saved Files",
    Description = "List all files",
    Icon = "list",
    Callback = function()
        ShowSavedFiles()
    end
})

InfoSection:Button({
    Title = "Export to Clipboard",
    Description = "Copy as text",
    Icon = "clipboard",
    Callback = function()
        if not SelectedRecording or not SavedRecordings[SelectedRecording] then
            WindUI:Notify({
                Title = "Export Error",
                Content = "No recording selected!",
                Icon = "alert-circle",
                Duration = 3
            })
            return
        end

        ExportToClipboard(SelectedRecording)
    end
})

InfoSection:Button({
    Title = "Import from Clipboard",
    Description = "Load from clipboard",
    Icon = "clipboard-paste",
    Callback = function()
        ImportFromClipboard()
    end
})

-- ==========================================
-- PERFORMANCE TAB
-- ==========================================

local GraphicsSection = PerformanceTab:Section({
    Title = "Graphics Optimization"
})

GraphicsSection:Toggle({
    Title = "Potato Graphics Mode",
    Description = "Gray plastic for FPS boost",
    Icon = "zap",
    Default = false,
    Callback = function(value)
        PotatoGraphicsEnabled = value
        if value then
            EnablePotatoGraphics()
        else
            DisablePotatoGraphics()
        end

        WindUI:Notify({
            Title = "Potato Graphics",
            Content = value and "FPS Boost!" or "Restored",
            Icon = "zap",
            Duration = 3
        })
    end
})

GraphicsSection:Button({
    Title = "Quick FPS Boost",
    Description = "Optimize rendering",
    Icon = "trending-up",
    Callback = function()
        ApplyQuickFPSBoost()
        WindUI:Notify({
            Title = "FPS Boost",
            Content = "Rendering optimized",
            Icon = "check-circle",
            Duration = 3
        })
    end
})

GraphicsSection:Button({
    Title = "Remove All Effects",
    Description = "Delete visual effects",
    Icon = "x-circle",
    Callback = function()
        RemoveAllEffects()

        WindUI:Notify({
            Title = "Effects Removed",
            Content = "All effects deleted",
            Icon = "check-circle",
            Duration = 3
        })
    end
})

local PerformanceMonitor = PerformanceTab:Section({
    Title = "Performance Monitor"
})

local currentFPS = 0
local fpsUpdateTime = tick()

RunService.Heartbeat:Connect(function()
    if tick() - fpsUpdateTime >= 1 then
        currentFPS = math.floor(1 / RunService.Heartbeat:Wait())
        fpsUpdateTime = tick()
    end
end)

PerformanceMonitor:Button({
    Title = "Show Performance Stats",
    Description = "Display FPS and info",
    Icon = "activity",
    Callback = function()
        local recordingCount = 0
        local totalFrames = 0

        for name, recording in pairs(SavedRecordings) do
            recordingCount = recordingCount + 1
            totalFrames = totalFrames + recording.FrameCount
        end

        local memUsage = totalFrames > 5000 and "High" or totalFrames > 2000 and "Medium" or "Low"

        local stats = string.format(
            "Performance:\n\nFPS: %d\nRecordings: %d\nTotal Frames: %d\nMemory: %s\n\nRecord FPS: %d\nReplay FPS: %d",
            currentFPS,
            recordingCount,
            totalFrames,
            memUsage,
            targetFPS,
            replayTargetFPS
        )

        WindUI:Notify({
            Title = "Performance Info",
            Content = stats,
            Icon = "activity",
            Duration = 6
        })
    end
})

PerformanceMonitor:Button({
    Title = "Clear Memory Cache",
    Description = "Remove old recordings",
    Icon = "trash-2",
    Callback = function()
        CleanupOldRecordings(5)
    end
})

PerformanceMonitor:Button({
    Title = "Restore All Graphics",
    Description = "Reset graphics",
    Icon = "rotate-ccw",
    Callback = function()
        DisablePotatoGraphics()

        WindUI:Notify({
            Title = "Graphics Restored",
            Content = "All reset",
            Icon = "check-circle",
            Duration = 3
        })
    end
})

-- ==========================================
-- CORE FUNCTIONS
-- ==========================================

local function GetAnimationState()
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

local function EaseInOutCubic(t)
    return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
end

-- OPTIMIZED GetInterpolatedFrame dengan Binary Search
local function GetInterpolatedFrame(currentTime, smoothLevel)
    if #RecordingData < 2 then return RecordingData[1] end

    -- Binary search untuk frame (lebih cepat)
    local left, right = 1, #RecordingData
    local frameIndex = 1

    while left <= right do
        local mid = math.floor((left + right) / 2)
        if RecordingData[mid].time <= currentTime then
            frameIndex = mid
            left = mid + 1
        else
            right = mid - 1
        end
    end

    frameIndex = math.max(1, math.min(frameIndex, #RecordingData - 1))

    local f1 = RecordingData[frameIndex]
    local f2 = RecordingData[frameIndex + 1]

    if not (f1 and f2) then return f1 end

    local timeDiff = f2.time - f1.time
    if timeDiff <= 0 then return f1 end

    local t = math.clamp((currentTime - f1.time) / timeDiff, 0, 1)

    local result = {}

    -- Simple lerp (lebih cepat dari Bezier)
    result.cframe = f1.cframe:Lerp(f2.cframe, t)
    result.velocity = f1.velocity:Lerp(f2.velocity, t)

    result.animationState = t < 0.5 and f1.animationState or f2.animationState
    result.humanoidState = t < 0.5 and f1.humanoidState or f2.humanoidState
    result.moveDirection = f1.moveDirection:Lerp(f2.moveDirection, t)
    result.moveSpeed = f1.moveSpeed + (f2.moveSpeed - f1.moveSpeed) * t
    result.verticalVelocity = f1.verticalVelocity + (f2.verticalVelocity - f1.verticalVelocity) * t
    result.jumpPower = f1.jumpPower

    return result
end

local function SetAnimationState(state, moveDir, speed, humanoidState, verticalVel)
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

function StartRecording()
    IsRecording = true
    IsPaused = false
    TotalPausedTime = 0
    RecordingData = {}
    RecordingStartTime = tick()

    WindUI:Notify({
        Title = "Recording Started",
        Content = "Recording at 60 FPS: " .. RecordingName,
        Icon = "circle",
        Duration = 3
    })

    local lastRecordTime = tick()
    local accumulatedDelta = 0

    RecordConnection = RunService.Heartbeat:Connect(function()
        if not IsRecording then return end
        if IsPaused then return end

        local currentTick = tick()
        local deltaTime = currentTick - lastRecordTime
        accumulatedDelta = accumulatedDelta + deltaTime

        while accumulatedDelta >= recordInterval do
            local currentTime = currentTick - RecordingStartTime - TotalPausedTime
            local animState = GetAnimationState()

            table.insert(RecordingData, {
                time = currentTime,
                deltaTime = recordInterval,
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

            accumulatedDelta = accumulatedDelta - recordInterval
        end

        lastRecordTime = currentTick
    end)
end

function StopRecording()
    IsRecording = false
    IsPaused = false
    TotalPausedTime = 0

    if RecordConnection then
        RecordConnection:Disconnect()
        RecordConnection = nil
    end

    if #RecordingData > 0 then
        SavedRecordings[RecordingName] = {
            Data = RecordingData,
            Duration = tick() - RecordingStartTime - TotalPausedTime,
            FrameCount = #RecordingData,
            CreatedAt = os.date("%X %x")
        }

        UpdateRecordingDropdown()
        CleanupOldRecordings(10)

        WindUI:Notify({
            Title = "Recording Saved",
            Content = string.format("%s saved! (%d frames, %.2fs)", RecordingName, #RecordingData,
                tick() - RecordingStartTime - TotalPausedTime),
            Icon = "save",
            Duration = 4
        })

        RecordingName = ""
    else
        WindUI:Notify({
            Title = "Recording Error",
            Content = "No data recorded!",
            Icon = "alert-circle",
            Duration = 3
        })
    end

    RecordingData = {}
end

function PauseRecording()
    if not IsRecording or IsPaused then return end

    IsPaused = true
    PauseStartTime = tick()

    WindUI:Notify({
        Title = "Recording Paused",
        Content = string.format("Paused at %.2fs", tick() - RecordingStartTime),
        Icon = "pause-circle",
        Duration = 3
    })
end

function ResumeRecording()
    if not IsRecording or not IsPaused then return end

    local pauseDuration = tick() - PauseStartTime
    TotalPausedTime = TotalPausedTime + pauseDuration
    IsPaused = false

    WindUI:Notify({
        Title = "Recording Resumed",
        Content = string.format("Paused for %.2fs", pauseDuration),
        Icon = "play-circle",
        Duration = 3
    })
end

-- OPTIMIZED StartReplay Function
function StartReplay(recordingName)
    local recording = SavedRecordings[recordingName]
    if not recording or not recording.Data then return end

    IsReplaying = true
    IsPaused = false
    TotalPausedTime = 0
    RecordingData = recording.Data
    CurrentLoopIteration = 0

    WindUI:Notify({
        Title = "Replay Started",
        Content = "Playing: " .. recordingName .. (IsLoopEnabled and " (Loop)" or ""),
        Icon = "play",
        Duration = 3
    })

    local startTime = tick()
    local lastFrame = nil
    local lastUpdateTime = tick()
    local pausedPosition = nil
    local isInLoopTransition = false
    local loopTransitionStartTime = 0

    -- Frame skip untuk performa
    local frameSkip = 0
    local maxFrameSkip = 2

    ReplayConnection = RunService.Heartbeat:Connect(function()
        if not IsReplaying or not RootPart then
            StopReplay()
            return
        end

        if IsPaused then
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

        -- Frame skip logic
        if deltaTime < replayInterval * 0.5 then
            frameSkip = frameSkip + 1
            if frameSkip < maxFrameSkip then
                return
            end
        end
        frameSkip = 0

        local currentTime = currentTick - startTime - TotalPausedTime
        local totalDuration = RecordingData[#RecordingData].time

        -- Loop Transition
        if isInLoopTransition then
            local transitionProgress = (currentTick - loopTransitionStartTime) / (LoopTransitionFrames * recordInterval)

            if transitionProgress >= 1 then
                isInLoopTransition = false
                startTime = tick()
                TotalPausedTime = 0
                currentTime = 0
                CurrentLoopIteration = CurrentLoopIteration + 1

                if CurrentLoopIteration % 5 == 0 or CurrentLoopIteration == 1 then
                    WindUI:Notify({
                        Title = "Loop " .. CurrentLoopIteration,
                        Content = MaxLoops == -1 and "Loop: " .. CurrentLoopIteration or
                            "Loop " .. CurrentLoopIteration .. "/" .. MaxLoops,
                        Icon = "repeat",
                        Duration = 1
                    })
                end
            else
                local lastRecordFrame = RecordingData[#RecordingData]
                local firstRecordFrame = RecordingData[1]

                local transitionFrame = {
                    cframe = lastRecordFrame.cframe:Lerp(firstRecordFrame.cframe, transitionProgress),
                    velocity = lastRecordFrame.velocity:Lerp(firstRecordFrame.velocity, transitionProgress),
                    animationState = transitionProgress < 0.5 and lastRecordFrame.animationState or
                    firstRecordFrame.animationState,
                    humanoidState = transitionProgress < 0.5 and lastRecordFrame.humanoidState or
                    firstRecordFrame.humanoidState,
                    moveDirection = lastRecordFrame.moveDirection:Lerp(firstRecordFrame.moveDirection, transitionProgress),
                    moveSpeed = lastRecordFrame.moveSpeed +
                    (firstRecordFrame.moveSpeed - lastRecordFrame.moveSpeed) * transitionProgress,
                    verticalVelocity = lastRecordFrame.verticalVelocity +
                    (firstRecordFrame.verticalVelocity - lastRecordFrame.verticalVelocity) * transitionProgress
                }

                RootPart.CFrame = transitionFrame.cframe
                RootPart.AssemblyLinearVelocity = transitionFrame.velocity
                SetAnimationState(transitionFrame.animationState, transitionFrame.moveDirection,
                    transitionFrame.moveSpeed, transitionFrame.humanoidState,
                    transitionFrame.verticalVelocity)

                return
            end
        end

        -- Check replay completion
        if currentTime >= totalDuration then
            if IsLoopEnabled then
                if MaxLoops ~= -1 and CurrentLoopIteration >= MaxLoops then
                    StopReplay()
                    WindUI:Notify({
                        Title = "Loop Completed",
                        Content = "Finished " .. MaxLoops .. " loops",
                        Icon = "check-circle",
                        Duration = 3
                    })
                    return
                end

                if LoopTransitionEnabled and LoopTransitionFrames > 0 then
                    isInLoopTransition = true
                    loopTransitionStartTime = tick()
                else
                    startTime = tick()
                    TotalPausedTime = 0
                    CurrentLoopIteration = CurrentLoopIteration + 1
                end
                return
            else
                StopReplay()
                WindUI:Notify({
                    Title = "Replay Completed",
                    Content = recordingName .. " finished!",
                    Icon = "check-circle",
                    Duration = 3
                })
                return
            end
        end

        local frame = GetInterpolatedFrame(currentTime, smoothnessLevel)

        if frame then
            RootPart.CFrame = frame.cframe

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
    IsReplaying = false
    IsPaused = false
    TotalPausedTime = 0
    CurrentLoopIteration = 0

    if ReplayConnection then
        ReplayConnection:Disconnect()
        ReplayConnection = nil
    end

    Humanoid:Move(Vector3.new(0, 0, 0), false)
    RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    WindUI:Notify({
        Title = "Replay Stopped",
        Content = "Replay stopped",
        Icon = "square",
        Duration = 2
    })
end

function PauseReplay()
    if not IsReplaying or IsPaused then return end

    IsPaused = true
    PauseStartTime = tick()

    if Humanoid then
        Humanoid:Move(Vector3.new(0, 0, 0), false)
    end

    WindUI:Notify({
        Title = "Replay Paused",
        Content = "Paused",
        Icon = "pause-circle",
        Duration = 2
    })
end

function ResumeReplay()
    if not IsReplaying or not IsPaused then return end

    local pauseDuration = tick() - PauseStartTime
    TotalPausedTime = TotalPausedTime + pauseDuration
    IsPaused = false

    WindUI:Notify({
        Title = "Replay Resumed",
        Content = "Resumed",
        Icon = "play-circle",
        Duration = 2
    })
end

function UpdateRecordingDropdown()
    RecordingDropdownOptions = {}

    for name, _ in pairs(SavedRecordings) do
        table.insert(RecordingDropdownOptions, name)
    end

    if #RecordingDropdownOptions == 0 then
        RecordingDropdownOptions = { "No recordings yet" }
    end

    RecordingDropdown:Refresh(RecordingDropdownOptions)
end

-- Merge Functions
function MergeRecordingsSequential(recordingNames, newName)
    local success, result = pcall(function()
        local mergedData = {}
        local totalDuration = 0
        local totalFrames = 0
        local currentTimeOffset = 0

        for index, name in ipairs(recordingNames) do
            local recording = SavedRecordings[name]
            if not recording then
                return false, "Recording '" .. name .. "' not found"
            end

            for i, frame in ipairs(recording.Data) do
                local newFrame = {
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
                }
                table.insert(mergedData, newFrame)
                totalFrames = totalFrames + 1
            end

            currentTimeOffset = currentTimeOffset + recording.Duration
            totalDuration = totalDuration + recording.Duration
        end

        SavedRecordings[newName] = {
            Data = mergedData,
            Duration = totalDuration,
            FrameCount = totalFrames,
            CreatedAt = os.date("%X %x"),
            IsMerged = true,
            MergedFrom = recordingNames
        }

        UpdateRecordingDropdown()
        UpdateMergeDropdown()
        SelectedRecordingsForMerge = {}

        return true, totalFrames, totalDuration
    end)

    if success and result then
        local frames, duration = select(2, result), select(3, result)
        WindUI:Notify({
            Title = "Merge Successful",
            Content = string.format("Created '%s'\n%d recordings\n%d frames, %.2fs",
                newName, #recordingNames, frames, duration),
            Icon = "check-circle",
            Duration = 5
        })
    else
        WindUI:Notify({
            Title = "Merge Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
    end
end

function MergeRecordingsSmooth(recordingNames, newName)
    local success, result = pcall(function()
        local mergedData = {}
        local totalDuration = 0
        local totalFrames = 0
        local currentTimeOffset = 0
        local transitionFrames = 20

        for index, name in ipairs(recordingNames) do
            local recording = SavedRecordings[name]
            if not recording then
                return false, "Recording '" .. name .. "' not found"
            end

            local isLastRecording = (index == #recordingNames)

            for i, frame in ipairs(recording.Data) do
                local newFrame = {
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
                }
                table.insert(mergedData, newFrame)
                totalFrames = totalFrames + 1
            end

            if not isLastRecording and index < #recordingNames then
                local nextRecording = SavedRecordings[recordingNames[index + 1]]
                if nextRecording and #nextRecording.Data > 0 then
                    local lastFrame = recording.Data[#recording.Data]
                    local firstNextFrame = nextRecording.Data[1]

                    for t = 1, transitionFrames do
                        local alpha = t / transitionFrames
                        local smoothAlpha = EaseInOutCubic(alpha)

                        local transitionTime = currentTimeOffset + recording.Duration + (t * recordInterval)

                        local transitionFrame = {
                            time = transitionTime,
                            deltaTime = recordInterval,
                            position = lastFrame.position:Lerp(firstNextFrame.position, smoothAlpha),
                            cframe = lastFrame.cframe:Lerp(firstNextFrame.cframe, smoothAlpha),
                            velocity = lastFrame.velocity:Lerp(firstNextFrame.velocity, smoothAlpha),
                            rotation = lastFrame.rotation:Lerp(firstNextFrame.rotation, smoothAlpha),
                            lookVector = lastFrame.lookVector:Lerp(firstNextFrame.lookVector, smoothAlpha),
                            animationState = alpha < 0.5 and lastFrame.animationState or firstNextFrame.animationState,
                            humanoidState = alpha < 0.5 and lastFrame.humanoidState or firstNextFrame.humanoidState,
                            isJumping = alpha < 0.5 and lastFrame.isJumping or firstNextFrame.isJumping,
                            jumpPower = lastFrame.jumpPower +
                            (firstNextFrame.jumpPower - lastFrame.jumpPower) * smoothAlpha,
                            moveDirection = lastFrame.moveDirection:Lerp(firstNextFrame.moveDirection, smoothAlpha),
                            moveSpeed = lastFrame.moveSpeed +
                            (firstNextFrame.moveSpeed - lastFrame.moveSpeed) * smoothAlpha,
                            verticalVelocity = lastFrame.verticalVelocity +
                            (firstNextFrame.verticalVelocity - lastFrame.verticalVelocity) * smoothAlpha
                        }

                        table.insert(mergedData, transitionFrame)
                        totalFrames = totalFrames + 1
                    end

                    totalDuration = totalDuration + (transitionFrames * recordInterval)
                end
            end

            currentTimeOffset = currentTimeOffset + recording.Duration +
            (isLastRecording and 0 or (transitionFrames * recordInterval))
            totalDuration = totalDuration + recording.Duration
        end

        SavedRecordings[newName] = {
            Data = mergedData,
            Duration = totalDuration,
            FrameCount = totalFrames,
            CreatedAt = os.date("%X %x"),
            IsMerged = true,
            IsSmooth = true,
            MergedFrom = recordingNames
        }

        UpdateRecordingDropdown()
        UpdateMergeDropdown()
        SelectedRecordingsForMerge = {}

        return true, totalFrames, totalDuration
    end)

    if success and result then
        local frames, duration = select(2, result), select(3, result)
        WindUI:Notify({
            Title = "Smooth Merge OK",
            Content = string.format("'%s' created\n%d recordings\n%d frames",
                newName, #recordingNames, frames),
            Icon = "check-circle",
            Duration = 5
        })
    else
        WindUI:Notify({
            Title = "Merge Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
    end
end

-- Save/Load Functions
function SaveRecordingsToFile(filename)
    local success, result = pcall(function()
        local dataToSave = {
            Version = "1.0",
            SaveDate = os.date("%Y-%m-%d %H:%M:%S"),
            RecordingCount = 0,
            Recordings = {}
        }

        local count = 0
        for name, recording in pairs(SavedRecordings) do
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
                    humanoidState = tostring(frame.humanoidState),
                    isJumping = frame.isJumping,
                    jumpPower = frame.jumpPower,
                    moveDirection = { frame.moveDirection.X, frame.moveDirection.Y, frame.moveDirection.Z },
                    moveSpeed = frame.moveSpeed,
                    verticalVelocity = frame.verticalVelocity
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

    if success and result then
        WindUI:Notify({
            Title = "Save Successful",
            Content = string.format("Saved %d recordings", result),
            Icon = "check-circle",
            Duration = 4
        })
    else
        WindUI:Notify({
            Title = "Save Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
    end
end

function SaveSingleRecording(filename, recordingName)
    local success, result = pcall(function()
        local recording = SavedRecordings[recordingName]

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
                humanoidState = tostring(frame.humanoidState),
                isJumping = frame.isJumping,
                jumpPower = frame.jumpPower,
                moveDirection = { frame.moveDirection.X, frame.moveDirection.Y, frame.moveDirection.Z },
                moveSpeed = frame.moveSpeed,
                verticalVelocity = frame.verticalVelocity
            })
        end

        local dataToSave = {
            Version = "1.0",
            SaveDate = os.date("%Y-%m-%d %H:%M:%S"),
            RecordingName = recordingName,
            Duration = recording.Duration,
            FrameCount = recording.FrameCount,
            CreatedAt = recording.CreatedAt,
            Data = serializedData
        }

        local jsonData = HttpService:JSONEncode(dataToSave)
        writefile(filename .. ".json", jsonData)

        return true
    end)

    if success then
        WindUI:Notify({
            Title = "Save Successful",
            Content = string.format("Saved '%s'", recordingName),
            Icon = "check-circle",
            Duration = 4
        })
    else
        WindUI:Notify({
            Title = "Save Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
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
            SavedRecordings = {}
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
                SavedRecordings[name] = {
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
                    SavedRecordings[name] = {
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

    if success and result then
        WindUI:Notify({
            Title = "Load Successful",
            Content = string.format("Loaded %d recordings", result),
            Icon = "check-circle",
            Duration = 4
        })
    else
        WindUI:Notify({
            Title = "Load Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
    end
end

function ShowSavedFiles()
    local success, result = pcall(function()
        local files = listfiles("")
        local recordingFiles = {}

        for _, file in ipairs(files) do
            if file:match("%.json$") then
                table.insert(recordingFiles, file)
            end
        end

        if #recordingFiles == 0 then
            return false, "No saved files found"
        end

        local fileList = "Saved files (" .. #recordingFiles .. "):\n"
        for i, file in ipairs(recordingFiles) do
            fileList = fileList .. "\n" .. i .. ". " .. file
        end

        return true, fileList, #recordingFiles
    end)

    if success and result then
        WindUI:Notify({
            Title = "Saved Files",
            Content = select(2, result),
            Icon = "folder",
            Duration = 8
        })
    else
        WindUI:Notify({
            Title = "Error",
            Content = tostring(result),
            Icon = "alert-circle",
            Duration = 4
        })
    end
end

function ExportToClipboard(recordingName)
    local success, result = pcall(function()
        local recording = SavedRecordings[recordingName]

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
                humanoidState = tostring(frame.humanoidState),
                isJumping = frame.isJumping,
                jumpPower = frame.jumpPower,
                moveDirection = { frame.moveDirection.X, frame.moveDirection.Y, frame.moveDirection.Z },
                moveSpeed = frame.moveSpeed,
                verticalVelocity = frame.verticalVelocity
            })
        end

        local dataToExport = {
            Version = "1.0",
            RecordingName = recordingName,
            Duration = recording.Duration,
            FrameCount = recording.FrameCount,
            CreatedAt = recording.CreatedAt,
            Data = serializedData
        }

        local jsonData = HttpService:JSONEncode(dataToExport)
        setclipboard(jsonData)

        return true
    end)

    if success then
        WindUI:Notify({
            Title = "Exported",
            Content = "Recording copied!",
            Icon = "clipboard-check",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "Export Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
    end
end

function ImportFromClipboard()
    local success, result = pcall(function()
        local clipboardData = getclipboard()

        if not clipboardData or clipboardData == "" then
            return false, "Clipboard is empty"
        end

        local loadedData = HttpService:JSONDecode(clipboardData)

        if not loadedData.RecordingName or not loadedData.Data then
            return false, "Invalid format"
        end

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

        local convertedData = {}
        for i, frame in ipairs(loadedData.Data) do
            table.insert(convertedData, {
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
            })
        end

        local name = loadedData.RecordingName
        SavedRecordings[name] = {
            Duration = loadedData.Duration,
            FrameCount = loadedData.FrameCount,
            CreatedAt = loadedData.CreatedAt,
            Data = convertedData
        }

        UpdateRecordingDropdown()

        return true, name
    end)

    if success and result then
        WindUI:Notify({
            Title = "Import OK",
            Content = "Imported '" .. result .. "'",
            Icon = "clipboard-check",
            Duration = 4
        })
    else
        WindUI:Notify({
            Title = "Import Failed",
            Content = "Error: " .. tostring(result),
            Icon = "x-circle",
            Duration = 4
        })
    end
end

-- Performance Functions
function EnablePotatoGraphics()
    OriginalProperties = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not OriginalProperties[obj] then
                OriginalProperties[obj] = {
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
            if not OriginalProperties[obj] then
                OriginalProperties[obj] = {
                    Transparency = obj.Transparency
                }
            end
            obj.Transparency = 1
        elseif obj:IsA("SurfaceAppearance") then
            if not OriginalProperties[obj] then
                OriginalProperties[obj] = {
                    Parent = obj.Parent
                }
            end
            obj.Parent = nil
        end
    end

    local Lighting = game:GetService("Lighting")
    if not OriginalProperties["Lighting"] then
        OriginalProperties["Lighting"] = {
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
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then
            if not OriginalProperties[effect] then
                OriginalProperties[effect] = {
                    Enabled = effect.Enabled or true
                }
            end
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = false
            elseif effect:IsA("Sky") or effect:IsA("Clouds") then
                effect.Parent = nil
                OriginalProperties[effect].Parent = Lighting
            end
        end
    end
end

function DisablePotatoGraphics()
    PotatoGraphicsEnabled = false

    for obj, props in pairs(OriginalProperties) do
        if obj == "Lighting" then
            local Lighting = game:GetService("Lighting")
            Lighting.Brightness = props.Brightness
            Lighting.GlobalShadows = props.GlobalShadows
            Lighting.OutdoorAmbient = props.OutdoorAmbient
            Lighting.Ambient = props.Ambient
        elseif typeof(obj) == "Instance" and obj:IsA("BasePart") then
            pcall(function()
                obj.Material = props.Material
                obj.Color = props.Color
                obj.Reflectance = props.Reflectance
                obj.Transparency = props.Transparency
            end)
        elseif typeof(obj) == "Instance" and (obj:IsA("Decal") or obj:IsA("Texture")) then
            pcall(function()
                obj.Transparency = props.Transparency
            end)
        elseif typeof(obj) == "Instance" and obj:IsA("SurfaceAppearance") then
            pcall(function()
                if props.Parent then
                    obj.Parent = props.Parent
                end
            end)
        elseif typeof(obj) == "Instance" and (obj:IsA("PostEffect") or obj:IsA("Atmosphere")) then
            pcall(function()
                obj.Enabled = props.Enabled
            end)
        elseif typeof(obj) == "Instance" and (obj:IsA("Sky") or obj:IsA("Clouds")) then
            pcall(function()
                if props.Parent then
                    obj.Parent = props.Parent
                end
            end)
        end
    end

    OriginalProperties = {}
end

function ApplyQuickFPSBoost()
    local Lighting = game:GetService("Lighting")

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    Lighting.GlobalShadows = false

    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or
            effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or
            effect:IsA("ColorCorrectionEffect") then
            effect.Enabled = false
        end
    end

    workspace.Terrain.Decoration = false
end

function RemoveAllEffects()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
            obj:IsA("Beam") or obj:IsA("Fire") or
            obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj:Destroy()
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or
            obj:IsA("SurfaceLight") then
            obj.Enabled = false
        end
    end

    local Lighting = game:GetService("Lighting")
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
end

function CleanupOldRecordings(maxRecordings)
    maxRecordings = maxRecordings or 10

    local count = 0
    for _ in pairs(SavedRecordings) do
        count = count + 1
    end

    if count > maxRecordings then
        local oldest = nil
        local oldestTime = math.huge

        for name, recording in pairs(SavedRecordings) do
            local time = recording.CreatedAt or os.time()
            if type(time) == "string" then
                time = 0
            end

            if time < oldestTime then
                oldestTime = time
                oldest = name
            end
        end

        if oldest then
            SavedRecordings[oldest] = nil
            UpdateRecordingDropdown()

            WindUI:Notify({
                Title = "Memory Cleanup",
                Content = "Removed: " .. oldest,
                Icon = "trash-2",
                Duration = 2
            })
        end
    end
end

-- God Mode Functions
local OriginalHealth = nil
local HealthConnection = nil

function EnableGodMode()
    if Humanoid and GodModeEnabled then
        OriginalHealth = Humanoid.MaxHealth
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge

        if HealthConnection then
            HealthConnection:Disconnect()
        end

        HealthConnection = Humanoid.HealthChanged:Connect(function(health)
            if GodModeEnabled and health < math.huge then
                Humanoid.Health = math.huge
            end
        end)
    end
end

function DisableGodMode()
    if Humanoid then
        if HealthConnection then
            HealthConnection:Disconnect()
            HealthConnection = nil
        end

        if OriginalHealth then
            Humanoid.MaxHealth = OriginalHealth
            Humanoid.Health = OriginalHealth
        else
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
        end
    end
end

-- ==========================================
-- CONNECTIONS & LOOPS
-- ==========================================

UserInputService.JumpRequest:Connect(function()
    if AirJumpEnabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Stepped:Connect(function()
    if NoclipEnabled and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

Player.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local function ProtectSpeed()
    if Humanoid then
        if WalkSpeedEnabled then
            Humanoid.WalkSpeed = WalkSpeedValue
        end

        if JumpPowerEnabled then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = JumpPowerValue
        end

        if GodModeEnabled and Humanoid.Health ~= math.huge then
            Humanoid.Health = math.huge
        end
    end
end

RunService.Heartbeat:Connect(function()
    ProtectSpeed()

    if GodModeEnabled then
        if Humanoid and Humanoid.Health ~= math.huge then
            EnableGodMode()
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")

    wait(0.1)

    Humanoid.UseJumpPower = true
    ProtectSpeed()

    if GodModeEnabled then
        EnableGodMode()
    end

    if IsRecording then
        StopRecording()
    end
    if IsReplaying then
        StopReplay()
    end
end)

if Humanoid then
    Humanoid.UseJumpPower = true
end

-- ==========================================
-- NOTIFICATION
-- ==========================================

WindUI:Notify({
    Title = "Script Loaded!",
    Content = "Movement Script Pro [OPTIMIZED] Ready!\n60 FPS Recording Mode",
    Icon = "check-circle",
    Duration = 5
})
