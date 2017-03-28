USE [DIIG]
GO
/****** Object:  View [Vendor].[AllVendorIsServiceHistoryDiscretization]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [Vendor].[AllVendorIsServiceHistoryDiscretization]
AS

SELECT C.Fiscal_year
, C.AllVendor
, isnull(PCN.CSISName, C.AllVendor + '^')  as ContractorDisplayName
, rank() over (partition by fiscal_year, isservice order by SumOfobligatedAmount desc)  as ContractAnnualVendorRank
, (SELECT VendorIsRanked from vendor.[VendorIsRanked](
			null --@ServiceCategory as varchar(255)
			,1 --,@ServicesOnly as bit
			,null --,@Customer as varchar(255)
			,null --,@SubCustomer as varchar(255)
			,C.SumOfobligatedAmount--,@SumOfobligatedAmount as decimal(19,4)
			,C.UnknownCompany--,@UnknownCompany as bit
			,C.Top100Federal--,@Top100Federal as bit

			,PCN.CSISName--,@CSISname as nvarchar(255)
			,C.AllVendor--,@AllContractor as varchar(255)
		)) as VendorIsRanked
, CASE
	WHEN C.Top6=1 and C.JointVenture=1
	THEN 'Large: Big 6 JV'
	WHEN C.Top6=1
	THEN 'Large: Big 6'
	WHEN C.LargeGreaterThan3B=1
	THEN 'Large'
	WHEN C.LargeGreaterThan1B=1
	THEN 'Medium >1B'
	WHEN C.MaxOfSmall=1
	THEN 'Small'
	when c.UnknownCompany=1
	Then 'Unlabeled'
	ELSE 'Medium <1B'
END AS VendorSize
, (SELECT ClassifyMaxcontractSize from contractor.ClassifyMaxcontractSize(
		c.LargeGreaterThan3B
		,c.MaxofSumofObligatedAmount)) as ClassifyMaxcontractSize
, C.jointventure

, C.UnknownCompany
, C.Top100Federal
, C.SumOfobligatedAmount
, C.SumOfnumberOfActions
, c.isservice
FROM (
SELECT        fiscal_year
, AllVendor
, C.isservice
, C.jointventure
, C.UnknownCompany
, C.Top100Federal
, C.LargeGreaterThan3B
, C.LargeGreaterThan1B
, C.Top6
, Max(c.small) as MaxOfSmall
, MAX(SumOfobligatedAmount) AS MaxOfSumOfobligatedAmount
, SUM(SumOfobligatedAmount) AS SumOfobligatedAmount
, SUM(SumOfnumberOfActions) AS SumOfnumberOfActions


FROM            Contract.AllVendorIDVPIIDHistoryBucketCustomerPartial AS C



GROUP BY fiscal_year
,AllVendor
, C.isservice
, C.jointventure
, C.UnknownCompany
, C.Top100Federal
, C.LargeGreaterThan3B
, C.LargeGreaterThan1B
, C.Top6


) as C
		LEFT JOIN Contractor.ParentContractorNameHistory as PCN
			ON C.AllVendor = PCN.ParentID
			AND C.Fiscal_Year = PCN.FiscalYear;
	















GO
