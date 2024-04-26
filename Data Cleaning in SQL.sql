/*

DATA  CLEANING IN SQL QUERIES

*/

select * from protofolioProject..nashvellihousing

--standardize date format--

update nashvellihousing
set SaleDate=convert(date,SaleDate)  

-- If it doesn't Update properly

alter table protofolioProject..nashvellihousing
add salesdateconverted date

update protofolioProject..nashvellihousing
set salesdateconverted =convert(date,SaleDate)

---------------populate address date-----------------

select PropertyAddress from protofolioProject..nashvellihousing
where PropertyAddress is null

-- Here, the property address is mandatory; we cannot fill it with our own choices of address.
-- We observe that the parcel ID is the same and the property is the same, and that it is repeated.
-- Therefore, we can replace the property address, which is null, with the property address of the same parcel ID.


select a.ParcelID,a.PropertyAddress ,b.parcelID , b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from protofolioProject..nashvellihousing a join protofolioProject..nashvellihousing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ] 
where a.PropertyAddress is null

--here we updated  null property address by existing address of  same parcelid ---

update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from protofolioProject..nashvellihousing a join protofolioProject..nashvellihousing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ] 
where a.PropertyAddress is null

------- Breaking out Address into Individual Columns (Address, City, State) -------

select PropertyAddress, 
substring (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address, 
substring (PropertyAddress,CHARINDEX(',',PropertyAddress )+1, len(PropertyAddress)) as address
from protofolioProject..nashvellihousing


alter table protofolioProject..nashvellihousing
add PropertySplitAddress nvarchar(255);

update protofolioProject..nashvellihousing
set PropertySplitAddress =substring (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table protofolioProject..nashvellihousing
add PropertySplitcity nvarchar(255);

update protofolioProject..nashvellihousing
set PropertySplitcity = substring (PropertyAddress,CHARINDEX(',',PropertyAddress )+1, len(PropertyAddress))

------------------ spliting using parsename of owneraddress -----------------------------

select  parsename(REPLACE(OwnerAddress,',','.'),3)from nashvellihousing
select  parsename(REPLACE(OwnerAddress,',','.'),2)from nashvellihousing
select  parsename(REPLACE(OwnerAddress,',','.'),1)from nashvellihousing

select  OwnerAddress from protofolioProject..nashvellihousing

alter table protofolioProject..nashvellihousing
add OwnerSplitAddress nvarchar(255)

alter table protofolioProject..nashvellihousing
add OwnerSplitCity nvarchar(255)

alter table protofolioProject..nashvellihousing
add OwnerSplitState nvarchar(255)

update protofolioProject..nashvellihousing
set OwnerSplitAddress=parsename(REPLACE(OwnerAddress,',','.'),3)

update protofolioProject..nashvellihousing
set OwnerSplitCity=parsename(REPLACE(OwnerAddress,',','.'),2)

update protofolioProject..nashvellihousing
set OwnerSplitState=parsename(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------------------
------ replacing Y with yes , N with NO -------

select distinct(SoldAsVacant) ,count(*)  from protofolioProject..nashvellihousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant= 'N' then 'No'
	 else SoldAsVacant
	 end 
from protofolioProject..nashvellihousing

------ we can do it by update comand also-------

update protofolioProject..nashvellihousing
set  SoldAsVacant=
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant= 'N' then 'No'
	 else SoldAsVacant
	 end 
--------------------------------------------------------------------------------------------------------
-- remove duplicates

with RownumCTE as(
select *, 
row_number() over (
partition by ParcelID,
PropertyAddress,
SaleDate,
LegalReference
order by
UniqueID
) row_num
from protofolioProject..nashvellihousing
)
select * from RownumCTE 
where row_num >1
 
--now to delete  the duplicates 

with RownumCTE as(
select *, 
row_number() over (
partition by ParcelID,
PropertyAddress,
SaleDate,
LegalReference
order by
UniqueID
) row_num
from protofolioProject..nashvellihousing
)
delete 
from RownumCTE 
where row_num >1

--- delete unused columns ---

select* 
from protofolioProject..nashvellihousing

alter table protofolioProject..nashvellihousing
drop column OwnerAddress,TaxDistrict, SaleDate,PropertyAddress



