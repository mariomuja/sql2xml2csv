/******************************************************************************************************
  * Author:     Mario Muja
  * Created:	2019-09-02
  * Purpose:    create CSV on SQL Server
  ******************************************************************************************************/
declare  @input  nvarchar(max) 

-- CSV from XML...
set @input=(select * from cockpit.dbo.fn_cockpit_bi_top_largest_claims(10000, '2017-103', '2019-05-31') for xml raw, root, elements) 
exec sp_csv @input

-- ... with another delimiter
set @input=(select top 10000 * from core.dbo.dim_policy_motor for xml raw, root, elements) 
exec sp_csv @input, ';'

-- ... with field separators and without header
set @input=(select top 10000 * from core.dbo.dim_claim_motor for xml raw, root, elements) 
exec sp_csv @input, ';', '"', 0

-- the same from an ordinary SQL statement
set @input='select top 10 * from core.dbo.dim_claim_motor' 
exec sp_csv @input, ';', '"', 0, 1

go
