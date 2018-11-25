
#define COMMS_CUTIN_EVENT_CHANCE 10
#define COMMS_CUTIN_EVENT_DURATION 5 MINUTES

/datum/game_mode/achlys
	name = "ONI Investigation: Achlys"
	round_description = ""
	extended_round_description = ""
	config_tag = "achlys"
	votable = 1
	probability = 0
	var/special_event_starttime = 0 //Used to determine if we should run the gamemode's "special event" (Currently just a comms cut-in). Is set to the time the event should start.
	var/item_destroy_tag = "destroythis" //Map-set tags for items that need to be destroyed.
	var/list/items_to_destroy = list()
	var/item_retrieve_tag = "retrievethis" //Map-set tags for items that need to be retrieved.
	var/list/items_to_retrieve = list()
	var/list/rank_retrieve_names = list("Commanding Officer")//The name of the job that needs to be holding the items-to-retrieve

/datum/game_mode/achlys/proc/populate_items_destroy()
	for(var/atom/destroy in world)
		if(destroy.tag == item_destroy_tag)
			items_to_destroy += destroy

/datum/game_mode/achlys/proc/populate_items_retrieve()
	for(var/atom/retrieve in world)
		if(retrieve.tag == item_retrieve_tag)
			items_to_retrieve += retrieve

/datum/game_mode/achlys/pre_setup()
	..()
	populate_items_destroy()
	populate_items_retrieve()
	if(prob(COMMS_CUTIN_EVENT_CHANCE))
		special_event_starttime = world.time + 5 MINUTES //TODO: MAKE THIS RANDOMISED.

/datum/game_mode/achlys/check_finished()
	. = check_item_destroy_status()
	. = check_item_retrieve_status()

/datum/game_mode/achlys/proc/check_item_destroy_status()
	. = 1 //This ensures that if the list is emptied due to the objects being deleted, it will still allow the gamemode to end.
	for(var/atom/item in items_to_destroy)
		if(istype(item,/obj/machinery))
			var/obj/machinery/item_machine = item
			if(!(item_machine.stat & BROKEN))
				. = 0

/datum/game_mode/achlys/proc/check_item_retrieve_status()
	. = 1
	for(var/atom/item in items_to_retrieve)
		if(istype(item.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/holder = item.loc
			if(!(holder.mind) || !(holder.mind.assigned_role in rank_retrieve_names))
				. = 0

/datum/game_mode/achlys/proc/do_special_event_handling() //Currently handles the "Comms cut-in event"
	special_event_starttime = 0
	for(var/z_level = 0,z_level <= world.maxz, z_level += 1)
		var/turf/item_spawn_turf = locate(0,0,z_level)
		var/area/spawned_nopower_area = new /area (item_spawn_turf)
		spawned_nopower_area.requires_power = 0
		var/spawned_relay = new /obj/machinery/telecomms/relay/ship_relay (item_spawn_turf)
		var/spawned_tcomms_machine = new /obj/machinery/telecomms/allinone (item_spawn_turf)
		var/obj/machinery/telecomms_jammers/spawned_jammer = new /obj/machinery/telecomms_jammers (item_spawn_turf)
		spawned_jammer.jam_chance = 50
		spawned_jammer.jam_range = 999
		spawn(COMMS_CUTIN_EVENT_DURATION)
			qdel(spawned_nopower_area)
			qdel(spawned_relay)
			qdel(spawned_tcomms_machine)
			qdel(spawned_jammer)

/datum/game_mode/achlys/process()
	..()
	if(special_event_starttime != 0 && world.time > special_event_starttime)
		do_special_event_handling()

/datum/game_mode/achlys/declare_completion()
	..()

/datum/game_mode/achlys/handle_mob_death(var/mob/victim, var/list/args = list())
	..()

#undef COMMS_CUTIN_EVENT_CHANCE
