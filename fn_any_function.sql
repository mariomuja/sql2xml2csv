create or alter function fn_any_function
()
returns table as return
(
select * from sys.tables
)