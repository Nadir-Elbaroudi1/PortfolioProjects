---------------------- Cleaning Date in SQL Queries ----------------------------------
-
SELECT * 
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------


--Standardize Date Format

SELECT SaleDateconverted, CAST(SaleDate AS date)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as date)



-----------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress,b.[UniqueID ], b. ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b. PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b. PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-----------------------------------------------------------------------------------------------------------------------------------------


----- Breaking out Address Into Individuals columns (using 2 different methods - substring command and parsename command)

--- First Method - SUBSTRING

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing 


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


-- Splitting Owner's Address into 3 different columns (address, city, state) 

SELECT owneraddress
FROM PortfolioProject..NashvilleHousing


SELECT 
PARSENAME(REPLACE(Owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(Owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


--Adding Owner's Address

ALTER TABLE NashvilleHousing
ADD PropertySplitOwnerAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitOwnerAddress =  PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)



--Adding Owner's City Column

ALTER TABLE NashvilleHousing
ADD PropertySplitOwnerCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitOwnerCity =  PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)



--Adding Owner's Address

ALTER TABLE NashvilleHousing
ADD PropertySplitOwnerState NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitOwnerState =  PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)



SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacnt" Field


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant 
	 END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant 
	 END


-----------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					uniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT * 
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN TaxDistrict, OwnerAddress, PropertyAddress



ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT * 
FROM PortfolioProject..NashvilleHousing







