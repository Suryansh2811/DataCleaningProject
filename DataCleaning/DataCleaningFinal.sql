--select * 
--from DataCleaning.dbo.NashvilleHousing


---- date format

--select SaleDate,convert(Date,SaleDate)
--from DataCleaning.dbo.NashvilleHousing


----update DataCleaning.dbo.NashvilleHousing

----set SaleDate = convert(Date,SaleDate)

----select * 
----from DataCleaning.dbo.NashvilleHousing


--Alter table DataCleaning.dbo.NashvilleHousing
--add SaleDateConverted Date;
--update DataCleaning.dbo.NashvilleHousing

--set SaleDateConverted = convert(Date,SaleDate)

--select * 
--from DataCleaning.dbo.NashvilleHousing

--select SaleDateConverted, convert(Date,SaleDate)
--from DataCleaning.dbo.NashvilleHousing




--Populate property address data

select *
from DataCleaning.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from DataCleaning.dbo.NashvilleHousing a 
join DataCleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]

	where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from DataCleaning.dbo.NashvilleHousing a 
join DataCleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]



-- Transforming address into columns
select PropertyAddress
from DataCleaning.dbo.NashvilleHousing



select substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from DataCleaning.dbo.NashvilleHousing


alter table DataCleaning.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update DataCleaning.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table DataCleaning.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

update DataCleaning.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select PropertySplitCity, PropertySplitAddress
from DataCleaning.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from DataCleaning.dbo.NashvilleHousing


alter table DataCleaning.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update DataCleaning.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table DataCleaning.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update DataCleaning.dbo.NashvilleHousing
set OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)


alter table DataCleaning.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

update DataCleaning.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from DataCleaning.dbo.NashvilleHousing



-- change y and n to yes and no in the sold as vacant field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from DataCleaning.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from DataCleaning.dbo.NashvilleHousing

update DataCleaning.dbo.NashvilleHousing

set SoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End


-- Remove Duplicates


with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID, PropertyAddress, Saleprice, SaleDate, LegalReference
	order by 
	UniqueID) as row_num
		
from DataCleaning.dbo.NashvilleHousing
--order by ParcelID
)

--delete
select *
from RowNumCTE
where row_num > 1


