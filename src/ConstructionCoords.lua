-- Define the global table for our mod
ConstructionCoords = {}

-- Track whether construction screen was open last frame (to detect open/close transitions)
ConstructionCoords.wasOpen = false

-- Track local/global snap mode (true = local snapping relative to building rotation)
ConstructionCoords.localSnapEnabled = false
