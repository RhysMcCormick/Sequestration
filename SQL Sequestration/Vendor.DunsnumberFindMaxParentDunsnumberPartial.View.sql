USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumberFindMaxParentDunsnumberPartial]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [Vendor].[DunsnumberFindMaxParentDunsnumberPartial]
AS


SELECT 
DP.DUNSNUMBER
, DP.fiscal_year
, Max(DP.SumOfobligatedamount) AS MaxOfSumOfobligatedamount
, Sum(DP.SumOfobligatedamount) AS SumOfobligatedamount
FROM Vendor.DunsnumberparentdunsnumberPartial as DP
GROUP BY DP.DUNSNUMBER
, DP.fiscal_year;











GO
