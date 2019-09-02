/******************************************************************************************************
  * Author:     Mario Muja
  * Created:	2019-09-02
  * Purpose:    create CSV on SQL Server
  ******************************************************************************************************/
use core
go

declare  @input  nvarchar(max) 

-- CSV from any SQL Server function...
set @input=(select * from cockpit.dbo.fn_cockpit_bi_top_largest_claims(10000, '2017-103', '2019-05-31') for xml raw, root, elements) 
exec sp_csv @input

-- use a semikolon instead of a comma
set @input=(select top 10000 * from core.dbo.dim_policy_motor for xml raw, root, elements) 
exec sp_csv @input, ';' -- another delimiter

-- no headers and double quotes
set @input=(select top 10000 * from core.dbo.dim_claim_motor for xml raw, root, elements) 
exec core.dbo.sp_csv @input, ';', '"' /*enclose fields with double quotes*/, 0

-- interprete the input as a SQL statement 
set @input='select * from core.dbo.dim_claim_motor' 
exec sp_csv @input, ';', '"', 1 /*with header*/, 1 /*accept SQL as input instead of XML*/

go
