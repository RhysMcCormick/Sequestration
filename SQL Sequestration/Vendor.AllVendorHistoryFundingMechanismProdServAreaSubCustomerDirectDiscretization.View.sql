USE [DIIG]
GO
/****** Object:  View [Vendor].[AllVendorHistoryFundingMechanismProdServAreaSubCustomerDirectDiscretization]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Vendor].[AllVendorHistoryFundingMechanismProdServAreaSubCustomerDirectDiscretization]
AS

SELECT C.Fiscal_year
, C.ParentID
, isnull(PCN.CSISName, C.allcontractor + '^')  as ContractorDisplayName
, C.ProductOrServiceArea
, C.Customer
, C.SubCustomer
, c.Simple
, C.contractfinancingtext
, C.typeofcontractpricingtext
, C.SumOfobligatedAmount
, C.SumOfnumberOfActions
FROM (--Subqueury
	SELECT C.Fiscal_year
	, isnull(parent.parentid,C.dunsnumber) AS AllContractor
	, parent.parentid
	, psc.ProductOrServiceArea
	, ISNULL(Agency.Customer, Agency.AGENCYIDText) as Customer
	, Agency.SubCustomer
	, psc.Simple
	,R.contractfinancingtext
	,F.typeofcontractpricingtext
	, Sum(C.obligatedAmount) AS SumOfobligatedAmount
	, Sum(C.numberOfActions) AS SumOfnumberOfActions
	FROM Contract.FPDS as C
		LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
			ON C.productorservicecode = PSC.ProductOrServiceCode 
		LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
			ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER 
			AND C.fiscal_year=Dunsnumber.FiscalYear)
		LEFT JOIN Contractor.ParentContractor as Parent
			ON Dunsnumber.ParentID=Parent.ParentID
		left outer join FPDSTypeTable.AgencyID AS Agency
			ON C.contractingofficeagencyid = Agency.AgencyID 
		LEFT OUTER JOIN FPDSTypeTable.contractfinancing AS R ON R.contractfinancing= C.Contractfinancing
		LEFT OUTER JOIN FPDSTypeTable.typeofcontractpricing AS F ON C.TypeofContractPricing = F.TypeofContractPricing
	GROUP BY C.fiscal_year
		, psc.ProductOrServiceArea
		, ISNULL(Agency.Customer, Agency.AGENCYIDText)
		, Agency.SubCustomer
		, psc.Simple
		, isnull(parent.parentid,C.dunsnumber) 
		, parent.parentid
		,R.contractfinancingtext
		,F.typeofcontractpricingtext
	) as C
	--End of the subquery
		LEFT JOIN Contractor.ParentContractorNameHistory as PCN
			ON C.ParentID = PCN.ParentID
			AND C.Fiscal_Year = PCN.FiscalYear;
	






















GO
