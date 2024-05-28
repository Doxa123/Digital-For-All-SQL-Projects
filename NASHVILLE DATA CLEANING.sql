/*
Cleaning data in SQL queries
*/
select*
from PortfolioProject.dbo.NashvilleHousing


-- Standardize date format
select SaleDateConverted, convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = Convert(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = Convert(Date,SaleDate)


--populate property address data

select*
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
order by parcelID


select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	and a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	and a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null


--Breaking out Address into Individual columns (Address, city,state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
--order by parcelID

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 ) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))as Address
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add	PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 )

Alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity =  substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select*
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
parsename(Replace(ownerAddress, ',', '.'), 3)
,parsename(Replace(ownerAddress, ',', '.'), 2)
,parsename(Replace(ownerAddress, ',', '.'), 1)
from portfolioproject.dbo.NashvilleHousing

Alter table NashvilleHousing
add	ownerSplitAddress Nvarchar(255);

update NashvilleHousing
set ownerSplitAddress = parsename(Replace(ownerAddress, ',', '.'), 3)

Alter table NashvilleHousing
add ownerSplitCity Nvarchar(255);

update NashvilleHousing
set ownerSplitCity = parsename(Replace(ownerAddress, ',', '.'), 2)

Alter table NashvilleHousing
add ownerSplitState Nvarchar(255);

update NashvilleHousing
set ownerSplitState =  parsename(Replace(ownerAddress, ',', '.'), 1)

select*
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in 'sold as vacant' field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end


--Remove Duplicates

with RowNumCTE AS(
select*,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



--Delete unused columns

select*
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column ownerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate



