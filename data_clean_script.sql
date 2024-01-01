--	Cleaning Data

SELECT * 
FROM PortfolioProject..nashville_housing


--	Standarized Date Format

SELECT saledateconverted,CAST(saledate AS date)
FROM PortfolioProject..nashville_housing


UPDATE nashville_housing
SET saledate = cast(saledate AS DATE)

ALTER TABLE nashville_housing
ADD saledateconverted DATE


UPDATE nashville_housing
SET saledateconverted = cast(saledate AS DATE)


--	Populate Property Address Data

SELECT *
FROM PortfolioProject..nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT 
	nh1.ParcelID, 
	nh1.PropertyAddress, 
	nh2.ParcelID, 
	nh2.PropertyAddress,
	ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
FROM PortfolioProject..nashville_housing nh1
JOIN PortfolioProject..nashville_housing nh2
	ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress IS NULL 


UPDATE nh1
SET nh1.PropertyAddress = ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
FROM PortfolioProject..nashville_housing nh1
JOIN PortfolioProject..nashville_housing nh2
	ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress IS NULL 


--	Break Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..nashville_housing 

SELECT 
SUBSTRING(
	PropertyAddress,
	1,
	CHARINDEX(',',PropertyAddress) -1 ) AS address,	-- Looking for , in Propertyaddress but won't include in the select
SUBSTRING(
	PropertyAddress,
	CHARINDEX(',',PropertyAddress) +1,
	LEN(propertyaddress)) AS city		

FROM PortfolioProject..nashville_housing 


ALTER TABLE nashville_housing
ADD propertySplitAddress NVARCHAR(255)

UPDATE nashville_housing
SET propertySplitAddress = SUBSTRING(
								PropertyAddress,
								1,
								CHARINDEX(',',PropertyAddress) -1 )


ALTER TABLE nashville_housing
ADD propertySplitCity NVARCHAR(255)

UPDATE nashville_housing
SET propertySplitCity = SUBSTRING(
							PropertyAddress,
							CHARINDEX(',',PropertyAddress) +1,
							LEN(propertyaddress))


SELECT *
FROM PortfolioProject..nashville_housing 



SELECT OwnerAddress
FROM PortfolioProject..nashville_housing 


SELECT 
	OwnerAddress,
	PARSENAME(REPLACE(owneraddress,',','.'),3),
	PARSENAME(REPLACE(owneraddress,',','.'),2),
	PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProject..nashville_housing 


ALTER TABLE nashville_housing
ADD ownerSplitAddress NVARCHAR(255)

UPDATE nashville_housing
SET ownerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE nashville_housing
ADD ownerSplitCity NVARCHAR(255)

UPDATE nashville_housing
SET ownerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE nashville_housing
ADD ownerSplitState NVARCHAR(255)

UPDATE nashville_housing
SET ownerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)


SELECT *
FROM PortfolioProject..nashville_housing 


--	Change Y and N to Yes and No in SoldAsVacant column

SELECT 
	DISTINCT soldasvacant,
	count(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY soldasvacant
ORDER BY 2


SELECT 
	soldasvacant,
	CASE 
    	WHEN soldasvacant = 'Y' THEN 'Yes'
    	WHEN soldasvacant = 'N' THEN 'No'
    	ELSE soldasvacant
    END
FROM PortfolioProject..nashville_housing

UPDATE nashville_housing
SET soldasvacant = 	
	CASE 
    		WHEN soldasvacant = 'Y' THEN 'Yes'
    		WHEN soldasvacant = 'N' THEN 'No'
    		ELSE soldasvacant
	END

SELECT 
	DISTINCT soldasvacant,
	count(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY soldasvacant
ORDER BY 2


--	Remove Duplicates

WITH cte_row_num AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY [UniqueID ]) AS row_num
	FROM PortfolioProject..nashville_housing)
SELECT *
FROM cte_row_num 
WHERE row_num <> 1
ORDER BY [UniqueID ]

WITH cte_row_num AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY [UniqueID ]) AS row_num
	FROM PortfolioProject..nashville_housing)
DELETE 
FROM cte_row_num 
WHERE row_num > 1


--	Delete Unused Columns

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..nashville_housing