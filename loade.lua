-- Key system z dekodowaniem base64 i ładowaniem skryptu z GitHub RAW
local HttpService = game:GetService("HttpService")

local githubRawUrl = "https://raw.githubusercontent.com/GuyformscriptROBLOX/test/refs/heads/main/script" -- <- podmień na swój link

-- Funkcja dekodująca base64
local function base64decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Pobierz klucz z GitHub RAW (zamiast trzymać go lokalnie)
local function getKeyFromRaw()
    local success, keyRaw = pcall(function()
        return HttpService:GetAsync("https://raw.githubusercontent.com/GuyformscriptROBLOX/test/refs/heads/main/key.txt") -- <- podmień na swój link do klucza (base64)
    end)
    if success and keyRaw then
        return base64decode(keyRaw)
    else
        warn("Nie udało się pobrać klucza z GitHub RAW.")
        return nil
    end
end

local realKey = getKeyFromRaw()

-- Pobierz kod od użytkownika
local function getUserKey()
    if not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("KeyInputGui") then
        local gui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
        gui.Name = "KeyInputGui"
        local box = Instance.new("TextBox", gui)
        box.Size = UDim2.new(0, 200, 0, 40)
        box.Position = UDim2.new(0.5, -100, 0.5, -20)
        box.PlaceholderText = "Wpisz klucz..."
        box.Text = ""
        box.TextScaled = true
        local btn = Instance.new("TextButton", gui)
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0.5, -100, 0.5, 30)
        btn.Text = "Zatwierdź"
        btn.TextScaled = true
        return box, btn, gui
    end
end

local box, btn, gui = getUserKey()

btn.MouseButton1Click:Connect(function()
    local userKey = box.Text
    if userKey == realKey then
        gui:Destroy()
        -- Pobierz i załaduj skrypt z GitHub RAW
        local success, result = pcall(function()
            return HttpService:GetAsync(githubRawUrl)
        end)
        if success and result then
            loadstring(result)()
        else
            warn("Nie udało się pobrać skryptu z GitHub RAW.")
        end
    else
        box.Text = "BŁĘDNY KLUCZ!"
        task.wait(1)
        box.Text = ""
    end
end)
