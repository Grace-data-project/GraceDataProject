/*BÀI TẬP 1: xây dựng cho mỗi phòng ban một VIEW */

---Phòng ban Head Office
create view V_Dep_Head as
	select *
	from MX_NHANVIEN
	Where DepName = N'Head Office'
---Phòng ban Finance
create view V_Dep_Finance as
	select *
	from MX_NHANVIEN
	Where DepName = N'Tài chính'
---Phòng ban Data
create view V_Dep_Data as
	select *
	from MX_NHANVIEN
	Where DepName = N'Data'
---Phòng ban Kế toán và sales
create view V_Dep_AccountingSales as
	select *
	from MX_NHANVIEN
	Where DepName = N'Kế toán' or DepName = N'Sales'
---Phòng ban Operation
create view V_Dep_Operation as
	select *
	from MX_NHANVIEN
	Where DepName = N'Nghiệp vụ'

/*BÀI TẬP 2: Tìm ra khoảng chênh lệch doanh số của nhân viên bán hàng có doanh số cao nhất, nhân viên có doanh số thấp nhất với trung bình doanh số bán hàng của tất cả các salesman*/
/*Kết hợp 2 bảng dữ liệu HOADON và HOADONMOI
Sử dụng SubQuery và CTE
Sử dụng UNION ALL
Sử dụng GROUP BY */

---Tạo bảng Sum_salesman từ tổng doanh thu của từng salesman
select 
	SalesID, 
	SUM(TotalLine) as Sum_sales
into 
	Sum_salesman
from 
	MX_HOADONTONG ---Union all 2 bảng HOADON & HOADONMOI
group by SalesID
--Tính mức chênh lệch
select 
	ss.SalesID,
	ss.Sum_sales,
	(select avg(ss.Sum_sales) from Sum_salesman ss ) as avg_salesman , --- tính doanh thu trung bình của các salesman
	ss.Sum_sales - (select avg(ss.Sum_sales) from Sum_salesman ss ) as range 
from Sum_salesman ss
where ss.Sum_sales = (select max(Sum_sales) from Sum_salesman ss) --- Salesman đem lại doanh thu cao nhất
or ss.Sum_sales = (select min(Sum_sales) from Sum_salesman ss) --- Salesman đem lại daonh thu thấp nhất

---Cách khác:
-----Tạo bảng Sum_salesman từ tổng doanh thu của từng salesman
select 
	SalesID, 
	SUM(TotalLine) as Sum_sales
into 
	Sum_salesman
from 
	MX_HOADONTONG ---Union all 2 bảng HOADON & HOADONMOI
group by SalesID;

-----Tạo bảng tb_avgsales từ bảng Sum_salesman để tính ra doanh thu trung bình của tất cả các salesman
select 
	avg(Sum_sales) as avg_sales
into 
	tb_avgsales
from 
	Sum_salesman;
----Kết hợp dữ liệu của 2 bằng bằng cross join
Select 
	s.SalesID, 
	s.Sum_sales , 
	a.avg_sales ,
	s.Sum_sales - avg_sales as range_sales
from 
	Sum_salesman s
cross join tb_avgsales a
where 
	s.Sum_sales = (select max(Sum_sales) from Sum_salesman)---Subquery lọc lấy giá trị có Sum_sales = với doanh thu lớn nhất/thấp nhất trong bảng Sum_salesman
or s.Sum_sales = (select min(Sum_sales) from Sum_salesman);

---Cách khác:
with sum_rev as (
    select 
	SalesID,
	sum(totalline) as sum_rev
	from MX_HOADONTONG
	group by SalesID
)

select
    SalesID, 
    sum_rev as 'max/min_rev',
	(select cast(avg(sum_rev) as int) from sum_rev) as 'average sales',
	(sum_rev - (select cast(avg(sum_rev) as int) from sum_rev)) as Range
from sum_rev
where sum_rev = (select min(sum_rev) from sum_rev)
union 
select
    SalesID, 
    sum_rev as 'max/min_rev',
	(select cast(avg(sum_rev) as int) from sum_rev) as 'average sales',
	(sum_rev - (select cast(avg(sum_rev) as int) from sum_rev)) as Range
from sum_rev
where sum_rev = (select max(sum_rev) from sum_rev)


/*BÀI TẬP 3: Bạn hãy tối ưu hoá bài tập 2 bằng cách sử dụng CTE*/

With sum_salesman as ( ---Tính tổng doanh số của từng Salesman
	Select 
		SalesID, 
		sum(TotalLine) as total_sales
	from 
		MX_HOADONTONG
	group by SalesID
),
max_min_salesman as ( --- Tìm salesman nào có doanh số lớn nhất và salesman nào có doanh số thấp nhất
	select 
		max(total_sales) as max_salesman,
		min(total_sales) as min_salesman
	from 
		sum_salesman
	
),
Avg_salesman as ( --- Tính doanh số trung bình của tất cả salesman
	select 
	avg(total_sales) as avg_sales
	from 
	sum_salesman 
) ---Tính khoảng chênh lệch
select 
	   SS.SalesID,
	   SS.total_sales as Max_MinSales,
	   ASM.avg_sales,
	   (SS.total_sales - ASM.avg_sales) as range
from Sum_salesman SS
cross join Avg_salesman ASM
where  SS.total_sales = (select max_salesman from max_min_salesman)
	or SS.total_sales = (select min_salesman from max_min_salesman)

---Cách khác:
with sum_rev as (
    select 
	SalesID,
	sum(totalline) as sum_rev
	from MX_HOADONTONG
	group by SalesID
),
--bảng value_rev chứa các giá trị tính toán: min, max, avg
value_rev as 
(
	select
		cast(avg(sum_rev) as int) as avg_sales,
		min(sum_rev) as min_value,
		max(sum_rev) as max_value
	from sum_rev
)
select
    SalesID, 
	min_value as 'Min/Max sales',
	avg_sales as 'average sales',
	sum_rev - avg_sales as Range
from sum_rev, value_rev
where sum_rev = min_value
union 
select
    SalesID, 
	max_value as 'Min/Max sales',
	avg_sales as 'average sales',
	sum_rev - avg_sales as Range
from sum_rev, value_rev
where sum_rev = max_value

/*BÀI TẬP 4: *Với mỗi sản phẩm, hãy tìm ra khách hàng nào mua nó nhiều nhất*/

With total_qty_by_cus as ( ---Số lượng mỗi sản phẩm của từng khách hàng mua
 Select 
	ProductID,
	CusID,
	Sum(Qty) as qty_pro
 from MX_HOADONTONG
 group by CusID,
	ProductID
),
max_pro_by_cus as (
select 
	tt.ProductID,
	tt.CusID,
	tt.qty_pro,
	rank() over ( partition by tt.ProductID order by tt.qty_pro DESC) as ranked ---sắp xếp sản phẩm theo số lượng của mỗi khách hàng mua
from total_qty_by_cus tt
)
Select 
	ProductID,
	CusID,
	qty_pro
from max_pro_by_cus
where ranked = 1 ---Lấy ra những khách hàng mua số lượng nhiều nhất của từng mã sản phẩm

/*Cách khác:*/

with total_pro_cus as(
select 
	ProductID, CusID,
	cast(sum(QTY) as int) as total_order
from MX_HOADONTONG
group by CusID,ProductID ),

--tìm max của từng sản phẩm
max_pro as(
select
	ProductID,
	max (total_order) as Total_Orders
from total_pro_cus
group by ProductID )

--Tìm ra khách hàng 
select 
max_pro.ProductID,
total_pro_cus.CusID,
Total_Orders
from total_pro_cus
JOIN max_pro ON max_pro.ProductID = total_pro_cus.ProductID
WHERE total_pro_cus.total_order = max_pro.Total_Orders

/*Cập nhật dữ liệu bị sai*/
update MX_HOADONTONG
set Qty = 2
Where CusID = 'KH014' AND ProductID = 'MXSP14'


/*BÀI TẬP 5:  Với mỗi category, hãy tìm chênh lệch doanh số bán hàng của sản phẩm mang lại doanh số cao nhất và thấp nhất của category đó.*/

With total_rev_cate as( ---Tổng doanh số bán hàng của từng sản phẩm trong  category 
	select 
		sp.ProductCategoryID,
		hdt.ProductID, 
		sum(hdt.TotalLine) as total_rev
	from MX_HOADONTONG hdt
	join MX_SANPHAM sp
	on hdt.ProductID = sp.ProductID
	group by sp.ProductCategoryID, hdt.ProductID
),
maxmin_rev as ( --- doanh thu cao nhất và thấp nhất của từng sp trong category
	select 
		ProductCategoryID,
		max(total_rev) as max_rev,
		min(total_rev) as min_rev
	from total_rev_cate 
	group by 
		ProductCategoryID
)
select -- chênh lệch doanh số bán hàng của sản phẩm mang lại doanh số cao nhất và thấp nhất của category
	ProductCategoryID,
	max_rev - min_rev as range_rev
from maxmin_rev 

