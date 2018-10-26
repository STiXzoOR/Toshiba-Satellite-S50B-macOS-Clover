// Custom configuration for Toshiba Sattelite S50B-N-15 laptop

DefinitionBlock ("", "SSDT", 2, "hack", "S50B", 0)
{
    Device(RMCF)
    {
        Name(_ADR, 0)   // do not remove
        
        // AUDL: Audio Layout
        //
        // The value here will be used to inject layout-id for HDEF and HDAU
        // If set to Ones, no audio injection will be done.
        Name(AUDL, 13)
        
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
    #include "Downloads/SSDT-HDEF.dsl"
    #include "Downloads/SSDT-HDAU.dsl"
    #include "Downloads/SSDT-DEHCI.dsl"
    #include "Downloads/SSDT-XOSI.dsl"
    #include "SSDT-GPRW.dsl"
    #include "SSDT-PS2K.dsl"
    #include "SSDT-UIAC.dsl"
    #include "SSDT-CX20756.dsl"
}
//EOF