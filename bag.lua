---代碼鳴謝：ALLEZ Jasongreen Cargor等等---
SlashCmdList["RELOADUI"] = function() ReloadUI() end
SLASH_RELOADUI1 = "/rl"

local cfg = {
	general = {
		bankcolumns = {
			order = 1,
			value = 12,
			type = "range",
			min = 2,
			max = 20,
		},
		bagcolumns = {
			order = 2,
			value = 8,
			type = "range",
			min = 2,
			max = 20,
		},
		bagbar = {
			order = 3,
			value = false,
		},
	},
	sizes = {
		buttonsize = {
			order = 1,
			value = 25,
			type = "range",
			min = 10,
			max = 60,
		},
		spacing = {
			order = 2,
			value = 7,
			type = "range",
			min = 0,
			max = 30,
		},
	},
}

local cfg = {}

local _, ns = ...

local addon = ns.cargBags:NewImplementation("Bags")
local button = addon:GetItemButtonClass()
local container = addon:GetContainerClass()
local bag = addon:GetClass("BagButton", true, "BagButton")
button:Scaffold("Default")

addon:RegisterBlizzard()

function addon:OnInit()
	local onlyBags = function(item) return item.bagID >= 0 and item.bagID <= 4 end
	local onlyKeyring =	function(item) return item.bagID == -2 end
	local onlyBank = function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end

	local main = container:New("Main", {
		Columns = 10,
		Scale = 1,
		Bags = "backpack+bags",
	})
	main:SetFilter(onlyBags, true)
	main:SetPoint("RIGHT", -100, 0)

	local bank = container:New("Bank", {
		Columns = 10,
		Scale = 1,
		Bags = "bankframe+bank",
	})
	bank:SetFilter(onlyBank, true)
	bank:SetPoint("LEFT", 5, 0)
	bank:Hide()
end

function addon:OnBankOpened()
	self:GetContainer("Bank"):Show()
end

function addon:OnBankClosed()
	self:GetContainer("Bank"):Hide()
end

function button:OnCreate()
	self:SetHighlightTexture("")
	self:SetPushedTexture("")
	self:SetNormalTexture("")
	self:SetSize(25, 25)
	self.bg = CreateBG(self)
	self.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	self.Icon:SetPoint("TOPLEFT")
	self.Icon:SetPoint("BOTTOMRIGHT")
	self.Count:SetPoint("BOTTOMRIGHT", -1, 3)
	self.Count:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	self:HookScript('OnEnter', function()
		self.oldColor = {self.bg:GetBackdropBorderColor()}
		self.bg:SetBackdropBorderColor(1, 1, 1)
	end)
	self:HookScript('OnLeave', function()
		self.bg:SetBackdropBorderColor(unpack(self.oldColor))
	end)
	_G[self:GetName()..'IconQuestTexture']:SetSize(0.01, 0.01)
end

function button:OnUpdate(item)
	if item.questID or item.isQuestItem then
		self.bg:SetBackdropBorderColor(1, 1, 0, 1)
	elseif item.rarity and item.rarity > 1 then
		local r, g, b = GetItemQualityColor(item.rarity)
		self.bg:SetBackdropBorderColor(r, g, b, 1)
	else
		self.bg:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	end
end

function container:OnContentsChanged()
	self:SortButtons("bagSlot")
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 7, 7, -17)
	self:SetSize(width + 14, height + 55)
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or 0.1)
end

CreateBG = function(parent, noparent)
	local bg = CreateFrame('Frame', nil, noparent and UIParent or parent)
	bg:SetPoint('TOPLEFT', parent, 'TOPLEFT', -2, 2)
	bg:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 2, -2)
	bg:SetFrameLevel(parent:GetFrameLevel()-1 > 0 and parent:GetFrameLevel()-1 or 0)
	bg:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeSize = 1,
		insets = { left = 1, right = 1, top = 1, bottom = 1}
	})
	bg:SetBackdropColor(0, 0, 0, .65) 
    bg:SetBackdropBorderColor(.35, .3, .3, 1)
	bg.border = CreateFrame("Frame", nil, bg)
	bg.border:SetPoint("TOPLEFT", 1, -1)
	bg.border:SetPoint("BOTTOMRIGHT", -1, 1)
	bg.border:SetFrameLevel(bg:GetFrameLevel())
	bg.border:SetBackdrop({
	  edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	  edgeSize = 1,
	  insets = { left = 1, right = 1, top = 1, bottom = 1}
	})
	bg.border:SetBackdropBorderColor(0, 0, 0, 1)
	bg.border2 = CreateFrame("Frame", nil, bg)
	bg.border2:SetPoint("TOPLEFT", -1, 1)
	bg.border2:SetPoint("BOTTOMRIGHT", 1, -1)
	bg.border2:SetFrameLevel(bg:GetFrameLevel())
	bg.border2:SetBackdrop({
	  edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	  edgeSize = 1,
	  insets = { left = 1, right = 1, top = 1, bottom = 1}
	})
	bg.border2:SetBackdropBorderColor(0, 0, 0, 0.9)
	return bg
