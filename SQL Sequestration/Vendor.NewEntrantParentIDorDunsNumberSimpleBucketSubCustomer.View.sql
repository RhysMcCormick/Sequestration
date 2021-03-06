USE [DIIG]
GO
/****** Object:  View [Vendor].[NewEntrantParentIDorDunsNumberSimpleBucketSubCustomer]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Vendor].[NewEntrantParentIDorDunsNumberSimpleBucketSubCustomer]
AS

SELECT 
F.fiscal_year
,isnull(DUNS.ParentID,F.dunsnumber) as ParentIDorDunsNumber
,F.dunsnumber
,DUNS.ParentID
,A.Customer
,A.SubCustomer
,PSC.ProductOrServiceArea
,PSC.Simple
,PSC.RnD_BudgetActivity
,F.obligatedamount
, CASE
	WHEN parent.Top6=1 and parent.JointVenture=1
	THEN 'Large: Big 5 JV'
	WHEN parent.Top6=1
	THEN 'Large: Big 5'
	WHEN parent.LargeGreaterThan3B=1
	THEN 'Large'
	WHEN Parent.IsPreTop6=1
	THEN 'Large: Pre-Big 5'
	WHEN duns.AlwaysIsSmall=1
	THEN 'Always Small'
	WHEN duns.AlwaysIsSmall=0 and duns.AnyIsSmall=1
	THEN 'Sometimes Small'
	when parent.UnknownCompany=1
	Then 'Unlabeled'
	ELSE 'Medium'
END AS VendorSize
,iif(duns.ParentID is null,
	iif(NEduns.MinOfFiscal_Year=F.Fiscal_Year , 1,0),
	iif(NEparentID.MinOfFiscal_Year=F.Fiscal_Year, 1,0)) as FirstFYinDataset
,iif(duns.ParentID is null,
	iif(NEduns.MinOfFiscal_Year=F.Fiscal_Year , NEduns.MaxOfObligatedAmount,NULL),
	iif(NEparentID.MinOfFiscal_Year=F.Fiscal_Year, NEparentID.MaxOfObligatedAmount,NULL)) as MaxParentIDorDunsNumberTransaction

	

FROM Contract.fpds AS F
LEFT JOIN FPDSTypeTable.AgencyID AS A
ON A.AgencyID = F.contractingofficeagencyid
LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
ON PSC.ProductOrServiceCode = F.productorservicecode
LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS DUNS
ON DUNS.DUNSnumber = F.dunsnumber AND DUNS.FiscalYear = F.fiscal_year
left outer join contractor.ParentContractor as parent
on DUNS.ParentID=parent.ParentID
left outer join (
	SELECT 
	F.dunsnumber
	--,DUNS.ParentID
	,min(F.fiscal_year) as MinOfFiscal_Year
	,A.Customer
	,A.SubCustomer
	--,PSC.ProductOrServiceArea
	,PSC.Simple
	--,PSC.RnD_BudgetActivity
	,sum(F.obligatedamount) as SumOfObligatedAmount
	,max(F.obligatedamount) as MaxOfObligatedAmount
	FROM Contract.fpds AS F
	LEFT JOIN FPDSTypeTable.AgencyID AS A
	ON A.AgencyID = F.contractingofficeagencyid
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
	ON PSC.ProductOrServiceCode = F.productorservicecode
	LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS DUNS
	ON DUNS.DUNSnumber = F.dunsnumber AND DUNS.FiscalYear = F.fiscal_year
	LEFT OUTER JOIN Economic.Deflators AS D
	ON D.Fiscal_Year = F.fiscal_year
	where F.obligatedamount/D.GDPdeflator >=3500
	and ParentID is null
	GROUP BY
	F.dunsnumber
	--,DUNS.ParentID
	,A.Customer
	,A.SubCustomer
	--,PSC.ProductOrServiceArea
	,PSC.Simple
	--,PSC.RnD_BudgetActivity

) as NEduns
on  f.dunsnumber=NEduns.DunsNumber
and A.Customer=NEduns.Customer
and A.SubCustomer = NEduns.SubCustomer
and PSC.Simple = NEduns.Simple
and duns.ParentID is null
--and PSC.ProductOrServiceArea = NEduns.ProductOrServiceArea
--and PSC.RnD_BudgetActivity = NEduns.RnD_BudgetActivity


left outer join (SELECT 
	--fiscal_year,
	DUNS.ParentID
	,min(F.fiscal_year) as MinOfFiscal_Year
	,A.Customer
	,A.SubCustomer
	,PSC.Simple
	,sum(F.obligatedamount) as SumOfObligatedAmount
	,max(F.obligatedamount) as MaxOfObligatedAmount

	FROM Contract.fpds AS F
	LEFT JOIN FPDSTypeTable.AgencyID AS A
	ON A.AgencyID = F.contractingofficeagencyid
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
	ON PSC.ProductOrServiceCode = F.productorservicecode
	LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS DUNS
	ON DUNS.DUNSnumber = F.dunsnumber AND DUNS.FiscalYear = F.fiscal_year
	LEFT OUTER JOIN Economic.Deflators AS D
	ON D.Fiscal_Year = F.fiscal_year

	where F.obligatedamount/D.GDPdeflator >=3500

	GROUP BY
	--F.fiscal_year,
	DUNS.ParentID
	,A.Customer
	,A.SubCustomer
	,PSC.Simple
	--,D.GDPdeflator
	) NEparentID
on DUNS.ParentID=NEparentID.ParentID
and A.Customer=NEparentID.Customer
and A.SubCustomer = NEparentID.SubCustomer
and PSC.Simple= NEparentID.Simple
--and PSC.ProductOrServiceArea = NEparentID.ProductOrServiceArea
--and PSC.RnD_BudgetActivity = NEparentID.RnD_BudgetActivity



--GROUP BY
--F.fiscal_year
--,F.dunsnumber
--,DUNS.ParentID
--,A.Customer
--,A.SubCustomer
--,PSC.ProductOrServiceArea
--,PSC.Simple
--,PSC.RnD_BudgetActivity
--,iif(duns.ParentID is null,NEduns.FirstYear,NEparentID.FirstYear)
--,isnull(DUNS.ParentID,F.dunsnumber)





GO
