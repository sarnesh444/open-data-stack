
  
    

    create table "iceberg"."test_schema"."third_model"
      
      
    as (
      select 1 as col, 
      'Alice' as name,
      'alice@example.com' as email
union all
select 2 as col, 
      'Bob' as name,
      'bob@example.com' as email
    );

  