USE [DIIG]
GO
/****** Object:  View [Vendor].[VendorSizeFPDShistoryBucketCustomerProgramCountry]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [Vendor].[VendorSizeFPDShistoryBucketCustomerProgramCountry] 
AS
SELECT 
	C.fiscal_year
	,getDate() AS Query_Run
	,isnull(A.Customer,A.AgencyIDtext) AS Customer
	,CountryCode.Country3LetterCodeText
	,CountryCode.Region
	,isnull(P.ServicesCategory, 'Unlabeled') AS ServicesCategory
	,PSC.IsService
	,P.DoDportfolio
	,P.PlatformPortfolio
	,COALESCE (St.StateCOCOM, COCOM.Country_COCOM) as COCOM
	,claim.ClaimantProgramCodeText
	, CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 6 JV'
		WHEN Parent.Top6=1
		THEN 'Large: Big 6'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 6'
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
	,C.obligatedamount
	,C.numberofactions 
	,unique_transaction_id
	,idvpiid
	,piid
	,IIf(Left(P.productorservicecode,1)='Q'
   Or Left(P.productorservicecode,1)='Y',
   'Other Service','Professional Service')
    AS Legacy
   ,A.SubCustomer
FROM Contract.FPDS AS C
	LEFT OUTER JOIN FPDSTypeTable.StateCOCOM as St 
		ON St.StateCode = C.pop_state_code
	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS A
		ON (C.contractingofficeagencyid=A.AgencyID)
	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS P
		ON (C.productorservicecode=P.ProductOrServiceCode)
	LEFT OUTER JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)
	LEFT OUTER JOIN FPDSTypeTable.Country3lettercode as CountryCode
		ON (C.placeofperformancecountrycode=CountryCode.Country3LetterCode)
	LEFT OUTER JOIN ProductOrServiceCode.ServicesCategory As PSC
		ON (PSC.ServicesCategory = P.ServicesCategory)
	left OUTER join FPDSTypeTable.ClaimantProgramCode as Claim
		on claim.ClaimantProgramCode=c.claimantprogramcode
	LEFT OUTER JOIN FPDSTypeTable.Country3LetterCode AS CountryCodeS 
		ON C.placeofperformancecountrycode = CountryCode.Country3LetterCode
	LEFT OUTER JOIN FPDSTypeTable.COCOMLabeling AS COCOM ON COCOM.Country = CountryCode.Country3LetterCodeText





GO
