DO $$
DECLARE
	record_id int = 32336;
BEGIN
	IF (SELECT EXISTS (
		SELECT FROM pg_catalog.pg_class c
		JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		WHERE  n.nspname = 'rollback' AND c.relname = 'case_47839_inventory_serial_transactions'
		)) THEN

		UPDATE public.inventory_serial_numbers pisn
		SET available_qty = available_qty + rist.recvd_qty
		FROM rollback.case_47839_inventory_serial_transactions rist
		where pisn.whse = rist.whse and pisn.part_no = rist.part_no and pisn.number = rist.number;

		INSERT INTO public.inventory_serial_transactions (SELECT * FROM rollback.case_47839_inventory_serial_transactions);

		DROP TABLE rollback.case_47839_inventory_serial_transactions;
	ELSE
		RAISE NOTICE 'Nothing here to rollback, no action taken';
	END IF;
END $$