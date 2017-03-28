USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_SingleCorpContactInfobyContractDesc]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Madison Riley>
-- Create date: <1/8/2015>
-- Description:	<Stored Proceedure to Run Query and pull information company contact information
-- (address, city, state, phone) in relation to the contract description. This was originally
-- designed to get contact information for companies involved in PBL contracts.>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_SingleCorpContactInfobyContractDesc]
	@ContractNature nvarchar(50),
	@CorpName nvarchar(50)

AS

	SET NOCOUNT ON;

	SELECT D.DUNSnumber, 
	P.ParentID,
	P.StandardizedTopContractor,
	F.vendor_state_code,
	F.streetaddress,
	F.city,
	F.phoneno,
	F.descriptionofcontractrequirement,
	F.idvpiid
	FROM Contractor.Dunsnumber AS D

	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory as P
	on D.DUNSnumber = P.DUNSnumber
	LEFT OUTER JOIN Contract.FPDS as F
	on D.DUNSnumber = F.dunsnumber

		WHERE F.descriptionofcontractrequirement LIKE '%'+@ContractNature+'%' AND 
			P.StandardizedTopContractor LIKE '%'+@CorpName+'%'

		GROUP BY D.DUNSnumber, 
			P.ParentID,
			P.StandardizedTopContractor,
			F.vendor_state_code,
			F.streetaddress,
			F.city,
			F.phoneno,
			F.descriptionofcontractrequirement,
			F.idvpiid;
	




GO
