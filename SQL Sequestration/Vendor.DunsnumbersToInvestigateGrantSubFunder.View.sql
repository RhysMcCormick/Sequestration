USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumbersToInvestigateGrantSubFunder]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Vendor].[DunsnumbersToInvestigateGrantSubFunder]
AS

SELECT
	case
		when (isnull(parent.LargeGreaterThan3B,0)=0 
			and isnull(parent.LargeGreaterThan1B,0)=0
			and parent.RevenueInMillions is null
			and isnull(parent.UnknownCompany,0)=0)
		then 'RevenueInMillions is null'
		when parent.MergerYear<=DtPCH.FiscalYear
		then 'ParentID is in use after parent.MergerYear'
		when (parent.FirstYear>DtPCH.FiscalYear and parent.SpunOffFrom is not null)
		then 'ParentID is in use before parent.firstyear and parent.spunofffrom is not null'
		else 'ERROR'
	end as ReasonForInclusion
	, ca.customer as ContractingComponent
	, ca.SubCustomer as ContractingSubComponent
	, fa.customer as FundingComponent
	, fa.SubCustomer as FundingSubcomponent
	,dtpch.fiscalyear
	, faads.fed_funding_amount/1000000000/def.GDPdeflator AS ConstantFedFundingBillions
	, dtpch.DUNSNumber
	, dtpch.StandardizedTopContractor
	, dtpch.parentid
	, parentduns.parentid as ParentDunsnumberParentIDsuggestion
	, parent.LargeGreaterThan3B
	, parent.LargeGreaterThan1B
	, parent.RevenueInMillions
	, parent.jointventure
	, parent.MergerYear
	, parent.MergerDate
	, parent.FirstYear
	, parent.SpunOffFrom
	,parent.isenterprise
			,parent.isfaithbased
			,parent.isgovernment
			,parent.ismultilateral
			,parent.isnetwork
			,parent.isngo
			,parent.ispublicprivatepartnership
			,parent.isUniversityorResearchInstitute

FROM grantloanassistance.faads as faads
	left outer join contractor.DunsnumberToParentContractorHistory as DtPCH 
	on faads.duns_no=dtpch.DUNSnumber and faads.fiscal_year=dtpch.FiscalYear
	LEFT Outer JOIN contractor.ParentContractor as Parent
	ON dtpch.Parentid = parent.parentid
	Left outer join Economic.Deflators as def
	on DtPCH.FiscalYear=def.Fiscal_Year
	left outer join contractor.DunsnumberToParentContractorHistory as Parentdtp
	on dtpch.parentdunsnumber=parentdtp.dunsnumber and dtpch.fiscalyear=Parentdtp.fiscalyear
	left outer join contractor.parentcontractor as Parentduns
	on parentdtp.parentid=parentduns.parentid
	left outer join FPDSTypeTable.TreasuryAgencyCode as t
		on faads.progsrc_agen_code=t.TreasuryAgencyCode
	left outer join budget.MainAccountCode as account
		on account.MainAccountCode=faads.progsrc_acnt_code  and
		account.TreasuryAgencyCode=faads.progsrc_agen_code
	left outer join FPDSTypeTable.agencyid as ca
		on faads.agency_code=ca.AgencyID
	left outer join FPDSTypeTable.agencyid as fa
		on coalesce(account.FundingAgencyID,t.agencyid,faads.agency_code)=fa.AgencyID

WHERE 
	(isnull(parent.LargeGreaterThan3B,0)=0 
	and isnull(parent.LargeGreaterThan1B,0)=0
	 and parent.RevenueInMillions is null
	 and isnull(parent.UnknownCompany,0)=0)
	 or parent.MergerYear<=DtPCH.FiscalYear
	 or parent.FirstYear>DtPCH.FiscalYear




















GO
