/*
Datafix #1 for FD Ticket# 52435
Author: Evan Tomboulian

Reason:
Because some requisitioned items on SO# 00815813-0 now references a PO that doesn't actually contain the items that were requisitioned, PO# 0000378655
In order to enable the client to do the requisition process again for these items we need to take the following actions 

Actions:
1. Removes the links to the bad PO that are contained in sales_order_items
2. Sets the requisition that was created for this item back to unprocessed
*/

DO $$
DECLARE
sales_order_number varchar = '00815813-0';
purchase_order_to_remove varchar = '0000378655';
row_count int;
BEGIN
	
	-- Remove the links to the purchase order in the Sales Order line items
	update sales_order_items soi 
	set po_number = ''
	where order_no = sales_order_number and po_number = purchase_order_to_remove;
	
	-- Print affected row count
	get diagnostics row_count = row_count;
	raise notice 'Update #1 has updated data in % rows', row_count;
	
	-- Set the requisition for each item back to unprocessed
	update inventory_requisitions ir
	set targ_no = '' , targ_guid = '' , status = 'U'
	where ir.src_no = sales_order_number and ir.targ_no = purchase_order_to_remove;
	
	-- Print affected row count
	get diagnostics row_count = row_count;
	raise notice 'Update #2 has updated data in % rows', row_count;

END $$