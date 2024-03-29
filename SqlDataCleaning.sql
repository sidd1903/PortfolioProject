/*

Cleaning Data in SQL Queries

*/

select * 
from [Portfolio Project]..HousingData


-- Standardize Date Format

select SaleDate
from [Portfolio Project]..HousingData

alter table HousingData
ADD SaleDateConverted Date

update HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select a.PropertyAddress, b.PropertyAddress,a.ParcelID, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..HousingData a
join [Portfolio Project]..HousingData b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..HousingData a
join [Portfolio Project]..HousingData b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is NULL


Select *
From [Portfolio Project]..HousingData
where PropertyAddress is NULL
order by ParcelID

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project]..HousingData
order by ParcelID

select PropertyAddress , SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as HouseAddress,
                         SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from [Portfolio Project]..HousingData

Alter table HousingData 
ADD HouseAddress nvarchar(255);

Alter table HousingData 
ADD City nvarchar(255);

update HousingData
SET HouseAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

update HousingData
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select OwnerAddress
From [Portfolio Project]..HousingData
order by ParcelID


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from [Portfolio Project]..HousingData

Alter table HousingData 
ADD OwnerHouseAddress nvarchar(255);

Alter table HousingData 
ADD OwnerCity nvarchar(255);

Alter table HousingData 
ADD OwnerState nvarchar(255);

update HousingData
SET OwnerHouseAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

update HousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

update HousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Changing Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
From [Portfolio Project]..HousingData
group by SoldAsVacant

Select SoldAsVacant, 
	Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	end 
From [Portfolio Project]..HousingData
group by SoldAsVacant

Update HousingData
Set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	end 

-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project]..HousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From [Portfolio Project]..HousingData

-- Deleting Unused Columns

Alter Table [Portfolio Project]..HousingData
Drop Column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict