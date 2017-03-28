USE [DIIG]
GO
/****** Object:  View [Vendor].[CompetitionVendorSizeHistoryBucketSubCustomerClassification]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [Vendor].[CompetitionVendorSizeHistoryBucketSubCustomerClassification]
AS
SELECT       C.fiscal_year
      ,C.Query_Run_Date
      ,C.Customer
      ,C.ServicesCategory
	  ,C.Simple
      ,C.IsService
	  ,C.ProductOrServiceArea
	  ,C.ProductOrServiceCode
	  ,C.ProductOrServiceCodeText
	 ,C.PlatformPortfolio
      ,C.SubCustomer
	  ,c.statecode
      ,C.Region
      ,C.Country3LetterCodeText
	  ,C.reasonnotcompetedText
	  ,C.statutoryexceptiontofairopportunityText
	  ,c.numberofoffersreceived
	,c.MajorCommandID
			,c.ContractingOfficeID
			,c.ContractingOfficeName
	,(SELECT CompetitionClassification from FPDSTypeTable.ClassifyCompetition(
		c.numberofoffersreceived --@NumberOfOffers as decimal(19,4)
	,c.UseFairOpportunity --@UseFairOpportunity as bit
	,c.ExtentIsFullAndOpen--@ExtentIsFullAndOpen as bit
	,c.ExtentIsSomeCompetition--@extentissomecompetition as bit
	,c.isfollowontocompetedaction--@ExtentIsfollowontocompetedaction as bit
	,c.ExtentIsOnlyOneSource
	,c.ReasonNotisfollowontocompetedaction
	,c.is6_302_1exception--@is6_302_1exception as bit
	,c.FairIsSomeCompetition--@fairissomecompetition as bit
	,c.FairIsfollowontocompetedaction--@FairIsfollowontocompetedaction as bit
	,c.FairIsonlyonesource--@FairIsonlyonesource as bit
		)) as CompetitionClassification
	,(SELECT CompetitionLegacyClassification from FPDSTypeTable.ClassifylegacyCompetition(
		c.numberofoffersreceived --@NumberOfOffers as decimal(19,4)
	,c.ExtentIsFullAndOpen--@ExtentIsFullAndOpen as bit
	,c.ExtentIsSomeCompetition--@extentissomecompetition as bit
	,c.isfollowontocompetedaction--@ExtentIsfollowontocompetedaction as bit
	,c.is6_302_1exception--@is6_302_1exception as bit
		)) as CompetitionLegacyClassification
	,(SELECT ClassifyNumberOfOffers from Fpdstypetable.ClassifyNumberOfOffers(
		c.numberofoffersreceived
		,c.UseFairOpportunity	--,@UseFairOpportunity as bit
		,c.ExtentIsSomeCompetition	--,@extentissomecompetition as bit
		,c.FairIsSomeCompetition	--,@fairissomecompetition as bit
		)) as ClassifyNumberOfOffers
      ,C.obligatedAmount as SUmofobligatedamount
      ,C.numberOfActions as sumofnumberofactions
	  ,C.Size
	  ,C.IsSiliconValley
  FROM (
  SELECT        C.fiscal_year, 
			GETDATE() AS Query_Run_Date, 
			ISNULL(Agency.Customer, Agency.AgencyIDtext) AS Customer,
			PSC.ServicesCategory,
			PSC.IsService,
			PSC.Simple,
			PSC.ProductOrServiceCode,
			PSC.ProductOrServiceCodeText,
			isnull(cpc.PlatformPortfolio,PSC.PlatformPortfolio) as PlatformPortfolio,
			PSC.ProductOrServiceArea,
			state.statecode,
			Agency.SubCustomer, 
			mcid.majorcommandid,
			mcid.ContractingOfficeID,
			mcid.ContractingOfficeName,
			CountryCode.Region,
			CountryCode.Country3LetterCodeText,
			notcompeted.isfollowontocompetedaction,
			notcompeted.is6_302_1exception,
			notcompeted.reasonnotcompetedText,
			notcompeted.isfollowontocompetedaction as ReasonNotisfollowontocompetedaction,
			competed.IsOnlyOneSource as ExtentIsOnlyOneSource,
			competed.IsFullAndOpen as ExtentIsFullAndOpen,
			competed.IsSomeCompetition as ExtentIsSomeCompetition,
			Fairopp.isfollowontocompetedaction as FairIsfollowontocompetedaction,
			Fairopp.isonlyonesource as FairIsonlyonesource,
			Fairopp.IsSomeCompetition as FairIsSomeCompetition,
			Fairopp.statutoryexceptiontofairopportunityText,
			setaside.typeofsetaside2category
            ,c.numberofoffersreceived 
			,pc.IsSiliconValley
			,CASE
				WHEN PC.Top6=1 and PC.JointVenture=1
				THEN 'Large: Big 6 JV'
				WHEN PC.Top6=1
				THEN 'Large: Big 6'
				WHEN PC.LargeGreaterThan3B=1
				THEN 'Large'
				WHEN PC.LargeGreaterThan1B=1
				THEN 'Medium >1B'
				WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
				THEN 'Small'
				ELSE 'Medium <1B'
				END AS [Size]
			,CASE 
				--Award or IDV Type show only (‘Definitive Contract’, ‘IDC’, ‘Purchase Order’)
				WHEN ctype.ForAwardUseExtentCompeted=1
				then 0 --Use extent competed
				--Award or IDV Type show only (‘Delivery Order’, ‘BPA Call’)
				--IDV Part 8 or Part 13 show only (‘Part 13’)
				--When  **Part 8 or Part 13  is not available!**
				--then 0 --Use extent competed

				--Award or IDV Type show only (‘Delivery Order’)
				--IDV Multiple or Single Award IDV show only (‘S’)
				when ctype.isdeliveryorder=1
					and isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =0
				then 0
				
				

				--Fair Opportunity / Limited Sources show only (‘Fair Opportunity Given’)
				--Award or IDV Type show only (‘Delivery Order’)
				--IDV Type show only (‘FSS’, ‘GWAC’, ‘IDC’)
				--	IDV Multiple or Single Award IDV show only (‘M’)
				when idvtype.ForIDVUseFairOpportunity=1 and 
					ctype.isdeliveryorder=1 and 
					isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =1
				then 1 --Use fair opportunity

				--	Number of Offers Received show only (‘1’)
				-- Award or IDV Type show only (‘BPA Call’, ‘BPA’)
				-- Part 8 or Part 13 show only (‘Part 8’)
				--When  **Part 8 or Part 13  is not available!**
				--then 0 --Use extent competed

				when fairopp.statutoryexceptiontofairopportunitytext is not null
				then 1
				else 0
			end as UseFairOpportunity,
			--SUM(C.obligatedamount) AS SumOfobligatedAmount,  
			--SUM(C.numberofactions) AS SumOfnumberOfActions
			C.obligatedamount,
			C.numberofactions

FROM            Contract.FPDS AS C
	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
		ON C.productorservicecode = PSC.ProductorServiceCode 
--Block of office joincs
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency 
		ON C.contractingofficeagencyid = Agency.AgencyID 
	left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory mcid
		on c.contractingofficeagencyid=mcid.contractingagencyid and
		c.contractingofficeid=mcid.contractingofficeid and
		c.fiscal_year=mcid.fiscal_year
		--Other joincs
	LEFT OUTER JOIN FPDSTypeTable.TypeOfSetAside AS SetAside 
		ON C.typeofsetaside = SetAside.TypeOfSetAside 
	LEFT OUTER JOIN FPDSTypeTable.extentcompeted AS Competed 
		ON C.extentcompeted = Competed.extentcompeted 
	LEFT OUTER JOIN FPDSTypeTable.ReasonNotCompeted AS NotCompeted 
		ON C.reasonnotcompeted = NotCompeted.reasonnotcompeted 
	LEFT OUTER JOIN FPDSTypeTable.Country3lettercode as CountryCode 
		ON (C.placeofperformancecountrycode=CountryCode.Country3LetterCode)
	LEFT OUTER JOIN FPDSTypeTable.statutoryexceptiontofairopportunity as FairOpp 
		ON C.statutoryexceptiontofairopportunity=FAIROpp.statutoryexceptiontofairopportunity
		
	LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT JOIN Contractor.ParentContractor As PC
		ON (PCH.ParentID=PC.ParentID)
	left outer join fpdstypetable.statecode state
		on c.pop_state_code= state.statecode
	left outer join FPDSTypeTable.ClaimantProgramCode  as cpc 
		on cpc.ClaimantProgramCode=c.claimantprogramcode		

--Block of CSISIDjoins
		left join contract.csistransactionid as CTID
			on c.CSIStransactionID=ctid.CSIStransactionID
		left join contract.CSISidvmodificationID as idvmod
			on ctid.CSISidvmodificationID=idvmod.CSISidvmodificationID
		left join contract.CSISidvpiidID as idv
			on idv.CSISidvpiidID=idvmod.CSISidvpiidID
			--Block of vehicle lookups
		Left JOIN FPDSTypeTable.multipleorsingleawardidc as Cmulti
			on C.multipleorsingleawardidc=Cmulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.multipleorsingleawardidc as IDVmulti
			on isnull(idvmod.multipleorsingleawardidc,idv.multipleorsingleawardidc)=IDVMulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.ContractActionType as Ctype
			on C.ContractActionType=Ctype.unseperated
		Left JOIN FPDSTypeTable.ContractActionType as IDVtype
			on isnull(idvmod.ContractActionType,idv.ContractActionType)=IDVtype.unseperated
--GROUP BY 
--	C.fiscal_year
--	,PSC.ServicesCategory
--	,PSC.IsService
--	,PSC.ProductOrServiceCode
--	,PSC.ProductOrServiceCodeText
--	,isnull(cpc.PlatformPortfolio,PSC.PlatformPortfolio) as PlatformPortfolio
--	, ISNULL(Agency.Customer, Agency.AgencyIDtext)
--	, Agency.SubCustomer
--	,c.numberofoffersreceived 
--	,CASE 
--				--Award or IDV Type show only (‘Definitive Contract’, ‘IDC’, ‘Purchase Order’)
--				WHEN ctype.ForAwardUseExtentCompeted=1
--				then 0 --Use extent competed
--				--Award or IDV Type show only (‘Delivery Order’, ‘BPA Call’)
--				--IDV Part 8 or Part 13 show only (‘Part 13’)
--				--When  **Part 8 or Part 13  is not available!**
--				--then 0 --Use extent competed

--				--Award or IDV Type show only (‘Delivery Order’)
--				--IDV Multiple or Single Award IDV show only (‘S’)
--				when ctype.isdeliveryorder=1
--					and isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =0
--				then 0
				
				

--				--Fair Opportunity / Limited Sources show only (‘Fair Opportunity Given’)
--				--Award or IDV Type show only (‘Delivery Order’)
--				--IDV Type show only (‘FSS’, ‘GWAC’, ‘IDC’)
--				--	IDV Multiple or Single Award IDV show only (‘M’)
--				when idvtype.ForIDVUseFairOpportunity=1 and 
--					ctype.isdeliveryorder=1 and 
--					isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =1
--				then 1 --Use fair opportunity

--				--	Number of Offers Received show only (‘1’)
--				-- Award or IDV Type show only (‘BPA Call’, ‘BPA’)
--				-- Part 8 or Part 13 show only (‘Part 8’)
--				--When  **Part 8 or Part 13  is not available!**
--				--then 0 --Use extent competed

--				when fairopp.statutoryexceptiontofairopportunitytext is not null
--				then 1
--				else 0
--			end 
--	,competed.IsFullAndOpen
--	,competed.IsSomeCompetition
--	,Fairopp.isfollowontocompetedaction 
--	,Fairopp.isonlyonesource 
--	,Fairopp.IsSomeCompetition
--	,Fairopp.statutoryexceptiontofairopportunityText
--	,notcompeted.isfollowontocompetedaction
--	,notcompeted.is6_302_1exception
--	,notcompeted.reasonnotcompetedText
--	,setaside.typeofsetaside2category
--	,CountryCode.Country3LetterCodeText
--	,CountryCode.Region
--	,ISNULL(setaside.typeofsetaside2category, 'Unlabeled')
--	,CASE
--				WHEN PC.Top6=1 and PC.JointVenture=1
--				THEN 'Large: Big 6 JV'
--				WHEN PC.Top6=1
--				THEN 'Large: Big 6'
--				WHEN PC.LargeGreaterThan3B=1
--				THEN 'Large'
--				WHEN PC.LargeGreaterThan1B=1
--				THEN 'Medium >1B'
--				WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
--				THEN 'Small'
--				ELSE 'Medium <1B'
--				END 

  ) as c
  

	

 






































GO
