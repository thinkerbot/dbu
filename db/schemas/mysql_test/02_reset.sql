drop procedure if exists reset;

delimiter $$
create procedure reset()
begin
  truncate table kv;
  insert into kv values ('a', '1');
  insert into kv values ('b', '2');
  insert into kv values ('c', '3');
end $$
delimiter ;
