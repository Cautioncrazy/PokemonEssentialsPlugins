Random Item and TM/HM Selectors

This repository contains two custom Ruby script plugins for Pokémon Essentials v21.1, designed to simplify giving random items and TMs/HMs to players in your game.

1. Plugin Overview
A. Random Item Selector (File: Random Item Selector.rb)
Allows you to give a truly random item from your items.txt database.

Features:

White-listing: Choose only from a specific list of items.

Black-listing: Exclude specific items from being chosen.

Flag-based exclusion: Exclude items with certain flags (e.g., exclude all Poke Balls, Key Items, or TMs/HMs). By default, it excludes TMs/HMs, Poke Balls, Key Items, Berries, Apricorns, Mail, and Type Gems.

Pocket-based inclusion: Restrict items to specific bag pockets.

B. Random TM/HM Selector (File: 003_Random_TM_HM_Selector.rb)
Provides functions specifically for giving random Technical Machines (TMs) or Hidden Machines (HMs).

TMs are identified by FieldUse = TR (internal value 5).

HMs are identified by FieldUse = HM (internal value 4).

Features:

White-listing: Choose only from a specific list of TMs/HMs.

Black-listing: Exclude specific TMs/HMs from being chosen.

Type-specific selection: Choose only TMs, only HMs, or both.

HM Duplication Prevention: Automatically tracks HMs given to the player via pbGiveRandomHM or pbGiveRandomTMorHM using a global variable $player_given_hms to prevent giving the same HM twice. TMs can be given multiple times as they are generally reusable.

2. Installation
These are standard Ruby script files that should be placed directly into your Pokemon Essentials project's Plugin Folder.

Steps:

Open your Pokemon Essentials project folder.

Navigate to the Plugins folder.

For Random Item Selector.rb:

Drop the Random Item Selector folder into the Plugin folder

For Random TM-HM Selector.rb (This file):

Drop the Random HM-TM Selector folder into the Plugin folder

3. Usage in RPG Maker XP Events
In any map event, you can use the "Script" command (found on Page 3 of the Event Commands) to call the functions provided by these plugins.

A. Giving a Random General Item (using Random Item Selector.rb)
Call the helper function:

pbGiveRandomGeneralItem

This will automatically pick a random item based on default exclusions (no TMs/HMs, Poke Balls, Key Items, etc.) and pockets (1, 2, 7), and give it to the player with a message.

For more custom control (e.g., a specific whitelist or different exclusions for a particular event), you can call pbChooseRandomItem directly and then pbReceiveItem:

chosen_item = pbChooseRandomItem(nil, [:POTION], [:KEYITEM], [1, 2])
if chosen_item; pbReceiveItem(chosen_item); end

B. Giving a Random TM (using Random TM-HM Selector.rb)
Call the helper function:

pbGiveRandomTM

This will pick a random TM from your items.txt (identified by FieldUse = TR) and give it to the player. TMs can be received multiple times.

You can pass an optional blacklist:

pbGiveRandomTM([:TM01, :TM02]) # Excludes TM01 and TM02

C. Giving a Random HM (using Random TM-HM Selector.rb)
Call the helper function:

pbGiveRandomHM

This will pick a random HM from your items.txt (identified by FieldUse = HM) that the player does not already possess.

Once an HM is given, it is permanently tracked and will not be given again.

You can pass an optional blacklist (in addition to owned HMs):

pbGiveRandomHM([:HM01]) # Excludes HM01 (and any already owned)

D. Giving a Random TM or HM (combined pool)
Call the helper function:

pbGiveRandomTMorHM

This function builds a pool of all available TMs and all HMs that the player does not already own.

It then picks one item randomly from this combined pool.

If an HM is chosen, it is added to the $player_given_hms list to prevent future duplication.

4. Important Notes
The global variable $player_given_hms is used to track received HMs and persists across save files. It's automatically initialized.

Ensure your items.txt definitions correctly use FieldUse = TR for TMs and FieldUse = HM for HMs, as these scripts rely on that.

Test thoroughly after installation to ensure desired behavior.
