desc "list columns in a table"

prepare :table_name, <<-SQL
select c.table_name,
       c.column_name,
       c.data_type,
       c.udt_name,
       c.ordinal_position as ord_pos,
       c.character_maximum_length as cmaxl,
       c.column_default as cdefault
  from information_schema.columns as c
 where table_name = $1
 order by c.table_name, c.column_name;
SQL
