Homes
=====

A simple plugin for https://github.com/mc-server.

-- * plugin homes.lua


-- * provides functions to create, request and list and delete player homes with names and configurable limit

-- * permission "homes.home"

-- * Usage /home [[name]|set|list|delete|help] [name]
-- * /home => port you to your default home
-- * /home myHome => port you to home 'myHome'
-- * /home set => set the actual position as default home
-- * /home set myHome => set the actual position as 'myHome'
-- * /home list => list all your home by name and world
-- * /home delete myHome => delete 'myHome"
-- * /home help => shows this help


-- * Configurable limit of homes for each rank. 0=infinite
-- * Homes.ini:
-- * [Limits]
-- * Default=3
-- * VIP=5
-- * Operator=10
-- * Admin=0


-- * created by nouseforname @ http://nouseforname.de
-- * november 2014
