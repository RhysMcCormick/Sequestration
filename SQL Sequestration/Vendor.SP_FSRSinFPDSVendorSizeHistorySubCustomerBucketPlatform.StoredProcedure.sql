USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Vendor].[SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]

as

SELECT [fiscal_year]
      ,[Customer]
      ,[SubCustomer]
      ,[ProductOrServiceArea]
      ,[Simple]
      ,[PlatformPortfolio]
      ,[VendorSize]
	  ,[IsInFSRS]
      ,sum([PrimeObligatedAmount]) as [PrimeObligatedAmount]
      --,sum([SubawardAmount]) as SubawardAmount
      ,sum([PrimeNumberOfActions]) as PrimeNumberOfActions
	  ,count(CSIScontractID) as PrimeNumberOfRows --Not a contract count, a row count
	  --,count(f.PrimeAwardReportID) as NumberOfTransactions
  FROM [DIIG].[Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]
  group by   [fiscal_year]
      ,[Customer]
      ,[SubCustomer]
      ,[ProductOrServiceArea]
      ,[Simple]
      ,[PlatformPortfolio]
      ,[VendorSize]
	  ,[IsInFSRS]

GO
