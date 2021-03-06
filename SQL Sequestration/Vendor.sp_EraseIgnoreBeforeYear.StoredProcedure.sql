USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_EraseIgnoreBeforeYear]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
create PROCEDURE [Vendor].[sp_EraseIgnoreBeforeYear]
	-- Add the parameters for the stored procedure here
	@dunsnumber varchar(13)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @dunsnumber is null
		raiserror('The value for @dunsnumber shold not be null.',15,1)
	-- Insert statements for procedure here
	update contractor.dunsnumber
	set ignorebeforeyear=NULL
	,CSISmodifiedBy=system_user
	,csismodifieddate=getdate()
	where dunsnumber=@dunsnumber 



		

END








GO
