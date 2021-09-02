/*

Cleaning Data in SQL Queries

*/


SELECT TOP 1000 *
FROM PortfolioProjectTaylor..NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Standardize Data Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProjectTaylor..NashvilleHousing

--ALTER TABLE PortfolioProjectTaylor..NashvilleHousing
--Add SaleDateConverted Date;

--UPDATE PortfolioProjectTaylor..NashvilleHousing
--SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted
FROM PortfolioProjectTaylor..NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProjectTaylor..NashvilleHousing
WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT A.ParcelID
	,A.PropertyAddress
	,B.ParcelID
	,B.PropertyAddress
	,ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProjectTaylor..NashvilleHousing A
JOIN PortfolioProjectTaylor..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--UPDATE A
--SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
--FROM PortfolioProjectTaylor..NashvilleHousing A
--JOIN PortfolioProjectTaylor..NashvilleHousing B
--	ON A.ParcelID = B.ParcelID
--	AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjectTaylor..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) As Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) As City
FROM PortfolioProjectTaylor..NashvilleHousing

--ALTER TABLE NashvilleHousing
--Add [PropertySplitAddress] NVARCHAR(255);

--UPDATE NashvilleHousing
--SET [PropertySplitAddress] = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

--ALTER TABLE NashvilleHousing
--Add [PropertySplitCity] NVARCHAR(255);

--UPDATE NashvilleHousing
--SET [PropertySplitCity] = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProjectTaylor..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProjectTaylor..NashvilleHousing

SELECT OwnerAddress 
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) As Address
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) As City
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) As State
FROM PortfolioProjectTaylor..NashvilleHousing

--ALTER TABLE NashvilleHousing
--Add [OwnerSplitAddress] NVARCHAR(255);

--UPDATE NashvilleHousing
--SET [OwnerSplitAddress] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--ALTER TABLE NashvilleHousing
--Add [OwnerSplitCity] NVARCHAR(255);

--UPDATE NashvilleHousing
--SET [OwnerSplitCity] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--ALTER TABLE NashvilleHousing
--Add [OwnerSplitState] NVARCHAR(255);

--UPDATE NashvilleHousing
--SET [OwnerSplitState] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProjectTaylor..NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)As CountOfResponses
FROM PortfolioProjectTaylor..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
	,CASE
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			Then 'No'
		ELSE SoldAsVacant
	END AS SoldAsVacant
FROM PortfolioProjectTaylor..NashvilleHousing
WHERE SoldAsVacant IN ('Y', 'N')
ORDER BY 1

--UPDATE NashvilleHousing
--SET SoldAsVacant = 	CASE
--		WHEN SoldAsVacant = 'Y'
--			THEN 'Yes'
--		WHEN SoldAsVacant = 'N'
--			Then 'No'
--		ELSE SoldAsVacant
--	END

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)As CountOfResponses
FROM PortfolioProjectTaylor..NashvilleHousing
GROUP BY SoldAsVacant

----------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *
	,ROW_NUMBER() OVER (PARTITION BY
						ParcelID
						,PropertyAddress
						,SalePrice
						,SaleDate
						,LegalReference
						ORDER BY
							UniqueID
						) row_num
FROM PortfolioProjectTaylor..NashvilleHousing
ORDER BY 27 DESC


WITH RowNumCTE AS (
SELECT *
	,ROW_NUMBER() OVER (PARTITION BY
						ParcelID
						,PropertyAddress
						,SalePrice
						,SaleDate
						,LegalReference
						ORDER BY
							UniqueID
						) row_num
FROM PortfolioProjectTaylor..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProjectTaylor..NashvilleHousing

ALTER TABLE PortfolioProjectTaylor..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate