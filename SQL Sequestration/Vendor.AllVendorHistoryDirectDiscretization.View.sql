USE [DIIG]
GO
/****** Object:  View [Vendor].[AllVendorHistoryDirectDiscretization]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [Vendor].[AllVendorHistoryDirectDiscretization]
AS

SELECT C.Fiscal_year
, C.AllVendor
, C.ParentID
, isnull(PCN.CSISName, C.allvendor + '^')  as ContractorDisplayName
, rank() over (partition by fiscal_year, C.UnknownCompany order by SumOfobligatedAmount desc)  as ContractAnnualVendorRank
, (SELECT VendorIsRanked from vendor.[VendorIsRanked](
			null --@ServiceCategory as varchar(255)
			,0 --,@ServicesOnly as bit
			,null --,@Customer as varchar(255)
			,null --,@SubCustomer as varchar(255)
			,C.SumOfobligatedAmount--,@SumOfobligatedAmount as decimal(19,4)
			,C.UnknownCompany--,@UnknownCompany as bit
			,C.Top100Federal--,@Top100Federal as bit

			,PCN.CSISName--,@CSISname as nvarchar(255)
			,C.allvendor--,@AllContractor as varchar(255)
		)) as VendorIsRanked
, C.Small
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
, Parent.jointventure
, iif(parent.parentid is null or
	parent.firstyear>c.fiscal_year or
	parent.mergeryear<=c.fiscal_year,1,0) as warningflag
, isnull(Parent.UnknownCompany,0) as UnknownCompany
, Parent.Top100Federal
, Sum(C.obligatedAmount) AS SumOfobligatedAmount
, Sum(C.numberOfActions) AS SumOfnumberOfActions
FROM (Contract.FPDS as C
       LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
              ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER) 
                     AND (C.fiscal_year=Dunsnumber.FiscalYear)) 
       LEFT JOIN Contractor.ParentContractor as Parent
              ON Dunsnumber.ParentID=Parent.ParentID
GROUP BY C.fiscal_year
, Parent.jointventure
, iif(parent.parentid is null or
	parent.firstyear>c.fiscal_year or
	parent.mergeryear<=c.fiscal_year,1,0) 
, Parent.UnknownCompany
, Parent.Top100Federal
, isnull(parent.parentid,C.dunsnumber) 
, parent.parentid
 ) as c
		LEFT JOIN Contractor.ParentContractorNameHistory as PCN
			ON C.ParentID = PCN.ParentID
			AND C.Fiscal_Year = PCN.FiscalYear;
	











GO
