#define JITTER_MEDIUM 100
#define JITTER_HIGH 300

/mob/living/carbon/human/examine(mob/user)
	var/msg = get_examine_text(user)
	to_chat(user, msg)
	if(istype(user))
		user.heard(src)

/mob/living/carbon/human/proc/get_examine_text(mob/user)
	var/list/obscured = check_obscured_slots()
	var/skipface = 0

	var/is_gender_visible = 1

	if(wear_mask)
		skipface |= check_hidden_head_flags(HIDEFACE)

	if(wear_mask?.is_hidden_identity() || head?.is_hidden_identity())
		is_gender_visible = 0

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "It" //capitalised for use at the start of each line.
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"
	var/t_s = "s"
	var/t_es = "es"

	var/msg = "<span class='info'>*---------*\nThis is "

	if((slot_w_uniform in obscured) && !is_gender_visible)
		t_He = "They"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
		t_s = ""
		t_es = ""
	else
		switch(gender)
			if(MALE)
				t_He = "He"
				t_his = "his"
				t_him = "him"
			if(FEMALE)
				t_He = "She"
				t_his = "her"
				t_him = "her"

	var/distance = get_dist(user,src)
	if(istype(user, /mob/dead/observer) || !istype(user) || user.stat == 2) // ghosts can see anything
		distance = 1

	msg += "<EM>[src.name]</EM>!\n"

	//uniform
	if(w_uniform && !(slot_w_uniform in obscured) && w_uniform.is_visible())
		if(w_uniform.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(w_uniform)] [w_uniform.a_stained()] [w_uniform.name]! [format_examine(w_uniform, "Examine")][w_uniform.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(w_uniform)] \a [w_uniform]. [format_examine(w_uniform, "Examine")][w_uniform.description_accessories()]\n"

	//head
	if(head && head.is_visible())
		if(head.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(head)] [head.a_stained()] [head.name] on [t_his] head! [format_examine(head, "Examine")][head.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(head)] \a [head] on [t_his] head. [format_examine(head, "Examine")][head.description_accessories()][head.description_hats()]\n"

	//suit/armour
	if(wear_suit && wear_suit.is_visible())
		if(wear_suit.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(wear_suit)] [wear_suit.a_stained()] [wear_suit.name]!  [format_examine(wear_suit, "Examine")][wear_suit.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(wear_suit)] \a [wear_suit]. [format_examine(wear_suit, "Examine")][wear_suit.description_accessories()]\n"

		//suit/armour storage
		if(s_store)
			if(s_store.is_blood_stained())
				msg += "<span class='warning'>[t_He] [t_is] carrying [bicon(s_store)] [s_store.a_stained()] [s_store.name] on [t_his] [wear_suit.name]!  [format_examine(s_store, "Examine")]</span>\n"
			else
				msg += "[t_He] [t_is] carrying [bicon(s_store)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back && !(slot_back in obscured) && back.is_visible())
		if(back.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_has] [bicon(back)] [back.a_stained()] [back.name] on [t_his] back! [format_examine(back, "Examine")][back.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(back)] \a [back] on [t_his] back. [format_examine(back, "Examine")][back.description_accessories()]\n"

	//hands
	for(var/obj/item/I in held_items)
		if(I.is_visible())
			if(I.is_blood_stained())
				msg += "<span class='warning'>[t_He] [t_is] holding [bicon(I)] [I.a_stained()] [I.name] in [t_his] [get_index_limb_name(is_holding_item(I))]!  [format_examine(I, "Examine")]</span>\n"
			else
				msg += "[t_He] [t_is] holding [bicon(I)] \a [I] in [t_his] [get_index_limb_name(is_holding_item(I))]. [format_examine(I, "Examine")]\n"

	//gloves
	if(gloves && !(slot_gloves in obscured) && gloves.is_visible())
		if(gloves.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_has] [bicon(gloves)] [gloves.a_stained()] [gloves.name] on [t_his] hands! [format_examine(gloves, "Examine")][gloves.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(gloves)] \a [gloves] on [t_his] hands. [format_examine(gloves, "Examine")][gloves.description_accessories()]\n"
	else if(bloody_hands && bloody_hands_data.len && !(slot_gloves in obscured))
		msg += "<span class='warning'>[t_He] [t_has] <span style='color: [get_stain_text_color(bloody_hands_data["blood_colour"])]'>[get_stain_name(bloody_hands_data["blood_type"])]-stained</span> hands!</span>\n"

	//handcuffed?
	if((handcuffed && handcuffed.is_visible()) || (mutual_handcuffs && mutual_handcuffs.is_visible()))
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"

	//belt
	if(belt && belt.is_visible())
		if(belt.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_has] [bicon(belt)] [belt.a_stained()] [belt.name] about [t_his] waist! [format_examine(belt, "Examine")][belt.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(belt)] \a [belt] about [t_his] waist. [format_examine(belt, "Examine")][belt.description_accessories()]\n"

	//shoes
	if(shoes && !(slot_shoes in obscured) && shoes.is_visible())
		if(shoes.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(shoes)] [shoes.a_stained()] [shoes.name] on [t_his] feet! [format_examine(shoes, "Examine")][shoes.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(shoes)] \a [shoes] on [t_his] feet. [format_examine(shoes, "Examine")][shoes.description_accessories()]\n"

	//mask
	if(wear_mask && !(slot_wear_mask in obscured) && wear_mask.is_visible())
		if(wear_mask.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.a_stained()] [wear_mask.name] [wear_mask.goes_in_mouth ? "in" : "on"] [t_his] [wear_mask.goes_in_mouth ? "mouth" : "face"]! [format_examine(wear_mask, "Examine")][wear_mask.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(wear_mask)] \a [wear_mask] [wear_mask.goes_in_mouth ? "in" : "on"] [t_his] [wear_mask.goes_in_mouth ? "mouth" : "face"]. [format_examine(wear_mask, "Examine")][wear_mask.description_accessories()]\n"

	//eyes
	if(glasses && !(slot_glasses in obscured) && glasses.is_visible())
		if(glasses.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_has] [bicon(glasses)] [glasses.a_stained()] [glasses.name] covering [t_his] eyes! [format_examine(glasses, "Examine")][glasses.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(glasses)] \a [glasses] covering [t_his] eyes. [format_examine(glasses, "Examine")][glasses.description_accessories()]\n"

	//ears
	if(ears && !(slot_ears in obscured) && ears.is_visible())
		if(ears.is_blood_stained())
			msg += "<span class='warning'>[t_He] [t_has] [bicon(ears)] [ears.a_stained()] [ears.name] on [t_his] ears! [format_examine(ears, "Examine")][ears.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(ears)] \a [ears] on [t_his] ears. [format_examine(ears, "Examine")][ears.description_accessories()]\n"

	//ID
	if(wear_id)
		/*var/id
		if(istype(wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/pda = wear_id
			id = pda.owner
		else if(istype(wear_id, /obj/item/weapon/card/id)) //just in case something other than a PDA/ID card somehow gets in the ID slot :[
			var/obj/item/weapon/card/id/idcard = wear_id
			id = idcard.registered_name
		if(id && (id != real_name) && (get_dist(src, user) <= 1) && prob(10))
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(wear_id)] \a [wear_id] yet something doesn't seem right...</span>\n"
		else
			*/
		msg += "[t_He] [t_is] wearing [bicon(wear_id)] \a [wear_id]. [format_examine(wear_id, "Examine")]\n"

	switch(jitteriness)
		if(JITTER_HIGH to INFINITY)
			msg += "<span class='danger'>[t_He] [t_is] convulsing violently!</span>\n"
		if(JITTER_MEDIUM to JITTER_HIGH)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		if(1 to JITTER_MEDIUM)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	if(getOxyLoss() > 30 && !skipface)
		msg += "<span class='info'>[t_He] [t_has] a bluish discoloration to their skin.</span>\n"
	if(getToxLoss() > 30 && !skipface)
		msg += "<span class='warning'>[t_He] looks sickly.</span>\n"
	if((radiation > 30 || rad_tick > 200) && !skipface && !(species.flags & RAD_ABSORB))
		msg += "<span class='blob'>[t_He] [t_has] reddish blotches on [t_his] skin.</span>\n"
	//splints
	for(var/organ in list(LIMB_LEFT_LEG,LIMB_RIGHT_LEG,LIMB_LEFT_ARM,LIMB_RIGHT_ARM))
		var/datum/organ/external/o = get_organ(organ)
		if(o && o.status & ORGAN_SPLINTED)
			msg += "<span class='warning'>[t_He] [t_has] a splint on [t_his] [o.display_name]!</span>\n"

	if(mind && mind.suiciding)
		msg += "<span class='warning'>[t_He] appear[t_s] to have committed suicide... there is no hope of recovery.</span>\n"

	if(M_DWARF in mutations)
		msg += "[t_He] [t_is] a short, sturdy creature fond of drink and industry.\n"

	if (isUnconscious())
		msg += "<span class='warning'>[t_He] [t_is]n't responding to anything around [t_him] and seem[t_s] to be asleep.</span>\n"
		if((isDead() || src.health < config.health_threshold_crit) && distance <= 3)
			msg += "<span class='warning'>[t_He] do[t_es] not appear to be breathing.</span>\n"

		if(ishuman(user) && !user.isUnconscious() && distance <= 1)
			user.visible_message("<span class='info'>[user] checks [src]'s pulse.</span>")

			spawn(15)
				if(user && distance <= 1 && (!istype(user) || !user.isUnconscious()))
					if(pulse == PULSE_NONE || (status_flags & FAKEDEATH))
						to_chat(user, "<span class='deadsay'>[t_He] [t_has] no pulse[mind ? "" : " and [t_his] soul has departed"]...</span>")
					else
						to_chat(user, "<span class='deadsay'>[t_He] [t_has] a pulse!</span>")

	msg += "<span class='warning'>"

	if(nutrition < 100)
		if(hardcore_mode_on && eligible_for_hardcore_mode(src))
			msg += "<span class='danger'>[t_He] [t_is] severely malnourished.</span>\n"
		else
			msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= 500)
		msg += "[t_He] [t_is] quite chubby.\n"

	msg += "</span>"

	if(show_client_status_on_examine || isAdminGhost(user))
		if(has_brain() && stat != DEAD && !ajourn)
			if(!key)
				msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
			else if(!client)
				msg += "[t_He] [t_has] a vacant, braindead stare...\n"

	// Religions
	if (ismob(user) && user.mind && user.mind.faith && user.mind.faith.leadsThisReligion(user) && mind)
		if (src.mind.faith == user.mind.faith)
			msg += "<span class='notice'>You recognise [t_him] as a follower of [user.mind.faith.name].</span><br/>"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	for(var/datum/organ/external/temp in organs)
		if(temp)
			if(!temp.is_existing())
				is_destroyed["[temp.display_name]"] = 1
				wound_flavor_text["[temp.display_name]"] = "<span class='danger'>[t_He] [t_is] missing [t_his] [temp.display_name].</span>\n"
				continue

			if(temp.status & ORGAN_PEG)
				if(!(temp.brute_dam + temp.burn_dam))
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a peg [temp.display_name]!</span>\n"
					continue
				else
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a peg [temp.display_name], it has"
				if(temp.brute_dam)
					switch(temp.brute_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some marks"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of damage"," severe cracks and splintering")
				if(temp.brute_dam && temp.burn_dam)
					wound_flavor_text["[temp.display_name]"] += " and"
				if(temp.burn_dam)
					switch(temp.burn_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some burns"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe charring")
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
			else if(temp.status & ORGAN_ROBOT)
				if(!(temp.brute_dam + temp.burn_dam))
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a robot [temp.display_name]!</span>\n"
					continue
				else
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a robot [temp.display_name], it has"
				if(temp.brute_dam)
					switch(temp.brute_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some dents"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of dents"," severe denting")
				if(temp.brute_dam && temp.burn_dam)
					wound_flavor_text["[temp.display_name]"] += " and"
				if(temp.burn_dam)
					switch(temp.burn_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some burns"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe melting")
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
			else if(temp.wounds.len > 0)
				var/list/wound_descriptors = list()
				for(var/datum/wound/W in temp.wounds)
					if(W.internal && !temp.open)
						continue // can't see internal wounds
					var/this_wound_desc = W.desc
					if(W.bleeding())
						this_wound_desc = "bleeding [this_wound_desc]"
					else if(W.bandaged)
						this_wound_desc = "bandaged [this_wound_desc]"
					if(W.germ_level > 600)
						this_wound_desc = "badly infected [this_wound_desc]"
					else if(W.germ_level > 330)
						this_wound_desc = "lightly infected [this_wound_desc]"
					if(this_wound_desc in wound_descriptors)
						wound_descriptors[this_wound_desc] += W.amount
						continue
					wound_descriptors[this_wound_desc] = W.amount
				if(wound_descriptors.len)
					var/list/flavor_text = list()
					var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
					"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
					for(var/wound in wound_descriptors)
						switch(wound_descriptors[wound])
							if(1)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has][prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
							if(2)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has][prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							if(3 to 5)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has] several [wound]s"
								else
									flavor_text += " several [wound]s"
							if(6 to INFINITY)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has] a bunch of [wound]s"
								else
									flavor_text += " a ton of [wound]\s"
					var/flavor_text_string = ""
					for(var/text = 1, text <= flavor_text.len, text++)
						if(text == flavor_text.len && flavor_text.len > 1)
							flavor_text_string += ", and"
						else if(flavor_text.len > 1 && text > 1)
							flavor_text_string += ","
						flavor_text_string += flavor_text[text]
					flavor_text_string += " on [t_his] [temp.display_name].</span><br>"
					wound_flavor_text["[temp.display_name]"] = flavor_text_string
				else
					wound_flavor_text["[temp.display_name]"] = ""
				if(temp.status & ORGAN_BLEEDING)
					is_bleeding["[temp.display_name]"] = 1
			else
				wound_flavor_text["[temp.display_name]"] = ""
			if(temp.open == 3) // Magic number! Someone #define this.
				var/organ_text = list("<span class='notice'>[capitalize(t_his)] [temp.display_name] is <span class='danger'>wide open</span>. ")
				if(length(temp.implants))
					if(length(temp.implants) == 1)
						organ_text += "\A [temp.implants[1]] is visible inside it."
					else
						organ_text += "[english_list(temp.implants)] are visible inside it."
				organ_text += "</span><br>"
				wound_flavor_text["[temp.display_name]"] += jointext(organ_text, null)

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	var/display_chest = 0
	var/display_shoes = 0
	var/display_gloves = 0
	if(wound_flavor_text["head"] && (is_destroyed["head"] || !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas))))
		msg += wound_flavor_text["head"]
	else if(is_bleeding["head"])
		msg += "<span class='warning'>[src] has blood running down [t_his] face!</span>\n"
	if(wound_flavor_text["chest"] && !w_uniform) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	else if(is_bleeding["chest"])
		display_chest = 1
	if(wound_flavor_text["left arm"] && (is_destroyed["left arm"] || !w_uniform))
		msg += wound_flavor_text["left arm"]
	else if(is_bleeding["left arm"])
		display_chest = 1
	if(wound_flavor_text["left hand"] && (is_destroyed["left hand"] || !gloves))
		msg += wound_flavor_text["left hand"]
	else if(is_bleeding["left hand"])
		display_gloves = 1
	if(wound_flavor_text["right arm"] && (is_destroyed["right arm"] || !w_uniform))
		msg += wound_flavor_text["right arm"]
	else if(is_bleeding["right arm"])
		display_chest = 1
	if(wound_flavor_text["right hand"] && (is_destroyed["right hand"] || !gloves))
		msg += wound_flavor_text["right hand"]
	else if(is_bleeding["right hand"])
		display_gloves = 1
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || !w_uniform))
		msg += wound_flavor_text["groin"]
	else if(is_bleeding["groin"])
		display_chest = 1
	if(wound_flavor_text["left leg"] && (is_destroyed["left leg"] || !w_uniform))
		msg += wound_flavor_text["left leg"]
	else if(is_bleeding["left leg"])
		display_chest = 1
	if(wound_flavor_text["left foot"] && (is_destroyed["left foot"] || !shoes))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_shoes = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || !w_uniform))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_chest = 1
	if(wound_flavor_text["right foot"]&& (is_destroyed["right foot"] || !shoes))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_shoes = 1
	if(display_chest)
		msg += "<span class='danger'>[src] has blood soaking through from under [t_his] clothing!</span>\n"
	if(display_shoes)
		msg += "<span class='danger'>[src] has blood running from [t_his] shoes!</span>\n"
	if(display_gloves)
		msg += "<span class='danger'>[src] has blood running from under [t_his] gloves!</span>\n"

	for(var/implant in get_visible_implants(1))
		msg += "<span class='warning'><b>[src] has \a [implant] sticking out of [t_his] flesh!</span>\n"

	if(!is_destroyed["head"])
		if(getBrainLoss() >= 60)
			msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

		if(distance <= 3)
			if(!has_brain())
				msg += "<span class='notice'><b>[t_He] [t_has] had [t_his] brain removed.</b></span>\n"

	var/butchery = "" //More information about butchering status, check out "code/datums/helper_datums/butchering.dm"
	if(butchering_drops && butchering_drops.len)
		for(var/datum/butchering_product/B in butchering_drops)
			butchery = "[butchery][B.desc_modifier(src, user)]"
	if(butchery)
		msg += "<span class='warning'>[butchery]</span>\n"

	if(istype(user))
		if(user.hasHUD(HUD_SECURITY))
			var/perpname = get_identification_name(get_face_name())
			var/criminal = "None"

			var/datum/data/record/sec_record = data_core.find_security_record_by_name(perpname)
			if(sec_record)
				msg += {"<span class = 'deptradio'><b><u>Security Data</u></b></span>\n"}
				criminal = sec_record.fields["criminal"]

				if(user.hasHUD(HUD_ARRESTACCESS))
					msg += {"<span class = 'deptradio'>Criminal status:</span> <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"}
				else
					msg += {"<span class = 'deptradio'>Criminal status:</span> \[[criminal]\]\n"}
				msg += {"<span class = 'deptradio'>Security records:</span> <a href='?src=\ref[src];secrecord=`'>\[View\]\n</a>"}
				if(!isjustobserver(user))
					msg += "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>\n"
				msg += {"[wpermit(src) ? "<span class = 'deptradio'>Has weapon permit.</span>\n" : ""]"}

		if(user.hasHUD(HUD_WAGE))
			var/perpname = get_identification_name(get_face_name())
			var/employment = "None"

			var/datum/data/record/gen_record = data_core.find_general_record_by_name(perpname)
			if(gen_record)
				msg += {"<span class = 'deptradio'><b><u>Employment Data</u></b></span>\n"}
				employment = gen_record.fields["notes"]

				msg += {"<span class = 'deptradio'>Employment Records:</span></a>\n"}
				msg += {"<span class = 'deptradio'>[employment]</span>\n"}

		if(user.hasHUD(HUD_MEDICAL))
			var/perpname = get_identification_name(get_face_name())
			var/medical = "None"
			var/medicalsanity = "None"

			var/datum/data/record/gen_record = data_core.find_general_record_by_name(perpname)
			if(gen_record)
				msg += {"<span class = 'deptradio'><b><u>Medical Data</u></b></span>\n"}
				medical = gen_record.fields["p_stat"]
				medicalsanity = gen_record.fields["m_stat"]

			msg += {"<span class = 'deptradio'>Physical status:</span> <a href='?src=\ref[src];medical=1'>\[[medical]\]</a>
				<span class = 'deptradio'>Mental status:</span> <a href='?src=\ref[src];medicalsanity=1'>\[[medicalsanity]\]</a>
				<span class = 'deptradio'>Medical records:</span> <a href='?src=\ref[src];medrecord=`'>\[View\]</a>\n"}
			for (var/ID in virus2)
				if (ID in virusDB)
					var/datum/data/record/v = virusDB[ID]
					msg += "<br><span class='warning'>[v.fields["name"]][v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""] detected in subject.</span>\n"
			if(!isjustobserver(user))
				msg += "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>\n"

		if(isjustobserver(user))
			var/mob/dead/observer/O = user
			if(O.antagHUD && mind && mind.antag_roles.len)
				msg += "<a href='?src=\ref[src];purchaselog=`'>\[Show antag purchase log\]</a>\n"

	if(flavor_text && can_show_flavor_text())
		msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"

	return msg

#undef JITTER_MEDIUM
#undef JITTER_HIGH
