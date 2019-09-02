This repository contains code to transform XML 
using XSLT on MS SQL Server.

The solution was implemented using
- MS Visual Studio 2019 Community Edition
- MS SQL Server 2017 Express Edition

How to reproduce what I have done:

1. Compile the Visual Studio solution using 
Visual Studio 2019 Community Edition

2. Run the following command on a Powershell prompt

"0x" +[System.BitConverter]::ToString([System.IO.File]::ReadAllBytes("X:\StoredProcedures.dll")).Replace("-","")

3. copy resulting bytes from the commandline to the clipboard

4. insert the bytes into the create assembly statement in the SQL script:

CREATE ASSEMBLY StoredProcedures
FROM 0x<paste from clipboard>WITH PERMISSION_SET = SAFE;

