/datum/wiki_template/food/proc/generate_output(datum/crafting_recipe/food/recipe)
	var/name_string = ""
	var/reqs_string = ""
	var/cat_string = ""
	name_string = capitalize(recipe.name)
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

	// Set the category string directly without looping, since category is a single value
	cat_string = "[initial(recipe.category)]<br>"

	// Check for missing components in requirements and category strings
	var/generated_requirements = ""
	if (reqs_string)
		generated_requirements += "**Required Ingredients:** <br>[reqs_string]"

	var/generated_category = ""
	if (cat_string)
		generated_category += "[cat_string]"

	// Create the template for output
	var/created_template = "## [name_string] \n"
	created_template += "| --- | --- | --- | \n"
	created_template += "<a name=\"[name_string]\"></a><td rowspan=2 width = 300px height=150px> <center> <img src =\"/wrench.png\" width = 96 height = 96> <br>[name_string] <td width=225> <center> Food Category | <center>Machine Required | \n"
	created_template += "| | [generated_category] | N/A \n"
	created_template += " <td colspan=2> <center> Recipe Requirements | \n"
	created_template += " | | [generated_requirements] |||\n"
	// Ensure all required fields are non-empty before generating template
	if (name_string == "" || generated_requirements == "" || generated_category == "")
		return null  // Skip this entry if any required string is empty
	return created_template

// Test proc to verify individual recipe templates
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

	for (var/type in typesof(/datum/crafting_recipe/food))
		var/datum/crafting_recipe/food/new_recipe = new type
		var/output = wiki_template.generate_output(new_recipe)

		if (output == null)  // Check for failed templates
			failed_templates += "[new_recipe.name] failed to generate.<br>"
		else
			mega_string += "[output] \n"

	GLOB.food_wiki = mega_string
	GLOB.food_wiki_failed = failed_templates
	mega_string += "This many templates failed to build: [length(failed_templates)] \n"
	// Display or log results
	return mega_string
