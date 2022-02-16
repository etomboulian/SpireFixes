DO $$
DECLARE
    row record;
    stmt varchar;
BEGIN

-- Disable Triggers
SET session_replication_role = replica;

-- For any table where there exists a column named _created_by, get the table_schema and table_name
FOR row in (
            select t.table_schema,
               t.table_name
            from information_schema.tables t
            inner join information_schema.columns c on c.table_name = t.table_name 
                                    and c.table_schema = t.table_schema
            where c.column_name = '_created_by'
              and t.table_schema not in ('information_schema', 'pg_catalog')
              and t.table_type = 'BASE TABLE') 
LOOP
-- Loop over all results of the select query above
    -- Print the table to update
    raise notice 'Updating Table: %.%', row.table_schema, row.table_name;
    -- Create the sql statement to run
    stmt = 'UPDATE ' || row.table_schema || '.' || row.table_name || ' set _created_by = upper(_created_by), _modified_by = upper(_modified_by)';
    -- Run the statement
    execute stmt;
    -- Print the statement that was just run
    raise notice 'Ran Statement: %', stmt;
    
END LOOP;

-- Re-enable Triggers
SET session_replication_role = DEFAULT;

END $$