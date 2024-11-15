/datum/wiki_template/chemical_reaction/proc/generate_output(datum/chemical_reaction/recipe)
	var/name_string = ""  // The reaction name
	var/reqs_string = ""  // List of required reagents and quantities
	var/results_string = ""  // List of resulting chemicals and quantities
	var/temp_string = ""  // Temperature details
	// Reaction name from results or chemical reaction itself
	for (var/atom/item_type as anything in recipe.results)
		name_string = item_type.name  // Accessing the name of the instantiated item

	// Process the results (produced chemicals and quantities)
	if (istype(recipe.results, /list))
		for (var/atom/item_type as anything in recipe.results)
			var/quantity = recipe.results[item_type]  // Quantity produced
			var/item_name = item_type.name  // Access the 'name' of the reagent
			results_string += "- [quantity]u [item_name]<br>"
	else
		results_string = "No results defined for this reaction.<br>"

	// Process the required reagents (needed chemicals and quantities)
	if (istype(recipe.required_reagents, /list))  // Ensure required_reagents is defined
		for (var/atom/item_type as anything in recipe.required_reagents)
			var/quantity = recipe.required_reagents[item_type]  // Quantity required
			var/item_name = item_type.name  // Access the 'name' of the reagent
			reqs_string += "- [quantity]u [item_name]<br>"
	else
		reqs_string = "No required reagents defined for this reaction.<br>"

	// Set temperature details
	temp_string = "Required Temp: [recipe.required_temp]°C<br>Optimal Temp: [recipe.optimal_temp]°C<br>Overheat Temp: [recipe.overheat_temp]°C<br>"

	// Finalize the template with the desired structure
	var/created_template = "### [name_string] \n"
	created_template += "| --- | --- | --- | \n"
	created_template += "<a name=\"[name_string]\"></a><td rowspan=2 width=300px height=150px> <center> <img src=\"/wrench.png\" width=96 height=96> <br>[name_string] <td width=225> <center> Chemical Reaction Category | \n"
	created_template += "| | Required Temp: [recipe.required_temp]°C<br>Optimal Temp: [recipe.optimal_temp]°C<br>Overheat Temp: [recipe.overheat_temp]°C<br> | \n"
	created_template += "| | Required Reagents: <br>[reqs_string] |||\n"
	created_template += " <td colspan=2> <center> Resulting Chemicals | \n"
	created_template += "| | [results_string] |||\n"

	// Ensure all required fields are non-empty before generating template
	if (reqs_string == "" || results_string == "" || temp_string == "")
		return null  // Skip this entry if any required string is empty

	// If no results, then no name to display
	if (results_string == "")
		return null

	return created_template

// Test proc to verify individual recipe templates
/proc/test_generate_chemical_reaction_wiki()
	var/datum/chemical_reaction/medicine/helbital = new /datum/chemical_reaction/medicine/helbital  // Example chemical reaction (helbital)
	var/datum/wiki_template/chemical_reaction/wiki_template = new /datum/wiki_template/chemical_reaction
	var/test_output = wiki_template.generate_output(helbital)
	return test_output

GLOBAL_VAR_INIT(chemical_reaction_wiki, "")
GLOBAL_VAR_INIT(chemical_reaction_wiki_failed, "")

/proc/generate_chemical_reaction_wiki_templates()
	var/mega_string = ""
	var/failed_templates = ""
	var/datum/wiki_template/chemical_reaction/wiki_template = new /datum/wiki_template/chemical_reaction

	// Loop through all chemical reactions to generate templates
	for (var/type in typesof(/datum/chemical_reaction))  // Search for medicine reactions only
		var/datum/chemical_reaction/medicine/new_recipe = new type
		var/output = wiki_template.generate_output(new_recipe)

		if (output == null)  // Check for failed templates
			failed_templates += "Failed to generate.<br>"
		else
			mega_string += "[output] \n"

	GLOB.chemical_reaction_wiki = mega_string
	GLOB.chemical_reaction_wiki_failed = failed_templates
	mega_string += "This many templates failed to build: [length(failed_templates)] \n"
	// Display or log results
	return mega_string
