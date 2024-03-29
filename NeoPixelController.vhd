-- WS2812 communication interface starting point for
-- ECE 2031 final project spring 2022.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity NeoPixelController is

	port(
		clk_10M   : in   std_logic;
		resetn    : in   std_logic;
		io_write  : in   std_logic;
		cs_addr   : in   std_logic;
		cs_data   : in   std_logic;
		pxl_all_en: in	  std_logic;
		pxl_24_bitcolor_en: in std_logic;
		pxl_24_red_en: in std_logic;
		pxl_24_green_en: in std_logic;
		pxl_24_blue_en: in std_logic;
		pattern_number_en: in std_logic;
		data_in   : in   std_logic_vector(15 downto 0);
		sda       : out  std_logic
	); 

end entity;

architecture internals of NeoPixelController is
	
	-- Signals for the RAM read and write addresses
	signal ram_read_addr, ram_write_addr : std_logic_vector(7 downto 0);
	-- RAM write enable
	signal ram_we : std_logic;

	-- Signals for data coming out of memory
	signal ram_read_data : std_logic_vector(23 downto 0);
	-- Signal to store the current output pixel's color data
	signal pixel_buffer : std_logic_vector(23 downto 0);

	-- Signal SCOMP will write to before it gets stored into memory
	signal ram_write_buffer : std_logic_vector(23 downto 0);
	
	signal pattern_number: std_logic_vector(15 downto 0); --signal to store the pattern number
	signal temp_color: std_logic_vector(23 downto 0); --signal to store the color to show it in the pattern
	signal counter: std_logic_vector(23 downto 0);
	signal delay: std_logic_vector(23 downto 0);
	signal half_delay: std_logic_vector(23 downto 0);
	signal checks_for_24bitcolor: std_logic_vector(2 downto 0); -- GRB order
	signal input_2: integer range 0 to 2;
	signal violet: std_logic_vector(23 downto 0);
	signal indigo: std_logic_vector(23 downto 0);
	signal blue: std_logic_vector(23 downto 0);
	signal green: std_logic_vector(23 downto 0);
	signal yellow: std_logic_vector(23 downto 0);
	signal orange: std_logic_vector(23 downto 0);
	signal red: std_logic_vector(23 downto 0);
	signal rainbow_starting_addr: std_logic_vector(7 downto 0);
	signal curr_color: std_logic_vector(6 downto 0);
	signal rainbow_reset_counter: std_logic_vector(6 downto 0);
	signal num_times: std_logic_vector(23 downto 0); -- to exit the rainbow
	

	-- RAM interface state machine signals
	type write_states is (idle, rainbow_reset, delay_rainbow_reset, rainbow_color_selection, rainbow, reset_storing, rainbow_storing, delay_rainbow_storing, determining24bitcolor, pattern_delay, pattern_0_storing, pattern_0_reset, receiving24bitredcolor, receiving24bitgreencolor, receiving24bitbluecolor, storing);
	signal wstate: write_states;


	
