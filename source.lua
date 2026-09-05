const runService = game:GetService("RunService")
const starterGui = game:GetService("StarterGui")
const coreGui = game:GetService("CoreGui")
const players = game:GetService("Players")

const player = players.LocalPlayer

local repository = "https://raw.githubusercontent.com/telamonium/RichTextConstructor/main/"

local interface = runService:IsStudio() and require(script.interface) or loadstring(game:HttpGet(repository.."interface.lua"))
local window = interface.Window :: ScreenGui
local sections = {
	convert = window.Convert :: Frame,
	topbar = window.Topbar :: Frame,
	tags = window.Tags :: Frame,
	formatting = window.Formatting :: Frame,
}
local richTags = {
	keywords = {Bold = "b", Underline = "u", Italic = "i", Strikethrough = "s", SmallCaps = "sc", Marked = "mark"},
	formatting = {Color = "color", Face = "face", Weight = "weight", Transparency = "transparency", Size = "size"},
}

local currentTags = {keywords = {}, formatting = {}}
local currentText = ""

local connections = {}

sections.convert.Items.Conversion.Convert.Visible = false

local function updateText()
	local preview = "Text Preview LOL"
	local output = sections.convert.Items.Input.InputBox.Text
	
	-- keywords
	local keywordsStart = ""
	local keywordsEnd = ""
	for tag, isEnabled in currentTags.keywords do
		if richTags.keywords[tag] and isEnabled then
			keywordsStart = keywordsStart..`<{richTags.keywords[tag]}>`
			keywordsEnd = `</{richTags.keywords[tag]}>`..keywordsEnd
		end
	end
	
	-- formatting
	local formatTextStart = ""
	local formatTextEnd = ""
	if next(currentTags.formatting) then
		formatTextStart = "<font "
		formatTextEnd = "</font>"
		
		for tag, value in currentTags.formatting do
			formatTextStart = formatTextStart..`{tag}="{value}" `
		end
		
		formatTextStart = formatTextStart:sub(1, formatTextStart:len() - 1)..">"
	end
	
	preview = `{formatTextStart}{keywordsStart}{preview}{keywordsEnd}{formatTextEnd}`
	output = `{formatTextStart}{keywordsStart}{output}{keywordsEnd}{formatTextEnd}`
	
	sections.convert.Items.Preview.PreviewText.Text = preview
	sections.convert.Items.Output.OutputBox.Text = output
end

for _, item in pairs(sections.tags.Items:GetChildren()) do
	if richTags.keywords[item.Name] and item:IsA("TextButton") then
		currentTags.keywords[item.Name] = false
		
		local isSelected = false
		
		connections[#connections + 1] = item.MouseButton1Click:Connect(function()
			if isSelected then
				currentTags.keywords[item.Name] = false
				item.BackgroundColor3 = Color3.fromHex("#3f3f41")
				isSelected = false
			else
				currentTags.keywords[item.Name] = true
				item.BackgroundColor3 = Color3.fromHex("#63a5ce")
				isSelected = true
			end
			updateText()
		end)
	end
end

-- formatting: colors
do
	currentTags.formatting["color"] = "#ffffff"
	local box = sections.formatting.Items.Color.Input :: TextBox
	connections[#connections + 1] = box:GetPropertyChangedSignal("Text"):Connect(function()
		local success = pcall(function()
			return Color3.fromHex(box.Text)
		end)
		if success then
			box.BackgroundColor3 = Color3.fromHex(box.Text)
			currentTags.formatting["color"] = box.Text:sub(1, 1) == "#" and box.Text or "#"..box.Text
			updateText()
		else
			box.BackgroundColor3 = Color3.fromHex("#000000")
		end
	end)
end

-- formatting: font face
do
	currentTags.formatting["face"] = "SourceSans"
	local box = sections.formatting.Items.Face.Input :: TextBox
	connections[#connections + 1] = box:GetPropertyChangedSignal("Text"):Connect(function()
		local success = pcall(function()
			return Enum.Font[box.Text]
		end)
		if success then
			currentTags.formatting["face"] = box.Text
			updateText()
		end
	end)
end

-- formatting: font weight
do
	currentTags.formatting["weight"] = "Regular"
	local box = sections.formatting.Items.Weight.Input :: TextBox
	connections[#connections + 1] = box:GetPropertyChangedSignal("Text"):Connect(function()
		local success = pcall(function()
			return Enum.FontWeight[box.Text]
		end)
		if success then
			currentTags.formatting["weight"] = box.Text
			updateText()
		end
	end)
end

-- formatting: transparency
do
	currentTags.formatting["transparency"] = "0"
	local box = sections.formatting.Items:FindFirstChild("Transparency").Input :: TextBox
	connections[#connections + 1] = box:GetPropertyChangedSignal("Text"):Connect(function()
		if tonumber(box.Text) then
			currentTags.formatting["transparency"] = box.Text
			updateText()
		end
	end)
end

-- formatting: size
do
	currentTags.formatting["size"] = "14"
	local box = sections.formatting.Items:FindFirstChild("Size").Input :: TextBox
	connections[#connections + 1] = box:GetPropertyChangedSignal("Text"):Connect(function()
		if tonumber(box.Text) then
			currentTags.formatting["size"] = box.Text
			updateText()
		end
	end)
end

do
	local box = sections.convert.Items.Input.InputBox :: TextBox
	connections[#connections + 1] = box:GetPropertyChangedSignal("Text"):Connect(updateText)
end

sections.topbar.Close.MouseButton1Click:Once(function()
	for index, connection in connections do
		connection:Disconnect()
	end
	interface:Destroy()
end)

interface.Parent = runService:IsStudio() and player:WaitForChild("PlayerGui") or coreGui
