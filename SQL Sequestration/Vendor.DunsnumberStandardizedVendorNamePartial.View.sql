USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumberStandardizedVendorNamePartial]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [Vendor].[DunsnumberStandardizedVendorNamePartial]
AS

Select 
	u.dunsnumber
	,u.fiscal_year
	,u.standardizedvendorname
	,sum(u.obligatedamount) as SumOfobligatedamount
	,sum(u.fed_funding_amount) as SumOffed_funding_amount
	,sum(u.TotalAmount) as TotalAmount
	from (SELECT 
		f.dunsnumber 
		,f.fiscal_year
		,VN.StandardizedVendorName
		, f.obligatedamount 
		, NULL as fed_funding_amount
		, f.obligatedamount AS TotalAmount
	FROM Contract.FPDS as f
	left outer join Vendor.VendorName as VN
		on f.vendorname=VN.vendorname
	--GROUP BY 
	--	f.dunsnumber
	--	,f.fiscal_year
	--	,VN.StandardizedVendorName
	UNION
	SELECT
		g.duns_no as dunsnumber
		,g.fiscal_year
		,VN.StandardizedVendorName
		, NULL AS obligatedamount
		, g.fed_funding_amount  
		, g.fed_funding_amount  AS TotalAmount
	FROM grantloanassistance.faads as g
	left outer join Vendor.VendorName as VN
		on g.recipient_name=VN.vendorname
	) u
	group by 
	u.dunsnumber
	,u.fiscal_year
	,u.standardizedvendorname



GO
