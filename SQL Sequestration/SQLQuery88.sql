USE [DIIG]
GO

DECLARE	@return_value int

EXEC	@return_value = [Restricted].[SP_ReAssignParentIDoverRange]
		@originalparentid = N'INDAL TECHNOLOGIES',
		@newparentid = N'CURTISS WRIGHT',
		@startyear = 2005,
		@endyear = 2016

SELECT	'Return Value' = @return_value

GO
