#===============================================================================
# ** Random Item Selector
#    This plugin provides functions to choose a random item from the game's
#    item data, with options for white-listing, black-listing, and
#    excluding items based on their defined flags in items.txt.
#    Compatible with Pokémon Essentials v21.1.
#===============================================================================

# Main function to choose a random item
#
# @param whiteList     [Array<Symbol>, nil] An array of item IDs (Symbols) to
#                                           choose ONLY from. If nil, considers
#                                           all items (filtered by blackList/flags).
# @param blackList     [Array<Symbol>, nil] An array of item IDs (Symbols) to
#                                           EXCLUDE from the random selection.
# @param exclude_flags [Array<Symbol>, nil] An array of item flags (Symbols)
#                                           whose items should be excluded.
#                                           e.g., [:TR, :HM, :KeyItem, :PokeBall]
# @param include_pockets [Array<Integer>, nil] An array of pocket numbers to
#                                             restrict the selection to.
#                                             e.g., [1, 2] for general items.
# @return [Symbol, nil] The ID of the randomly chosen item, or nil if no item
#                       could be chosen based on the criteria.
def pbChooseRandomItem(whiteList = nil, blackList = nil, exclude_flags = nil, include_pockets = nil)
  # Ensure blackList and exclude_flags are arrays if provided, otherwise empty
  blackList     = [] if blackList.nil?
  exclude_flags = [] if exclude_flags.nil?
  include_pockets = [] if include_pockets.nil?

  arr = [] # Array to store eligible item IDs

  # Process whiteList if provided
  if whiteList
    whiteList.each do |item_id|
      item_data = GameData::Item.try_get(item_id)
      next if item_data.nil?
      # Check if item is in blackList
      next if blackList.include?(item_id)
      # Check if item has any excluded flags
      next if exclude_flags.any? { |flag| item_data.has_flag?(flag) }
      # Check if item is in an included pocket (if specified)
      next if !include_pockets.empty? && !include_pockets.include?(item_data.pocket)

      arr.push(item_id)
    end
  else
    # If no whiteList, iterate through all items
    GameData::Item.each do |item_data|
      item_id = item_data.id
      # Check if item is in blackList
      next if blackList.include?(item_id)
      # Check if item has any excluded flags
      next if exclude_flags.any? { |flag| item_data.has_flag?(flag) }
      # Check if item is in an included pocket (if specified)
      next if !include_pockets.empty? && !include_pockets.include?(item_data.pocket)

      arr.push(item_id)
    end
  end

  # Pull random entry from array
  chosen_item = arr.sample
  return chosen_item
end

# Example usage function for demonstration purposes.
# This can be called from an event using `pbGiveRandomGeneralItem`
def pbGiveRandomGeneralItem
  # Define flags to exclude for "general items" (e.g., TRs/HMs, PokeBalls, KeyItems)
  # Updated :TM to :TR based on your items.txt
  excluded_flags = [:TR, :HM, :PokeBall, :KeyItem, :Berry, :Apricorn, :Mail, :TypeGem]
  # Define pockets to include (e.g., Pocket 1 for general items, Pocket 2 for medicine)
  # You can see pocket numbers in your items.txt file.
  included_pockets = [1, 2, 7] # Example: General, Medicine, Battle Items

  # You can also define a blacklist for specific items you never want
  # e.g., blacklisted_items = [:MASTERBALL, :SACREDASH]
  blacklisted_items = []

  # Choose a random item
  item_id = pbChooseRandomItem(
    nil,                # No whitelist, consider all (filtered)
    blacklisted_items,  # Apply specific blacklist
    excluded_flags,     # Apply flag-based exclusions
    included_pockets    # Restrict to these pockets
  )

  if item_id
    # Use pbReceiveItem for proper messaging and bag handling
    # This also indirectly helps with $Trainer being nil in early game states
    # as pbReceiveItem is more robustly designed for such situations.
    pbReceiveItem(item_id)
  else
    pbMessage(_INTL("No suitable item could be found!"))
  end
end

