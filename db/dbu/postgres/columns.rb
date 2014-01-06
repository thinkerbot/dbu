desc "list columns in a table"
args :table_name

query <<-SQL
select column_name,
       data_type
  from information_schema.columns
 where table_name = %{table_name}
 order by column_name;
SQL
