# TeleportCloak

TeleportCloak saves your currently equipped item when you switch to a teleport item and automatically re-equips it after teleporting.

[Open a ticket to report any issues](https://github.com/jordonwow/teleportcloak/issues)

[Submit a pull request](https://github.com/jordonwow/teleportcloak/pulls)

## Supported Items

* [Cloak of Coordination](https://www.wowhead.com/item=65360)
* [Wrap of Unity](https://www.wowhead.com/item=63206)
* [Shroud of Cooperation](https://www.wowhead.com/item=63352)
* [Ring of the Kirin Tor](https://www.wowhead.com/item=44935)
* [Time-Lost Artifact](https://www.wowhead.com/item=103678)
* [Stormpike Insignia](https://www.wowhead.com/item=17691)
* [Frostwolf Insignia](https://www.wowhead.com/item=17690)
* [Boots of the Bay](https://www.wowhead.com/item=50287)
* [Ruby Slippers](https://www.wowhead.com/item=28585)
* [Blessed Medallion of Karabor](https://www.wowhead.com/item=32757)
* [Brassiest Knuckle](https://www.wowhead.com/item=95051)
* [Argent Crusader's Tabard](https://www.wowhead.com/item=46874)
* [Hellscream's Reach Tabard](https://www.wowhead.com/item=63378)
* [Baradin's Wardens Tabard](https://www.wowhead.com/item=63379)

## Usage

You can manually equip and use teleport items, or you can add `/click TeleportCloak` to a macro. Clicking the macro once equips a teleport cloak from your inventory, and clicking it again uses the item.

After using a teleport item, TeleportCloak will attempt to re-equip your previously equipped item. If this restoration fails, a warning will be displayed. You can toggle warnings on or off by typing `/tc warnings`.

## Macros

### Specific Items

If you wish to limit a TeleportCloak macro to a specific set of items, you can do so by adding `/tc add <item>` before `/click TeleportCloak` for each item.

```
/tc add Boots of the Bay
/tc add Ruby Slippers
/click TeleportCloak
```

### Specific Types

You can also `/tc add <type>` to limit the macro to a specific type. Valid types are: `cloaks`, `feet`, `necks`, `rings`, `tabards`, `trinkets`

```
/tc add rings
/click TeleportCloak
```

Items added with `/tc add` will be reset after each click.

## Contributors
* [@petewooley](https://github.com/peterwooley)
* Kanegasi
