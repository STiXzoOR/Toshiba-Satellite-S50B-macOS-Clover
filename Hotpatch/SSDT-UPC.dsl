// USB _UPC configuration for Toshiba Sattelite S50-B-N
 #ifndef NO_DEFINITIONBLOCK
DefinitionBlock ("", "SSDT", 2, "hack", "_UPC", 0)
{
#endif
    External(_SB.PCI0.XHC.RHUB, DeviceObj)
    Scope(_SB.PCI0.XHC.RHUB)
    {
        Name(UPC2, Package() // USB2
        {
            0xFF, 0, 0, 0
        })
        
        Name(UPC3, Package() // USB3
        {
            0xFF, 3, 0, 0
        })
        
        Name(UPCP, Package() // Internal (built-in)
        {
            0xFF, 0xFF, 0, 0
        })
        
        Method(HS01._UPC) // USB2 device on port #1 from USB3, port <01 00 00 00>
        {
            Return(UPC3)
        }
        
        Method(HS02._UPC) // USB2 device on port #2 from USB3, port <02 00 00 00>
        {
            Return(UPC3)
        }
        
        Method(HS03._UPC) // USB2 device on port USB2, port <03 00 00 00>
        {
            Return(UPC2)
        }
         Method(HS05._UPC) // Internal Bluetooth, port <05 00 00 00>
        {
            Return(UPCP)
        }
        
        Method(HS06._UPC) // Web Camera, port <06 00 00 00>
        {
            Return(UPCP)
        }
        
        Method(SSP1._UPC) // USB3 #1 from USB3, port <12 00 00 00>
        {
            Return(UPC3)
        }
        
        Method(SSP2._UPC) // USB3 #2 from USB3, port <13 00 00 00>
        {
            Return(UPC3)
        }
        
    }   
#ifndef NO_DEFINITIONBLOCK
}
#endif
//EOF 