USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumberFindMaxStandardizedVendorNamePartial]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [Vendor].[DunsnumberFindMaxStandardizedVendorNamePartial]
AS


SELECT 
DVN.DUNSNUMBER
, DVN.fiscal_year
, Sum(DVN.SumOfobligatedamount) AS SumOfobligatedamount
, Sum(DVN.SumOffed_funding_amount) AS SumOffed_funding_amount
, Sum(DVN.TotalAmount) AS TotalAmount
FROM Vendor.DunsnumberStandardizedVendorNamePartial as DVN
GROUP BY DVN.DUNSNUMBER
, DVN.fiscal_year;









GO
