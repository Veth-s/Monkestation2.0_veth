//All bundles and telecrystals
/datum/uplink_category/dangerous
	name = "Conspicuous Weapons"
	weight = 9

/datum/uplink_item/dangerous
	category = /datum/uplink_category/dangerous

/datum/uplink_item/dangerous/foampistol
	name = "Toy Pistol with Riot Darts"
	desc = "An innocent-looking toy pistol designed to fire foam darts. Comes loaded with riot-grade \
			darts effective at incapacitating a target."
	item = /obj/item/gun/ballistic/automatic/pistol/toy/riot
	cost = 2
	surplus = 50 //monkestation edit: from 10 to 50
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/pistol
	name = "Makarov Pistol"
	desc = "A small, easily concealable handgun that uses 9mm auto rounds in 8-round magazines and is compatible \
			with suppressors."
	progression_minimum = 10 MINUTES
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = 7
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3
	illegal_tech = FALSE

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be \
			pocketed when inactive. Activating it produces a loud, distinctive noise."
	progression_minimum = 20 MINUTES
	item = /obj/item/melee/energy/sword/saber
	cost = 8
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
			Upon hitting a target, the piston-ram will extend forward to make contact for some serious damage. \
			Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
			deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	progression_minimum = 20 MINUTES
	item = /obj/item/melee/powerfist
	cost = 6
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user punch people very fast. Does not improve weapon attack speed or the meaty fists of a hulk."
	progression_minimum = 20 MINUTES
	item = /obj/item/clothing/gloves/rapid
	cost = 8

/datum/uplink_item/dangerous/doublesword
	name = "Double-Bladed Energy Sword"
	desc = "The double-bladed energy sword does slightly more damage than a standard energy sword and will deflect \
			energy projectiles it blocks, but requires two hands to wield. It also struggles to protect you from tackles."
	progression_minimum = 30 MINUTES
	item = /obj/item/dualsaber

	cost = 13
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/doublesword/get_discount_value(discount_type)
	switch(discount_type)
		if(TRAITOR_DISCOUNT_BIG)
			return 0.5
		if(TRAITOR_DISCOUNT_AVERAGE)
			return 0.35
		else
			return 0.2

/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an \
			organic host as a home base and source of fuel. Holoparasites come in various types and share damage with their host."
	progression_minimum = 30 MINUTES
	item = /obj/item/guardian_creator/tech
	cost = 18
	surplus = 40 //monkestation edit: from 0 to 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/dangerous/revolver
	name = "Syndicate Revolver"
	desc = "Waffle Co.'s modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum."
	item = /obj/item/gun/ballistic/revolver/syndicate
	progression_minimum = 30 MINUTES
	cost = 13
	surplus = 50
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/cat
	name = "Feral cat grenade"
	desc = "This grenade is filled with 5 feral cats in stasis. Upon activation, the feral cats are awoken and unleashed unto unlucky bystanders. WARNING: The cats are not trained to discern friend from foe!"
	cost = 5
	item = /obj/item/grenade/spawnergrenade/cat
	surplus = 30

/datum/uplink_item/dangerous/rebarxbowsyndie
	name = "Syndicate Rebar Crossbow"
	desc = "A much more proffessional version of the engineer's bootleg rebar crossbow. 3 shot mag, quicker loading, and better ammo. Owners manual included."
	item = /obj/item/storage/box/syndie_kit/rebarxbowsyndie
	cost = 10

/datum/uplink_item/dangerous/minipea
	name = "5 peashooters strapped together"
	desc = "For use in a trash tank, 5 small machineguns strapped together using syndicate technology. It burns through ammo like no other."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/minipea
	cost = 8
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/devitt
	name = "Devitt Mk3 Light Tank"
	desc = "An ancient tank teleported in for your machinations, comes prepared with a cannon and machinegun. REQUIRES TWO CREWMEMBERS TO OPPERATE EFFECTIVELY."
	item = /obj/vehicle/sealed/mecha/devitt
	cost = 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
