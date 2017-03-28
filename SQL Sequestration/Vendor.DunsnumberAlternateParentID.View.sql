USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumberAlternateParentID]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [Vendor].[DunsnumberAlternateParentID]
AS

Select 
	d.[DUNSnumber]
      ,d.[FiscalYear]
      ,d.[ParentID]
	  ,d.[StandardizedTopContractor]
	  ,d.TopVendorNameTotalAmount
	  ,vn.parentid as VendorNameParentID
	  ,d.[ObligatedAmount]
	  ,d.fed_funding_amount
	  ,d.TotalAmount
      ,d.[Notes]
      ,d.[TooHard]
      ,d.[NotableSubdivision]
      ,d.[SubdivisionName]
      ,d.[Parentdunsnumber]
	  ,pduns.ParentID as ParentDunsnumberParentID
	  ,d.HeadquarterCode
	  ,hq.ParentID as HeadquarterCodeParentID
	  ,d.CAGE
	  ,d.topISO3countrycode
	  ,l.name as TopCountryName
	  ,d.topISO3countrytotalamount
	from contractor.DunsnumberToParentContractorHistory as D
	left outer join Location.CountryCodes l
	on l.[alpha-3]=d.topISO3countrycode
	left outer join contractor.DunsnumberToParentContractorHistory as PDuns
	on PDuns.DUNSnumber=d.Parentdunsnumber and pduns.FiscalYear = d.FiscalYear
	left outer join contractor.DunsnumberToParentContractorHistory as HQ
	on HQ.DUNSnumber=d.HeadquarterCode and HQ.FiscalYear = d.FiscalYear
		left outer join Vendor.vendorname as VN
	on d.StandardizedTopContractor=vn.vendorname



GO
