
-- info.lua

-- Implements the g_PluginInfo standard plugin description

g_PluginInfo =
{
	Name = "Homes"
	Date = "2014-11-27"
	SourceLocation = "https://github.com/nouseforname/Homes"
	Description = 
	[[
		Provides functions to create, request and list and delete player homes with names and configurable limit.
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
			HelpString = "Ports you to your default home | Usage /home [[name]|set|list|delete|help] [name]"
			Permission = "homes.home"
			Alias = "/hm"
			Handler = HandleHomeCmdPort
			ParameterCombinations =
			{
				{
					Params = "HomeName",
					Help = "Ports you to the given home"
				}
			},
			
			SubCommands =
			{
				list =
				{
					HelpString = "List all player homes",
					Permission = "",
					Alias = "l",
					Handler = HandleHomeCommandList
				} -- list
				
				help = 
				{
					HelpString = "Show help",
					Permission = "",
					Alias = "h",
					Handler = HandleHomeCommandHelp
				} -- help
				
				delete = 
				{
					HelpString = "",
					Permission = "",
					Alias = "d",
					Handler = HandleHomeCommandDelete
					ParameterCombinations =
					{
						{
							Params = "HomeName",
							Help = "Key in the name of a existing home",
						},
					},
				
				} -- delete
				
				set =
				{
					
				}
			
			}
		}
	}, -- Commands
	
	ConsoleCommands = 
	{
		inithomes =
		{
			HelpString = "Deletes and recreated the database"
			Handler = HandleConCommandReInit,
		}
	
	}, -- ConsoleCommands
	
	Permissions = 
	{
		["homes.home"] =
		{
			Description = "Allows the player to save and delete home postitions for teleporting"
			RecommendedGroups = "*"
		}
	}, -- Permissions
}
