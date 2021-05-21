local registry = require("ItemRegistry")

if EID then
	EID:addCollectible(registry.Tumbler, "Breaks all rocks when you enter a room.")
	EID:addCollectible(registry.Scale, "All pickups become one, gaining/using one type, gains/spends it for all types")
	EID:addCollectible(registry.Katana, "TBD")
	EID:addCollectible(registry.Mars, "+0.3 damage for every miniboss killed, +1 damage for every boss killed")
	EID:addCollectible(registry.Fireflower, "10% chance to fire a tear that burns enemies")
end
