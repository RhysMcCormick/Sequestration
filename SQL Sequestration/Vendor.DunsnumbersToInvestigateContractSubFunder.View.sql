USE [DIIG]
GO
/****** Object:  View [Vendor].[DunsnumbersToInvestigateContractSubFunder]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
























CREATE VIEW [Vendor].[DunsnumbersToInvestigateContractSubFunder]
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
	, ISNULL(CAgency.Customer, CAgency.AgencyIDtext) AS ContractingComponent
	, CAgency.SubCustomer as ContractingSubComponent
	, COALESCE(FAgency.Customer, FAgency.AgencyIDText, CAgency.Customer, CAgency.AGENCYIDText) as FundingComponent
	, COALESCE(FAgency.SubCustomer, FAgency.AgencyIDText, CAgency.SubCustomer, CAgency.AGENCYIDText) as FundingSubComponent
	,dtpch.fiscalyear
	, c.obligatedAmount/1000000000/def.GDPdeflator AS ConstantObligatedBillions
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
	,parent.isngo
	,parent.isnetwork
	,parent.isgovernment
	,parent.ismultilateral
	,parent.ispublicprivatepartnership
	,parent.isUniversityorResearchInstitute
	,parent.isinternationalNGO
	,parent.isforeign
FROM contract.fpds as c
	left outer join contractor.DunsnumberToParentContractorHistory as DtPCH 
	on c.dunsnumber=dtpch.DUNSnumber and c.fiscal_year=dtpch.FiscalYear
	LEFT Outer JOIN contractor.ParentContractor as Parent
	ON dtpch.Parentid = parent.parentid
	Left outer join Economic.Deflators as def
	on DtPCH.FiscalYear=def.Fiscal_Year
	left outer join contractor.DunsnumberToParentContractorHistory as Parentdtp
	on dtpch.parentdunsnumber=parentdtp.dunsnumber and dtpch.fiscalyear=Parentdtp.fiscalyear
	left outer join contractor.parentcontractor as Parentduns
	on parentdtp.parentid=parentduns.parentid
	LEFT OUTER JOIN
		FPDSTypeTable.AgencyID AS CAgency ON C.contractingofficeagencyid = CAgency.AgencyID
	LEFT OUTER JOIN
		FPDSTypeTable.AgencyID AS FAgency ON C.fundingrequestingagencyid = FAgency.AgencyID

WHERE 
	(isnull(parent.LargeGreaterThan3B,0)=0 
	and isnull(parent.LargeGreaterThan1B,0)=0
	 and parent.RevenueInMillions is null
	 and isnull(parent.UnknownCompany,0)=0)
	 or parent.MergerYear<=DtPCH.FiscalYear
	 or parent.FirstYear>DtPCH.FiscalYear



















GO
