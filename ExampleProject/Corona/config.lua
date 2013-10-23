application = 
{
    content =
    {
        width = 320,
        height = 480,
        scale = "letterBox",
        xAlign = "center",
        yAlign = "center",
        audioPlayFrequency = 22050,
        imageSuffix = 
        {
            ["@2"] = 1.5,
            ["@4"] = 3.0,
        },
    },

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert"
            }
        }
    }
}