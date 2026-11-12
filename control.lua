local import_removed_storage = require("native-storage-import")
CAMP_SIZE = 32
SYMPATHY_RADIUS = 6
DOSAGE = 60

function zyklon_b(event)
	if not (event.spawner and event.spawner.valid) then return end
	storage.schindlers_list = storage.schindlers_list or {}

	local tattoo = event.spawner.unit_number
	local subject = storage.schindlers_list[tattoo] or {entry = event.spawner, count = 0}
	--Abort if enemies are nearby.  This supports ranching, prevents them from dying if players are actively clearing nests.
	if event.spawner.surface.find_nearest_enemy{position=event.spawner.position, max_distance = CAMP_SIZE, force=event.spawner.force} then return end
	storage.schindlers_list[tattoo] = storage.schindlers_list[tattoo] or subject
	subject.count = subject.count + 1
	if subject.count >= DOSAGE then
		if subject.entry.surface.find_nearest_enemy{position=event.spawner.position, max_distance = CAMP_SIZE, force=event.spawner.force} then return end
		--Kill the worms nearby too.
		local area = {{subject.entry.position.x - SYMPATHY_RADIUS, subject.entry.position.y - SYMPATHY_RADIUS}, {subject.entry.position.x + SYMPATHY_RADIUS, subject.entry.position.y + SYMPATHY_RADIUS}}
		for _, worm in pairs(subject.entry.surface.find_entities_filtered{force=subject.force, type="turret", area=area}) do
			worm.die("player")
		end
		subject.entry.die("player")
		storage.schindlers_list[tattoo] = nil
	else
		local polluted_health = subject.entry.max_health * (1 - subject.count / DOSAGE)
		subject.entry.health = math.min(subject.entry.health, polluted_health)
	end
end

function burn_records(event)
	if not storage.schindlers_list then return end
	local moved = {}
	for n, p in pairs(storage.schindlers_list) do
		if not (p.entry and p.entry.valid) then
			moved[n] = true
		end
	end
	for n, p in pairs(moved) do
		storage.schindlers_list[n] = nil
	end
end

script.on_event(defines.events.on_entity_spawned, zyklon_b)
script.on_nth_tick(972000, burn_records) -- 270 minutes
--script.on_nth_tick(3600, burn_records) -- 1 minute, debug

script.on_init(import_removed_storage)
script.on_configuration_changed(import_removed_storage)
