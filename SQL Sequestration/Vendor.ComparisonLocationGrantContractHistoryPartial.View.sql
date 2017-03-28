USE [DIIG]
GO
/****** Object:  View [Vendor].[ComparisonLocationGrantContractHistoryPartial]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




   CREATE VIEW [Vendor].[ComparisonLocationGrantContractHistoryPartial] as
 --USAID Greenbook Version
  
  SELECT       faads.fiscal_year
  ,'October to September Fiscal Year' as YearType
  , NULL as CSIStransactionID
  , faads.CSISfaadsTransactionID
  , iif(isnull(parentduns.UnknownCompany,1)=1
		, coalesce(parentname.parentid,parentduns.ParentID)
		, coalesce(parentduns.ParentID,parentname.parentid)) as parentid
  , iif(isnull(parentduns.UnknownCompany,1)=1
	,coalesce(parentname.parentid,faads.recipient_name)
	,parentduns.parentid) as partnername
, faads.duns_no as dunsnumber
, faads.recip_cat_type
, case
	when parentduns.UnknownCompany=1
	then coalesce(parentname.isforeign,parentduns.isforeign)
	when duns.overrideISO3countrycode=1
	then iif(duns.topISO3countrycode='USA',0,1)
	when parentduns.isoverrideISO3countrycode=1
	then iif(parentduns.topISO3countrycode='USA',0,1)
	when PartnerISo.isforeign is not null
	then PartnerISO.isforeign
	else coalesce(parentduns.isforeign,parentname.isforeign)
	end as isforeign
,partneriso.IsNotUSAIDforwardRecipient as partnerISOisNotUSAIDforwardRecipient-- Vendor from country that receives USAID funding
--,coalesce(forwardduns.Vendorname,forwardname.VendorName) as ForwardVendorName
, iif(forwardduns.Vendorname is not null 
	or vname.isUSAforwardLocalOrganization=1,1,NULL) as isUSAforwardLocalOrganization
,case
	when duns.overrideISO3countrycode=1
	then Duns.topISO3countrycode
	when parentduns.isoverrideISO3countrycode=1
	then parentduns.topISO3countrycode
	when parentname.isoverrideISO3countrycode=1
	then parentname.topISO3countrycode
	else isnull(PartnerISO.[alpha-3], faads.recipient_county_code) 
end as PartnerCountryISO3
,coalesce(placeiso.name, faads.principal_place_country_code,lcc.name ) as PlaceCountry 
,coalesce(placeiso.[USAID region],lcc.[usaid region],caid.topusaidregion) as PlaceUSAIDregion
, ia.customer as Implementer
, ia.subcustomer as SubImplementer
, faads.agency_code as  ImplementingAgencyID
, ia.AgencyIDtext as ImplementingAgencyText
, fa.customer as Funder
, fa.subcustomer as SubFunder
, fa.agencyid as FundingAgencyID
, fa.AgencyIDtext as FundingAgencyText
, faads.progsrc_agen_code as TreasuryAgencyCode 
,faads.progsrc_acnt_code as AccountCode
, account.AccountTitle
,account.IsOMBvsGreenbookContradiction
, faads.fed_funding_amount as Fed_Grant_Funding_Amount
, faads.non_fed_funding_amount as Non_Fed_Grant_Funding_Amount
, NULL AS ContractObligatedAmount
, faads.fed_funding_amount as TotalAmount

FROM GrantLoanAssistance.faads AS faads



inner join grantloanassistance.csisawardidmod caidm
on faads.csisawardidmod=caidm.csisawardidmod
inner join grantloanassistance.csisawardid caid
on caidm.federal_award_id=caid.federal_award_id
left outer join Location.CountryCodes lcc
on lcc.[alpha-3]=caid.topISO3countrycode

left outer join FPDSTypeTable.TreasuryAgencyCode as t
	on faads.progsrc_agen_code=t.TreasuryAgencyCode
left outer join budget.MainAccountCode as account
	on account.MainAccountCode=faads.progsrc_acnt_code  and
	account.TreasuryAgencyCode=faads.progsrc_agen_code

left outer join FPDSTypeTable.agencyid as ia
	on faads.agency_code=ia.AgencyID
left outer join FPDSTypeTable.agencyid as fa
	on coalesce(account.FundingAgencyID,t.agencyid,faads.agency_code)=fa.AgencyID

left outer join Contractor.DunsnumberToParentContractorHistory as dtpc
	on dtpc.DUNSnumber=faads.duns_no and dtpc.FiscalYear=faads.fiscal_year
left outer join Contractor.Dunsnumber as Duns
	on dtpc.DUNSnumber=duns.DUNSnumber
left outer join Contractor.ParentContractor as parentduns
	on dtpc.ParentID=parentduns.ParentID
left outer join Vendor.VendorName as vname
	on vname.vendorname=faads.recipient_name
left outer join Contractor.parentcontractor as parentname
	on parentname.parentid=vname.parentid
left outer join assistance.USAIDforwardLocalOrganization as forwardduns
	on forwardduns.parentid = parentduns.ParentID

LEFT JOIN FPDSTypeTable.Country3lettercode as PartnerCountryCode
	ON faads.recipient_country_code = PartnerCountryCode.Country3LetterCode
left outer join location.CountryCodes as PartnerISO
	on coalesce(PartnerCountryCode.isoalpha3 
		,duns.topISO3countrycode
		,parentduns.topISO3countrycode)= PartnerISO.[alpha-3]
LEFT JOIN FPDSTypeTable.Country3lettercode as PlaceCountryCode
	ON faads.principal_place_country_code = PartnerCountryCode.Country3LetterCode
left outer join location.CountryCodes as PlaceISO
	on PlaceCountryCode.isoAlpha3=placeiso.[alpha-3]


left outer join Vendor.VendorName as vendorname
	on vendorname.vendorname=faads.recipient_name



UNION 
SELECT   
	C.fiscal_year
  ,'October to September Fiscal Year' as YearType
  , c.CSIStransactionID
  , NULL as CSISfaadsTransactionID
	, iif(isnull(parentduns.UnknownCompany,1)=1
		, coalesce(parentname.parentid,parentduns.ParentID)
		, coalesce(parentduns.ParentID,parentname.parentid)) as parentid
  , iif(isnull(parentduns.UnknownCompany,1)=1
	,coalesce(parentname.parentid,c.vendorname)
	,parentduns.parentid) as partnername
, c.dunsnumber 
, c.organizationaltype as OrgType
, case
	when parentduns.UnknownCompany=1
	then coalesce(parentname.isforeign,parentduns.isforeign)
	when duns.overrideISO3countrycode=1
	then iif(duns.topISO3countrycode='USA',0,1)
	when parentduns.isoverrideISO3countrycode=1
	then iif(parentduns.topISO3countrycode='USA',0,1)
	when PartnerISO.isforeign is not null
	then PartnerISO.isforeign
	else coalesce(parentduns.isforeign,parentname.isforeign)
	end as isforeign


,partneriso.IsNotUSAIDforwardRecipient as partnerISOIsNotUSAIDforwardRecipient-- Vendor from country that receives USAID funding
--,coalesce(forwardduns.Vendorname,
--	vendorname.isUSAforwardLocalOrganization
--	,alternatevendorname.isUSAforwardLocalOrganization
--	,doingbusinessname.isUSAforwardLocalOrganization
--	,legalorganizationname.isUSAforwardLocalOrganization
--	,divisionname.isUSAforwardLocalOrganization
--) as ForwardVendorName

, iif(forwardduns.parentid is not null,1,
	coalesce(vendorname.isUSAforwardLocalOrganization
	,alternatevendorname.isUSAforwardLocalOrganization
	,doingbusinessname.isUSAforwardLocalOrganization
	,legalorganizationname.isUSAforwardLocalOrganization
	,divisionname.isUSAforwardLocalOrganization
)) as isUSAforwardLocalOrganization


,case
	when duns.overrideISO3countrycode=1
	then Duns.topISO3countrycode
	when parentduns.isoverrideISO3countrycode=1
	then parentduns.topISO3countrycode
	when parentname.isoverrideISO3countrycode=1
	then parentname.topISO3countrycode
	else isnull(PartnerISO.[alpha-3], c.vendorcountrycode) 
end as PartnerCountryISO3
,isnull(placeiso.name, c.placeofperformancecountrycode) as PlaceCountry 
,placeiso.[USAID region] as PlaceUSAIDregion
, CAgency.customer as Implementer
, CAgency.subcustomer as SubImplementer



	  ,CAgency.AgencyID  as ImplementingAgencyID
	,CAgency.AGENCYIDText as ImplementingAgencyText
	,COALESCE(FAgency.customer, CAgency.customer)  as Funder
,COALESCE(FAgency.subcustomer, CAgency.subcustomer) as SubFunder
	,COALESCE(FAgency.AgencyID, CAgency.AGENCYID) as FundingAgencyID
	,COALESCE(FAgency.AgencyIDText, CAgency.AGENCYIDText) as FundingAgencyText
	,c.progsourceagency as TreasuryAgencyCode
	,c.progsourceaccount as AccountCode
	,account.AccountTitle
	,account.IsOMBvsGreenbookContradiction
	, NULL as GrantObligations
	, NULL as  Non_Fed_Grant_Funding_Amount
	, c.obligatedamount AS ContractObligatedAmount
	, c.obligatedamount  as TotalAmount
FROM      
     Contract.FPDS AS C 
		LEFT OUTER JOIN FPDSTypeTable.AgencyID AS CAgency 
				ON C.contractingofficeagencyid = CAgency.AgencyID
		LEFT OUTER JOIN FPDSTypeTable.AgencyID AS FAgency
				ON C.fundingrequestingagencyid = FAgency.AgencyID 

		left outer join FPDSTypeTable.TreasuryAgencyCode as t
			on c.progsourceagency=t.TreasuryAgencyCode
		left outer join budget.MainAccountCode as account
			on account.MainAccountCode=c.progsourceaccount  and
			account.TreasuryAgencyCode=c.progsourceagency

		left outer join Contractor.DunsnumberToParentContractorHistory as dtpc
			on dtpc.DUNSnumber=c.dunsnumber and dtpc.FiscalYear=c.fiscal_year
		left outer join Contractor.Dunsnumber as Duns
			on dtpc.DUNSnumber=duns.DUNSnumber
		left outer join Contractor.ParentContractor as parentduns
			on dtpc.ParentID=parentduns.ParentID
		left outer join assistance.USAIDforwardLocalOrganization as forwardduns
			on forwardduns.parentid=parentduns.ParentID
	left outer join Vendor.VendorName as vname
		on vname.vendorname=c.vendorname
	left outer join Contractor.parentcontractor as parentname
		on parentname.parentid=vname.parentid
	--left outer join assistance.USAIDforwardLocalOrganization as forwardname
	--	on forwardname.parentid=parentname.ParentID


		LEFT JOIN FPDSTypeTable.vendorcountrycode as PartnerCountryCodePartial
			ON C.vendorcountrycode=PartnerCountryCodePartial.vendorcountrycode
		left outer join location.CountryCodes as PartnerISO
			on coalesce(PartnerCountryCodePartial.isoalpha3 
				,duns.topISO3countrycode
				,parentduns.topISO3countrycode)= PartnerISO.[alpha-3]
		LEFT JOIN FPDSTypeTable.Country3lettercode as PlaceCountryCode
			ON C.placeofperformancecountrycode=PlaceCountryCode.Country3LetterCode
		left outer join location.CountryCodes as PlaceISO
			on PlaceCountryCode.ISOcountryCode =placeiso.[alpha-2]


		left outer join Vendor.VendorName as vendorname
			on vendorname.vendorname=c.vendorname
		left outer join Vendor.VendorName as alternatevendorname
			on alternatevendorname.vendorname=c.vendoralternatename
		left outer join Vendor.VendorName as doingbusinessname
			on doingbusinessname.vendorname=c.vendordoingasbusinessname
		left outer join Vendor.VendorName as legalorganizationname
			on legalorganizationname.vendorname=c.vendorlegalorganizationname
		left outer join Vendor.VendorName as divisionname
			on divisionname.vendorname=c.divisionname
		left outer join Contractor.parentcontractor as parentvendorname
			on parentname.parentid=vendorname.parentid
		left outer join Contractor.parentcontractor as parentalternatevendorname
			on parentname.parentid=vendorname.parentid
		left outer join Contractor.parentcontractor as parentdoingbusinessname
			on parentname.parentid=doingbusinessname.parentid
		left outer join Contractor.parentcontractor as parentlegalorganizationname
			on parentname.parentid=legalorganizationname.parentid
		left outer join Contractor.parentcontractor as parentlegaldivisionname
			on parentname.parentid=divisionname.parentid











GO
