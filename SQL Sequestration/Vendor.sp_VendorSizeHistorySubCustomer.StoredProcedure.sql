USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_VendorSizeHistorySubCustomer]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [Vendor].[sp_VendorSizeHistorySubCustomer]
@Customer VARCHAR(255),
@IsService Bit

AS

IF (@IsService is not null)
BEGIN --Begin path where only service or only product entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services or only products only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run
			,IsService
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Vendor.VendorSizeFPDShistoryBucketCustomerCountry as S
		--Here's the where clause for @IsService=@IsService and Customer is not null
		WHERE S.Customer=@Customer
			AND S.IsService=@IsService
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
			,IsService
		--End of your query
		END
	ELSE --Begin sub path where only services or only products but all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run
			,IsService
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Vendor.VendorSizeFPDShistoryBucketCustomerCountry as S
		--Here's the where clause for @IsService=@IsService and Customer is null
		WHERE S.IsService=@IsService
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
			,IsService
		--End of your query
		END
	END
ELSE --Begin the path where all product or service codes will be returned
BEGIN
	IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run
			,S.VendorSize
			,S.Customer
			,S.SubCustomer
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Vendor.VendorSizeFPDShistoryBucketCustomerCountry as S
		--Here's the where clause for @IsService is null and Customer is not null
		WHERE S.Customer=@Customer
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
		--End of your query
		END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Vendor.VendorSizeFPDShistoryBucketCustomerCountry as S
		--There is no Where clause, because everything is being returned
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.SubCustomer
			,S.VendorSize
		--End of your query
		END
	END









GO
