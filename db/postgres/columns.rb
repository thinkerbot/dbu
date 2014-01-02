desc "list columns in a table"

prepare :table_name, <<-SQL
select column_name,
       data_type
  from information_schema.columns
 where table_name = $1
 order by column_name;
SQL
