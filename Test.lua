getgenv().FireRemote = function(targetRemoteName, payloadData)
	local rs = game:GetService("ReplicatedStorage")
	local initFn, wireNameFn, getEncoderFn

	for _, child in ipairs(rs.Shared:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ok, mod = pcall(require, child)
			if type(mod) == "table" then
				local fns = {}
				for _, fn in pairs(mod) do if type(fn) == "function" then fns[#fns + 1] = fn end end
				if #fns == 3 then
					local iFn, wFn, eFn
					for _, fn in ipairs(fns) do
						local ok1, r1 = pcall(fn, "a")
						local ok2, r2 = pcall(fn, "b")
						if ok1 and r1 == nil then eFn = fn
						elseif ok1 and ok2 and type(r1) == "string" then
							if r1 == r2 then iFn = fn else wFn = fn end
						end
					end
					if wFn and eFn then initFn, wireNameFn, getEncoderFn = iFn, wFn, eFn break end
				end
			end
		end
	end

	if initFn then pcall(initFn) end

	local realEncode
	for _, v in ipairs(debug.getupvalues(getEncoderFn)) do
		if type(v) == "function" then realEncode = v break end
	end

	local targetName = wireNameFn(targetRemoteName)
	for _, d in ipairs(rs:GetDescendants()) do
		if d.Name == targetName and d:IsA("RemoteFunction") then
			d:InvokeServer(realEncode(targetRemoteName, payloadData))
			break
		end
	end
end
