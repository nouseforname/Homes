
-- info.lua

-- Implements the g_PluginInfo standard plugin description

g_PluginInfo =
{
	Name = "Homes",
	Date = "2014-11-27",
	SourceLocation = "https://github.com/nouseforname/Homes",
	Description = 
	[[
		Provides functions to create, request, list and delete player homes with names and configurable limit.
	]],
	
	AdditionalInfo =
	{
		{
			Title = "Configuration",
			Contents =
			[[
				The configuration is stored in "Homes.ini" and gives the max numbers of homes positions per user rank.
				
				[Limits]
				Default=3
				VIP=5
				Operator=10
				Admin=0
			]],
		},
	}, -- AdditionalInfo
	
	Commands = 
	{
		["/home"] =
		{
			HelpString = "Usage /home <goto|set|list|delete|help> [name]",
			Permission = "homes.home",
			Alias = "/~",
			Handler = nil,

            Subcommands =
			{
                goto =
                {
                    HelpString = "Move to given home",
                    Permission = "",
                    Alias = "g",
                    Handler = HandleHomeCommand,
                    
                }, -- goto 
                
				list =
				{
					HelpString = "List all player homes",
					Permission = "",
					Alias = "l",
					Handler = HandleHomeCommandList,
				}, -- list
				
				help = 
				{
					HelpString = "Show help",
					Permission = "",
					Alias = "h",
					Handler = HandleHomeCommandHelp,
				}, -- help
				
				del = 
				{
					HelpString = "Delete the given home",
					Permission = "",
					Alias = "d",
					Handler = HandleHomeCommandDelete,
					ParameterCombinations =
					{
						{
							Params = "HomeName",
							Help = "Key in the name of a existing home",
						},
					},
				}, -- delete
				
				set =
				{
					HelpString = "Save a position as player home",
					Permission = "",
					Alias = "s",
					Handler = HandleHomeCommandSet,
					ParameterCombinations =
					{
						{
							Params = "",
							Help = "Set the actual position as home [default]",
						},
						{
							Params = "HomeName",
							Help = "Set the actual position as home [HomeName]",
						},
					},
				}, -- set
			}
		}
	}, -- Commands
	
	ConsoleCommands = 
	{
		dropTableHomes =
		{
			HelpString = "Deletes and recreated the database...",
			Handler = HandleConCommandReInit,
		}
	
	}, -- ConsoleCommands
	
	Permissions = 
	{
		["homes.home"] =
		{
			Description = "Allows the player to save and delete home postitions for teleporting",
			RecommendedGroups = "*"
		}
	}, -- Permissions
}
