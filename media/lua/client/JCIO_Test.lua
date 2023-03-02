------------------------------------------
------------- JUST CUT IT OUT ------------
------------------------------------------
--------- TEST AND DEBUG FUNCTIONS -------

------ TEST FUNCTIONS, DON'T USE THESE!!! ---------------

-- Side functions
local function TocGetAmputationFullTypeFromInventory(player, side, limb)
    local player_inventory = player:getInventory()
    local item_name = "TOC.Amputation_" .. side .. "_" .. limb
    local found_item = player_inventory:FindAndReturn(item_name)
    if found_item then
        return found_item:getFullType()

    end

end

local function TocGetEquippedProsthesisFullTypeFromInventory(player, side, limb)
    local player_inventory = player:getInventory()
    for _, prost in ipairs(GetProsthesisList()) do
        local item_name = TocFindCorrectClothingProsthesis(prost, side .."_" .. limb)
        local found_item = player_inventory:FindAndReturn(item_name)
        if found_item then
            return found_item:getFullType()
        end
    end
end

-- Set correct body locations for items in inventory
function TocResetClothingItemBodyLocation(player, side, limb)

    local playerInv = player:getInventory()
    local limbsData = player:getModData().JCIO.limbs

    local amputationItemName = TocGetAmputationFullTypeFromInventory(player, side, limb)
    local equippedProsthesisItemName = TocGetEquippedProsthesisFullTypeFromInventory(player, side, limb)

    if amputationItemName ~= nil then

        local amputationItem = playerInv:FindAndReturn(amputationItemName)
        if amputationItem ~= nil then
            player:removeWornItem(amputationItem)
            player:getInventory():Remove(amputationItem)
            amputationItem = playerInv:AddItem(amputationItemName)
            JCIO_Visuals.SetTextureForAmputation(amputationItem, player, limbsData[side .. "_" .. limb].is_cicatrized)
            player:setWornItem(amputationItem:getBodyLocation(), amputationItem)
        end
        amputationItem = nil -- reset it
    end

    if equippedProsthesisItemName ~= nil then
        local prosthesisItem = playerInv:FindAndReturn(equippedProsthesisItemName)
        if prosthesisItem ~= nil then
            print("Resetting " .. prosthesisItem:getName())
            player:removeWornItem(prosthesisItem)
            player:getInventory():Remove(prosthesisItem)
            prosthesisItem = playerInv:AddItem(equippedProsthesisItemName)
            player:setWornItem(prosthesisItem:getBodyLocation(), prosthesisItem)

        end
        prosthesisItem = nil -- reset it
    end
end



function TocTestBodyLocations()

    local group = BodyLocations.getGroup("Human")
    local list = getClassFieldVal(group, getClassField(group, 1))

    for i=1, list:size() do
 
            print(list:get(i -1):getId())

    end
end

function JCIOTestItem()
    local player = getPlayer()
    local player_inventory = player:getInventory()
    local item_name = "JCIO.Amputation_" .. "Right" .. "_" .. "Hand"
    local found_item = player_inventory:FindAndReturn(item_name)

    print(found_item:getID())
    print("_______________")
    found_item:setID(12334)
    print(found_item:getID())
end