#===============================================================================
# ** Random HM/TM Selector
#    This plugin provides a specialized function to choose a random TM or HM.
#    Compatible with Pokémon Essentials v21.1.
#===============================================================================

# Main function to choose a random TM or HM
#
# @param whiteList   [Array<Symbol>, nil] An array of TM/HM IDs (Symbols) to
#                                         choose ONLY from. If nil, considers
#                                         all (filtered by blackList/include_type).
# @param blackList   [Array<Symbol>, nil] An array of item IDs (Symbols) to
#                                         EXCLUDE from the random selection.
# @param include_type [Symbol, nil] Specifies to include only :TM, only :HM,
#                                   or :ALL for both. If nil, defaults to :ALL.
#                                   Note: TMs are identified by :TR field_use value.
# @return [Symbol, nil] The ID of the randomly chosen TM/HM, or nil if no
#                       TM/HM could be chosen based on the criteria.
def pbChooseRandomTMHM(whiteList = nil, blackList = nil, include_type = :ALL)
  blackList = [] if blackList.nil?
  include_type = :ALL if include_type.nil?

  arr = [] # Array to store eligible TM/HM IDs

  # Helper to check if an item is a TR (TM) or HM
  is_tm = proc { |item_data| item_data.field_use == 5 }
  is_hm = proc { |item_data| item_data.field_use == 4 }

  echoln "DEBUG: [pbChooseRandomTMHM] called. include_type: #{include_type}, blackList: #{blackList}"

  # Process whiteList if provided
  if whiteList
    whiteList.each do |item_id|
      item_data = GameData::Item.try_get(item_id)
      next if item_data.nil?
      next if blackList.include?(item_id)
      
      is_eligible = false
      if include_type == :TM
        is_eligible = is_tm.call(item_data)
      elsif include_type == :HM
        is_eligible = is_hm.call(item_data)
      elsif include_type == :ALL
        is_eligible = is_tm.call(item_data) || is_hm.call(item_data)
      end

      if is_eligible
        arr.push(item_id)
      end
    end
  else
    # If no whiteList, iterate through all items
    GameData::Item.each do |item_data|
      item_id = item_data.id
      next if blackList.include?(item_id)

      is_eligible = false
      if include_type == :TM
        is_eligible = is_tm.call(item_data)
      elsif include_type == :HM
        is_eligible = is_hm.call(item_data)
      elsif include_type == :ALL
        is_eligible = is_tm.call(item_data) || is_hm.call(item_data)
      end

      if is_eligible
        arr.push(item_id)
      end
    end
  end

  echoln "DEBUG: [pbChooseRandomTMHM] Final eligible array size: #{arr.length}. Eligible items: #{arr.inspect}"
  chosen_tm_hm = arr.sample
  echoln "DEBUG: [pbChooseRandomTMHM] Chosen TM/HM: #{chosen_tm_hm}"
  return chosen_tm_hm
end


# Example usage function for demonstration purposes.
# This can be called from an event using `pbGiveRandomTM` or `pbGiveRandomHM`
def pbGiveRandomTM
  # You can customize the blacklist if there are TMs/HMs you never want to give randomly
  blacklisted_tm_hms = [] # Example: Exclude TM01 - [:TM01]

  # Choose a random TM only (now correctly checks for :TR FieldUse)
  item_id = pbChooseRandomTMHM(nil, blacklisted_tm_hms, :TM)

  if item_id
    # Use pbReceiveItem for proper messaging and bag handling
    pbReceiveItem(item_id)
  else
    pbMessage(_INTL("No suitable TMs could be found!"))
  end
end

# Global variable to track given HMs. This will persist across saves.
# It needs to be initialized if not already present.
# It's better to ensure this is done in a game initialization script or similar.
# For now, we'll initialize it here if it's nil.
$player_given_hms = [] if !$player_given_hms.is_a?(Array)

def pbGiveRandomHM
  # Use the global list of already given HMs as the blacklist
  blacklisted_hms = $player_given_hms.clone # Use .clone to avoid modifying the original array directly in selection

  echoln "DEBUG: [pbGiveRandomHM] Current $player_given_hms: #{$player_given_hms.inspect}"
  echoln "DEBUG: [pbGiveRandomHM] Blacklisting HMs: #{blacklisted_hms.inspect}"

  # Pass the list of existing HMs as the blackList to prevent duplicates
  item_id = pbChooseRandomTMHM(nil, blacklisted_hms, :HM)

  if item_id
    pbReceiveItem(item_id)
    # Add the newly received HM to the global list
    $player_given_hms.push(item_id)
    echoln "DEBUG: [pbGiveRandomHM] Just gave player HM: #{item_id}. Updated $player_given_hms: #{$player_given_hms.inspect}"
  else
    # If no suitable HM is found (e.g., player has all HMs or all are blacklisted)
    pbMessage(_INTL("No suitable HMs could be found!"))
  end
end

# New function: Gives a random TM or HM, treating HMs as unique and TMs as reusable.
def pbGiveRandomTMorHM
  eligible_items_for_selection = []
  
  # Add all TMs to the pool (TMs are reusable, so no blacklisting by ownership here)
  GameData::Item.each do |item_data|
    if item_data.field_use == 5 # This is the internal value for TR (TM)
      eligible_items_for_selection.push(item_data.id)
    end
  end

  # Add HMs to the pool, but only if the player doesn't already have them
  # Use the global list of already given HMs for blacklisting.
  GameData::Item.each do |item_data|
    if item_data.field_use == 4 # This is the internal value for HM
      unless $player_given_hms.include?(item_data.id)
        eligible_items_for_selection.push(item_data.id)
      end
    end
  end
  
  echoln "DEBUG: [pbGiveRandomTMorHM] Combined eligible items (before random pick): #{eligible_items_for_selection.inspect}"

  chosen_item_id = eligible_items_for_selection.sample

  if chosen_item_id
    pbReceiveItem(chosen_item_id)
    # If the chosen item is an HM, add it to the tracking list
    if GameData::Item.get(chosen_item_id).field_use == 4 # Check if it's an HM
      $player_given_hms.push(chosen_item_id)
      echoln "DEBUG: [pbGiveRandomTMorHM] Gave player HM: #{chosen_item_id}. Updated $player_given_hms: #{$player_given_hms.inspect}"
    else
      echoln "DEBUG: [pbGiveRandomTMorHM] Gave player TM: #{chosen_item_id}."
    end
  else
    pbMessage(_INTL("No suitable TMs or HMs could be found!"))
    echoln "DEBUG: [pbGiveRandomTMorHM] No suitable TMs or HMs could be found (pool was empty)."
  end
end
