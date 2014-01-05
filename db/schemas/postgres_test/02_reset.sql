drop function if exists reset();
create function reset() returns void as
$$
  truncate table kv;
  insert into kv values ('a', '1');
  insert into kv values ('b', '2');
  insert into kv values ('c', '3');
$$ language sql;
