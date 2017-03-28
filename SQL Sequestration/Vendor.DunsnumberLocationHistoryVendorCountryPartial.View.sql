USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumberLocationHistoryVendorCountryPartial]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [Vendor].[DunsnumberLocationHistoryVendorCountryPartial]
AS

Select 
	u.dunsnumber
	,u.fiscal_year
	,u.topISO3countrycode
	,sum(u.obligatedamount) as SumOfobligatedamount
	,sum(u.fed_funding_amount) as SumOffed_funding_amount
	,sum(u.TotalAmount) as TotalAmount
	from (SELECT 
			f.dunsnumber 
			,f.fiscal_year
			,PartnerISO.[alpha-3] as topISO3countrycode
			, f.obligatedamount 
			, NULL as fed_funding_amount
			, f.obligatedamount AS TotalAmount
		FROM Contract.FPDS as f
		LEFT JOIN FPDSTypeTable.vendorcountrycode as PartnerCountryCodePartial
			ON f.vendorcountrycode=PartnerCountryCodePartial.vendorcountrycode
		left outer join location.CountryCodes as PartnerISO
			on PartnerCountryCodePartial.isoalpha3 = PartnerISO.[alpha-3]
	--GROUP BY 
	--	f.dunsnumber
	--	,f.fiscal_year
	--	,VN.StandardizedVendorName
		UNION
		SELECT
			g.duns_no as dunsnumber
			,g.fiscal_year
			,PartnerISO.[alpha-3] as topISO3countrycode
			, NULL AS obligatedamount
			, g.fed_funding_amount  
			, g.fed_funding_amount  AS TotalAmount
		FROM grantloanassistance.faads as g
		LEFT JOIN FPDSTypeTable.Country3lettercode as PartnerCountryCode
			ON g.recipient_country_code = PartnerCountryCode.Country3LetterCode
		left outer join location.CountryCodes as PartnerISO
			on PartnerCountryCode.ISOcountryCode = PartnerISO.[alpha-2]

	) u
	group by 
	u.dunsnumber
	,u.fiscal_year
	,u.topISO3countrycode



GO
