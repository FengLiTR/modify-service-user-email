--Feb 13
show users like '%service%';


select current_user();
show stages;
list @feng_internal_stage;

create or replace table preprod_user_to_modify_table (user text, primary_email text, backup_email text);
copy into preprod_user_to_modify_table from @feng_internal_stage/user-new-emails-pre-prod.csv
    file_format = (type=csv, skip_header=1);
select * from preprod_user_to_modify_table;

create or replace table prod_user_to_modify_table (user text, primary_email text, backup_email text, notify_by_email text);
copy into prod_user_to_modify_table from @feng_internal_stage/user-new-emails-prod.csv
    file_format = (type=csv, skip_header=1);
select * from prod_user_to_modify_table;


create or replace table user_test_table (user text, primary_email text, backup_email text);
insert into user_test_table values ('service1_feng_li', 'aaa_primary@example.com', 'aaa_backup@example.com'),
                                   ('service_feng_li', 'bbb_primary@example.com', 'bbb_backup@example.com');
select * from user_test_table;

create or replace procedure modify_user_email()
returns text
language sql
as
$$
declare
  myusers cursor for select user,primary_email, backup_email from user_test_table;
  user varchar;
  primary_email varchar;
  backup_email varchar;
begin
  open myusers;
  for myrow in myusers do
      user := myrow.user::varchar;
      primary_email := myrow.primary_email::varchar;
      backup_email := myrow.backup_email::varchar;
      execute immediate 'alter user "'||:user||'" set email = "'||:primary_email||'", comment = "'||:backup_email||'"';
  end for;
  close myusers;
  return 'success';
end;
$$;
call modify_user_email();

show users like '%service%';
