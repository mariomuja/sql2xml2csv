USE [core]
GO
/****** Object:  StoredProcedure [dbo].[sp_csv]    Script Date: 2019-09-02 15:20:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************************
  * Author:     Mario Muja
  * Created:	2019-09-02
  * Purpose:    transform XML to CSV
  ******************************************************************************************************/
ALTER   PROCEDURE [dbo].[sp_csv]
(@input      NVARCHAR(MAX),				-- some XML or a SQL SELECT statement		- the XML should have: a root, any number of row elements, any number of column elements - XML attributes are NOT supported
 @delimiter  NCHAR(1)      = ',',		-- use a comma by default					- set to ; to use a semikolon instead
 @cover      NVARCHAR(1)   = '',		-- use no field separator by default		- set to " to use double quotes instead
 @withHead   BIT           = 1,			-- output a header row by default			- set to 0 to omit headers
 @inputAsSQL BIT		   = 0,			-- interprete the input as XML by default	- if set to 1, the use a SELECT as @input
 @pResCode   INT           = 0 OUTPUT   -- procedure return code					- 0-OK, 1-ERROR
)
AS
    BEGIN
        SET NOCOUNT ON;

		-- here we store the result
        DECLARE @csv NVARCHAR(MAX);

		-- XSL to create the header row
        DECLARE @header NVARCHAR(MAX)= '
	<xsl:template match="/">
		<xsl:for-each select="/*/*[1]/*">
			<xsl:if test="position()!=last()">' + @cover + '<xsl:value-of select="name(.)"/>' + @cover + @delimiter + '</xsl:if>
			<xsl:if test="position()=last()">' + @cover + '<xsl:value-of select="name(.)"/>' + @cover + '<xsl:text>&#xD;</xsl:text></xsl:if>
		</xsl:for-each>
		<xsl:apply-templates />
    </xsl:template>';

        IF @withHead = 0
            SET @header = '';

		-- XSL to create the data rows
        DECLARE @xsl NVARCHAR(MAX)= '
	<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="iso-8859-1"/>

	<xsl:strip-space elements="*" />

	' + @header + '

	<xsl:template match="/*/*">
	<xsl:for-each select="*">
		<xsl:if test="position()!=last()">' + @cover + '<xsl:value-of select="normalize-space(.)"/>' + @cover + @delimiter + '</xsl:if>
		<xsl:if test="position()=last()">' + @cover + '<xsl:value-of select="normalize-space(.)"/>' + @cover + '<xsl:text>&#xD;</xsl:text></xsl:if>
	</xsl:for-each>
	</xsl:template>

	</xsl:stylesheet>';

		-- let's try :-)
        BEGIN TRY
            -- if no input was provided, then raise an error
			IF @input IS NULL
                BEGIN
                    RAISERROR('The first argument of sp_csv was NULL. Please provide some XML or a SQL SELECT statement.', 16, 1);
            END;

			-- interprete the input as a SQL statement and execute it dynamically
			IF @inputAsSQL=1 
			BEGIN
				DECLARE @sSQL nvarchar(max);
				DECLARE @out nvarchar(max);

				SELECT @sSQL = N'SELECT @retvalOUT = ('+@input+' for xml raw, root, elements)';  
				SET @out = N'@retvalOUT nvarchar(max) OUTPUT';

				-- run the given SQL statement dynamically (only if explicitly wanted by the caller)
				EXEC sp_executesql @sSQL, @out, @retvalOUT=@input OUTPUT;
			END

			-- here the magic happens - transform the input 
            EXEC sp_transform 
                 @csv OUT, -- here we store the result
                 @input,   -- this is the XML that we transform
                 @xsl;	   -- this is the XSL that we use for the transformation

            SELECT @csv;

            -- commit transaction if necessary
            IF @@TRANCOUNT > 0
                COMMIT;
        END TRY
        BEGIN CATCH
            -- rollback transaction if necessary
            IF @@TRANCOUNT > 0
                ROLLBACK;
            -- output error number and text
            SELECT ERROR_NUMBER() AS ErrorNumber;
            SELECT ERROR_MESSAGE() AS ErrorMessage;
            -- set the procedure result code
            SET @pResCode = 1;
        END CATCH;
    END;