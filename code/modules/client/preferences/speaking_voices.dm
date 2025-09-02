GLOBAL_LIST_INIT(speaking_voices, list(
    "Default" = "default",
    "CBAT" = "cbat"
))

/datum/preference/choiced/speaking_voice
    category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
    savefile_key = "speaking_voice"  // Fixed incorrect savefile key
    savefile_identifier = PREFERENCE_CHARACTER


/datum/preference/choiced/speaking_voice/apply_to_client(client/client, value)
    client.speaking_voice = value

/datum/preference/choiced/speaking_voice/init_possible_values()
    return GLOB.speaking_voices
