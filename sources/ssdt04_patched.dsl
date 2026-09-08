/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of /mnt/ssd/Abdalrhman/Devlopment/SSDT Kernel Driver/cpio_build/kernel/firmware/acpi/ssdt04.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00001F0A (7946)
 *     Revision         0x01
 *     Checksum         0xE5
 *     OEM ID           "LENOVO"
 *     OEM Table ID     "CB-01   "
 *     OEM Revision     0x00000001 (1)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200717 (538969879)
 */
DefinitionBlock ("", "SSDT", 1, "LENOVO", "CB-01   ", 0x00000001)
{
    External (_SB_.GGIV, MethodObj)    // 1 Arguments
    External (_SB_.PC00, DeviceObj)
    External (_SB_.PC00.LPCB.EC0_.ECPI, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.GZ44, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.NVD1, UnknownObj)
    External (_SB_.PC00.LPCB.EC0_.NVRE, UnknownObj)
    External (_SB_.PC00.PEG1, DeviceObj)
    External (_SB_.PC00.PEG1.DL23, MethodObj)    // 0 Arguments
    External (_SB_.PC00.PEG1.L23D, MethodObj)    // 0 Arguments
    External (_SB_.PC00.PEG1.PEGP, DeviceObj)
    External (_SB_.PC00.PEG1.PXP_._OFF, MethodObj)    // 0 Arguments
    External (_SB_.PC00.PEG1.PXP_._ON_, MethodObj)    // 0 Arguments
    External (_SB_.PC00.PEG1.RSTG, IntObj)
    External (_SB_.PR00, DeviceObj)
    External (_SB_.PR01, DeviceObj)
    External (_SB_.PR02, DeviceObj)
    External (_SB_.PR03, DeviceObj)
    External (_SB_.PR04, DeviceObj)
    External (_SB_.PR05, DeviceObj)
    External (_SB_.PR06, DeviceObj)
    External (_SB_.PR07, DeviceObj)
    External (_SB_.PR08, DeviceObj)
    External (_SB_.PR09, DeviceObj)
    External (_SB_.PR10, DeviceObj)
    External (_SB_.PR11, DeviceObj)
    External (_SB_.PR12, DeviceObj)
    External (_SB_.PR13, DeviceObj)
    External (_SB_.PR14, DeviceObj)
    External (_SB_.PR15, DeviceObj)
    External (_SB_.PR16, DeviceObj)
    External (_SB_.PR17, DeviceObj)
    External (_SB_.PR18, DeviceObj)
    External (_SB_.PR19, DeviceObj)
    External (_SB_.PR20, DeviceObj)
    External (_SB_.PR21, DeviceObj)
    External (_SB_.PR22, DeviceObj)
    External (_SB_.PR23, DeviceObj)
    External (BATC, IntObj)
    External (CPL1, IntObj)
    External (DGST, FieldUnitObj)
    External (DHEV, FieldUnitObj)
    External (H265, FieldUnitObj)
    External (HDRS, UnknownObj)
    External (HRA0, UnknownObj)
    External (HRE0, UnknownObj)
    External (HRG0, UnknownObj)
    External (NVDB, MethodObj)    // 0 Arguments
    External (NVRF, UnknownObj)
    External (ODV2, IntObj)
    External (ODV3, IntObj)
    External (P8XH, MethodObj)    // 2 Arguments
    External (PEGH, FieldUnitObj)
    External (PIN_.OFF_, MethodObj)    // 1 Arguments
    External (PIN_.ON__, MethodObj)    // 1 Arguments
    External (SGGP, UnknownObj)
    External (TCNT, FieldUnitObj)

    Scope (\_SB.PC00)
    {
        OperationRegion (HGOP, SystemMemory, 0x709DDF18, 0x00000012)
        Field (HGOP, AnyAcc, Lock, Preserve)
        {
            DGDA,   32, 
            DGBA,   32, 
            OPTF,   8, 
            NVGE,   8, 
            DSSV,   32, 
            DISM,   8, 
            DISG,   8, 
            DISS,   8, 
            HGST,   8
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        OperationRegion (VBOR, SystemMemory, 0x7387F018, 0x00040004)
        Field (VBOR, DWordAcc, Lock, Preserve)
        {
            RVBS,   32, 
            VBS1,   262144, 
            VBS2,   262144, 
            VBS3,   262144, 
            VBS4,   262144, 
            VBS5,   262144, 
            VBS6,   262144, 
            VBS7,   262144, 
            VBS8,   262144
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        OperationRegion (NOPR, SystemMemory, 0x7387C018, 0x00002027)
        Field (NOPR, AnyAcc, Lock, Preserve)
        {
            DHPS,   8, 
            DPCS,   8, 
            GPSS,   8, 
            VENS,   8, 
            NBCS,   8, 
            GC6S,   8, 
            NVSR,   8, 
            NPCS,   8, 
            SLVS,   8, 
            PBCM,   8, 
            EXMD,   8, 
            MXBS,   32, 
            MXMB,   32768, 
            SMXS,   32, 
            SMXB,   32768, 
            FBEN,   32, 
            ENVT,   32, 
            PWGD,   32, 
            DMMP,   32, 
            DLRP,   32
        }
    }

    Scope (\_SB.PC00.PEG1)
    {
        OperationRegion (RPCX, SystemMemory, \_SB.PC00.DGBA, 0x1000)
        Field (RPCX, DWordAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            CMDR,   8, 
            Offset (0x19), 
            PRBN,   8, 
            Offset (0x4A), 
            CEDR,   1, 
            Offset (0x69), 
                ,   2, 
            LREN,   1, 
            Offset (0xA4), 
            D0ST,   2
        }

        Method (GSTA, 0, NotSerialized)
        {
            Sleep (0x0A)
            If ((\_SB.GGIV (\_SB.PC00.PEG1.PEGP.PWGD) == Zero))
            {
                Return (Zero)
            }
            Else
            {
                Return (One)
            }
        }

        Device (NVHD)
        {
            Name (_ADR, One)  // _ADR: Address
            Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
            {
                Return (Zero)
            }
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        Name (LTRE, Zero)
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((DGST == One))
            {
                Return (0x0F)
            }
            Else
            {
                Return (Zero)
            }
        }

        OperationRegion (PCIM, SystemMemory, \_SB.PC00.DGDA, 0x1000)
        Field (PCIM, DWordAcc, NoLock, Preserve)
        {
            NVID,   16, 
            NDID,   16, 
            CMDR,   8, 
            VGAR,   2008, 
            Offset (0x48B), 
                ,   1, 
            HDAE,   1
        }

        OperationRegion (DGPU, SystemMemory, \_SB.PC00.DGDA, 0x0100)
        Field (DGPU, DWordAcc, NoLock, Preserve)
        {
            Offset (0x40), 
            SSSV,   32
        }

        OperationRegion (NVMM, SystemMemory, (PEGH + 0x00022408), 0x10)
        Field (NVMM, DWordAcc, NoLock, Preserve)
        {
            H265,   32
        }

        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("a486d8f8-0bda-471b-a72b-6042a6b5bee0") /* Unknown UUID */))
            {
                Return (\_SB.PC00.PEG1.PEGP.NVOP (Arg0, Arg1, Arg2, Arg3))
            }

            If ((Arg0 == ToUUID ("a3132d01-8cda-49ba-a52e-bc9d46df6b81") /* Unknown UUID */))
            {
                Return (\_SB.PC00.PEG1.PEGP.GPS (Arg0, Arg1, Arg2, Arg3))
            }

            If ((Arg0 == ToUUID ("cbeca351-067b-4924-9cbd-b46b00b86f34") /* Unknown UUID */))
            {
                If ((\_SB.PC00.PEG1.PEGP.GC6S != Zero))
                {
                    Return (\_SB.PC00.PEG1.PEGP.NVJT (Arg0, Arg1, Arg2, Arg3))
                }
            }

            If ((Arg0 == ToUUID ("d4a50b75-65c7-46f7-bfb7-41514cea0244") /* Unknown UUID */))
            {
                If ((\_SB.PC00.PEG1.PEGP.NBCS != Zero))
                {
                    Return (\_SB.PC00.PEG1.PEGP.NBCI (Arg0, Arg1, Arg2, Arg3))
                }
            }

            If ((Arg0 == ToUUID ("4004a400-917d-4cf2-b89c-79b62fd55665") /* Unknown UUID */))
            {
                Return (\_SB.PC00.PEG1.PEGP.MXM (Arg0, Arg1, Arg2, Arg3))
            }

            Return (0x80000001)
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        Name (VGAB, Buffer (0xFB)
        {
             0x00                                             // .
        })
        Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
        {
            If ((DGPS != Zero))
            {
                \_SB.PC00.PEG1.PXP._ON ()
                If ((GPRF != One))
                {
                    VGAR = VGAB /* \_SB_.PC00.PEG1.PEGP.VGAB */
                }

                DGPS = Zero
            }
        }

        Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
        {
            If ((OMPR == 0x03))
            {
                If ((GPRF != One))
                {
                    VGAB = VGAR /* \_SB_.PC00.PEG1.PEGP.VGAR */
                }

                \_SB.PC00.PEG1.PXP._OFF ()
                DGPS = One
                OMPR = 0x02
            }
        }

        Name (DGPS, Zero)
        Name (OMPR, 0x02)
        Name (GPRF, Zero)
        Method (NVOP, 4, Serialized)
        {
            Debug = "------- NV OPTIMUS DSM --------"
            If ((Arg1 != 0x0100))
            {
                Return (0x80000001)
            }

            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Debug = "   NVOP fun0 NVOP_FUNC_SUPPORT"
                    Return (Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x0C                           // ....
                    })
                }
                Case (0x1A)
                {
                    Debug = "   NVOP fun26 NVOP_FUNC_OPTIMUSCAPS"
                    CreateField (Arg3, Zero, One, FLCH)
                    CreateField (Arg3, One, One, DVSR)
                    CreateField (Arg3, 0x02, One, DVSC)
                    CreateField (Arg3, 0x18, 0x02, OPCE)
                    If ((ToInteger (FLCH) && (ToInteger (OPCE) != OMPR)))
                    {
                        OMPR = ToInteger (OPCE)
                    }

                    Local0 = Buffer (0x04)
                        {
                             0x00, 0x00, 0x00, 0x00                           // ....
                        }
                    CreateField (Local0, Zero, One, OPEN)
                    CreateField (Local0, 0x03, 0x02, CGCS)
                    CreateField (Local0, 0x06, One, SHPC)
                    CreateField (Local0, 0x08, One, SNSR)
                    CreateField (Local0, 0x18, 0x03, DGPC)
                    CreateField (Local0, 0x1B, 0x02, OHAC)
                    OPEN = One
                    SHPC = One
                    DGPC = One
                    OHAC = 0x03
                    If (ToInteger (DVSC))
                    {
                        If (ToInteger (DVSR))
                        {
                            GPRF = One
                        }
                        Else
                        {
                            GPRF = Zero
                        }
                    }

                    SNSR = GPRF /* \_SB_.PC00.PEG1.PEGP.GPRF */
                    If ((DGPS == Zero))
                    {
                        CGCS = 0x03
                    }
                    Else
                    {
                        CGCS = Zero
                    }

                    Return (Local0)
                }
                Case (0x1B)
                {
                    Debug = "   NVOP fun27 NVOP_FUNC_OPTIMUSFLAGS"
                    CreateField (Arg3, Zero, One, OACC)
                    CreateField (Arg3, One, One, UOAC)
                    CreateField (Arg3, 0x02, 0x08, OPDA)
                    CreateField (Arg3, 0x0A, One, OPDE)
                    Local1 = Zero
                    Local1 = \_SB.PC00.PEG1.PEGP.HDAE
                    Return (Local1)
                }
                Default
                {
                    Return (0x80000002)
                }

            }
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        Name (NLIM, One)
        Name (PSLS, Zero)
        Name (NTCC, 0x57)
        Name (GPSP, Buffer (0x2C){})
        CreateDWordField (GPSP, Zero, RETN)
        CreateDWordField (GPSP, 0x04, VRV1)
        CreateDWordField (GPSP, 0x08, TGPU)
        CreateDWordField (GPSP, 0x0C, PDTS)
        CreateDWordField (GPSP, 0x10, SFAN)
        CreateDWordField (GPSP, 0x14, SKNT)
        CreateDWordField (GPSP, 0x18, CPUE)
        CreateDWordField (GPSP, 0x1C, TMP1)
        CreateDWordField (GPSP, 0x20, TMP2)
        CreateDWordField (GPSP, 0x24, CTGP)
        CreateDWordField (GPSP, 0x28, PPMD)
        Method (GPS, 4, Serialized)
        {
            If (((H265 != Ones) && DHEV))
            {
                H265 |= 0xC0000000
            }

            Debug = "------- NV GPS DSM --------"
            If ((Arg1 != 0x0200))
            {
                Return (0x80000002)
            }

            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Debug = "   GPS fun 0"
                    Return (Buffer (0x08)
                    {
                         0x01, 0x00, 0x0C, 0x00, 0x11, 0x04, 0x00, 0x00   // ........
                    })
                }
                Case (0x12)
                {
                    Debug = "   GPS fun 18"
                }
                Case (0x13)
                {
                    Debug = "   GPS fun 19"
                    If ((NVRF == Zero))
                    {
                        NVRF = One
                        \_SB.PC00.LPCB.EC0.NVRE = One
                        If ((\_SB.PC00.LPCB.EC0.NVD1 == 0x02))
                        {
                            Notify (\_SB.PC00.PEG1.PEGP, 0xD2) // Hardware-Specific
                        }
                        ElseIf ((\_SB.PC00.LPCB.EC0.NVD1 == 0x03))
                        {
                            Notify (\_SB.PC00.PEG1.PEGP, 0xD3) // Hardware-Specific
                        }
                        ElseIf ((\_SB.PC00.LPCB.EC0.NVD1 == 0x04))
                        {
                            Notify (\_SB.PC00.PEG1.PEGP, 0xD4) // Hardware-Specific
                        }
                        ElseIf ((\_SB.PC00.LPCB.EC0.NVD1 == 0x05))
                        {
                            Notify (\_SB.PC00.PEG1.PEGP, 0xD5) // Hardware-Specific
                        }
                        Else
                        {
                            Notify (\_SB.PC00.PEG1.PEGP, 0xD1) // Hardware-Specific
                        }
                    }

                    CreateDWordField (Arg3, Zero, TEMP)
                    If ((TEMP == Zero))
                    {
                        Return (0x04)
                    }

                    If ((TEMP && 0x04))
                    {
                        Return (0x04)
                    }
                }
                Case (0x20)
                {
                    Debug = "   GPS fun 32"
                    Name (RET1, Zero)
                    CreateBitField (Arg3, 0x02, SPBI)
                    If (NLIM)
                    {
                        RET1 |= One
                    }

                    If (PSLS)
                    {
                        RET1 |= 0x02
                    }

                    Return (RET1) /* \_SB_.PC00.PEG1.PEGP.GPS_.RET1 */
                }
                Case (0x2A)
                {
                    Debug = "   GPS fun 42"
                    CreateField (Arg3, Zero, 0x04, PSH0)
                    CreateBitField (Arg3, 0x08, GPUT)
                    VRV1 = 0x00010000
                    Switch (ToInteger (PSH0))
                    {
                        Case (Zero)
                        {
                            RETN = 0x00010100
                            Return (GPSP) /* \_SB_.PC00.PEG1.PEGP.GPSP */
                        }
                        Case (One)
                        {
                            RETN = 0x00010100
                            RETN |= ToInteger (PSH0)
                            Return (GPSP) /* \_SB_.PC00.PEG1.PEGP.GPSP */
                        }
                        Case (0x02)
                        {
                            RETN = 0x00010102
                            TGPU = NTCC /* \_SB_.PC00.PEG1.PEGP.NTCC */
                            PPMD = 0x0700
                            Return (GPSP) /* \_SB_.PC00.PEG1.PEGP.GPSP */
                        }

                    }
                }
                Case (0x24)
                {
                    Debug = "   GPS fun 36 GETPPL"
                    Return (Buffer (0x0C)
                    {
                         0x00, 0x00, 0x01, 0x00, 0xC8, 0xAF, 0x00, 0x00,   // ........  V1, PL1=45000mW
                         0xE8, 0xFD, 0x00, 0x00                              // ......   PL2=65000mW
                    })
                }
                Default
                {
                    Return (0x80000002)
                }

            }

            Return (0x80000002)
        }
    }

    Scope (\_SB.PC00)
    {
        Name (TDGC, Zero)
        Name (DGCX, Zero)
        Name (TGPC, Buffer (0x04)
        {
             0x00                                             // .
        })
        Method (GC6I, 0, Serialized)
        {
            Debug = "   JT GC6I"
            \_SB.PC00.PEG1.PEGP.LTRE = \_SB.PC00.PEG1.LREN
            \_SB.PC00.PEG1.DL23 ()
            Sleep (0x0A)
            \PIN.ON (\_SB.PC00.PEG1.RSTG)
        }

        Method (GC6O, 0, Serialized)
        {
            Debug = "   JT GC6O"
            \PIN.OFF (\_SB.PC00.PEG1.RSTG)
            \_SB.PC00.PEG1.L23D ()
            \_SB.PC00.PEG1.CMDR |= 0x04
            \_SB.PC00.PEG1.D0ST = Zero
            While ((\_SB.PC00.PEG1.PEGP.NVID != 0x10DE))
            {
                Sleep (One)
            }

            \_SB.PC00.PEG1.LREN = \_SB.PC00.PEG1.PEGP.LTRE
            \_SB.PC00.PEG1.CEDR = One
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        Method (NVJT, 4, Serialized)
        {
            Debug = "------- NV JT DSM --------"
            If ((ToInteger (Arg1) < 0x0100))
            {
                Return (0x80000001)
            }

            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Debug = "   JT fun0 JT_FUNC_SUPPORT"
                    Return (Buffer (0x04)
                    {
                         0x1B, 0x00, 0x00, 0x00                           // ....
                    })
                }
                Case (One)
                {
                    Debug = "   JT fun1 JT_FUNC_CAPS"
                    Name (JTCA, Buffer (0x04)
                    {
                         0x00                                             // .
                    })
                    CreateField (JTCA, Zero, One, JTEN)
                    CreateField (JTCA, One, 0x02, SREN)
                    CreateField (JTCA, 0x03, 0x02, PLPR)
                    CreateField (JTCA, 0x05, One, SRPR)
                    CreateField (JTCA, 0x06, 0x02, FBPR)
                    CreateField (JTCA, 0x08, 0x02, GUPR)
                    CreateField (JTCA, 0x0A, One, GC6R)
                    CreateField (JTCA, 0x0B, One, PTRH)
                    CreateField (JTCA, 0x0D, One, MHYB)
                    CreateField (JTCA, 0x0E, One, RPCL)
                    CreateField (JTCA, 0x0F, 0x02, GC6V)
                    CreateField (JTCA, 0x11, One, GEIS)
                    CreateField (JTCA, 0x12, One, GSWS)
                    CreateField (JTCA, 0x14, 0x0C, JTRV)
                    JTEN = One
                    GC6R = Zero
                    RPCL = One
                    SREN = One
                    FBPR = Zero
                    MHYB = One
                    GC6V = 0x02
                    JTRV = 0x0200
                    Return (JTCA) /* \_SB_.PC00.PEG1.PEGP.NVJT.JTCA */
                }
                Case (0x02)
                {
                    Debug = "   JT fun2 JT_FUNC_POLICYSELECT"
                    Return (0x80000002)
                }
                Case (0x03)
                {
                    Debug = "   JT fun3 JT_FUNC_POWERCONTROL"
                    CreateField (Arg3, Zero, 0x03, GPPC)
                    CreateField (Arg3, 0x04, One, PLPC)
                    CreateField (Arg3, 0x07, One, ECOC)
                    CreateField (Arg3, 0x0E, 0x02, DFGC)
                    CreateField (Arg3, 0x10, 0x03, GPCX)
                    \_SB.PC00.TGPC = Arg3
                    If (((ToInteger (GPPC) != Zero) || (ToInteger (DFGC
                        ) != Zero)))
                    {
                        \_SB.PC00.TDGC = ToInteger (DFGC)
                        \_SB.PC00.DGCX = ToInteger (GPCX)
                    }

                    Name (JTPC, Buffer (0x04)
                    {
                         0x00                                             // .
                    })
                    CreateField (JTPC, Zero, 0x03, GUPS)
                    CreateField (JTPC, 0x03, One, GPWO)
                    CreateField (JTPC, 0x07, One, PLST)
                    If ((ToInteger (DFGC) != Zero))
                    {
                        GPWO = One
                        GUPS = One
                        Return (JTPC) /* \_SB_.PC00.PEG1.PEGP.NVJT.JTPC */
                    }

                    Debug = "   JT fun3 GPPC="
                    Debug = ToInteger (GPPC)
                    If ((ToInteger (GPPC) == One))
                    {
                        \_SB.PC00.GC6I ()
                        PLST = One
                        GUPS = Zero
                    }
                    ElseIf ((ToInteger (GPPC) == 0x02))
                    {
                        \_SB.PC00.GC6I ()
                        If ((ToInteger (PLPC) == Zero))
                        {
                            PLST = Zero
                        }

                        GUPS = Zero
                    }
                    ElseIf ((ToInteger (GPPC) == 0x03))
                    {
                        \_SB.PC00.GC6O ()
                        If ((ToInteger (PLPC) != Zero))
                        {
                            PLST = Zero
                        }

                        GPWO = One
                        GUPS = One
                    }
                    ElseIf ((ToInteger (GPPC) == 0x04))
                    {
                        \_SB.PC00.GC6O ()
                        If ((ToInteger (PLPC) != Zero))
                        {
                            PLST = Zero
                        }

                        GPWO = One
                        GUPS = One
                    }
                    ElseIf ((\_SB.GGIV (PWGD) == One))
                    {
                        Debug = "   JT GETS() return 0x1"
                        GPWO = One
                        GUPS = One
                    }
                    Else
                    {
                        Debug = "   JT GETS() return 0x3"
                        GPWO = Zero
                        GUPS = 0x03
                    }

                    Return (JTPC) /* \_SB_.PC00.PEG1.PEGP.NVJT.JTPC */
                }
                Case (0x04)
                {
                    Debug = "   JT fun4 JT_FUNC_PLATPOLICY"
                    CreateField (Arg3, 0x02, One, PAUD)
                    CreateField (Arg3, 0x03, One, PADM)
                    CreateField (Arg3, 0x04, 0x04, PDGS)
                    Local0 = Zero
                    Local0 = (\_SB.PC00.PEG1.PEGP.HDAE << 0x02)
                    Return (Local0)
                }

            }

            Return (0x80000002)
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        Name (GSV1, Buffer (One)
        {
             0x00                                             // .
        })
        Name (GSV2, Buffer (One)
        {
             0x00                                             // .
        })
        Name (GSDR, Buffer (One)
        {
             0x00                                             // .
        })
        Method (NBCI, 4, Serialized)
        {
            Debug = "------- NV NBCI DSM --------"
            If ((Arg1 != 0x0102))
            {
                Debug = " NBCI DSM: NOT SUPPORTED!"
                Return (0x80000002)
            }

            If ((Arg2 == Zero))
            {
                Debug = "   NBCI fun0 NBCI_FUNC_SUPPORT"
                Return (Buffer (0x04)
                {
                     0x01, 0x00, 0x11, 0x00                           // ....
                })
            }

            If ((Arg2 == 0x10))
            {
                Debug = "   NBCI fun16 NBCI_FUNC_GETOBJBYTYPE"
                CreateWordField (Arg3, 0x02, BFF0)
                If ((BFF0 == 0x564B)){}
                If ((BFF0 == 0x4452))
                {
                    Return (GSDR) /* \_SB_.PC00.PEG1.PEGP.GSDR */
                }
            }

            If ((Arg2 == 0x14))
            {
                Debug = "   NBCI fun20 NBCI_FUNC_GETBACKLIGHT"
                If ((HDRS == One))
                {
                    Return (Package (0x20)
                    {
                        0x8000A450, 
                        0x0203, 
                        Zero, 
                        Zero, 
                        0x05, 
                        One, 
                        0x03E8, 
                        Zero, 
                        0x03E8, 
                        0x0B, 
                        Zero, 
                        0x1E, 
                        0x32, 
                        0x50, 
                        0x78, 
                        0xAA, 
                        0xFA, 
                        0x015E, 
                        0x01F4, 
                        0x02BC, 
                        0x03E8, 
                        Zero, 
                        0x64, 
                        0xC8, 
                        0x012C, 
                        0x0190, 
                        0x01F4, 
                        0x0258, 
                        0x02BC, 
                        0x0320, 
                        0x0384, 
                        0x03E8
                    })
                }
                Else
                {
                    Return (Package (0x20)
                    {
                        0x8000A450, 
                        0x0200, 
                        Zero, 
                        Zero, 
                        0x05, 
                        One, 
                        0x03E8, 
                        Zero, 
                        0x03E8, 
                        0x0B, 
                        0x06, 
                        0x0B, 
                        0x20, 
                        0x47, 
                        0x84, 
                        0xCF, 
                        0x0131, 
                        0x01B4, 
                        0x025A, 
                        0x030F, 
                        0x03E8, 
                        Zero, 
                        0x64, 
                        0xC8, 
                        0x012C, 
                        0x0190, 
                        0x01F4, 
                        0x0258, 
                        0x02BC, 
                        0x0320, 
                        0x0384, 
                        0x03E8
                    })
                }
            }
        }
    }

    Scope (\_SB)
    {
        Device (NPCF)
        {
            Name (ACBT, 0x50)
            Name (DCBT, Zero)
            Name (DBAC, Zero)
            Name (DBDC, Zero)
            Name (AMAT, 0x78)
            Name (AMIT, 0xFF88)
            Name (ATPP, 0x0168)
            Name (DTPP, Zero)
            Name (TPPL, 0x00017700)
            Name (DROS, Zero)
            Name (LTBL, Zero)
            Name (STBL, Zero)
            Name (CDIS, Zero)
            Name (CUSL, Zero)
            Name (CUCT, Zero)
            Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
            {
                CDIS = Zero
                Return ("NVDA0820")
            }

            Name (_UID, "NPCF")  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((CDIS == One))
                {
                    Return (0x0D)
                }

                Return (0x0F)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                CDIS = One
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("36b49710-2483-11e7-9598-0800200c9a66") /* Unknown UUID */))
                {
                    If ((\_SB.PC00.PEG1.PEGP.NPCS != Zero))
                    {
                        Return (NPCF (Arg0, Arg1, Arg2, Arg3))
                    }
                }
            }

            Method (NPCF, 4, Serialized)
            {
                Debug = "------- NVPCF DSM --------"
                If ((ToInteger (Arg1) != 0x0200))
                {
                    Return (0x80000001)
                }

                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Debug = "   NVPCF sub-func#0"
                        Name (BUFF, Buffer (0x04)
                        {
                             0xBF, 0x06, 0x00, 0x00                           // ....
                        })
                        Local1 = DerefOf (BUFF [One])
                        BUFF [One] = (Local1 | One)
                        Return (BUFF) /* \_SB_.NPCF.NPCF.BUFF */
                    }
                    Case (One)
                    {
                        Debug = "   NVPCF sub-func#1"
                        Return (Buffer (0x0E)
                        {
                            /* 0000 */  0x20, 0x03, 0x01, 0x00, 0x25, 0x04, 0x05, 0x01,  //  ...%...
                            /* 0008 */  0x01, 0x01, 0x00, 0x00, 0x00, 0xAB               // ......
                        })
                    }
                    Case (0x02)
                    {
                        Debug = "   NVPCF sub-func#2"
                        Name (PBD2, Buffer (0x31)
                        {
                             0x00                                             // .
                        })
                        CreateByteField (PBD2, Zero, PTV2)
                        CreateByteField (PBD2, One, PHB2)
                        CreateByteField (PBD2, 0x02, GSB2)
                        CreateByteField (PBD2, 0x03, CTB2)
                        CreateByteField (PBD2, 0x04, NCE2)
                        PTV2 = 0x25
                        PHB2 = 0x05
                        GSB2 = 0x10
                        CTB2 = 0x1C
                        NCE2 = One
                        CreateWordField (PBD2, 0x05, TGPA)
                        CreateWordField (PBD2, 0x07, TGPD)
                        CreateByteField (PBD2, 0x15, PC01)
                        CreateByteField (PBD2, 0x16, PC02)
                        CreateWordField (PBD2, 0x19, TPPA)
                        CreateWordField (PBD2, 0x1B, TPPD)
                        CreateWordField (PBD2, 0x1D, MAGA)
                        CreateWordField (PBD2, 0x1F, MAGD)
                        CreateWordField (PBD2, 0x21, MIGA)
                        CreateWordField (PBD2, 0x23, MIGD)
                        CreateDWordField (PBD2, 0x25, DROP)
                        CreateDWordField (PBD2, 0x29, LTBC)
                        CreateDWordField (PBD2, 0x2D, STBC)
                        CreateField (Arg3, 0x28, 0x02, NIGS)
                        CreateByteField (Arg3, 0x15, IORC)
                        CreateField (Arg3, 0xB0, One, PWCS)
                        CreateField (Arg3, 0xB1, One, PWTS)
                        CreateField (Arg3, 0xB2, One, CGPS)
                        If ((ToInteger (NIGS) == Zero))
                        {
                            NVDB ()
                            TGPA = ACBT /* \_SB_.NPCF.ACBT */
                            TGPD = DCBT /* \_SB_.NPCF.DCBT */
                            PC01 = Zero
                            PC02 = (DBAC | (DBDC << One))
                            TPPA = ATPP /* \_SB_.NPCF.ATPP */
                            TPPD = DTPP /* \_SB_.NPCF.DTPP */
                            MAGA = AMAT /* \_SB_.NPCF.AMAT */
                            MIGA = AMIT /* \_SB_.NPCF.AMIT */
                            DROP = DROS /* \_SB_.NPCF.DROS */
                            LTBC = LTBL /* \_SB_.NPCF.LTBL */
                            STBC = STBL /* \_SB_.NPCF.STBL */
                        }

                        If ((ToInteger (NIGS) == One))
                        {
                            If ((ToInteger (PWCS) == One)){}
                            Else
                            {
                            }

                            If ((ToInteger (PWTS) == One)){}
                            Else
                            {
                            }

                            If ((ToInteger (CGPS) == One)){}
                            Else
                            {
                            }

                            TGPA = Zero
                            TGPD = Zero
                            PC01 = Zero
                            PC02 = Zero
                            TPPA = Zero
                            TPPD = Zero
                            MAGA = Zero
                            MIGA = Zero
                            MAGD = Zero
                            MIGD = Zero
                        }

                        Return (PBD2) /* \_SB_.NPCF.NPCF.PBD2 */
                    }
                    Case (0x03)
                    {
                        Debug = "   NVPCF sub-func#3"
                        Return (Buffer (0x3D)
                        {
                            /* 0000 */  0x11, 0x04, 0x13, 0x03, 0x00, 0xFF, 0x00, 0x28,  // .......(
                            /* 0008 */  0x2D, 0x2D, 0x33, 0x33, 0x39, 0x39, 0x3F, 0x3F,  // --3399??
                            /* 0010 */  0x45, 0x42, 0x4B, 0x46, 0x50, 0xFF, 0xFF, 0x05,  // EBKFP...
                            /* 0018 */  0xFF, 0x00, 0x3C, 0x41, 0x41, 0x46, 0x46, 0x4B,  // ..<AAFFK
                            /* 0020 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0028 */  0xFF, 0xFF, 0x02, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0030 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0038 */  0x00, 0x30, 0x34, 0x34, 0x3A                     // .044:
                        })
                    }
                    Case (0x04)
                    {
                        Debug = "   NVPCF sub-func#4"
                        Return (Buffer (0x32)
                        {
                            /* 0000 */  0x11, 0x04, 0x2E, 0x01, 0x05, 0x00, 0x01, 0x02,  // ........
                            /* 0008 */  0x03, 0x04, 0x03, 0x01, 0x02, 0x03, 0x00, 0x02,  // ........
                            /* 0010 */  0x03, 0x04, 0x00, 0x02, 0x03, 0x04, 0x00, 0x02,  // ........
                            /* 0018 */  0x03, 0x04, 0x00, 0x02, 0x03, 0x04, 0x00, 0x02,  // ........
                            /* 0020 */  0x03, 0x04, 0x01, 0x02, 0x03, 0x04, 0x02, 0x02,  // ........
                            /* 0028 */  0x03, 0x04, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04,  // ........
                            /* 0030 */  0x04, 0x04                                       // ..
                        })
                    }
                    Case (0x05)
                    {
                        Debug = "   NVPCF sub-func#5"
                        Name (PBD5, Buffer (0x28)
                        {
                             0x00                                             // .
                        })
                        CreateByteField (PBD5, Zero, PTV5)
                        CreateByteField (PBD5, One, PHB5)
                        CreateByteField (PBD5, 0x02, TEB5)
                        CreateByteField (PBD5, 0x03, NTE5)
                        PTV5 = 0x11
                        PHB5 = 0x04
                        TEB5 = 0x24
                        NTE5 = One
                        CreateDWordField (PBD5, 0x04, F5O0)
                        CreateDWordField (PBD5, 0x08, F5O1)
                        CreateDWordField (PBD5, 0x0C, F5O2)
                        CreateDWordField (PBD5, 0x10, F5O3)
                        CreateDWordField (PBD5, 0x14, F5O4)
                        CreateDWordField (PBD5, 0x18, F5O5)
                        CreateDWordField (PBD5, 0x1C, F5O6)
                        CreateDWordField (PBD5, 0x20, F5O7)
                        CreateDWordField (PBD5, 0x24, F5O8)
                        CreateField (Arg3, 0x20, 0x03, INC5)
                        CreateDWordField (Arg3, 0x08, F5P1)
                        CreateDWordField (Arg3, 0x0C, F5P2)
                        Switch (ToInteger (INC5))
                        {
                            Case (Zero)
                            {
                                F5O0 = Zero
                                F5O1 = Zero
                                F5O2 = Zero
                                F5O3 = Zero
                            }
                            Case (One)
                            {
                                F5O0 = Zero
                                F5O1 = Zero
                                F5O2 = Zero
                                F5O3 = Zero
                            }
                            Case (0x02)
                            {
                                F5O0 = Zero
                                F5O1 = Zero
                                F5O2 = Zero
                                F5O3 = Zero
                                F5O4 = Zero
                                F5O5 = Zero
                                F5O6 = Zero
                                F5O7 = Zero
                                F5O8 = Zero
                            }
                            Case (0x03)
                            {
                                CUSL = (F5P1 & 0xFF)
                            }
                            Case (0x04)
                            {
                                CUCT = F5P2 /* \_SB_.NPCF.NPCF.F5P2 */
                            }
                            Default
                            {
                                Return (0x80000002)
                            }

                        }

                        Return (PBD5) /* \_SB_.NPCF.NPCF.PBD5 */
                    }
                    Case (0x07)
                    {
                        Debug = "   NVPCF sub-func#7"
                        CreateDWordField (Arg3, 0x05, AMAX)
                        CreateDWordField (Arg3, 0x09, ARAT)
                        CreateDWordField (Arg3, 0x0D, DMAX)
                        CreateDWordField (Arg3, 0x11, DRAT)
                        CreateDWordField (Arg3, 0x15, TGPM)
                        Return (Zero)
                    }
                    Case (0x08)
                    {
                        Debug = "   NVPCF sub-func#8"
                        If ((\_SB.PC00.LPCB.EC0.GZ44 == 0x02))
                        {
                            Return (Buffer (0x16)
                            {
                                /* 0000 */  0x20, 0x04, 0x09, 0x02, 0x64, 0x58, 0x1B, 0x00,  //  ...dX..
                                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x4C, 0x1D,  // ......L.
                                /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00               // ......
                            })
                        }
                        Else
                        {
                            Return (Buffer (0x16)
                            {
                                /* 0000 */  0x20, 0x04, 0x09, 0x02, 0x64, 0xA4, 0x1F, 0x00,  //  ...d...
                                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x34, 0x21,  // ......4!
                                /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00               // ......
                            })
                        }
                    }
                    Case (0x09)
                    {
                        Debug = "   NVPCF sub-func#9"
                        CreateDWordField (Arg3, 0x03, CPTD)
                        If ((CPTD <= 0x2710)){}
                        ElseIf ((ToInteger (PWTS) == One))
                        {
                            If (CondRefOf (\CPL1))
                            {
                                Divide (CPTD, 0x03E8, Local1, Local2)
                                Local3 = (Local2 * 0x08)
                                \CPL1 = Local3
                            }
                        }
                        Else
                        {
                        }

                        Return (Zero)
                    }
                    Case (0x0A)
                    {
                        Debug = "   NVPCF sub-func#10"
                        Name (PBDA, Buffer (0x08)
                        {
                             0x00                                             // .
                        })
                        CreateByteField (PBDA, Zero, DTTV)
                        CreateByteField (PBDA, One, DTSH)
                        CreateByteField (PBDA, 0x02, DTSE)
                        CreateByteField (PBDA, 0x03, DTTE)
                        CreateDWordField (PBDA, 0x04, DTTL)
                        DTTV = 0x10
                        DTSH = 0x04
                        DTSE = 0x04
                        DTTE = One
                        DTTL = TPPL /* \_SB_.NPCF.TPPL */
                        Return (PBDA) /* \_SB_.NPCF.NPCF.PBDA */
                    }

                }

                Return (0x80000002)
            }
        }
    }

    Scope (\_SB.PC00.PEG1.PEGP)
    {
        Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
        {
            Return (Package (0x01)
            {
                0x80087330
            })
        }

        Method (MXMX, 1, Serialized)
        {
            If ((Arg0 == Zero))
            {
                P8XH (One, 0x99)
                P8XH (Zero, Zero)
                Return (One)
            }

            If ((Arg0 == One))
            {
                P8XH (One, 0x99)
                P8XH (Zero, One)
                Return (One)
            }

            If ((Arg0 == 0x02))
            {
                P8XH (One, 0x99)
                P8XH (Zero, 0x02)
            }

            Return (Zero)
        }

        Method (MXDS, 1, Serialized)
        {
            If ((Arg0 == Zero)){}
            If ((Arg0 == One)){}
            Return (Zero)
        }

        Method (MXM, 4, Serialized)
        {
            Switch (ToInteger (Arg2))
            {
                Case (Zero)
                {
                    Return (Buffer (0x04)
                    {
                         0x01, 0x00, 0x01, 0x01                           // ....
                    })
                }
                Case (0x10)
                {
                    If ((Arg1 == 0x0300))
                    {
                        If ((MXBS != Zero))
                        {
                            Name (MXM3, Buffer (MXBS)
                            {
                                 0x00                                             // .
                            })
                            MXM3 = MXMB /* \_SB_.PC00.PEG1.PEGP.MXMB */
                            Return (MXM3) /* \_SB_.PC00.PEG1.PEGP.MXM_.MXM3 */
                        }
                    }
                }
                Case (0x18)
                {
                    Return (Unicode ("0"))
                }

            }
        }
    }
}

