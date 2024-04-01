drop table if exists documents;
create table documents (
    id integer primary key autoincrement not null,
    body text not null,
    token_count integer not null
);

drop table if exists tokens;
create table tokens (
    id integer primary key autoincrement not null,
    term varchar(512) not null unique
);

drop table if exists inverted_indexes;
create table inverted_indexes (
    token_id integer not null primary key,
    posting_list longblob not null
);