DO $$
DECLARE
	record_id int = 32336;
BEGIN
-- Setup to do datafix ---
    -- Check if the rollback schema is created and if not then create it
    IF(select not exists (select * from pg_catalog.pg_namespace where nspname ='rollback')) THEN
        CREATE SCHEMA rollback;
    END IF;
    
	-- Check to see if the rollback table for this case already exists, if not then do the fix
	IF (SELECT NOT EXISTS (
				SELECT FROM pg_catalog.pg_class c 
				JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
				WHERE  n.nspname = 'rollback' AND c.relname = 'case_47839_inventory_serial_transactions'
				)) THEN
   		-- Create a new table to hold the rollback data for this datafix
    	CREATE TABLE rollback.case_47839_inventory_serial_transactions (LIKE public.inventory_serial_transactions INCLUDING ALL);
    
    	-- Backup the Record that is the target for deletion
    	INSERT INTO rollback.case_47839_inventory_serial_transactions (SELECT * FROM public.inventory_serial_transactions where id = record_id);
    
-- Perform Fix Action ----
   		-- Delete the bad serial number record from inventory_serial_transactions
    	UPDATE inventory_serial_numbers isn
    	SET available_qty = available_qty - (ist.recvd_qty)
    	from inventory_serial_transactions ist 
    	where isn.whse = ist.whse and isn.part_no = ist.part_no and isn.number = ist.number 
    	and ist.id = record_id;
    
    	-- Delete The bad serial from the database
   	 	DELETE FROM public.inventory_serial_transactions where id = record_id and receipt_no is null;
	-- if the rollback table for this case exists then notify and exit with no action
	ELSE
		RAISE NOTICE 'Datafix already has been run here. Exiting with no action';
   	END IF;
END $$