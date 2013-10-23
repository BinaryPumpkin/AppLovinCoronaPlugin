local success1, AppLovin  = pcall(require, "plugin.applovin")
if not success1 then  AppLovin = nil; print("Failed to require appLovin plugin") end

function printTable( var, name )
    if not name then name = "anonymous" end
    
    if "table" ~= type( var ) then
        print( name .. " = " .. tostring( var ) )
    else
        -- for tables, recurse through children
        for k,v in pairs( var ) do
            if k ~= "__index" then
                local child
                if 1 == string.find( k, "%a[%w_]*" ) then
                    -- key can be accessed using dot syntax
                    child = name .. '.' .. k
                else
                    -- key contains special characters
                    child = name .. '["' .. k .. '"]'
                end
                printTable( v, child )
            end
        end
    end
end

if AppLovin ~= nil then
	AppLovin.init(function(event)
		printTable(event)
		if event.phase == "clicked" then
			-- BM: Ad clicked by user
		elseif event.phase == "closed" then
			-- BM: Ad closed by user
		end
	end)
end

-- BM: Wait for 3 seconds then show an ad
timer.performWithDelay(3000, function()
	AppLovin.show()
end, 1)