USE [DIIG]
GO
/****** Object:  View [Vendor].[AllVendorIsServiceHistorySubCustomerSystemEquipDirectDiscretization]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





















CREATE VIEW [Vendor].[AllVendorIsServiceHistorySubCustomerSystemEquipDirectDiscretization]
AS

SELECT C.Fiscal_year
, C.Customer
, C.SubCustomer
, C.systemequipmentcodeText
, C.AllVendor 
, C.ParentID
, c.IsService
, isnull(PCN.CSISName, C.AllVendor + '^')  as ContractorDisplayName
, rank() over (partition by fiscal_year, c.customer, c.subcustomer,isservice, C.UnknownCompany  order by SumOfobligatedAmount desc)  as ContractAnnualSubCustomerVendorRank
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
, S.systemequipmentcodeText
, Parent.jointventure
, iif(parent.parentid is null or
	parent.firstyear>c.fiscal_year or
	parent.mergeryear<=c.fiscal_year,1,0) as WarningFlag
, isnull(Parent.UnknownCompany,0) as UnknownCompany
, Parent.Top100Federal
, Sum(C.obligatedAmount) AS SumOfobligatedAmount
, Sum(C.numberOfActions) AS SumOfnumberOfActions
FROM (Contract.FPDS as C
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
		ON C.productorservicecode = PSC.ProductOrServiceCode 
		left outer join FPDSTypeTable.AgencyID AS Agency
		 ON C.contractingofficeagencyid = Agency.AgencyID 
       LEFT JOIN FPDSTypetable.systemequipmentcode as S
	   ON C.systemequipmentcode = S.systemequipmentcode
	   LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
              ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER) 
                     AND (C.fiscal_year=Dunsnumber.FiscalYear)) 
       LEFT JOIN Contractor.ParentContractor as Parent
              ON Dunsnumber.ParentID=Parent.ParentID

GROUP BY C.fiscal_year
, psc.IsService
, ISNULL(Agency.Customer, Agency.AGENCYIDText)
, Agency.SubCustomer
, S.systemequipmentcodeText
, Parent.jointventure
, iif(parent.parentid is null or
	parent.firstyear>c.fiscal_year or
	parent.mergeryear<=c.fiscal_year,1,0) 
, Parent.UnknownCompany
, Parent.Top100Federal
, isnull(parent.parentid,C.dunsnumber) 
, parent.parentid) as C
		LEFT JOIN Contractor.ParentContractorNameHistory as PCN
			ON C.ParentID = PCN.ParentID
			AND C.Fiscal_Year = PCN.FiscalYear

	

















GO
