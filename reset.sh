rm db/test.db
sqlite3 db/test.db ".read db/1_initialize_schema.sql"
sqlite3 db/test.db "select * from documents;"