USE [DIIG]
GO
/****** Object:  View [Vendor].[ContractsByVendorBucketSubCustomer]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Vendor].[ContractsByVendorBucketSubCustomer]
AS

SELECT
F.fiscal_year
,Parent.ParentID
,A.Customer
,A.SubCustomer
,PSC.ProductServiceOrRnDarea
,PSC.ProductOrServiceCodeText
,F.idvpiid
,F.piid
,F.descriptionofcontractrequirement
,F.pop_state_code
,F.signeddate
,sum(F.obligatedamount) AS SumOfObligatedAmount

FROM Contract.FPDS AS F
LEFT JOIN FPDSTypeTable.AgencyID AS A
ON A.AgencyID = F.contractingofficeagencyid
LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
ON PSC.ProductOrServiceCode = F.productorservicecode
 LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
            ON (F.DUNSNumber=Dunsnumber.DUNSNUMBER) 
                   AND (F.fiscal_year=Dunsnumber.FiscalYear) 
       LEFT JOIN Contractor.ParentContractor as Parent
              ON Dunsnumber.ParentID=Parent.ParentID

GROUP BY
F.fiscal_year
,Parent.ParentID
,A.Customer
,A.SubCustomer
,PSC.ProductServiceOrRnDarea
,PSC.ProductOrServiceCodeText
,F.idvpiid
,F.piid
,F.descriptionofcontractrequirement
,F.pop_state_code
,F.signeddate

GO
