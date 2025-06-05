README: Random Item and TM/HM Selectors
This repository contains two custom Ruby script plugins for Pokémon Essentials v21.1, designed to simplify giving random items and TMs/HMs to players in your game.

1. Plugin Overview
A. Random Item Selector (File: Random Item Selector.rb)
Allows you to give a truly random item from your items.txt database. This plugin focuses on general items, excluding TMs/HMs, Poke Balls, Key Items, and similar specialized categories by default.

Features:

White-listing: Choose only from a specific list of item IDs (e.g., [:POTION, :SUPERPOTION]).

Black-listing: Exclude specific item IDs from being chosen (e.g., [:MASTERBALL, :SACREDASH]).

Flag-based exclusion: Exclude items that have certain "Flags" defined in items.txt. By default, the pbGiveRandomGeneralItem helper function excludes items with the following flags: [:TR, :HM, :PokeBall, :KeyItem, :Berry, :Apricorn, :Mail, :TypeGem]. You can customize these exclusions.

Pocket-based inclusion: Restrict the random selection to items found only in specific bag pockets (e.g., [1, 2, 7] for general, medicine, and battle items pockets).

B. Random TM/HM Selector (File: Random HM-TM Selector.rb)
Provides functions specifically for giving random Technical Machines (TMs) or Hidden Machines (HMs).

Important: TMs are identified by FieldUse = TR (internal value 5) in items.txt. HMs are identified by FieldUse = HM (internal value 4) in items.txt.

Features:

White-listing: Choose only from a specific list of TMs/HMs.

Black-listing: Exclude specific TMs/HMs from being chosen.

Type-specific selection: Choose only TMs, only HMs, or both.

HM Duplication Prevention: Automatically tracks HMs given to the player via pbGiveRandomHM or pbGiveRandomTMorHM using a global variable $player_given_hms to prevent giving the same HM twice. TMs can be given multiple times as they are generally reusable.

2. Installation
These are standard Ruby script plugins that should be placed directly into your Pokémon Essentials project's Plugins folder.

Steps:

Navigate to your Pokémon Essentials project folder.

Locate the Plugins subfolder within your project.

Drag and drop the Random Item Selector.rb file into the Plugins folder.

Drag and drop the Random HM-TM Selector.rb file into the Plugins folder.

Launch your RPG Maker XP project. The plugins will be automatically loaded by Essentials.

Save your RPG Maker XP project (File > Save).

3. Usage in RPG Maker XP Events
In any map event, you can use the "Script" command (found on Page 3 of the Event Commands) to call the functions provided by these plugins.

A. Giving a Random General Item (using Random Item Selector.rb)
Call the helper function:

pbGiveRandomGeneralItem

This will automatically pick a random item based on its default exclusions (no TMs/HMs, Poke Balls, Key Items, etc.) and pockets (1, 2, 7), and give it to the player with a message. This is suitable for most common use cases.

For more custom control (e.g., a specific whitelist of items, or different exclusions for a particular event), you can call pbChooseRandomItem directly and then pbReceiveItem:

# Example: Give a random Potion or Super Potion
chosen_item = pbChooseRandomItem([:POTION, :SUPERPOTION])
if chosen_item
  pbReceiveItem(chosen_item)
else
  pbMessage(_INTL("No suitable item could be found."))
end

# Example: Give a random item from pocket 1, but exclude "REPEL"
custom_exclusions = [:REPEL]
custom_pockets = [1]
chosen_item = pbChooseRandomItem(nil, custom_exclusions, nil, custom_pockets)
if chosen_item
  pbReceiveItem(chosen_item)
else
  pbMessage(_INTL("No suitable item could be found with custom rules."))
end

B. Giving a Random TM (using Random HM-TM Selector.rb)
Call the helper function:

pbGiveRandomTM

This will pick a random TM from your items.txt (identified by FieldUse = TR) and give it to the player. TMs can be received multiple times.

You can pass an optional blacklist:

pbGiveRandomTM([:TM01, :TM02]) # Excludes TM01 and TM02

C. Giving a Random HM (using Random HM-TM Selector.rb)
Call the helper function:

pbGiveRandomHM

This will pick a random HM from your items.txt (identified by FieldUse = HM) that the player does not already possess.

Once an HM is given, it is permanently tracked and will not be given again.

You can pass an optional blacklist (in addition to owned HMs):

pbGiveRandomHM([:HM01]) # Excludes HM01 (and any already owned)

D. Giving a Random TM or HM (combined pool, using Random HM-TM Selector.rb)
Call the helper function:

pbGiveRandomTMorHM

This function builds a pool of all available TMs and all HMs that the player does not already own.

It then picks one item randomly from this combined pool.

If an HM is chosen, it is added to the $player_given_hms list to prevent future duplication.

4. Important Notes
The global variable $player_given_hms is used to track received HMs and persists across save files. It's automatically initialized.

Ensure your items.txt definitions correctly use FieldUse = TR for TMs and FieldUse = HM for HMs, as these scripts rely on that.

Test thoroughly after installation to ensure desired behavior.