end

CreateFS = function(frame, fsize, fstyle, font)
	local fstring = frame:CreateFontString(nil, 'OVERLAY')
	fstring:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	fstring:SetShadowColor(0, 0, 0, 1)
	fstring:SetShadowOffset(0, 0)
	return fstring
end

function container:OnCreate(name, settings)
	self.Settings = settings

	self.button = CreateFrame("Button", nil, self)
	self.button:SetPoint("TOPRIGHT", 10, 10)
	self.button:SetSize(20, 20)
	self.button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	self.button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	self.button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	self.button:SetScript("OnClick", function()
		addon:Hide()
	end)

	self:EnableMouse(true)
	self:SetMovable(true)
	self:SetMovable(true)
	self:RegisterForClicks("LeftButton", "RightButton")
    self:SetScript("OnMouseDown", function()
    	self:ClearAllPoints() 
		self:StartMoving() 
    end)
	self:SetScript("OnMouseUp",  self.StopMovingOrSizing)

	self.bg = CreateBG(self)

	self:SetParent(addon)
	self:SetFrameStrata("HIGH")

	settings.Columns = settings.Columns or 14

	local infoFrame = CreateFrame("Frame", nil, self)
	infoFrame:SetPoint("BOTTOMLEFT", 7, 10)
	infoFrame:SetPoint("BOTTOMRIGHT", -7, 10)
	infoFrame:SetHeight(25)

	local space = self:SpawnPlugin("TagDisplay", "[space:free/max] free", infoFrame)
	space:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	space:SetPoint("LEFT", infoFrame, "LEFT")
	space.bags = ns.cargBags:ParseBags(settings.Bags)

	local tagDisplay = self:SpawnPlugin("TagDisplay", "[currencies] [ammo] [money]", infoFrame)
	tagDisplay:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	tagDisplay:SetPoint("RIGHT", infoFrame, "RIGHT", -7, 0)

	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", 1, 7, 7, -7)
	bagBar.highlightFunction = highlightFunction
	bagBar:SetSize(width + 14, height + 14)
	bagBar.bg = CreateBG(bagBar)
	if name == "Bank" then
		bagBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	else
		bagBar:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
	end
	if not cfg.bagbar then bagBar:Hide() end
	
	local bagToggle = CreateFrame("Button", nil, self)
	bagToggle:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
	bagToggle:SetWidth(60)
	bagToggle:SetHeight(12)
	bagToggle:SetPoint("TOP", self, "TOP", -30, -1)
	bagToggle.label = CreateFS(bagToggle)
	bagToggle.label:SetPoint("CENTER")
	bagToggle.label:SetText("背包欄")
	bagToggle:SetScript("OnClick", function()
		if bagBar:IsShown() then
			bagBar:Hide()
		else
			bagBar:Show()
		end
	end)
	
	local SortButton = CreateFrame("Button", nil, self)
	SortButton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
	SortButton:SetWidth(60)
	SortButton:SetHeight(12)
	SortButton:SetPoint("TOP", self, "TOP", 30, -1)
	SortButton:SetScript("OnClick", function() JPack:Pack() end)
	SortButton.Text = SortButton:CreateFontString(nil, "OVERLAY")
	SortButton.Text:SetPoint("CENTER", SortButton)
	SortButton.Text:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
	SortButton.Text:SetText("整理")
	
	local searchFrame = CreateFrame("Button", nil, self)
	searchFrame:SetPoint("BOTTOMLEFT", 7, 3)
	searchFrame:SetPoint("BOTTOMRIGHT", -7, 3)
	searchFrame:SetHeight(12)
	searchFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
	searchFrame.label = CreateFS(searchFrame)
	searchFrame.label:SetPoint("CENTER")
	searchFrame.label:SetText("搜索")
	local search = self:SpawnPlugin("SearchBar", searchFrame)
	search.highlightFunction = highlightFunction
end

function bag:OnCreate()
	self:SetHighlightTexture("")
	self:SetPushedTexture("")
	self:SetNormalTexture("")
	self:SetCheckedTexture("")
	self:SetSize(25, 25)
	self.bg = CreateBG(self)
	self.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	self.Icon:SetPoint("TOPLEFT", 1, -1)
	self.Icon:SetPoint("BOTTOMRIGHT", -1, 1)
	self:HookScript('OnEnter', function()
		self.oldColor = {self.bg:GetBackdropBorderColor()}
		self.bg:SetBackdropBorderColor(1, 1, 1)
	end)
	self:HookScript('OnLeave', function()
		self.bg:SetBackdropBorderColor(unpack(self.oldColor))
		self:OnUpdate()
	end)
end

function bag:OnUpdate()
	if self:GetChecked() then
		self.bg:SetBackdropBorderColor(0, 144, 255)
	else
		self.bg:SetBackdropBorderColor(0, 0, 0)
	end
end