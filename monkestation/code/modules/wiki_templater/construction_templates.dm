/datum/wiki_template/construction/proc/generate_output(obj/machinery/machine)
    var/name_string = ""
    var/reqs_string = ""
    var/cat_string = ""

    // Use the machine name and description directly
    name_string = capitalize(machine.name)
    cat_string = "[initial(machine.desc)]<br>"

    // Iterate over component_parts if available for construction requirements
    if (istype(machine.component_parts, /list))
        for (var/atom/item_type as anything in machine.component_parts)
            var/quantity = machine.component_parts[item_type]
            var/part_name = capitalize(item_type.name)
            reqs_string += "- [quantity]x [part_name]<br>"

    // Finalize requirements and category strings
    var/generated_requirements = ""
    if (reqs_string)
        generated_requirements += "**Required Components:** <br>[reqs_string]"

    var/generated_category = ""
    if (cat_string)
        generated_category += "[cat_string]"

    // Create the wiki template for output
    var/created_template = "## [name_string] \n"
    created_template += "| --- | --- | --- | \n"
    created_template += "<a name=\"[name_string]\"></a><td rowspan=2 width=300px height=150px> <center> <img src=\"/sink.png\" width=96 height=96> <br>[name_string] <td width=225> <center> Machine Category | <center>Requirements | \n"
    created_template += "| | [generated_category] | N/A \n"
    created_template += " <td colspan=2> <center> Construction Requirements | \n"
    created_template += " | | [generated_requirements] |||\n"

    // Ensure all required fields are non-empty before generating template
    if (name_string == "" || generated_requirements == "" || generated_category == "")
        return null  // Skip this entry if any required string is empty
    return created_template

// Test proc to verify individual machine templates
/proc/test_generate_machine_wiki()
    var/obj/machinery/machine = new /obj/machinery/dna_scannernew  // Example machine
    var/datum/wiki_template/construction/wiki_template = new /datum/wiki_template/construction
    var/test_output = wiki_template.generate_output(machine)
    return test_output

GLOBAL_VAR_INIT(machine_wiki, "")
GLOBAL_VAR_INIT(machine_wiki_failed, "")

proc/generate_machine_wiki_templates()
    var/mega_string = ""
    var/failed_templates = ""
    var/datum/wiki_template/construction/wiki_template = new /datum/wiki_template/construction

    // Loop through all machinery types to generate templates
    for (var/type in typesof(/obj/machinery))
        var/obj/machinery/new_machine = new type
        var/output = wiki_template.generate_output(new_machine)

        if (output == null)  // Check for failed templates
            failed_templates += "[new_machine.name] failed to generate.<br>"
        else
            mega_string += "[output] \n"

    GLOB.machine_wiki = mega_string
    GLOB.machine_wiki_failed = failed_templates
    mega_string += "This many templates failed to build: [length(failed_templates)] \n"
    // Display or log results
    return mega_string
