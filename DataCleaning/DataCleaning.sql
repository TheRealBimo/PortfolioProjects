-- Data Cleaning in SQL Quieries

Select *
from PortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format, removing the time from the date

Select SaleDateConverted, convert(date,saledate)
from PortfolioProject.dbo.NashvilleHousing

--Update Nashvillehousing
--set saledate = convert(date,saledate)

alter table Nashvillehousing
add SaleDateConverted Date;

Update Nashvillehousing
set SaleDateConverted = convert(date,saledate)
-------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

-- Updates the NULL address from a.PropertyAddress to b.PropertyAddress
Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into Individual columns (address, city, state)

Select propertyaddress
from PortfolioProject.dbo.NashvilleHousing

select 
-- Goes to the comma for the address and removes the comma
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

-- Adds the split address in the table
alter table Nashvillehousing
add PropertySplitAddress nvarchar(255);

Update Nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table Nashvillehousing
add PropertySplitCity nvarchar(255);

Update Nashvillehousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Using Parsename to separte the address for the OwnerAddress (address, city, state)

Select OwnerAddress
from PortfolioProject.dbo.nashvillehousing

Select
-- parsename does the function backwards
parsename(replace(OwnerAddress, ',', '.'), 3)
, parsename(replace(OwnerAddress, ',', '.'), 2)
, parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.nashvillehousing

alter table Nashvillehousing
add OwnerSplitAddress nvarchar(255);

Update Nashvillehousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table Nashvillehousing
add OwnerSplitCity nvarchar(255);

Update Nashvillehousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table Nashvillehousing
add OwnerSplitState nvarchar(255);

Update Nashvillehousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.nashvillehousing
group by SoldAsVacant
order by 2



Select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant ='N' THEN 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.nashvillehousing

Update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant ='N' THEN 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.nashvillehousing


-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num

from PortfolioProject.dbo.nashvillehousing
-- order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
order by PropertyAddress

-- Deleting Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate