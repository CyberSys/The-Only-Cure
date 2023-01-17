require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISEquipWeaponAction"
require "TimedActions/ISUnequipAction"
require "ISUI/ISInventoryPaneContextMenu"

local og_ISEquipTimedActionAdjustMaxTime = ISBaseTimedAction.adjustMaxTime

-- FIXME something is seriously broken here, it stacks up 
function ISBaseTimedAction:adjustMaxTime(maxTime)

    local original_max_time = og_ISEquipTimedActionAdjustMaxTime(self, maxTime)       -- TODO will it work?
    local modified_max_time = original_max_time

    local toc_data = getPlayer():getModData().TOC
    local burn_factor = 1.3

    -- To make it faster, let's have everything already written in another func
    local all_body_parts = GetBodyParts()


    -- TODO this gets awfully slow really quick, doesn't even make much sense. 
    for _, part_name in ipairs(all_body_parts) do


        if toc_data[part_name].is_cut then
            
            if toc_data[part_name].is_prosthesis_equipped then
                modified_max_time = modified_max_time * toc_data[part_name].prosthesis_factor

            else
                modified_max_time = modified_max_time * 2
            end
            if toc_data[part_name].is_cauterized then
                modified_max_time = modified_max_time * burn_factor
            end


            -- Perk scaling
            if part_name == "RightHand" or part_name == "LeftHand" then
                modified_max_time = modified_max_time * (1 + (9 - self.character:getPerkLevel(Perks[part_name])) / 20 )
            end

        end
    end

    if modified_max_time > 10 * original_max_time then modified_max_time = 10 * original_max_time end


    print("MODIFIED MAX TIME: " .. modified_max_time)


    return modified_max_time

end




local og_ISEquipWeaponActionPerform = ISEquipWeaponAction.perform

function ISEquipWeaponAction:perform()
    og_ISEquipWeaponActionPerform(self)
    local toc_data = self.character:getModData().TOC
    local can_be_held = {}

    for _, side in ipairs ({"Left", "Right"}) do
        can_be_held[side] = true

        if toc_data[side .. "Hand"].is_cut then
            if toc_data[side .. "Forearm"].is_cut then
                if not toc_data[side .. "Forearm"].is_prosthesis_equipped then
                    can_be_held[side] = false
                end
            elseif not toc_data[side .. "Hand"].is_prosthesis_equipped then
                can_be_held[side] = false
            end
        end
    end

    if not self.item:isRequiresEquippedBothHands() then
        if can_be_held["Right"] and not can_be_held["Left"] then
            self.character:setPrimaryHandItem(self.item)
            self.character:setSecondaryHandItem(nil)
        elseif not can_be_held["Right"] and can_be_held["Left"] then
            self.character:setPrimaryHandItem(nil)
            self.character:setSecondaryHandItem(nil)
        elseif not can_be_held["Left"] and not can_be_held["Right"] then
            self.character:dropHandItems()
        end
    else
        if (can_be_held["Right"] and not can_be_held["Left"]) or
                (not can_be_held["Right"] and can_be_held["Left"]) or
                (not can_be_held["Left"] and not can_be_held["Right"]) then
            self.character:dropHandItems()

        end
    end



end


-- local og_ISUnequipActionPerform = ISUnequipAction.perform
-- function ISUnequipAction:perform()
-- --     -- check if the "clothing" is actually an amputation or an equipped prosthesis

--     -- TODO Find a way to disable the green advancement UI thing
--     if CheckIfItemIsAmputatedLimb(self.item) == false and CheckIfItemIsInstalledProsthesis(self.item) == false then
--         og_ISUnequipActionPerform(self)
--     end
-- end



local og_ISInventoryPaneContextMenuUnequipItem = ISInventoryPaneContextMenu.unequipItem
function ISInventoryPaneContextMenu.unequipItem(item, player)
    if CheckIfItemIsAmputatedLimb(item) == false and CheckIfItemIsInstalledProsthesis(item) == false then
        og_ISInventoryPaneContextMenuUnequipItem(item, player)
    end
end

local og_ISInventoryPaneContextMenuDropItem = ISInventoryPaneContextMenu.dropItem

function ISInventoryPaneContextMenu.dropItem(item, player)

    if CheckIfItemIsAmputatedLimb(item) == false and CheckIfItemIsInstalledProsthesis(item) == false then
        og_ISInventoryPaneContextMenuDropItem(item, player)
    end

end
