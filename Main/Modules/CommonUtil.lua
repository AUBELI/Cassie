-- CommonUtil.luau
-- Utility functions for the script

local Services = setmetatable({}, {
    __index = function(self, name: string): any
        local service = game:GetService(name)
        rawset(self, name, service)
        return service
    end
})

local RemoteCache = {}
local CommonUtil = {}

function CommonUtil.GetService(name: string): any
    return Services[name]
end

function CommonUtil.GetKnitRemote(serviceName: string, remoteType: string, remoteName: string): any?
    local cacheKey = serviceName .. "/" .. remoteType .. "/" .. remoteName
    if RemoteCache[cacheKey] then
        return RemoteCache[cacheKey]
    end

    local success, remote = pcall(function()
        local Knit = Services.ReplicatedStorage:WaitForChild("ReplicatedModules")
            :WaitForChild("KnitPackage"):WaitForChild("Knit")
        local service = Knit:WaitForChild("Services"):WaitForChild(serviceName)
        local container = service:WaitForChild(remoteType)
        return container:WaitForChild(remoteName)
    end)
    if success then
        RemoteCache[cacheKey] = remote
        return remote
    end
    warn("Failed to get Knit remote: " .. cacheKey)
    return nil
end

function CommonUtil.Teleport(position: Vector3): boolean
    local player = Services.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 1)
    if not root then
        return false
    end

    local anchored = root.Anchored
    root.Anchored = true
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    local success, err = pcall(function()
        if char:FindFirstChild("PivotTo") then
            char:PivotTo(CFrame.new(position))
        else
            root.CFrame = CFrame.new(position)
        end
    end)
    if not success then
        warn("Teleport error: " .. tostring(err))
        root.Anchored = anchored
        return false
    end

    task.delay(0.05, function()
        root.Anchored = anchored
    end)
    return true
end

-- Add any other utility functions here

return CommonUtil
