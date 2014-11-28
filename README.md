

Provides functions to create, request, list and delete player homes with names and configurable limit. 	

# Configuration
The configuration is stored in "Homes.ini" and gives the max numbers of homes positions per user rank.

[Limits] 
Default=3 
VIP=5 
Operator=10 
Admin=0 			

# Commands

### General
| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/home | homes.home | Usage /home <goto|set|list|delete|help> [name]|
|/home del |  | Delete the given home|
|/home goto |  | Move to given home|
|/home help |  | Show help|
|/home list |  | List all player homes|
|/home set |  | Save a position as player home|



# Permissions
| Permissions | Description | Commands | Recommended groups |
| ----------- | ----------- | -------- | ------------------ |
| homes.home | Allows the player to save and delete home postitions for teleporting | `/home`, `/~` | * |



-- * created by nouseforname @ http://nouseforname.de  
-- * november 2014
