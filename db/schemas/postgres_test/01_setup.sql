drop table if exists kv;
create table kv (
  k varchar,
  v varchar
);
insert into kv values ('a', '1');
insert into kv values ('b', '2');
insert into kv values ('c', '3');

drop table if exists datatypes;
create table datatypes (
  cstring   varchar,
  cinteger  integer,
  cfloat    double precision,
  cbool     boolean,
  ctime     timestamp,
  cbit      bit(5)
);
