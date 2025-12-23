# Setting Up the OneChipBook-12 Project in Quartus II

## Prerequisites
- Quartus II 9.1 SP2 Web Edition installed
- TG68_MiniSOC cloned from GitHub

## Step 1: Copy Board Files

Copy the `onechipbook12` folder into the TG68_MiniSOC project:

```
TG68_MiniSOC/
├── Board/
│   ├── c3board/
│   ├── de1/
│   ├── onechipbook12/     <-- Add this folder
│   │   ├── OneChipBook12Toplevel.vhd
│   │   ├── onechipbook12.qsf
│   │   └── pll_21to43.vhd  (we'll generate this)
```

## Step 2: Generate the PLL

The PLL converts your 21.47727 MHz clock to ~43 MHz for the system.

1. Open Quartus II
2. File → New Project Wizard
   - Directory: `TG68_MiniSOC/Board/onechipbook12`
   - Name: `onechipbook12`
   - Top-level entity: `OneChipBook12Toplevel`
3. Select device: Family = **Cyclone**, Device = **EP1C12Q240C8**
4. Finish the wizard

5. Tools → MegaWizard Plug-In Manager
6. Select "Create a new custom megafunction variation"
7. Choose: I/O → ALTPLL
8. Output file: `pll_21to43.vhd` (VHDL)
9. Click Next

10. PLL Settings:
    - What is the frequency of the inclk0 input? **21.47727 MHz**
    - Device speed grade: **8**

11. Output Clocks tab:
    - **clk c0**: ✓ Use this clock
      - Clock multiplication factor: **2**
      - Clock division factor: **1**
      - (This gives ~42.95 MHz)
    
    - **clk c1**: ✓ Use this clock  
      - Clock multiplication factor: **2**
      - Clock division factor: **1**
      - Clock phase shift: **-3 ns** (for SDRAM)

12. Click Finish to generate the PLL

## Step 3: Add Source Files

In Quartus:

1. Project → Add/Remove Files in Project

2. Add these files (navigate to TG68_MiniSOC folder):

**SOC files:**
- `SOC/RTL/SOC_VirtualToplevel.vhd`
- `SOC/RTL/Toplevel_Config.vhd`
- `SOC/RTL/DMACache_config.vhd`

**CPU files:**
- `RTL/CPU/TG68K_Pack.vhd`
- `RTL/CPU/TG68K_ALU.vhd`
- `RTL/CPU/TG68KdotC_Kernel.vhd`

**Memory files:**
- `RTL/Memory/sdram.vhd`
- `RTL/Memory/DMACache_pkg.vhd`
- `RTL/Memory/DMACache.vhd`
- `RTL/Memory/DMACacheRAM.vhd`
- `RTL/Memory/DualPortRAM.vhd`
- `RTL/Memory/TwoWayCache.v`

**Peripheral files:**
- `RTL/Peripherals/simple_uart.vhd`
- `RTL/Peripherals/spi.vhd`
- `RTL/Peripherals/io_ps2_com.vhd`
- `RTL/Peripherals/peripheral_controller.vhd`
- `RTL/Peripherals/interrupt_controller.vhd`
- `RTL/Peripherals/cascade_timer.vhd`

**Board files:**
- `Board/onechipbook12/OneChipBook12Toplevel.vhd`
- `Board/onechipbook12/pll_21to43.vhd`

## Step 4: Check for Missing Files

Some projects have additional dependencies. If you get errors about missing files:

1. Look in `RTL/Video/` - you might need video controller files
2. Look in `RTL/Sound/` - audio files
3. Look in `CharROM/` - character ROM for text display

Common missing files to add:
- `CharROM/CharROM_ROM.vhd`
- `RTL/Sound/hybrid_pwm_sd.v`

## Step 5: First Compilation Attempt

1. Processing → Start → Start Analysis & Elaboration

This does a quick check without full compilation. Fix any errors about:
- Missing files
- Undefined entities
- Syntax errors

2. Once analysis passes:
   Processing → Start Compilation

## Step 6: Check Resource Usage

After compilation, check:
- Compilation Report → Flow Summary

You want to see:
- Total logic elements: Should be under 12,060 (your max)
- Total memory bits: Should be under 239,616

If it's too big, we may need to disable features (like VGA).

## Step 7: Program the FPGA

1. Connect USB Blaster to OneChipBook-12 programming port
2. Tools → Programmer
3. Add `output_files/onechipbook12.sof`
4. Click Start

## Troubleshooting

### "Entity not found" errors
- Make sure all VHDL files are added to project
- Check that TG68K_Pack.vhd is compiled first (it defines types)

### "Design too large" 
- Disable VGA: In SOC_VirtualToplevel.vhd, comment out video
- Reduce cache size in DMACache settings
- Use SPEED optimization instead of BALANCED

### PLL won't lock
- Check clock input frequency
- Try different multiplication factors
- Verify pin 28 is actually the clock input

### SDRAM not working
- Verify all pin assignments match your board
- Check SDRAM timing parameters in sdram.vhd
- Make sure the PLL phase shift is correct for SDRAM clock

## Next Steps

Once you get a successful compile:
1. Test with LED blink to verify basic operation
2. Connect serial terminal at 115200 baud
3. You should see boot messages from the TG68 system
4. Then we can work on loading FUZIX!
