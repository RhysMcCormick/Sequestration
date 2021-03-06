USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_VendorHistoryBySubCustomer]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [Vendor].[SP_VendorHistoryBySubCustomer]

@ParentID VARCHAR(255)


AS
	BEGIN
		--Copy the start of your query here
		SELECT 
			C.Fiscal_Year
			,ParentID
			,Max(GetDate()) AS Query_Run
			,C.Customer
			,C.SubCustomer
			,Sum(C.SumOfobligatedAmount) AS SumOfSumOfobligatedAmount
			FROM Vendor.AllVendorIsServiceHistorySubCustomerDirectDiscretization as C
			WHERE ParentID = @ParentID
		--Copy the end of your query here
			GROUP BY 
				C.fiscal_year
				,ParentID
				,C.Customer
				,C.SubCustomer
			order by
				c.Fiscal_year
				,C.Customer
				,Sum(C.SumOfobligatedAmount) desc
		--End of your query
		END






GO
