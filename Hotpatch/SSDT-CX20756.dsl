// CodecCommander.kext configuration to fix external mic issues

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock ("", "SSDT", 2, "hack", "CX20756", 0)
{
#endif
    External(_SB.PCI0.HDEF, DeviceObj)
    Name(_SB.PCI0.HDEF.RMCF, Package(0x02)
    {
        "CodecCommander", Package (0x0C)
        {
            "Custom Commands", Package (0x03)
            {
                Package (0x00) {}, 
                Package (0x08)
                {
                    "Command", Buffer (0x04) { 0x01, 0x97, 0x07, 0x24 }, 
                    "On Init", ">y", 
                    "On Sleep", ">n", 
                    "On Wake", ">y"
                }, 

                Package (0x08)
                {
                    "Command", Buffer (0x04) { 0x01, 0xA7, 0x07, 0x20 }, 
                    "On Init", ">y", 
                    "On Sleep", ">n", 
                    "On Wake", ">y"
                }
            }, 

            "Perform Reset", ">n", 
            "Perform Reset on External Wake", ">n", 
            "Send Delay", 0x0A, 
            "Sleep Nodes", ">n", 
            "Update Nodes", ">n"
        }
    })
#ifndef NO_DEFINITIONBLOCK
}
#endif
//EOF
