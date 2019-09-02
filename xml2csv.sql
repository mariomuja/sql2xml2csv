/******************************************************************************************************
  * Author:     Mario Muja
  * Created:	2019-09-02
  * Purpose:    just an example
  ******************************************************************************************************/
declare  @input  nvarchar(max) 

set @input=(select * from cockpit.dbo.fn_cockpit_bi_top_largest_claims(10000, '2017-103', '2019-05-31') for xml raw, root, elements) 
exec sp_csv @input

set @input=(select top 10000 * from core.dbo.dim_policy_motor for xml raw, root, elements) 
exec sp_csv @input

go
