USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_InvestigateGrantNames]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




































-- =============================================
-- Author:		Alex Stephenson
-- Create date: 2014-01-13
-- Description:	List the top unlabeled DUNS numbers for grants
-- =============================================
CREATE PROCEDURE [Vendor].[SP_InvestigateGrantNames] 
	@Customer VARCHAR(255)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	

		BEGIN
		-- Insert statements for procedure here
		SELECT 
		[fiscal_year]
		,sum([total_funding_amount]) as Totalfed_funding_amount
      ,[ParentID]
      ,[vendor_name]
      ,[agency_code]
      ,[Customer]
      ,[SubCustomer]
      ,[agency_name]
      ,[cfda_program_num]
      ,[cfda_program_title]
      ,[account_title]
      ,[project_description]
			FROM Vendor.TopVendorGrantNames as G
			WHERE Customer = @Customer
			group by
			[fiscal_year]
      ,[ParentID]
      ,[vendor_name]
      ,[agency_code]
      ,[Customer]
      ,[SubCustomer]
      ,[agency_name]
      ,[cfda_program_num]
      ,[cfda_program_title]
      ,[account_title]
      ,[project_description]
	END
	END

















GO
