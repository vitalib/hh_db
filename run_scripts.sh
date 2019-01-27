# dropdb hh_homework
# createdb hh_homework
psql -f create_db.sql hh_homework
# psql -f create_outer_tables.sql hh_homework
# psql -f outer_drop_constr.sql hh_homework
# psql -f insert_outer.sql hh_homework
psql -f insert_data.sql hh_homework
psql -f mapping.sql hh_homework
psql -f transfer.sql hh_homework
# psql -f scenario.sql hh_homework
