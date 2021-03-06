USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_EraseParentIDwithOverrideParentDunsnumber]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_EraseParentIDwithOverrideParentDunsnumber]
	-- Add the parameters for the stored procedure here
	@parentid nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @parentid is null
		raiserror('The value for @parentid should not be null.',15,1)
	
    -- Insert statements for procedure here
	update parent
	set OverrideParentDunsnumber=0
	,CSISmodifiedBy=system_user
	,csismodifieddate=getdate()
	from contractor.ParentContractor as parent
	where parent.parentid=@parentid

	/*select 'A list '

	select d.FiscalYear
		,d.dunsnumber
		,@owner as newparent
		,d.parentid as oldparent
		,d.StandardizedTopContractor
	from contractor.DunsnumberToParentContractorHistory as d
	where d.parentid=@parentid and d.FiscalYear>iif(month(@MergerDate)<4,year(@MergerDate),year(@MergerDate)+1)*/
END









GO
