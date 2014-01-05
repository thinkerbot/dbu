drop table if exists kv;
create table kv (
  k varchar,
  v varchar
);

drop table if exists datatypes;
create table datatypes (
  cstring   varchar,
  cinteger  integer,
  cfloat    double precision,
  cbool     boolean,
  ctime     timestamp,
  cbit      bit(5)
);