begin

	-- This is the RAM that will store the pixel data.
	-- It is dual-ported.  SCOMP will access port "A",
	-- and the NeoPixel controller will access port "B".
	pixelRAM : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		init_file => "pixeldata.mif",
		intended_device_family => "Cyclone V",
		lpm_type => "altsyncram",
		numwords_a => 256,
		numwords_b => 256,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
		widthad_a => 8,
		widthad_b => 8,
		width_a => 24,
		width_b => 24,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		address_a => ram_write_addr,
		address_b => ram_read_addr,
		clock0 => clk_10M,
		data_a => ram_write_buffer,
		data_b => x"000000",
		wren_a => ram_we,
		wren_b => '0',
		q_b => ram_read_data
	);
	


	-- This process implements the NeoPixel protocol by
	-- using several counters to keep track of clock cycles,
	-- which pixel is being written to, and which bit within
	-- that data is being written.
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8; -- high time for '1'
		constant t0h : integer := 3; -- high time for '0'
		constant ttot : integer := 12; -- total bit time
		
		constant npix : integer := 256;

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 31;
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 1000;
		-- Counter for the current pixel
		variable pixel_count : integer range 0 to 255;
		
		
	begin
		
		if resetn = '0' then
			-- reset all counters
			bit_count := 23;
			enc_count := 0;
			reset_count := 1000;
			-- set sda inactive
			sda <= '0';

		elsif (rising_edge(clk_10M)) then

			-- This IF block controls the various counters
			if reset_count /= 0 then -- in reset/end-of-frame period
				-- during reset period, ensure other counters are reset
				pixel_count := 0;
				bit_count := 23;
				enc_count := 0;
				-- decrement the reset count
				reset_count := reset_count - 1;
				-- load data from memory
				pixel_buffer <= ram_read_data;
				
			else -- not in reset period (i.e. currently sending data)
				-- handle reaching end of a bit
				if enc_count = (ttot-1) then -- is end of this bit?
					enc_count := 0;
					-- shift to next bit
					pixel_buffer <= pixel_buffer(22 downto 0) & '0';
					if bit_count = 0 then -- is end of this pixels's data?
						bit_count := 23; -- start a new pixel
						pixel_buffer <= ram_read_data;
						if pixel_count = npix-1 then -- is end of all pixels?
							-- begin the reset period
							reset_count := 1000;
						else

							pixel_count := pixel_count + 1;
						end if;
					else
						-- if not end of this pixel's data, decrement count
						bit_count := bit_count - 1;
					end if;
				else
					-- within a bit, count to achieve correct pulse widths
					enc_count := enc_count + 1;
				end if;
			end if;
			
			
			-- This IF block controls the RAM read address to step through pixels
			if reset_count /= 0 then
				ram_read_addr <= x"00";
			elsif (bit_count = 1) AND (enc_count = 0) then
				-- increment the RAM address as each pixel ends
				ram_read_addr <= ram_read_addr + 1;
			end if;
			
			
			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif 
				-- sda is 1 in the first part of a bit.
				-- Length of first part depends on if bit is 1 or 0
				( (pixel_buffer(23) = '1') and (enc_count < t1h) )
				or
				( (pixel_buffer(23) = '0') and (enc_count < t0h) )
				then sda <= '1';
			else
				sda <= '0';
			end if;
			
		end if;
	end process;
	
	
	
	process(clk_10M, resetn, cs_addr)
	begin
		-- For this implementation, saving the memory address
		-- doesn't require anything special.  Just latch it when
		-- SCOMP sends it.
		if resetn = '0' then
			ram_write_addr <= x"00";
			rainbow_starting_addr <= x"00";
		elsif rising_edge(clk_10M) then
			-- If SCOMP is writing to the address register...
			if (io_write = '1') and (cs_addr='1') then
				ram_write_addr <= data_in(7 downto 0);
			end if;
			
			--if (pxl_all_en = '1') then
			--	ram_write_addr <= ram_write_addr + 1;
		--	end if;
			
			--if (wstate = storing) and ((pxl_all_en = '1') or (pattern_number_en = '1')) then
				--ram_write_addr <= ram_write_addr + 1;
			--end if;
			
			if (io_write = '0') and (pxl_all_en = '1') then
				ram_write_addr <= ram_write_addr + 1;
			end if;

			if (io_write = '0') and (cs_data = '1') then
				ram_write_addr <= ram_write_addr + 1;
			end if;

			if (wstate = storing) then
				ram_write_addr <= ram_write_addr + 1;
			end if;
			
			if (wstate = pattern_0_storing) then
				ram_write_addr <= ram_write_addr - 1;
			end if;
			
			if (wstate = rainbow_storing) then
				ram_write_addr <= ram_write_addr + 1;
			end if;
			
			if (wstate = rainbow_reset) then 
				ram_write_addr <= ram_write_addr - 1;
			end if;
			
			if (wstate = rainbow) then 
				rainbow_starting_addr <= rainbow_starting_addr + 1;
				ram_write_addr <= rainbow_starting_addr;
			end if;
			
			--if (counter >= delay) and (wstate = storing) then
				--ram_write_addr <= ram_write_addr + 1;
			--end if;
			
			
			
		end if;
	
	
		-- The sequnce of events needed to store data into memory will be
		-- implemented with a state machine.
		-- Although there are ways to more simply connect SCOMP's I/O system
		-- to an altsyncram module, it would only work with under specific 
		-- circumstances, and would be limited to just simple writes.  Since
		-- you will probably want to do more complicated things, this is an
		-- example of something that could be extended to do more complicated
		-- things.
		-- Note that 'ram_we' is *not* implemented as a Moore output of this state
		-- machine, because Moore outputs are susceptible to glitches, and
		-- that's a bad thing for memory control signals.
		if resetn = '0' then
			wstate <= idle;
			ram_we <= '0';
			ram_write_buffer <= x"000000";
			delay <= x"0F4240";
			half_delay <= x"07A120";
			counter <= x"000000";
			checks_for_24bitcolor <= "000";
			violet <= x"82eeee";
			indigo <= x"004b82";
			blue <= x"0000ff";
			green <= x"800000";
			yellow <= x"ffff00";
			orange <= x"a5ff00";
			red <= x"00ff00";
			num_times <= x"000000";
			-- Note that resetting this device does NOT clear the memory.
			-- Clearing memory would require cycling through each address
			-- and setting them all to 0.
		elsif rising_edge(clk_10M) then
			case wstate is
			when idle =>
				if ((io_write = '1') and (cs_data='1')) or (pxl_all_en = '1') then
					-- latch the current data into the temporary storage register,
					-- because this is the only time it'll be available.
					-- Convert RGB565 to 24-bit color
					ram_write_buffer <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000";
					temp_color <= ram_write_buffer;
					-- can raise ram_we on the upcoming transition, because data
					-- won't be stored until next clock cycle.
					ram_we <= '1';
					-- Change state
					wstate <= storing;
				elsif (io_write = '1') and (pxl_24_bitcolor_en = '1') then
					--ram_write_buffer <= x"000000";
					wstate <= receiving24bitredcolor;
					ram_we <= '1';
				
				elsif (io_write = '1') and (pattern_number_en = '1') then
					pattern_number <= data_in(15 downto 0);
					if (pattern_number = "0") then
						wstate <= pattern_delay;
					elsif (pattern_number = "1") then 
						wstate <= idle;
					elsif (pattern_number = "010") then
							wstate <= rainbow;
					end if;
				end if;
			
			When rainbow =>
					curr_color <= "0000000";
					wstate <= rainbow_color_selection;
					
			when rainbow_color_selection => 
				if curr_color = "0000000" then
					ram_write_buffer <= violet;
					curr_color <= "0000001";
					wstate <= delay_rainbow_storing;
				elsif curr_color = "0000001" then
					ram_write_buffer <= indigo;
					curr_color <= "0000011" ; 
					wstate <= delay_rainbow_storing;
				elsif curr_color = "0000011" then
					ram_write_buffer <= blue;
					curr_color <= "0000111" ; 
					wstate <= delay_rainbow_storing;
				elsif curr_color = "0000111" then
					ram_write_buffer <= green;
					curr_color <= "0001111" ; 
					wstate <= delay_rainbow_storing;
				elsif curr_color = "0001111" then
					ram_write_buffer <= yellow;
					curr_color <= "0011111";  
					wstate <= delay_rainbow_storing;
				elsif curr_color = "0011111" then
					ram_write_buffer <= orange;
					curr_color <= "0111111" ; 
					wstate <= delay_rainbow_storing;
				elsif curr_color = "0111111" then
					ram_write_buffer <= red;
					curr_color <= "1111111" ; 
					wstate <= delay_rainbow_storing;
				elsif curr_color = "1111111" then
					rainbow_reset_counter <= "0000000";
					wstate <= delay_rainbow_reset;
				end if;
			
			when rainbow_reset=>
				ram_write_buffer <= x"000000";
				if rainbow_reset_counter = "0000111" then
					wstate <= idle;
				else
					rainbow_reset_counter <= rainbow_reset_counter + 1;
					ram_we <= '1';
					wstate <= reset_storing;
				end if;
			
			when delay_rainbow_storing =>	
				ram_we <='1';
				wstate <= rainbow_storing;
				
				--if counter /= delay then
					--wstate <= delay_rainbow_storing;
					--counter <= counter + 1;
				--else 
					--ram_we <= '1';
					--counter <= x"000000";
					--wstate <= rainbow_storing;
				--end if;
				
			when delay_rainbow_reset =>
				if counter /= delay then
					wstate <= delay_rainbow_reset;
					counter <= counter + 1;
				else 
					ram_we <= '1';
					counter <= x"000000";
					wstate <= rainbow_reset;
				end if;
				
			when reset_storing =>
				ram_we <= '0';
				wstate <= rainbow_reset;
				
			
	
			when rainbow_storing =>
				ram_we <= '0';
				wstate <= rainbow_color_selection;
					
			when pattern_delay =>
				if (counter /= half_delay) then
					counter <= counter + 1;
				else
					--counter <= 0;
					ram_write_buffer <= temp_color;
					ram_we <= '1';
					wstate <= pattern_0_storing;
				end if;
				
				
			
			when pattern_0_storing =>
				ram_we <= '0';
				wstate <= pattern_0_reset;

			
			when pattern_0_reset =>
				if (counter /= delay) then 
					counter <= counter + 1;
				else
					counter <= x"000000";
					ram_write_buffer <= x"000000";
					ram_we <= '1';
					wstate <= storing;
				end if;
					
			when receiving24bitredcolor =>
				if (io_write = '1') and (pxl_24_red_en = '1') then
					ram_write_buffer <= "00000000" & data_in(7 downto 0) & "00000000";
					wstate <= receiving24bitgreencolor;
				end if;
			when receiving24bitgreencolor =>
				if (io_write = '1') and (pxl_24_green_en = '1') then
					ram_write_buffer <= (data_in(7 downto 0) & "0000000000000000") OR ram_write_buffer;
					wstate <= receiving24bitbluecolor;
				end if;
			when receiving24bitbluecolor =>
				if (io_write = '1') and (pxl_24_blue_en = '1') then
					ram_write_buffer <= ram_write_buffer OR ("0000000000000000" & data_in(7 downto 0));
					wstate <= storing;
				end if;
			when storing =>
				-- All that's needed here is to lower ram_we.  The RAM will be
				-- storing data on this clock edge, so ram_we can go low at the
				-- same time.
				ram_we <= '0';
				wstate <= idle;
			when others =>
				wstate <= idle;
			end case;
		end if;
	end process;

	
	
end internals;
