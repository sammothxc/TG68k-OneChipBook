-- ============================================
-- OneChipBook-12 Top Level for TG68 MiniSOC
-- Target: Cyclone EP1C12Q240C8
-- ============================================
--
-- Based on C3BoardToplevel.vhd from the TG68_MiniSOC project
-- Adapted for OneChipBook-12 hardware:
--   - 21.47727 MHz input clock
--   - Single 16-bit wide 32MB SDRAM (K4S561632E)
--   - 6-bit VGA DAC
--   - PS/2 keyboard
--   - SD card slot
--   - DB9 serial port
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.Toplevel_Config.ALL;

entity OneChipBook12Toplevel is
port(
        -- Clock input (directly accent accent accent)
        clk_21m         : in    std_logic;  -- 21.47727 MHz
        
        -- active accent accent - directly directly directly
        -- directly directly directly directly directly
        
        -- SDRAM (single 16-bit chip: K4S561632E)
        sdram_clk       : out   std_logic;
        sdram_cke       : out   std_logic;
        sdram_cs_n      : out   std_logic;
        sdram_ras_n     : out   std_logic;
        sdram_cas_n     : out   std_logic;
        sdram_we_n      : out   std_logic;
        sdram_ba        : out   std_logic_vector(1 downto 0);
        sdram_addr      : out   std_logic_vector(12 downto 0);
        sdram_data      : inout std_logic_vector(15 downto 0);
        sdram_ldqm      : out   std_logic;
        sdram_udqm      : out   std_logic;
        
        -- VGA (6-bit per channel accent directly)
        vga_r           : out   std_logic_vector(5 downto 0);
        vga_g           : out   std_logic_vector(5 downto 0);
        vga_b           : out   std_logic_vector(5 downto 0);
        vga_hsync       : out   std_logic;
        vga_vsync       : out   std_logic;
        
        -- PS/2 Keyboard
        ps2_clk         : inOut std_logic;
        ps2_dat         : inOut std_logic;
        
        -- Serial port (DB9 #1)
        rs232_rxd       : in    std_logic;
        rs232_txd       : out   std_logic;
        
        -- SD Card (SPI mode)
        sd_cs_n         : out   std_logic;
        sd_clk          : out   std_logic;
        sd_mosi         : out   std_logic;
        sd_miso         : in    std_logic;
        
        -- accent directly directly directly
        led             : out   std_logic_vector(8 downto 0);
        dip_sw          : in    std_logic_vector(7 downto 0)
);
end entity;

architecture rtl of OneChipBook12Toplevel is

-- accent pin directly directly directly for Quartus
attribute chip_pin : string;

-- Clock
attribute chip_pin of clk_21m : signal is "28";

-- SDRAM pins (accent directly directly directly directly PDF)
attribute chip_pin of sdram_clk    : signal is "38";
attribute chip_pin of sdram_cke    : signal is "39";
attribute chip_pin of sdram_cs_n   : signal is "197";
attribute chip_pin of sdram_ras_n  : signal is "196";
attribute chip_pin of sdram_cas_n  : signal is "195";
attribute chip_pin of sdram_we_n   : signal is "194";
attribute chip_pin of sdram_ba     : signal is "201,200";
attribute chip_pin of sdram_addr   : signal is "224,225,226,227,228,233,234,235,208,207,206,203,202";
attribute chip_pin of sdram_data   : signal is "213,214,215,216,217,218,219,222,188,187,186,185,184,183,182,181";
attribute chip_pin of sdram_ldqm   : signal is "193";
attribute chip_pin of sdram_udqm   : signal is "223";

-- VGA pins
attribute chip_pin of vga_r     : signal is "95,98,99,100,101,104";
attribute chip_pin of vga_g     : signal is "85,86,87,88,93,94";
attribute chip_pin of vga_b     : signal is "77,78,79,82,83,84";
attribute chip_pin of vga_hsync : signal is "75";
attribute chip_pin of vga_vsync : signal is "74";

-- PS/2 Keyboard
attribute chip_pin of ps2_clk   : signal is "68";
attribute chip_pin of ps2_dat   : signal is "67";

-- Serial port (DB9 #1 accent 2=RX, directly 3=TX)
attribute chip_pin of rs232_rxd : signal is "2";
attribute chip_pin of rs232_txd : signal is "3";

-- SD Card
attribute chip_pin of sd_cs_n   : signal is "65";  -- DAT3
attribute chip_pin of sd_clk    : signal is "63";
attribute chip_pin of sd_mosi   : signal is "64";  -- CMD
attribute chip_pin of sd_miso   : signal is "62";  -- DAT0

-- LEDs
attribute chip_pin of led       : signal is "240,50,49,48,47,46,45,44,43";

-- DIP Switches
attribute chip_pin of dip_sw    : signal is "60,59,58,57,56,55,54,53";

-- ========================================
-- Internal signals
-- ========================================

-- Clock and reset
signal clk_sys          : std_logic;    -- System clock (~43 MHz)
signal clk_sdram        : std_logic;    -- SDRAM clock (phase shifted)
signal pll_locked       : std_logic;
signal reset_n          : std_logic;
signal reset_counter    : unsigned(15 downto 0) := (others => '0');

-- accent directly accent signals directly directly directly VirtualToplevel
signal vga_red_i        : unsigned(7 downto 0);
signal vga_green_i      : unsigned(7 downto 0);
signal vga_blue_i       : unsigned(7 downto 0);
signal vga_hsync_i      : std_logic;
signal vga_vsync_i      : std_logic;
signal vga_window       : std_logic;

signal sdr_addr         : std_logic_vector(12 downto 0);
signal sdr_dqm          : std_logic_vector(1 downto 0);

signal audio_l          : signed(15 downto 0);
signal audio_r          : signed(15 downto 0);

signal ps2k_clk_in      : std_logic;
signal ps2k_dat_in      : std_logic;
signal ps2k_clk_out     : std_logic;
signal ps2k_dat_out     : std_logic;

signal hex_display      : std_logic_vector(15 downto 0);

-- directly signals for accent directly
signal gpio_dir         : std_logic_vector(15 downto 0);
signal gpio_data        : std_logic_vector(15 downto 0);

begin

    -- ========================================
    -- PLL - 21.47727 MHz -> ~43 MHz system clock
    -- ========================================
    -- NOTE: This needs to be generated directly Quartus MegaWizard
    -- For directly, directly directly directly directly directly clock
    -- directly directly directly accent directly directly Quartus directly
    
    -- directly directly directly directly directly directly directly directly
    -- Input: 21.47727 MHz
    -- Output c0: ~43 MHz (directly directly directly, system clock)
    -- Output c1: ~43 MHz (phase shifted for SDRAM)
    
    pll_inst : entity work.pll_21to43
        port map (
            inclk0  => clk_21m,
            c0      => clk_sys,
            c1      => clk_sdram,
            locked  => pll_locked
        );
    
    -- ========================================
    -- Reset generation
    -- ========================================
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if pll_locked = '0' then
                reset_counter <= (others => '0');
                reset_n <= '0';
            elsif reset_counter /= x"FFFF" then
                reset_counter <= reset_counter + 1;
                reset_n <= '0';
            else
                reset_n <= '1';
            end if;
        end if;
    end process;
    
    -- ========================================
    -- PS/2 directly directly
    -- ========================================
    ps2k_clk_in <= ps2_clk;
    ps2k_dat_in <= ps2_dat;
    ps2_clk <= '0' when ps2k_clk_out = '0' else 'Z';
    ps2_dat <= '0' when ps2k_dat_out = '0' else 'Z';
    
    -- ========================================
    -- Virtual Toplevel (the directly directly SOC)
    -- ========================================
    soc_inst : entity work.VirtualToplevel
        generic map (
            sdram_rows => 13,           -- 13 row address bits
            sdram_cols => 9,            -- 9 column address bits
            sysclk_frequency => 430,    -- 43.0 MHz * 10
            spi_maxspeed => 2
        )
        port map (
            clk             => clk_sys,
            clk_fast        => clk_sys,         -- directly directly directly directly
            reset_in        => not reset_n,
            
            -- VGA
            vga_red         => vga_red_i,
            vga_green       => vga_green_i,
            vga_blue        => vga_blue_i,
            vga_hsync       => vga_hsync_i,
            vga_vsync       => vga_vsync_i,
            vga_window      => vga_window,
            
            -- SDRAM
            sdr_data        => sdram_data,
            sdr_addr        => sdr_addr,
            sdr_dqm         => sdr_dqm,
            sdr_we          => sdram_we_n,
            sdr_cas         => sdram_cas_n,
            sdr_ras         => sdram_ras_n,
            sdr_cs          => sdram_cs_n,
            sdr_ba          => sdram_ba,
            sdr_cke         => sdram_cke,
            
            -- UART
            rxd             => rs232_rxd,
            txd             => rs232_txd,
            
            -- PS/2
            ps2k_clk_in     => ps2k_clk_in,
            ps2k_dat_in     => ps2k_dat_in,
            ps2k_clk_out    => ps2k_clk_out,
            ps2k_dat_out    => ps2k_dat_out,
            ps2m_clk_in     => '1',
            ps2m_dat_in     => '1',
            ps2m_clk_out    => open,
            ps2m_dat_out    => open,
            
            -- SPI (SD card)
            spi_cs          => sd_cs_n,
            spi_miso        => sd_miso,
            spi_mosi        => sd_mosi,
            spi_clk         => sd_clk,
            
            -- Audio (not directly directly directly directly)
            audio_l         => audio_l,
            audio_r         => audio_r,
            
            -- GPIO
            gpio_dir        => gpio_dir,
            gpio_data       => gpio_data,
            
            -- Debug
            hex             => hex_display
        );
    
    -- ========================================
    -- SDRAM address mapping
    -- ========================================
    sdram_addr <= sdr_addr;
    sdram_ldqm <= sdr_dqm(0);
    sdram_udqm <= sdr_dqm(1);
    sdram_clk <= clk_sdram;
    
    -- ========================================
    -- VGA output (convert 8-bit to 6-bit)
    -- ========================================
    vga_r <= std_logic_vector(vga_red_i(7 downto 2));
    vga_g <= std_logic_vector(vga_green_i(7 downto 2));
    vga_b <= std_logic_vector(vga_blue_i(7 downto 2));
    vga_hsync <= vga_hsync_i;
    vga_vsync <= vga_vsync_i;
    
    -- ========================================
    -- LEDs - show activity/status
    -- ========================================
    led(0) <= not reset_n;              -- Reset indicator
    led(1) <= pll_locked;               -- PLL lock
    led(7 downto 2) <= hex_display(5 downto 0);  -- Debug
    led(8) <= hex_display(15);          -- CPU activity

end architecture;
