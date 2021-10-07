DO $$
DECLARE
segment_count int;
gl_account record;
BEGIN
	-- Get the count of how many gl segments exist
	select num_data into segment_count from system_settings where key= 'spire.gl.segments.count';
	
	-- Loop through the count of gl_segments to know how many history_segment records to insert for each account
	for counter in 1..segment_count loop
	
		-- Loop through a list of the gl_account records that were archived for that year end
        for gl_account in (select * from gl_accounts gla order by account_no) loop
			
			-- Insert the segment records
			insert into gl_segments (segment_no, code, description) VALUES (counter, gl_account.account_no, gl_account.name);
				
		end loop;
		-- End looping through gl accounts
	end loop;
	-- End looping through gl segments
END$$;
