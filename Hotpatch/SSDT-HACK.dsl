// Custom configuration for Toshiba Sattelite S50B-N-15 laptop

DefinitionBlock ("", "SSDT", 2, "hack", "S50B", 0)
{
    Device(RMCF)
    {
        Name(_ADR, 0)   // do not remove

    }
    
    #define NO_DEFINITIONBLOCK
    #include "Downloads/SSDT-PNLF.dsl"
    #include "Downloads/SSDT-DEHCI.dsl"
    #include "Downloads/SSDT-XOSI.dsl"
    #include "SSDT-UIAC.dsl"
    #include "SSDT-CX20756.dsl"
    #include "SSDT-PS2K.dsl"
    #include "SSDT-GPRW.dsl"
}
//EOF