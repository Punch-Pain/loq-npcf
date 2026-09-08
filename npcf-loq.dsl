DefinitionBlock ("", "SSDT", 2, "Linux", "npcf-loq", 0x01000000)
{
    Device (NPCF)
    {
        Name (ACBT, 0x50)
        Name (DCBT, Zero)
        Name (DBAC, Zero)
        Name (DBDC, Zero)
        Name (AMAT, 0x78)
        Name (AMIT, 0xFF88)
        Name (ATPP, 0x0428)
        Name (DTPP, Zero)
        Name (TPPL, 0x00017700)
        Name (DROS, Zero)
        Name (LTBL, Zero)
        Name (STBL, Zero)
        Name (CDIS, Zero)
        Name (CUSL, Zero)
        Name (CUCT, Zero)

        Method (_HID, 0, NotSerialized)
        {
            Return ("NVDA0820")
        }

        Name (_UID, "NPCF")

        Method (_STA, 0, NotSerialized)
        {
            Return (0x0F)
        }

        Method (_DSM, 4, Serialized)
        {
            If (Arg0 == ToUUID ("36b49710-2483-11e7-9598-0800200c9a66"))
            {
                If (Arg1 == 0x0200)
                {
                    Switch (Arg2)
                    {
                        Case (0x02)
                        {
                            Name (BUFF, Buffer (0x31)
                            {
                                0x00, 0x25, 0x05, 0x1C, 0x01,
                                0x50, 0x02, 0x1C, 0x02, 0x20,
                                0x70, 0x04, 0x00, 0x00, 0x30,
                                0x03, 0x78, 0x00, 0x00, 0x00,
                                0x00, 0x00, 0x00, 0x00, 0x00,
                                0x00, 0x00
                            })
                            Return (BUFF)
                        }
                        Default
                        {
                            Return (Arg3)
                        }
                    }
                }
                Else
                {
                    Return (Arg3)
                }
            }
            Else
            {
                Return (Zero)
            }
        }
    }
}
