USE [DIIG]
GO
/****** Object:  View [Vendor].[AllVendorHistorySubCustomerRegimeDirectDiscretization]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





















CREATE VIEW [Vendor].[AllVendorHistorySubCustomerRegimeDirectDiscretization]
AS

SELECT C.Fiscal_year
, C.Customer
, C.SubCustomer
, C.AllVendor 
, C.ParentID
, isnull(PCN.CSISName, C.AllVendor + '^')  as ContractorDisplayName
, rank() over (partition by fiscal_year, c.customer
	, c.subcustomer,isservice, C.UnknownCompany  order by SumOfobligatedAmount desc)  as ContractAnnualSubCustomerRegimeVendorRank
, (SELECT VendorIsRanked from vendor.[VendorIsRanked](
			null --@ServiceCategory as varchar(255)
			,1 --,@ServicesOnly as bit
			,C.Customer --,@Customer as varchar(255)
			,C.SubCustomer --,@SubCustomer as varchar(255)
			,C.SumOfobligatedAmount--,@SumOfobligatedAmount as decimal(19,4)
			,C.UnknownCompany--,@UnknownCompany as bit
			,C.Top100Federal--,@Top100Federal as bit

			,PCN.CSISName--,@CSISname as nvarchar(255)
			,C.AllVendor--,@AllContractor as varchar(255)
		)) as VendorIsRanked, C.Small
, C.jointventure
, C.WarningFlag
, C.UnknownCompany
, C.Top100Federal
, C.SumOfobligatedAmount
, C.SumOfnumberOfActions
	,c.USDATL
		,c.ITFsmallBusiness
	,c.BBP1
	,c.WSARAreg
	,c.BBP2
	,c.BBP3
FROM (
SELECT C.Fiscal_year
, isnull(parent.parentid,C.dunsnumber) AS AllVendor 
, parent.parentid
, Max(IIf(C.contractingofficerbusinesssizedetermination='S' 
       And Not (parent.largegreaterthan3B=1 Or parent.Largegreaterthan3B=1)
       ,1
       ,0)) AS Small
, psc.IsService
, ISNULL(Agency.Customer, Agency.AGENCYIDText) as Customer
, Agency.SubCustomer
, Parent.jointventure
, iif(parent.parentid is null or
	parent.firstyear>c.fiscal_year or
	parent.mergeryear<=c.fiscal_year,1,0) as WarningFlag
, isnull(Parent.UnknownCompany,0) as UnknownCompany
, Parent.Top100Federal
	,atl.USDATL
		,atl.ITFsmallBusiness
	,atl.BBP1
	,atl.WSARAreg
	,atl.BBP2
	,atl.BBP3
, Sum(C.obligatedAmount) AS SumOfobligatedAmount
, Sum(C.numberOfActions) AS SumOfnumberOfActions
FROM (Contract.FPDS as C
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
		ON C.productorservicecode = PSC.ProductOrServiceCode 
		left outer join FPDSTypeTable.AgencyID AS Agency
		 ON C.contractingofficeagencyid = Agency.AgencyID 
       LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
              ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER) 
                     AND (C.fiscal_year=Dunsnumber.FiscalYear)) 
       LEFT JOIN Contractor.ParentContractor as Parent
              ON Dunsnumber.ParentID=Parent.ParentID
		left join contract.CSIStransactionID ctid
	on c.CSIStransactionID=ctid.CSIStransactionID
left join Agency.ContractATLregime atl
	on ctid.CSIScontractID=atl.CSIScontractID

GROUP BY C.fiscal_year
, psc.IsService
, ISNULL(Agency.Customer, Agency.AGENCYIDText)
, Agency.SubCustomer
, Parent.jointventure
, iif(parent.parentid is null or
	parent.firstyear>c.fiscal_year or
	parent.mergeryear<=c.fiscal_year,1,0) 
, Parent.UnknownCompany
, Parent.Top100Federal
, isnull(parent.parentid,C.dunsnumber) 
, parent.parentid
	,atl.USDATL
		,atl.ITFsmallBusiness
	,atl.BBP1
	,atl.WSARAreg
	,atl.BBP2
	,atl.BBP3) as C

		LEFT JOIN Contractor.ParentContractorNameHistory as PCN
			ON C.ParentID = PCN.ParentID
			AND C.Fiscal_Year = PCN.FiscalYear

	

















GO
