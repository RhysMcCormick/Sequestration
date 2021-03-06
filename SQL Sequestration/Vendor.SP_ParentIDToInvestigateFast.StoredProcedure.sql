USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_ParentIDToInvestigateFast]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_ParentIDToInvestigateFast]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT top 1000 
	max(d.ReasonForInclusion) as ReasonForInclusion
		,min(D.[fiscalyear]) as  MinFiscalYear
		,max(D.[fiscalyear]) as  MaxFiscalYear
      ,sum(D.[ConstantObligatedBillions]) as TotalConstantObligatedBillions
	  ,max(D.[ConstantObligatedBillions]) as MaxAnnualConstantObligatedBillions

      ,D.[parentid]
      ,D.[LargeGreaterThan3B]
      ,D.[LargeGreaterThan1B]
      ,D.[RevenueInMillions]
	  ,D.[jointventure]
	  ,d.MergerYear
	  ,d.MergerDate
	  ,d.Owners
	  ,d.FirstYear
	  ,d.SpunOffFrom
	FROM Contractor.DunsnumbersToInvestigateFast as D
	where d.parentid is not null
	group by
       D.[parentid]
      ,D.[LargeGreaterThan3B]
      ,D.[LargeGreaterThan1B]
      ,D.[RevenueInMillions]
	  ,D.[jointventure]
	  ,d.MergerYear
	  ,d.MergerDate
	  ,d.Owners
	  ,d.FirstYear
	  ,d.SpunOffFrom
	having max(D.[ConstantObligatedBillions])>=0.5
		or sum(D.[ConstantObligatedBillions])>=2
	Order by max(d.[ConstantObligatedBillions]) desc
	


END














GO
