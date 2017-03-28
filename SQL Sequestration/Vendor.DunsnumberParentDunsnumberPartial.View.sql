USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumberParentDunsnumberPartial]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [Vendor].[DunsnumberParentDunsnumberPartial]
AS

SELECT 
	f.dunsnumber
	,f.fiscal_year
	,f.parentdunsnumber
	, Sum(f.obligatedamount) AS SumOfobligatedamount
FROM Contract.FPDS as f
GROUP BY 
	f.dunsnumber
	,f.fiscal_year
	,f.parentdunsnumber








GO
