// Main procedure to generate the full surgery procedure templates
GLOBAL_VAR_INIT(surgery_wiki, "")
GLOBAL_VAR_INIT(surgery_wiki_failed, "")

/proc/generate_surgery_procedure_templates()
	var/mega_string = ""  // To store all generated templates
	var/failed_templates = ""  // To store any failed templates
	var/datum/wiki_template/surgery/wiki_template = new /datum/wiki_template/surgery
	var/list/surgeries = list()
	var/list/sorted = list()

	// Loop through all surgery procedures to generate templates
	for (var/type in subtypesof(/datum/surgery))
		surgeries += type
	sorted = sort_names(surgeries, TRUE)  // Sort surgeries alphabetically

	for (var/surgery_type in sorted)
		var/datum/surgery/init = new surgery_type
		var/output = wiki_template.generate_output(init)
		if (isnull(output))  // Check for failed templates
			failed_templates += "Failed to generate: [init.name]<br>"
		else
			mega_string += "[output]\n"

	// Global variables to store results
	GLOB.surgery_wiki = mega_string
	GLOB.surgery_wiki_failed = failed_templates
	mega_string += "This many templates failed to build: [length(failed_templates)]\n"

	// Return the full wiki string with failure counts
	return mega_string

// Updated procedure to generate a full surgery procedure template
/datum/wiki_template/surgery/proc/generate_output(datum/surgery/surgery_procedure)
	var/tool_string = ""
	var/surgery_name = capitalize(surgery_procedure.name)
	var/steps_tool_string = ""
	for (var/datum/surgery_step/step as anything in surgery_procedure.steps)
		var/step_name = capitalize(step.name)
		tool_string = ""
		for (var/obj/item/tool as anything in step.implements)
			new tool
			var/tool_name = capitalize(initial(tool.name))
			tool_string += "[tool_name]: [step.implements[tool]]% success<br>"
		steps_tool_string += "| Step: [step_name] | Tools: [tool_string] |\n"

	var/surgery_template = "## Surgery Procedure: [surgery_name]\n"
	surgery_template += "### Surgery Steps\n"
	surgery_template += "| Step | Tools |\n"
	surgery_template += "| --- | --- |\n"
	surgery_template += "[steps_tool_string]"

	if (steps_tool_string == "")
		return null
	return surgery_template

// Test procedure to verify individual surgery procedure templates
/proc/test_generate_surgery_procedure_wiki()
	var/datum/surgery/organ_manipulation/external = new
	var/datum/wiki_template/surgery/wiki_template = new
	var/test_output = wiki_template.generate_output(external)
	return test_output
