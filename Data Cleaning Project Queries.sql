  /*
Cleaning Data in SQL Queries
*/

select *
from PortfolioProject.dbo.nashvillehousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Sale Date Format


ALTER TABLE nashvillehousing
Add saledateconverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET saledateconverted = CONVERT(Date,saledate)


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitstate Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitstate = PARSENAME(replace(owneraddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select
(case when lower(soldasvacant) like 'N%' then 'No' 
when lower(soldasvacant) like 'Y%' then 'Yes' else soldasvacant end)
-- left(soldasvacant,1) as soldasvacant
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET soldasvacant = (case when lower(soldasvacant) like 'N%' then 'No' 
when lower(soldasvacant) like 'Y%' then 'Yes' else soldasvacant end)


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


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
From PortfolioProject.dbo.NashvilleHousing
 )

select * 
from RowNumCTE
where row_num > 2
order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SalesDate

