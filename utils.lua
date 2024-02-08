local _, addon = ...

if addon:IsRetail() then
	function addon:HookTooltip(callback)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if not (tooltip and not tooltip:IsForbidden() and tooltip:GetOwner()) then
				return
			end

			if tooltip ~= GameTooltip then
				-- disqualify shopping tooltips
				return
			end

			if data.guid then
				local location = C_Item.GetItemLocation(data.guid)
				if location and location:IsBagAndSlot() then
					local bagID = location:GetBagAndSlot()
					if bagID >= 0 and bagID <= 5 then -- limit to player bags
						callback(tooltip, Item:CreateFromItemLocation(location))
					end
				end
			elseif tooltip:GetOwner():GetName() == 'TradeRecipientItem7ItemButton' then
				-- special handling for trade window
				local _, itemLink = tooltip:GetItem()
				if itemLink then
					callback(tooltip, Item:CreateFromItemLink(itemLink))
				end
			end
		end)
	end
else
	local function getBagAndSlotID(parent)
		if parent then
			local grandParent = parent:GetParent()
			if grandParent then
				local slotID = parent.GetID and parent:GetID()
				local bagID = grandParent.GetID and grandParent:GetID()
				if bagID and slotID and slotID >= 0 then
					return bagID, slotID
				end
			end
		end
	end

	function addon:HookTooltip(callback)
		GameTooltip:HookScript('OnTooltipSetItem', function(tooltip)
			if not (tooltip and not tooltip:IsForbidden() and tooltip:GetOwner()) then
				return
			end

			local _, itemLink = tooltip:GetItem()
			if itemLink then
				local bagID, slotID = getBagAndSlotID(tooltip:GetOwner())
				if bagID and slotID and bagID >= 0 and bagID <= 4 then -- limit to player bags
					callback(tooltip, Item:CreateFromItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID)))
				elseif tooltip:GetOwner():GetName() == 'TradeRecipientItem7ItemButton' then
					-- special handling for trade window
					callback(tooltip, Item:CreateFromItemLink(itemLink))
				end
			end
		end)
	end
end
