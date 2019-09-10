SQL2XML2CSV

This repository contains code to transform XML using XSLT on MS SQL Server.

The code can be used to create CSV files directly out of SQL Server stored procedures / functions / scripts.

The code can also be used to run any XML/XSL transformation from within SQL Server stored procedures / function / scripts. 

As an example, I have included a SQL Server stored procedure sp_csv, which can be used to create CSV files using XSL transformations on MS SQL Server. You can schedule calls to this procedure on SQL Server to generate CSV content from SELECT statements or SQL Server functions in your database to support data exchange with customers or other systems using the CSV format.

The solution was implemented using
- MS Visual Studio 2019 Community Edition
- MS SQL Server 2017 Express Edition

Idea: 
- have a .NET assembly that runs a XSL transformation
- register this assembly on MS SQL Server
- call into the assembly from a stored procedure that creates CSV from any SQL statement
- run any other XSL transformation on SQL Server

Some example for the generation of CSV from any SQL Server SELECT statement:
---------------------------------
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
---------------------------------

How to reproduce what I have done:

1. Compile the Visual Studio solution using 
Visual Studio 2019 Community Edition

2. Run the following command on a Powershell prompt

"0x" +[System.BitConverter]::ToString([System.IO.File]::ReadAllBytes("X:\StoredProcedures.dll")).Replace("-","")

3. copy resulting bytes from the commandline to the clipboard

4. insert the bytes into the create assembly statement in file deploy_assembly.sql:

CREATE ASSEMBLY StoredProcedures
FROM 0x<paste from clipboard>WITH PERMISSION_SET = SAFE;

5. run deploy_assembly.sql in SQL Server Management Studio (or any other SQL editor)

6. try other input XML/XSL 

For any questions about the code, you can reach me at
mario.muja@gmx.de

Have fun,
Mario
