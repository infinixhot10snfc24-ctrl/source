## 📥 I. Getting Started

Before creating any UI elements, you need to load the library using your raw script link.

```lua
-- Replace with your actual raw link
local Library = loadstring(game:HttpGet("YOUR_RAW_LINK_HERE"))()
```

---

## 🏛️ II. Creating the Base UI

### Create a Window

Start by creating a main window. This will contain all your UI elements.

```lua
local MainWindow = Library:CreateWindow("Primary Interface")
```

### Organize with Folders (Tabs)

Use folders to group related UI elements.

```lua
local CombatTab = MainWindow:AddFolder("Combat")
local VisualTab = MainWindow:AddFolder("Visuals")
```

---

## 🧩 III. UI Components

Below are all available UI elements you can use inside folders or windows.

### 1. Label

Displays static text (no interaction).

```lua
CombatTab:AddLabel({
    text = "Make sure your weapon is equipped before proceeding."
})
```

---

### 2. Button

Triggers a function when clicked.

```lua
CombatTab:AddButton({
    text = "Execute Strike",
    callback = function()
        print("Strike executed!")
    end
})
```

---

### 3. Toggle

Used for enabling/disabling features.

```lua
CombatTab:AddToggle({
    text = "Enable Auto Logic",
    state = false,
    flag = "AutoLogicToggle",
    callback = function(value)
        print("Auto Logic:", value)
    end
})
```

---

### 4. Slider

Used to select a numeric value.

```lua
VisualTab:AddSlider({
    text = "Field of View",
    min = 70,
    max = 120,
    value = 90,
    float = 1,
    flag = "FOVSlider",
    callback = function(value)
        print("FOV:", value)
    end
})
```

---

### 5. Dropdown (List)

Lets users select from predefined options.

```lua
CombatTab:AddList({
    text = "Select Target",
    values = {"King", "Knight", "Peasant"},
    value = "Knight",
    flag = "TargetList",
    callback = function(selected)
        print("Selected:", selected)
    end
})
```

---

### 6. Text Box

Allows custom user input.

```lua
VisualTab:AddBox({
    text = "Custom Player Name",
    value = "John Doe",
    flag = "CustomNameBox",
    callback = function(text)
        print("Input:", text)
    end
})
```

---

### 7. Key Bind

Bind actions to keyboard input.

```lua
CombatTab:AddBind({
    text = "Dash",
    key = Enum.KeyCode.Q,
    hold = false,
    flag = "DashBind",
    callback = function()
        print("Dash triggered")
    end
})
```

---

### 8. Color Picker

Allows users to select colors.

```lua
VisualTab:AddColor({
    text = "Aura Color",
    color = Color3.fromRGB(255, 215, 0),
    flag = "AuraColor",
    callback = function(color)
        print("Selected color:", color)
    end
})
```

---

## ⚙️ IV. Finalizing & Control

### Initialize UI

You must call this after setting everything up.

```lua
Library:Init()
```

---

### Toggle Visibility

```lua
-- Show / hide the entire UI
Library:Close()
```

---

### Access Flags

```lua
game:GetService("RunService").RenderStepped:Connect(function()
    if Library.flags["AutoLogicToggle"] then
        -- Run your logic here
    end
end)
```

---

## 📜 V. Complete Example

```lua
-- Load library
local Library = loadstring(game:HttpGet("YOUR_RAW_LINK_HERE"))()

-- Create window
local Window = Library:CreateWindow("Example UI")

-- Create folders
local ConfigTab = Window:AddFolder("Config")
local ESPTab = Window:AddFolder("ESP")

-- Add elements
ConfigTab:AddLabel({ text = "Welcome." })

ConfigTab:AddToggle({
    text = "Active State",
    flag = "isActive"
})

ConfigTab:AddBox({
    text = "Password",
    value = "Open Sesame",
    callback = function(val)
        print("Password:", val)
    end
})

ConfigTab:AddButton({
    text = "Clear Data",
    callback = function()
        print("Data cleared")
    end
})

ESPTab:AddColor({
    text = "ESP Color",
    color = Color3.fromRGB(255, 50, 50),
    flag = "espColor"
})

ESPTab:AddBind({
    text = "Toggle UI",
    key = Enum.KeyCode.RightShift,
    callback = function()
        Library:Close()
    end
})

-- Initialize
Library:Init()
```
