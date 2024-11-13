/datum/wiki_template/food/proc/generate_output(datum/crafting_recipe/food/recipe)
	// Initialize required strings
	var/name_string = recipe.name ? capitalize(initial(recipe.name)) : ""
	var/reqs_string = ""
	var/cat_string = ""

	// Iterate over reqs to create a readable list of ingredients
	if (istype(recipe.reqs, /list))
		for (var/atom/item_type as anything in recipe.reqs)
			var/quantity = recipe.reqs[item_type]
			var/liquidornot = new item_type

			// Only add "units" if the item is a reagent
			if (istype(liquidornot, /datum/reagent))
				var/item_name = capitalize(item_type.name)
				reqs_string += "- [quantity]u [item_name]<br>"
			else
				var/item_name = capitalize(item_type.name)
				reqs_string += "- [quantity]x [item_name]<br>"

	// Set category string directly without looping
	if (recipe.category)
		cat_string = "[initial(recipe.category)]<br>"

	// Format the generated requirements section
	var/generated_requirements = ""
	if (reqs_string)
		generated_requirements += "**Required Ingredients:** <br>[reqs_string]"

	var/generated_category = ""
	if (cat_string)
		generated_category += "[cat_string]"

	// Track missing components and return failure reasons if needed
	var/missing_reasons = ""
	if (name_string == "")
		missing_reasons += "name "
	if (generated_requirements == "")
		missing_reasons += "requirements "
	if (generated_category == "")
		missing_reasons += "category "

	if (missing_reasons)
		return "[recipe.name ? recipe.name : "Unnamed recipe"] failed:[missing_reasons]" // Include fallback for unnamed recipes

	// Create the template for output
	var/created_template = "## [name_string] \n"
	created_template += "| --- | --- | --- | \n"
	created_template += "<a name=\"[initial(recipe.name)]\"></a><td rowspan=2 width = 300px height=150px> <center> <img src =\"/wrench.png\" width = 96 height = 96> <br>[name_string] <td width=225> <center> Food Category | <center>Machine Required | \n"
	created_template += "| | [generated_category] | N/A \n"
	created_template += " <td colspan=2> <center> Recipe Requirements | \n"
	created_template += " | | [generated_requirements] |||\n"

	return created_template

/proc/test_generate_food_wiki()
	var/datum/crafting_recipe/food/recipe = new /datum/crafting_recipe/food/birthdaycake
	var/datum/wiki_template/food/wiki_template = new /datum/wiki_template/food
	var/test_output = wiki_template.generate_output(recipe)
	return test_output

GLOBAL_VAR_INIT(food_wiki, "")
GLOBAL_VAR_INIT(food_wiki_failed, "")

/proc/generate_food_wiki_templates()
	var/mega_string = ""
	var/failed_templates = ""
	var/datum/wiki_template/food/wiki_template = new /datum/wiki_template/food

	var/name_missing_count = 0
	var/requirements_missing_count = 0
	var/category_missing_count = 0

	for (var/type in typesof(/datum/crafting_recipe/food))
		var/datum/crafting_recipe/food/new_recipe = new type
		var/output = wiki_template.generate_output(new_recipe)

		if (output && findtext(output, "failed:"))  // Check for failed templates with reasons
			var/failure_reason = "[new_recipe.name ? new_recipe.name : "Unnamed recipe"] failed to generate due to: "

			if (findtext(output, "name"))
				failure_reason += "Missing name; "
				name_missing_count += 1

			if (findtext(output, "requirements"))
				failure_reason += "Missing requirements; "
				requirements_missing_count += 1

			if (findtext(output, "category"))
				failure_reason += "Missing category; "
				category_missing_count += 1

			failed_templates += failure_reason + "<br>"
		else
			mega_string += "[output] \n"

	GLOB.food_wiki = mega_string
	GLOB.food_wiki_failed = failed_templates

	mega_string += "Summary of failures:<br>"
	mega_string += "Templates with missing name: [name_missing_count]<br>"
	mega_string += "Templates with missing requirements: [requirements_missing_count]<br>"
	mega_string += "Templates with missing category: [category_missing_count]<br>"
	mega_string += "<br>Details of each failure:<br>[failed_templates]"

	// Display or log results
	return mega_string
