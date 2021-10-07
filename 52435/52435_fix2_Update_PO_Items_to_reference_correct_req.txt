/*
Datafix #2 for FD Ticket# 52435
Author: Evan Tomboulian

Reason:
Because one of the requisitioned items on SO# 00815813-0 now references a PO that does contain the item requisitioned but that same PO 
doesn't reference back to the SO line item it was requisitioned from, we need to update the purchase_order_items to reference the correct requisition

Actions:
1. Update the requisition number and guid on the PO line items so that it references the correct requisition and thus sales order line item
*/

DO $$
DECLARE
src_order_no varchar = '00815813-0';
existing_po_no varchar = '0000378635';
target_req_no varchar;
target_guid varchar;
target_part_no varchar;
row_count int;
BEGIN

	-- Get the requisition number from the sales order line item
	select req_no into target_req_no from sales_order_items where order_no = src_order_no and po_number = existing_po_no;
	
	-- Get the target guid and the part number from the requisition table
	select targ_guid, part_no into target_guid, target_part_no from inventory_requisitions where requisition_no = target_req_no;

	-- Since we only have fuzzy links to this item find it by the po number and part_no and update the requisition number and guid
	update purchase_order_items 
	set requisition_no = target_req_no, guid = target_guid
	where po_number = existing_po_no and part_no = target_part_no;
	
	-- Now print how many rows were affected
	get diagnostics row_count = row_count;
	raise notice 'Updated % rows on PO_No: % containing Part_No: % to reference Req_No: %', row_count, existing_po_no, target_part_no, target_req_no;

END$$