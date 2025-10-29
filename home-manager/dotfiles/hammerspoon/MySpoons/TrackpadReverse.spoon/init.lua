local obj = {}
obj.__index = obj

local reverseScrollTap = nil

-- Starts reversing the scroll direction for trackpads.
function obj:start()
	if reverseScrollTap then
		return self
	end

	reverseScrollTap = hs.eventtap
		.new({ hs.eventtap.event.types.scrollWheel }, function(event)
			local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)

			if isTrackpad ~= 1 then
				return false -- Mouse: pass the event along
			end

			-- Reverse vertical scroll (Axis 1)
			local deltaAxis1 = event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1)
			if deltaAxis1 then
				event:setProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1, -deltaAxis1)
			end

			-- Reverse horizontal scroll (Axis 2)
			local deltaAxis2 = event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis2)
			if deltaAxis2 then
				event:setProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis2, -deltaAxis2)
			end

			return false -- Pass the modified event along
		end)
		:start()

	return self
end

-- Stops reversing the scroll direction.
function obj:stop()
	if reverseScrollTap then
		reverseScrollTap:stop()
		reverseScrollTap:delete()
		reverseScrollTap = nil
	end
	return self
end

return obj

