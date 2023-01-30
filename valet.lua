require("lfs")

---@type Mq
local mq = require('mq')

--- @type ImGui
require 'ImGui'

local icons = require('mq/icons')

dofile('valet/lib/persistence.lua')

local isOpen = false
local shouldDraw = true
local terminate = false
local favorites = {}

local classic = require("zonedata/classic")
local kunark = require("zonedata/kunark")
local velious = require("zonedata/velious")
local luclin = require("zonedata/luclin")
local pop = require("zonedata/pop")
local god = require("zonedata/god")
local oow = require("zonedata/oow")
local special = require("zonedata/special")

lfs.mkdir(mq.configDir.."/valet")
if lfs.attributes(mq.configDir.."/valet/favorites.lua") then
	print("[Valet] Config file found, loading favorites...")
else
	print("[Valet] favorites.lua file not found, creating...")
	persistence.store(mq.configDir.."/valet/favorites.lua", {});
end

local aboutText = [[
[Valet] 
[Valet]  The Lazarus Valet
[Valet]  Version: 1.0
[Valet]  
[Valet]  Simply hail a translocation NPC to
[Valet]  bring up the interface!
[Valet]  
[Valet]  /valet : Manual Show/Hide GUI
[Valet]  /vexit : End Script
[Valet] 
[Valet]  Note: Requires E3 or support for /bark
]]

local notes = [[
Coming Soon:
- Support for Magus NPCs
- Auto-navigation to port NPCs
- More settings to customize all the things!

Changelog:
- Version 1 Release! Jan 30th 2023	
]]

print(aboutText)

local loadFavorites = function ()
	favorites = persistence.load(mq.configDir .. "/valet/favorites.lua")
end

local saveFavorites = function ()
	persistence.store(mq.configDir.."/valet/favorites.lua", favorites);
end

local selfZone = function (zoneName)
	isOpen = false
	mq.cmd("/say " .. zoneName)
end

local barkZone = function (zoneName)
	isOpen = false
	mq.cmd("/bark " .. zoneName)
end

local addToFavorites = function (shortName, cleanName)
	table.insert(favorites, {shortName, cleanName})
	saveFavorites()
end

local findInTableKeys = function (table, searchTerm)
	for k, v in pairs(table) do
		if v[1] == searchTerm then return k end
	end
	return nil
end

local removeFromFavorites = function (shortName)
	local pos = findInTableKeys(favorites, shortName)
	table.remove(favorites, pos)
end

local isInTableKeys = function (table, searchTerm)
	for k, v in pairs(table) do
		if v[1] == searchTerm then return true end
	end
	return false
end

local drawZoneList = function (tableName, title)
	if ImGui.BeginTabItem(title) then

		for k, v in pairs(tableName) do
			local shortName = v[1]
			local cleanName = v[2]

			ImGui.PushID(shortName)

			local isFav = isInTableKeys(favorites, shortName)
			local setFav = false
			if tableName ~= favorites then
				setFav = ImGui.Checkbox(icons.MD_STAR, isFav)
				if setFav and not isFav then
					addToFavorites(shortName, cleanName)
				end
			else
				setFav = ImGui.Checkbox(icons.MD_STAR, isFav)
				if not setFav then
					removeFromFavorites(shortName)
				end
			end
			

			ImGui.SameLine()
			if ImGui.Button("Self") then
				selfZone(shortName)
			end

			ImGui.SameLine()
			if ImGui.Button("Bark") then
				barkZone(shortName)
			end

			ImGui.SameLine()
			ImGui.Text(cleanName)

			ImGui.PopID()
		end

		ImGui.EndTabItem()
	end
end

local LazPortGUI = function()
	if not isOpen then return end

	isOpen, shouldDraw = ImGui.Begin('Lazarus Valet', isOpen)

	if shouldDraw then

		ImGui.BeginTabBar("continents")

		drawZoneList(favorites, "Favorites")
		drawZoneList(classic, "Classic")
		drawZoneList(kunark, "Kunark")
		drawZoneList(velious, "Velious")
		drawZoneList(luclin, "Luclin")
		drawZoneList(pop, "Planes of Power")
		drawZoneList(god, "Gates of Discord")
		drawZoneList(oow, "Omens of War")
		drawZoneList(special, "Special")

		if ImGui.BeginTabItem("About") then
			ImGui.Text(aboutText)
			ImGui.Text(notes)
			ImGui.EndTabItem()
		end
		
		ImGui.EndTabBar()

		-- ImGui.End()
	end
	ImGui.End()
end

loadFavorites()

mq.imgui.init('LazPortGUI', LazPortGUI)

mq.bind('/valet', function()
	isOpen = not isOpen
end)
mq.bind('/vexit', function()
	terminate = true
end)

mq.event('hail_valium', "You say, 'Hail, Valium'", function()
	isOpen = true
end)

mq.event('hail_klonopin', "You say, 'Hail, Klonopin'", function()
	isOpen = true
end)

while not terminate do
	mq.doevents()
	mq.delay(1000)
end
