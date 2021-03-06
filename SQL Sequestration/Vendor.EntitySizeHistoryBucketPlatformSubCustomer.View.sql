USE [DIIG]
GO
/****** Object:  View [Vendor].[RoughUniqueEntityVendorSizeHistoryBucketSubCustomer]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Vendor].[RoughUniqueEntityVendorSizeHistoryBucketSubCustomer]
AS

SELECT C.Fiscal_year
	,RUE.RoughUniqueEntity 
	,RUE.AllContractor 
	,Parent.ParentID
	--,RUE.ContractorDisplayName
	, RUE.VendorSize
	--, RUE.MaxOfSmall
	, Parent.jointventure
	, iif(parent.parentid is null or
		parent.firstyear>c.fiscal_year or
		parent.mergeryear<=c.fiscal_year,1,0) as WarningFlag
	, Parent.UnknownCompany
	, Parent.Top100Federal
	, parent.LargeGreaterThan3B
	, parent.LargeGreaterThan1B
	, parent.Top6
	, psc.ServicesCategory
	, ISNULL(Agency.Customer, Agency.AGENCYIDText) as Customer
	, Agency.SubCustomer
	, psc.IsService
	, psc.Simple
	, C.obligatedAmount
	, C.numberOfActions
--, rank() over (partition by fiscal_year, c.servicescategory, c.customer order by SumOfobligatedAmount desc)  as ContractAnnualBucketCustomerVendorRank
--, (SELECT VendorIsRanked from vendor.[VendorIsRanked](
--			C.ServicesCategory --@ServiceCategory as varchar(255)
--			,0 --,@ServicesOnly as bit
--			,C.Customer --,@Customer as varchar(255)
--			,null --,@SubCustomer as varchar(255)
--			,C.SumOfobligatedAmount--,@SumOfobligatedAmount as decimal(19,4)
--			,C.UnknownCompany--,@UnknownCompany as bit
--			,C.Top100Federal--,@Top100Federal as bit

--			,PCN.CSISName--,@CSISname as nvarchar(255)
--			,C.allcontractor--,@AllContractor as varchar(255)
--		)) as VendorIsRanked
	
, (SELECT ClassifyMaxcontractSize from contractor.ClassifyMaxcontractSize(
		parent.LargeGreaterThan3B
		,rue.[MaxOfobligatedAmountMultiyear])) as ClassifyMaxcontractSize
	
	FROM Contract.FPDS as C
		LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
			ON C.productorservicecode = PSC.ProductOrServiceCode 
		LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
			ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER 
			AND C.fiscal_year=Dunsnumber.FiscalYear)
		LEFT JOIN Contractor.ParentContractor as Parent
			ON Dunsnumber.ParentID=Parent.ParentID
	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as ParentDUNS
		ON C.fiscal_year = ParentDUNS.FiscalYear AND C.parentdunsnumber = ParentDUNS.DUNSnumber
	LEFT OUTER JOIN Contractor.ParentContractor as PARENTsquared
		ON ParentDUNS.ParentID = PARENTsquared.ParentID
		left outer join FPDSTypeTable.AgencyID AS Agency
			ON C.contractingofficeagencyid = Agency.AgencyID 
	LEFT OUTER JOIN Vendor.RoughUniqueEntityHistory RUE
		on RUE.RoughUniqueEntity=	 CASE
	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	THEN Parent.ParentID 
	WHEN c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0 
	THEN c.parentdunsnumber
	WHEN c.dunsnumber is not null and isnull(Parent.UnknownCompany,0)=0 
	THEN c.dunsnumber
	ELSE coalesce(c.vendorname
		, c.vendorlegalorganizationname
		, c.vendordoingasbusinessname
		, c.vendoralternatename
		, c.divisionname
	)
	END 
	--GROUP BY C.Fiscal_year
	--,RUE.RoughUniqueEntity
	--,RUE.VendorSize
	--,RUE.AllContractor
	--, parent.parentid
	--, RUE.MaxOfSmall
	--, Parent.jointventure
	--, iif(parent.parentid is null or
	--	parent.firstyear>c.fiscal_year or
	--	parent.mergeryear<=c.fiscal_year,1,0)
	--, Parent.UnknownCompany
	--, Parent.Top100Federal
	--, parent.LargeGreaterThan3B
	--, parent.LargeGreaterThan1B
	--, parent.Top6
	--, psc.ServicesCategory
	--, ISNULL(Agency.Customer, Agency.AGENCYIDText)
	--, Agency.SubCustomer
	--, psc.IsService
	--, psc.Simple




GO
