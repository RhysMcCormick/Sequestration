USE [DIIG]
GO
/****** Object:  View [Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER View [Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]
as 

  select c.fiscal_year
  ,A.Customer 
  ,A.SubCustomer 
  ,psc.ProductOrServiceArea
 ,psc.Simple
 ,coalesce(claim.PlatformPortfolio,psc.PlatformPortfolio) as PlatformPortfolio
 ,0 as IsSubContract
 , CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 5 JV'
		WHEN Parent.Top6=1
		THEN 'Large: Big 5'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 5'
		WHEN Parent.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN Parent.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		THEN 'Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		ELSE 'Medium <1B'
	END AS VendorSize	
  ,c.obligatedamount as PrimeObligatedAmount
  ,c.numberofactions as PrimeNumberOfActions
  ,NULL as SubawardAmount
  ,c.obligatedamount as PrimeOrSubObligatedAmount
 ,t.CSIScontractID
  ,iif(p.CSIScontractID is not null, 1,0) as IsInFSRS
  from contract.FPDS c
  inner join contract.CSIStransactionID t
  on t.CSIStransactionID = c.CSIStransactionID
  left outer join contract.ContractFSRSprimeHistory p
  on t.CSIScontractID=  p.CSIScontractID
  and c.fiscal_year=p.PrimeAwardDateSignedFiscalYear
  	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS A
		ON (C.contractingofficeagencyid=A.AgencyID)
	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
		ON (C.productorservicecode=PSC.ProductOrServiceCode)
	left OUTER join FPDSTypeTable.ClaimantProgramCode as Claim
		on claim.ClaimantProgramCode=c.claimantprogramcode
	--Vendor
	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT OUTER JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)

UNION ALL
  select 
  s.SubawardFiscalYear
  ,A.Customer 
  ,A.SubCustomer 
  ,plat.ProductOrServiceArea
  ,plat.SimpleArea
  ,[PlatformPortfolio]
  ,1 as IsSubContract
 ,NULL as VendorSize--  , CASE
	--	WHEN Parent.Top6=1 and Parent.JointVenture=1
	--	THEN 'Large: Big 5 JV'
	--	WHEN Parent.Top6=1
	--	THEN 'Large: Big 5'
	--	WHEN Parent.IsPreTop6=1
	--	THEN 'Large: Pre-Big 5'
	--	WHEN Parent.LargeGreaterThan3B=1
	--	THEN 'Large'
	--	WHEN Parent.LargeGreaterThan1B=1
	--	THEN 'Medium >1B'
	--	WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
	--	THEN 'Small'
	--	when Parent.UnknownCompany=1
	--	Then 'Unlabeled'
	--	ELSE 'Medium <1B'
	--END AS VendorSize	
,NULL -- ,c.obligatedamount as PrimeObligatedAmount
,NULL -- ,c.numberofactions as PrimeNumberOfActions
,s.SubawardAmount 
,s.SubawardAmount  as PrimeOrSubObligatedAmount
,u.CSIScontractID
--,NULL --,p.CSIScontractID
  ,1 as IsInFSRS
  from contract.FSRS s
    inner join Contract.PrimeAwardReportID u
  on s.PrimeAwardReportID = u.PrimeAwardReportID
	left outer join [Contract].[ContractPlatformBucket] plat
  on u.CSIScontractID=plat.CSIScontractID
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS A
		ON (s.PrimeAwardContractingAgencyID=A.AgencyID)
	--Vendor
	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (s.SubawardeeDunsnumber=PCH.Dunsnumber)
		AND (s.SubawardFiscalYear=PCH.FiscalYear)
	LEFT OUTER JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)
GO
