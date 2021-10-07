DO $$
DECLARE
segment_count int;
year_end_row record;
gl_account record;
BEGIN
	-- Get the count of how many gl segments exist
	select num_data into segment_count from system_settings where key= 'spire.gl.segments.count';

		-- Loop through a list of the year end values contained in gl_history_periods
			for year_end_row in (select distinct year_end from gl_history_periods where year_end is not null order by year_end) loop

			-- Loop through the count of gl_segments to know how many history_segment records to insert for each account
			for counter in 1..segment_count loop

				-- Loop through a list of the gl_history_account records that were archived for that year end
					for gl_account in (select * from gl_history_accounts glha where glha.year_end = year_end_row.year_end order by account_no) loop
							insert into gl_history_segments (segment_no, code, description, year_end)
					VALUES (counter, gl_account.account_no, gl_account.name, gl_account.year_end);
				end loop;
				-- Finish loop on gl_accounts
			end loop;
		-- Finish loop on gl_segment_count
	end loop;
	-- Finish loop on year_ends
END $$