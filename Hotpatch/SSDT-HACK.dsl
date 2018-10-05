// Custom configuration for Toshiba Sattelite S50B-N-15 laptop

DefinitionBlock ("", "SSDT", 2, "hack", "S50B", 0)
{
    Device(RMCF)
    {
        Name(_ADR, 0)   // do not remove
        
        // DAUD: Digital audio
        //
        // 0: "hda-gfx" is disabled, injected as "#hda-gfx" instead
        // 1: (default when not specified) "hda-gfx" is injected
        //Name(DAUD, 0)
        
        // DWOU: Disable wake on USB
        // 1: Disable wake on USB
        // 0: Do not disable wake on USB
        Name(DWOU, 1)

    }
    
    #define NO_DEFINITIONBLOCK
    #include "Downloads/SSDT-PNLF.dsl"
    #include "Downloads/SSDT-DEHCI.dsl"
    #include "Downloads/SSDT-XOSI.dsl"
    #include "SSDT-GPRW.dsl"
    #include "SSDT-PS2K.dsl"
    #include "SSDT-UIAC.dsl"
    #include "SSDT-CX20756.dsl"
}
//EOF