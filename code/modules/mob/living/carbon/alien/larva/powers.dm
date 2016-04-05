/mob/living/carbon/alien/larva/proc/check_can_infest(var/mob/living/M)
	if(!src)
		return 0
	if(!istype(loc, /turf))
		src << "<span class='danger'>You cannot infest a target in your current position.</span>"
		return 0
	if(incapacitated())
		src << "<span class='danger'>You cannot infest a target in your current state.</span>"
		return 0
	if(!M)
		return 1
	if(!M.lying)
		src << "<span class='danger'>\The [M] is not prone.</span>"
		return 0
	if(!(src.Adjacent(M)))
		src << "<span class='danger'>\The [M] is not in range.</span>"
		return 0
	return 1

/spell/attach_host
	name = "Attach to host"
	desc = "Burrow into a prone victim and begin drinking their blood."
	spell_flags = SELECTABLE
	range = 1
	charge_max = 50


/spell/attach_host/choose_targets()
	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,holder))
		if(isxenomorph(H))
			continue
		if(H.Adjacent(holder) && H.lying)
			choices += H
	return choices

/spell/attach_host/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/human/target
	if(!istype(user, /mob/living/carbon/alien/larva))
		return
	var/mob/living/carbon/alien/larva/A = user
	if(targets.len == 1)
		target = targets[1]
	else
		target = input(A, "Who do you wish to infest?") as null|anything in targets

	if(!target || !A || !target.lying)
		return

	A.visible_message("<span class='danger'>\The [A] begins questing blindly towards \the [target]'s warm flesh...</span>")

	if(!do_after(A,30,target))
		return

	if(!A.check_can_infest(target))
		return

	var/obj/item/organ/external/E = pick(target.organs)
	A << "<span class='danger'>You burrow deeply into \the [target]'s [E.name]!</span>"
	var/obj/item/weapon/holder/holder = new (A.loc)
	A.loc = holder
	holder.name = A.name
	E.embed(holder,0,"\The [A] burrows deeply into \the [target]'s [E.name]!")

/mob/living/carbon/alien/larva/verb/attach_host()

	set name = "Attach to host"
	set desc = "Burrow into a prone victim and begin drinking their blood."
	set category = "Abilities"

	if(!check_can_infest())
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		if(isxenomorph(H))
			continue
		if(src.Adjacent(H) && H.lying)
			choices += H

	if(!choices.len)
		src << "<span class='danger'>There are no viable hosts within range.</span>"
		return

	var/mob/living/carbon/human/H = input(src,"Who do you wish to infest?") as null|anything in choices

	if(!H || !src || !H.lying) return

	visible_message("<span class='danger'>\The [src] begins questing blindly towards \the [H]'s warm flesh...</span>")

	if(!do_after(src,30, H))
		return

	if(!check_can_infest(H))
		return

	var/obj/item/organ/external/E = pick(H.organs)
	src << "<span class='danger'>You burrow deeply into \the [H]'s [E.name]!</span>"
	var/obj/item/weapon/holder/holder = new (loc)
	src.loc = holder
	holder.name = src.name
	E.embed(holder,0,"\The [src] burrows deeply into \the [H]'s [E.name]!")

/mob/living/carbon/alien/larva/verb/release_host()
	set category = "Abilities"
	set name = "Release Host"
	set desc = "Release your host."

	if(incapacitated())
		src << "You cannot leave your host in your current state."
		return

	if(!loc || !loc.loc)
		src << "You are not inside a host."
		return

	var/mob/living/carbon/human/H = loc.loc

	if(!istype(H))
		src << "You are not inside a host."
		return

	src << "<span class='danger'>You begin writhing your way free of \the [H]'s flesh...</span>"

	if(!do_after(src, 30, H))
		return

	if(!H || !src)
		return

	leave_host()

/mob/living/carbon/alien/larva/proc/leave_host()
	if(!loc || !loc.loc)
		src << "You are not inside a host."
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!istype(H))
		src << "You are not inside a host."
		return
	var/obj/item/weapon/holder/holder = loc
	var/obj/item/organ/external/affected
	if(istype(holder))
		for(var/obj/item/organ/external/organ in H.organs) //Grab the organ holding the implant.
			for(var/obj/item/O in organ.implants)
				if(O == holder)
					affected = organ
					break
		affected.implants -= holder
		holder.loc = get_turf(holder)
	else
		src.loc = get_turf(src)
	if(affected)
		src << "<span class='danger'>You crawl out of \the [H]'s [affected.name] and plop to the ground.</span>"
	else
		src << "<span class='danger'>You plop to the ground.</span>"