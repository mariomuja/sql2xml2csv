
/******************************************************************************************************
  * Author:     Mario Muja
  * Created:	2019-09-02
  * Purpose:    transform XML to CSV
  ******************************************************************************************************/

CREATE OR ALTER PROCEDURE sp_csv
(@input     NVARCHAR(MAX), 
 @delimiter NCHAR(1)      = ',', 
 @cover     NVARCHAR(1)   = '', 
 @withHead  BIT           = 1, 
 @pResCode  INT           = 0 OUTPUT --0-OK, 1-ERROR
)
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @csv NVARCHAR(MAX);

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
        DECLARE @message NVARCHAR(150);
        BEGIN TRY
            IF @input IS NULL
                BEGIN
                    RAISERROR('The first argument of sp_csv was NULL. Please provide some XML to tranform.', 16, 1);
            END;
            EXEC sp_transform 
                 @csv OUT, 
                 @input, 
                 @xsl;
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