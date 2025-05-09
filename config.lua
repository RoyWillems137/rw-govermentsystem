Config = {}
Config.Locale = 'nl' -- Locales: en, nl. Add custom locale in /locale folder.
Config.item1 = "identification" --Identificationcard
Config.item2 = "driverslicense" --driverslicense
Config.Peds = {
    ["1"] = {
        blip = {
            enabled = true,
            colour = 0,         -- https://docs.fivem.net/docs/game-references/blips/
            sprite = 498,
            scale = 0.8,
            name = "Gemeentehuis"
        },
        ped = {
            model = "a_f_y_business_01", --https://docs.fivem.net/docs/game-references/ped-models/
        },
        coords = {
            { x = -549.9123, y = -190.0376, z = 37.2231, h = 173.5094 },   
        }
    }
}