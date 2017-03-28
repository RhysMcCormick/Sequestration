USE [DIIG]
GO
/****** Object:  View [Vendor].[ComparisonLocationGrantContractHistory]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





   CREATE VIEW [Vendor].[ComparisonLocationGrantContractHistory] as
 --USAID Greenbook Version
  
  
SELECT        
	C.fiscal_year
	,c.YearType
	,c.csistransactionid
	,c.csisfaadstransactionid
	,c.parentid
  , c.partnername
, c.dunsnumber 
, c.isforeign
, case
	when c.isforeign=0 and 
		isnull(c.isUSAforwardLocalOrganization,0)=0-- Known U.S. vendor
	then 'U.S. Partner'
	when partneriso.name=c.PlaceCountry  
		and c.isUSAforwardLocalOrganization=1
		and c.isforeign=1 -- Place of performance and vendor match and USAID forward
	then 'Confident USAID forward'
	when fcountry.parentid is not null --Matches to USAIDforward in same country
		--isUSAforwardLocalOrganization=1--USAforwardLocalOrganization
		--and c.partnerISOIsNotUSAIDforwardRecipient=0
		then 'Confident USAID forward'
	when c.isforeign=1 
		and c.partnerISOIsNotUSAIDforwardRecipient=1 -- Vendor from country that does not receive USAID funding
	then NULL --Should exclude on the basis of parent
	when partneriso.name=c.PlaceCountry  
		and c.isforeign=1 -- Place of performance and vendor match
	then 'Probable USAID forward'
	when fregion.parentid is not null
		--c.isforeign=1
		--and isUSAforwardLocalOrganization=1--USAforwardLocalOrganization
		and c.partnerISOIsNotUSAIDforwardRecipient=0
		then 'Probable USAID forward'
	when partneriso.[USAID region]=c.PlaceUSAIDregion
		and c.isforeign=1 -- Place of performance and vendor match
	then 'Possible USAID forward'
	when c.isforeign=1
		and c.PlaceUSAIDregion is null
		and c.partnerISOIsNotUSAIDforwardRecipient=0-- Lack place information for vendor (because of FAADS error)
	then 'Possible USAID forward'
	--when c.isforeign=1 
	--	and c.partnerISOIsNotUSAIDforwardRecipient=0 -- Vendor from country that receives USAID funding
	--then 'Possible USAID forward'
	when isUSAforwardLocalOrganization=1--USAforwardLocalOrganization
	then 'Possible USAID forward'
	when isnull(c.isforeign,1)=1 
		and PlaceUSAIDregion is null
		and c.partnerISOIsNotUSAIDforwardRecipient is null--parent vendor classified (typically undisclosed) with unclear nationality
	then 'Unlabeled Foreign Vendor'
	else NULL --Leave unlabeled
end as USAIDforwardPartnerType
, c.isUSAforwardLocalOrganization
, parent.isinternationalNGO
, parent.isenterprise
, parent.isngo
, parent.isfaithbased
, parent.isgovernment
, parent.isUniversityorResearchInstitute
, parent.ismultilateral
, parent.ispublicprivatepartnership
, parent.isnetwork 
, parent.UnknownCompany
,CASE
	WHEN parent.isenterprise=1
	THEN 'Enterprise'
	WHEN parent.isngo =1
	THEN 'NGO'
	WHEN parent.isfaithbased=1
	THEN 'Faithbased'
	WHEN parent.isgovernment=1
	THEN 'Government'
	WHEN parent.isUniversityorResearchInstitute=1
	THEN 'University or Research Institute'
	WHEN parent.ismultilateral=1
	THEN 'Multilateral'
	WHEN parent.ispublicprivatepartnership=1
	THEN 'Public-Private Partnership'
	WHEN parent.isnetwork=1
	THEN 'Network'
	when parent.isnonprofit=1
	then 'Non Profit'
	WHEN parent.UnknownCompany=1
	THEN 'Unknown Partner'
	ELSE NULL
END as PartnerType
,CASE
	WHEN parent.isenterprise=1
	THEN 'For Profit'
	WHEN parent.isngo =1
	THEN 'Non Profit'
	WHEN parent.isfaithbased=1
	THEN 'Non Profit'
	WHEN parent.isgovernment=1
	THEN 'Government'
	WHEN parent.isUniversityorResearchInstitute=1
	THEN 'Educ Inst'
	WHEN parent.ismultilateral=1
	THEN 'Non Profit'
	when parent.isnonprofit=1
	then 'Non Profit'
	WHEN parent.ispublicprivatepartnership=1
	THEN 'Non Profit' --'Public-Private Partnership' Double check this
	WHEN parent.isnetwork=1
	THEN 'Non Profit' --'Network' Double check this
	WHEN parent.UnknownCompany=1
	THEN NULL --'Unknown Partner'
	ELSE NULL
END as VendorCategory 
  
, partneriso.name as partnercountry
, c.partnerISOisNotUSAIDforwardRecipient
, partneriso.[USAID region] as PartnerUSAIDregion
,c.PlaceCountry 
,c.PlaceUSAIDregion
,c.Implementer
,c.subimplementer
	  ,c.ImplementingAgencyID
	,c.ImplementingAgencyText
	,c.funder
	,c.subfunder
	,c.FundingAgencyID
	,c.FundingAgencyText
	,c.TreasuryAgencyCode
	,c.AccountCode
	,c.AccountTitle
	,iif(c.fundingagencytext ='Agency for International Development' or
		AccountTitle='Global Health Programs',1,0) as IsUSAIDfundedOrGlobalHealth

	,c.IsOMBvsGreenbookContradiction
	, c.Fed_Grant_Funding_Amount
	, c.ContractObligatedAmount
	, c.TotalAmount
FROM      
     vendor.ComparisonLocationGrantContractHistoryPartial as c
	 left outer join Contractor.ParentContractor as parent
		on c.ParentID=parent.ParentID



	--	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS CAgency 
	--			ON C.contractingofficeagencyid = CAgency.AgencyID
	--	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS FAgency
	--			ON C.fundingrequestingagencyid = FAgency.AgencyID 

	--	left outer join FPDSTypeTable.TreasuryAgencyCode as t
	--		on c.progsourceagency=t.TreasuryAgencyCode
	--	left outer join budget.FundingAccount as account
	--		on account.AccountCode=c.progsourceaccount  and
	--		account.TreasuryAgencyCode=c.progsourceagency

	--	left outer join Contractor.DunsnumberToParentContractorHistory as dtpc
	--		on dtpc.DUNSnumber=c.dunsnumber and dtpc.FiscalYear=c.fiscal_year
	--	left outer join Contractor.Dunsnumber as Duns
	--		on dtpc.DUNSnumber=duns.DUNSnumber

	--	left outer join assistance.USAIDforwardLocalOrganization as forward
	--		on forward.parentid=parentduns.ParentID
	--left outer join Vendor.VendorName as vname
	--	on vname.vendorname=c.vendorname
	--left outer join Contractor.parentcontractor as parentname
	--	on parentname.parentid=vname.parentid


	--	LEFT JOIN FPDSTypeTable.vendorcountrycode as PartnerCountryCodePartial
	--		ON C.vendorcountrycode=PartnerCountryCodePartial.vendorcountrycode
		left outer join location.CountryCodes as PartnerISO
			on PartnerCountryISO3 = PartnerISO.[alpha-3]


		left outer join 
		(select f.parentid
		,v.ISOalpha3
		from Assistance.USAIDforwardLocalOrganization f
		inner join FPDSTypeTable.vendorcountrycode v
		on v.vendorcountrycode=f.Country
		group by f.parentid
		,v.ISOalpha3
		) fcountry
		 on fcountry.ISOalpha3=c.PartnerCountryISO3 and
		 fcountry.parentid=c.parentid
	left outer join 
		(select f.parentid
		,l.[USAID region]
		from Assistance.USAIDforwardLocalOrganization f
		inner join FPDSTypeTable.vendorcountrycode v
		on v.vendorcountrycode=f.Country
		inner join location.CountryCodes l
		on v.ISOalpha3=l.[alpha-3]
		group by f.parentid
		,l.[USAID region]) fregion
		 on fregion.[usaid region]=partneriso.[USAID region]
		 and fregion.parentid=c.parentid
	--	LEFT JOIN FPDSTypeTable.Country3lettercode as PlaceCountryCode
	--		ON C.placeofperformancecountrycode=PlaceCountryCode.Country3LetterCode
	--	left outer join location.CountryCodes as PlaceISO
	--		on PlaceCountryCode.ISOcountryCode =placeiso.[alpha-2]


	--	left outer join Vendor.VendorName as vendorname
	--		on vendorname.vendorname=c.vendorname
	--	left outer join Vendor.VendorName as alternatevendorname
	--		on alternatevendorname.vendorname=c.vendoralternatename
	--	left outer join Vendor.VendorName as doingbusinessname
	--		on doingbusinessname.vendorname=c.vendordoingasbusinessname
	--	left outer join Vendor.VendorName as legalorganizationname
	--		on legalorganizationname.vendorname=c.vendorlegalorganizationname
	--	left outer join Vendor.VendorName as divisionname
	--		on divisionname.vendorname=c.divisionname

















GO
