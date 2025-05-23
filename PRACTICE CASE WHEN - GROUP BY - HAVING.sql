-------------Bài tập 1: Những sản phẩm có giá bán từ 50$ là sản phẩm thuộc loại 'Gía trị cao', còn lại 'Gía trị thấp'
select *,
	case
		when Price >= 50 then N'Giá trị cao'
		else N'Giá trị thấp'
	end as Type
from MX_SANPHAM;

-------------Bài tập 2: tìm ra tổng doanh số và tổng số sản phẩm bán được của từng ProductCategoryID
select P.ProductCategoryID, 
	   count(H.QTY) as Total_Order,
	   sum(H.TotalLine) as Revenue
from MX_HOADON H 
join MX_SANPHAM P on H.ProductID = P.ProductID
group by P.ProductCategoryID
union all
select P.ProductCategoryID, 
	   count(HM.QTY) as Total_Order,
	   sum(HM.TotalLine) as Revenue
from MX_HOADONMOI HM 
join MX_SANPHAM P on HM.ProductID = P.ProductID
group by P.ProductCategoryID;

-------------Bài tập 3: tìm tổng doanh số của các nhân viên bán hàng Tổng doanh số trên 350$ thì hiển thị “Excellent Staff”,còn lại thì hiển thị “Normal Staff”

select H.SalesID,
	   sum(H.TotalLine) as Sum_sales,
	   case 
			when sum(H.TotalLine) > 350 then 'Excellent Staff'
			else 'Normal Staff'
	   end as sale_type
from MX_HOADON H
join MX_NHANVIEN E on H.SalesID = E.EmID
group by H.SalesID
union all
select HM.SalesID,
	   sum(HM.TotalLine) as Sum_sales,
	   case 
			when sum(HM.TotalLine) > 350 then 'Excellent Staff'
			else 'Normal Staff'
	   end as sale_type
from MX_HOADONMOI HM
join MX_NHANVIEN E on HM.SalesID = E.EmID
group by HM.SalesID;


--------------------Bài tập 4: tìm tổng số lượng sản phẩm được mua của từng category vào tháng 3, tháng 5 và tạo thêm trường thông tin hiển thị chi tiết tỷ lệ tăng/giảm bao nhiêu % của tháng 3 -5.
----CÁCH 1: SỬ DỤNG SELECT INTO
---Tổng số lượng sản phẩm bán ra trong tháng 3
select P.ProductCategoryID,
	   datepart(month,H.OrderDate) as M3,
	   cast(sum(H.QTY) AS float) as Total_product_M3
into M3 -----Thêm dữ liệu vào bảng mới với tên M3
from MX_HOADON H
join MX_SANPHAM P on H.ProductID = P.ProductID
group by P.ProductCategoryID, datepart(month,H.OrderDate);

SELECT * FROM M3
 
---Tổng số lượng sản phẩm bán ra trong tháng 5
select P.ProductCategoryID,
	   datepart(month,HM.OrderDate) as M5,
	   cast(sum(HM.QTY) as float) as Total_product_M5
into M5 -----Thêm dữ liệu vào bảng mới với tên M5
from MX_HOADONMOI HM
join MX_SANPHAM P on HM.ProductID = P.ProductID
group by P.ProductCategoryID, datepart(month,HM.OrderDate);

SELECT * FROM M5

---Gộp 2 bảng M3 và M5 -> Số sản phẩm bán được trong M3 & M5 và mức độ tăng/giảm giữa 2 tháng
Select M3.ProductCategoryID, M3.Total_product_M3, M5.Total_product_M5,
	   case
			when M5.Total_product_M5 / M3.Total_product_M3 > 1 then concat(N'Tăng',' ', M5.Total_product_M5 / M3.Total_product_M3)
			when M5.Total_product_M5 / M3.Total_product_M3 < 1 then concat(N'Giảm',' ', M5.Total_product_M5 / M3.Total_product_M3)
			else N'Không thay đổi'
		end as N'Tăng/Giảm'
from M3
join M5 on M3.ProductCategoryID = M5.ProductCategoryID
group by M3.ProductCategoryID, M3.Total_product_M3, M5.Total_product_M5;
----Cập nhật lại dữ liệu sai ở bảng MX_HOADON
UPDATE MX_HOADON
SET QTY = 2
WHERE ProductID = 'MXSP14';


------CÁCH 2: Làm bài bằng CTE
WITH M3 AS (
		SELECT P.ProductCategoryID,
			   DATEPART(MONTH, H.OrderDate) as Month3,
			   CAST(SUM(H.QTY) AS Float) as Total_M3
		FROM MX_SANPHAM P
		JOIN MX_HOADON H
		ON P.ProductID = H.ProductID
		GROUP BY P.ProductCategoryID, DATEPART(MONTH, H.OrderDate) 
		)
, 
M5 AS (
		SELECT P.ProductCategoryID,
			   DATEPART(MONTH, HM.OrderDate) as Month5,
			   CAST(SUM(HM.QTY) AS Float) as Total_M5
		FROM MX_SANPHAM P
		JOIN MX_HOADONMOI HM
		ON P.ProductID = HM.ProductID
		GROUP BY P.ProductCategoryID, DATEPART(MONTH, HM.OrderDate) 
		)
	SELECT M3.ProductCategoryID, M3.Total_M3, M5.Total_M5,
		CASE
			WHEN M5.Total_M5 / M3.Total_M3 > 1 THEN CONCAT(N'Tăng',' ', M5.Total_M5 / M3.Total_M3)
			WHEN M5.Total_M5 / M3.Total_M3 < 1 THEN CONCAT(N'Giảm',' ', M5.Total_M5 / M3.Total_M3)
			ELSE N'Không thay đổi'
		END AS N'Tăng/Giảm'
	FROM M3
	JOIN M5 ON M3.ProductCategoryID = M5.ProductCategoryID


---Cách khác:
select * from MX_SANPHAM
select * from MX_HOADONTONG

SELECT 
    P.ProductCategoryID,
    SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END) AS QRT_3,
    SUM(CASE WHEN MONTH(B.OrderDate) = 5 THEN B.QTY ELSE 0 END) AS QRT_5,
    CASE
        WHEN SUM(CASE WHEN MONTH(B.OrderDate) = 5 THEN B.QTY ELSE 0 END) > 
             SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END) 
        THEN CONCAT(N'Tăng ', 
                    ROUND(CAST((SUM(CASE WHEN MONTH(B.OrderDate) = 5 THEN B.QTY ELSE 0 END) - 
                                SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END)) 
                                AS FLOAT) * 100 / 
                                NULLIF(SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END), 0), 2), 
                    '%')

        WHEN SUM(CASE WHEN MONTH(B.OrderDate) = 5 THEN B.QTY ELSE 0 END) < 
             SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END) 
        THEN CONCAT(N'Giảm ', 
                    ROUND(CAST((SUM(CASE WHEN MONTH(B.OrderDate) = 5 THEN B.QTY ELSE 0 END) - 
                                SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END)) 
                                AS FLOAT) * 100 / 
                                NULLIF(SUM(CASE WHEN MONTH(B.OrderDate) = 3 THEN B.QTY ELSE 0 END), 0), 2), 
                    '%')

        ELSE N'Không thay đổi'
    END AS Tăng_giảm
FROM MX_SANPHAM P
JOIN MX_HOADONTONG B ON P.ProductID = B.ProductID
GROUP BY P.ProductCategoryID;
-------------------------------------------------------------------------------------------------END ------------------------------------------------------------------------------------------------------------------------------
