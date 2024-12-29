-- DATA CLEANING NASHVILLE 
select *
from PortfolioProject..Nashvillehousing 
WHERE [UniqueID ] = '48700'

--standardize date format
select convert(date,saledate) ConvertDATE
from PortfolioProject..Nashvillehousing 

ALTER TABLE PortfolioProject..Nashvillehousing 
ADD SaleConvertDate DATe ;

UPDATE PortfolioProject..Nashvillehousing 
SET SaleConvertDate = convert(date,saledate)

-- Populate Property Adress Data

select T1.parcelID,T1.PropertyAddress,T2.parcelID,T2.PropertyAddress,ISNULL(T1.PropertyAddress,T2.PropertyAddress)
from PortfolioProject..Nashvillehousing T1
JOIN PortfolioProject..Nashvillehousing T2
	ON T1.parcelID = T2.parcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

UPDATE T1
SET PropertyAddress =  ISNULL(T1.PropertyAddress,T2.PropertyAddress)
from PortfolioProject..Nashvillehousing T1
JOIN PortfolioProject..Nashvillehousing T2
	ON T1.parcelID = T2.parcelID
	AND T1.[UniqueID ]<> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

-- Breaking out Propertyaddress into individual columns (Address,city)

select PropertyAddress,substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
from PortfolioProject..Nashvillehousing 

ALTER TABLE Nashvillehousing
ADD PrpoertySlipAddress nvarchar(255)

UPDATE Nashvillehousing
SET PrpoertySlipAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 
from PortfolioProject..Nashvillehousing 

ALTER TABLE Nashvillehousing
ADD PrpoertySlipCity nvarchar(255)

UPDATE Nashvillehousing
SET PrpoertySlipCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
from PortfolioProject..Nashvillehousing 

-- Breaking out Owneraddress into individual columns (Address,city,state)
select OwnerAddress, PARSENAME(replace(OwnerAddress,',','.'),3),
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..Nashvillehousing 

ALTER TABLE Nashvillehousing
ADD OwnerSplipAddress nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplipAddress = PARSENAME(replace(OwnerAddress,',','.'),3)
from PortfolioProject..Nashvillehousing 

ALTER TABLE Nashvillehousing
ADD OwnerSplipCity nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplipCity = PARSENAME(replace(OwnerAddress,',','.'),2)
from PortfolioProject..Nashvillehousing 

ALTER TABLE Nashvillehousing
ADD OwnerSplipState nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplipState = PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..Nashvillehousing

--Change Y and N to Yes and No in "Sold as vacant"

select distinct SoldAsVacant
from PortfolioProject..Nashvillehousing 

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END SoldAsVacantUpdate
from PortfolioProject..Nashvillehousing 
group by SoldAsVacant

UPDATE Nashvillehousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
from PortfolioProject..Nashvillehousing 

-- Remove duplicates 

with RowsNumbers AS (
SELECT*,
	ROW_NUMBER () over (partition by parcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									legalreference,
									ownername,
									OwnerAddress order by uniqueID) as RowsNumber
FROM PortfolioProject..Nashvillehousing )

select *
from RowsNumbers
WHERE RowsNumber > 1

-- delete unused columns 

select *
from PortfolioProject..Nashvillehousing

ALTER TABLE Nashvillehousing
DROP COLUMN propertyAddress, Saledate,ownerAddress

-- Change name of columns

EXEC sp_rename 'Nashvillehousing.saleConvertDate' , 'SaleDate','Column'

