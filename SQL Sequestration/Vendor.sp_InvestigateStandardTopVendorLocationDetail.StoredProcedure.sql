USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_InvestigateStandardTopVendorLocationDetail]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_InvestigateStandardTopVendorLocationDetail]
	-- Add the parameters for the stored procedure here
		@parentid nvarchar(255)
		,@standardizedtopcontractor nvarchar(255)
		,@CountryText_See_Country3LetterCode nvarchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		if @parentid is null
		raiserror('The value for @parentid shold not be null.',15,1)
	if @CountryText_See_Country3LetterCode is null 
	begin
		select 
			 [Fiscal_year]
		,parentid
     -- ,[ContractorDisplayName]
	  ,[StandardizedTopContractor]
      ,[Small]
      ,[jointventure]
      ,[warningflag]
      ,[UnknownCompany]
      ,[Top100Federal]
      ,[fundedbyforeignentity]
      ,[isforeignownedandlocated]
      ,[isforeigngovernment]
      ,[isinternationalorganization]
      ,[organizationaltype]
       ,[PlaceIsUnitedstates]
      ,[PlaceCountryText]
      ,[OriginIsUnitedStates]
      ,[OriginCountryText]
      ,[VendorIsUnitedStates]
      ,[VendorCountryText]
      ,[placeofmanufactureText]
      ,[vendorcountrycode]
			,sum(l.[SumOfnumberOfActions]) as SumOfnumberOfActions
			,sum(l.[SumOfobligatedAmount]) as SumOfobligatedAmount
		from location.StandardizedTopVendorBucketSubCustomerPartial as l --VendorHistoryBucketSubCustomerDiscretization as l
			where  l.parentid like ('%'+@parentid+'%') or l.parentid =@parentid
		group by 
			 [Fiscal_year]
			 		,parentid
      --,[ContractorDisplayName]
	  ,[StandardizedTopContractor]
      ,[Small]
      ,[jointventure]
      ,[warningflag]
      ,[UnknownCompany]
      ,[Top100Federal]
      ,[fundedbyforeignentity]
      ,[isforeignownedandlocated]
      ,[isforeigngovernment]
      ,[isinternationalorganization]
      ,[organizationaltype]
 ,[PlaceIsUnitedstates]
      ,[PlaceCountryText]
      ,[OriginIsUnitedStates]
      ,[OriginCountryText]
      ,[VendorIsUnitedStates]
      ,[VendorCountryText]
      ,[placeofmanufactureText]
      ,[vendorcountrycode]
		end
	else
	begin
		select 
			 [Fiscal_year]
		,parentid
      ,[ContractorDisplayName]
	  ,[StandardizedTopContractor]
      ,[Small]
      ,[jointventure]
      ,[warningflag]
      ,[UnknownCompany]
      ,[Top100Federal]
      ,[fundedbyforeignentity]
      ,[isforeignownedandlocated]
      ,[isforeigngovernment]
      ,[isinternationalorganization]
      ,[organizationaltype]
        ,[PlaceCountryText]
      ,[OriginIsUnitedStates]
      ,[OriginCountryText]
      ,[VendorIsUnitedStates]
      ,[VendorCountryText]
      ,[placeofmanufactureText]
      ,[vendorcountrycode]
			,sum(l.[SumOfnumberOfActions]) as SumOfnumberOfActions
			,sum(l.[SumOfobligatedAmount]) as SumOfobligatedAmount
		from location.VendorHistoryBucketSubCustomerDiscretization as l
			where  @CountryText_See_Country3LetterCode in (l.VendorCountryText, l.OriginCountryText, l.PlaceCountryText ) and 
				l.parentid like ('%'+@parentid+'%') or l.parentid =@parentid
		group by 
			 [Fiscal_year]
			 ,StandardizedTopContractor
			 		,parentid
      ,[ContractorDisplayName]
	  ,[StandardizedTopContractor]
      ,[Small]
      ,[jointventure]
      ,[warningflag]
      ,[UnknownCompany]
      ,[Top100Federal]
      ,[fundedbyforeignentity]
      ,[isforeignownedandlocated]
      ,[isforeigngovernment]
      ,[isinternationalorganization]
      ,[organizationaltype]
 ,[PlaceIsUnitedstates]
      ,[PlaceCountryText]
      ,[OriginIsUnitedStates]
      ,[OriginCountryText]
      ,[VendorIsUnitedStates]
      ,[VendorCountryText]
      ,[placeofmanufactureText]
      ,[vendorcountrycode]


		
end


end








GO
