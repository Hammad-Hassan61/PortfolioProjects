USE Portfolio;

-- Checking whether All data is imported or not

SELECT COUNT(*) FROM NashvileHousing;

--exec sp_rename Sheet1$, NashvileHousing

--CLeaning Data IN SQL Queries

SELECT * FROM NashvileHousing;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Changing Date Format

SELECT SaleDate, CONVERT (DATE, SaleDate)
FROM NashvileHousing


ALTER TABLE  NashvileHousing
ADD SALESDateConverted DATE;

UPDATE NashvileHousing
SET SalesDateConverted = CONVERT(DATE,SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populating property Address

SELECT *
FROM NashvileHousing
--WHERE propertyAddress is NULL
ORDER BY parcelId

SELECT a.parcelId, a.propertyAddress , b.parcelId, b.propertyAddress ,ISNULL (a.propertyAddress,b.propertyAddress)
FROM NashvileHousing a 
JOIN NashvileHousing  b ON
	a.parcelId = b.parcelId
	AND a.uniqueId <> b.UniqueId
WHERE a.propertyAddress is NULL


UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvileHousing a 
JOIN NashvileHousing  b ON
	a.parcelId = b.parcelId
	AND a.uniqueId <> b.UniqueId
WHERE a.propertyAddress is NULL


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out address into its Components (Address, City, Sate)

SELECT PropertyAddress
FROM NashvileHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress)+1 , LEN(propertyAddress)) AS City
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD propertySplitAddress nvarchar(255)

UPDATE NashvileHousing
SET propertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyAddress) -1)

ALTER TABLE NashvileHousing
ADD propertySplitCITY nvarchar(255)


UPDATE NashvileHousing
SET propertySplitCITY = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress)+1 , LEN(propertyAddress))

--SELECT * FROM NashvileHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Splitting the OwnerAddress

SELECT OwnerAddress FROM NashvileHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvileHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--SELECT * FROM NashvileHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Changing Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM NashvileHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
	CASE 
		WHEN SOLDAsVacant ='Y' THEN 'YES'
		WHEN SOLDAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE 
		WHEN SOLDAsVacant ='Y' THEN 'YES'
		WHEN SOLDAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
	END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH ROWNUM_CTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARtITION BY parcelid,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference

	ORDER BY 
		UniqueID
	) Row_Num
FROM NashvileHousing
--ORDER BY ParcelID
)
--DELETE 
SELECT *
FROM ROWNUM_CTE
WHERE Row_Num > 1


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETE UNUSE  COLUMNS

SELECT * 
FROM NashvileHousing


ALTER TABLE NashVileHousing
DROP COLUMN OWnerAddress,TaxDistrict, propertyAddress, SaleDate



