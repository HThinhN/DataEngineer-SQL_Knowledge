﻿-- Knowledge 4: Truy vấn lồng
USE SCHOOL_MANAGEMENT
----------------------------------------------------------------------------------------
-- 1. Giới thiệu truy vấn lồng
-- Định nghĩa: Truy vấn lồng là một câu truy vấn mà ở bên trong nội dung của nó có chứa một 
-- câu truy vấn con khác
-- Cú pháp: 
-- SELECT A
-- FROM X
-- WHERE ... (SELECT B FROM Y WHERE ...) ...

-- Phân loại: Dựa vào đặc điểm của câu truy vấn con người ta phân truy vấn lồng thành 2 loại chính:
-- + Truy vấn lồng phân cấp: Khi nội dung của câu truy vấn con độc lập với câu truy vấn cha
---- => Cú pháp: SELECT A
---------------- FROM X
---------------- WHERE ... (SELECT B,C FROM Y) ...
---- Ở ví dụ trên, câu truy vấn con SELECT B FROM Y không sử dụng bất kỳ thành phần nào của câu truy vấn cha.
---- Do đó đây là một câu truy vấn lồng phân cấp.
-- + Truy vấn lồng tương quan: Khi nội dung của câu truy vấn con phụ thuộc vào câu truy vấn cha
---- => Cú pháp: SELECT A
---------------- FROM X
---------------- WHERE ... (SELECT B,C FROM Y WHERE B = X.A)...
---- Ở ví dụ này, câu truy vấn con SELECT B,C FROM Y WHERE B = X.A có sử dụng thành phần của câu truy vấn cha qua
---- biểu thức so sánh B = X.A. Do đó, đây là một câu truy vấn lồng tương quan.

----------------------------------------------------------------------------------------
-- 2. Các vị trí của câu truy vấn con:
-- Câu truy vấn con có thể nằm ở vị trí bất kỳ trong câu truy vấn cha. Câu truy vấn con có thể đặt
-- tại mệnh đề SELECT, mệnh đề FROM hoặc thông thường nhất là ở mệnh đề WHERE

-- 2.1. Đặt tại mệnh đề SELECT
-- Kết quả của câu truy vấn sẽ như là một giá trị của một thuộc tính
-- Ví dụ 1: Với mỗi bộ môn, cho biết tên bộ môn và số lượng giáo viên của bộ môn đó
---- Dùng GROUP BY:
SELECT BM.TENBM, COUNT(*) AS SLGV
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM
GROUP BY BM.MABM, BM.TENBM

---- Sử dụng truy vấn lồng
SELECT BM.TENBM, (SELECT COUNT(*)
				  FROM GIAOVIEN AS GV
				  WHERE GV.MABM = BM.MABM) AS SLGV
FROM BOMON AS BM 

---- => Ta có thể xem cả những bộ môn có số lượng giáo viên là 0

-- 2.2. Đặt tại mệnh đề FROM
-- Kết quả của câu truy vấn sẽ xem như là 1 bảng dữ liệu, do vậy có thể truy
-- vấn từ bảng dữ liệu này

-- Ví dụ 2: Cho biết họ tên và lương của các giáo viên bộ môn HTTT
SELECT GVHTTT.HOTEN, GVHTTT.LUONG
FROM (SELECT *
	  FROM GIAOVIEN 
	  WHERE MABM = 'HTTT') AS GVHTTT

-- 2.3. Đặt tại mệnh đề WHERE
-- Kết quả của câu truy vấn được sử dụng như một thành phần trong biểu thức 
-- điều kiện

-- Ví dụ 3: Cho biết những giáo viên có lương lớn hơn lương của giáo viên có
-- MAGV = '001'
SELECT *
FROM GIAOVIEN GV
WHERE GV.LUONG > (SELECT LUONG
				  FROM GIAOVIEN
				  WHERE MAGV = '001')

----------------------------------------------------------------------------------------
-- 3. Truy vấn lồng phân cấp

-- 3.1. Truy vấn lồng phân cấp với toán tử IN
-- Toán tử IN dùng để kiểm tra một giá trị có nằm trong một tập hợp nào đó hay không.
-- Tập hợp đó có thể là kết quả của một câu truy vấn hoặc một tập hợp tường minh

-- Cú pháp của biểu thức điều kiện: [Thuộc tính] IN [Tập hợp]
-- ...[Thuộc tính] IN ( SELECT ...
--					    FROM ...
--						WHERE ...)
-- Hoặc 
-- [Thuộc tính] IN (Giá trị 1, giá trị 2, ..., giá trị n)

-- Ví dụ 4: Cho biết họ tên những giáo viên mà không có một người thân nào
SELECT GV.HOTEN
FROM GIAOVIEN AS GV
WHERE GV.MAGV NOT IN (SELECT MAGV
				  FROM NGUOITHAN)

-- Ví dụ 5: Cho biết những giáo viên có tham gia đề tài
SELECT *
FROM GIAOVIEN AS GV
WHERE GV.MAGV IN (SELECT MAGV FROM THAMGIADT)

-- 3.2. Truy vấn lồng phân cấp với toán tử ALL
-- Toán tử ALL được sử dụng với các toán tử so sánh số học: >, <, >=, <=, ...
-- Cú pháp của biểu thức điều kiện: 
-- [THUỘC TÍNH] [> | < | >= | <= | !=] ALL [TẬP HỢP]
-- Biểu thức điều kiện này cho chân trị đúng nếu giá trị của thuộc tính > | < | >= | <= | != 
-- mọi phần tử trong tập hợp

-- Ví dụ 6: Cho những giáo viên có lương nhỏ nhất
SELECT *
FROM GIAOVIEN 
WHERE LUONG <= ALL(SELECT LUONG 
				  FROM GIAOVIEN) 

-- Ví dụ 7: Cho những giáo viên có lương cao hơn tất cả các giáo viên của bộ môn HTTT
SELECT * 
FROM GIAOVIEN
WHERE LUONG >= ALL(SELECT LUONG 
				  FROM GIAOVIEN 
				  WHERE MABM = 'HTTT')

-- Ví dụ 8: Cho biết bộ môn (MABM) có đông giáo viên nhất
SELECT MABM
FROM GIAOVIEN 
GROUP BY MABM
HAVING COUNT(*) >= ALL(SELECT COUNT(*)
					FROM GIAOVIEN 
					GROUP BY MABM)

-- Ví dụ 9: Cho biết họ tên những giáo viên mà không có một người thân nào.
-- (Sử dụng ALL thay vì NOT IN)
---- NOT IN
SELECT HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN (SELECT MAGV
				   FROM NGUOITHAN)
---- ALL
SELECT HOTEN
FROM GIAOVIEN
WHERE MAGV != ALL(SELECT MAGV
				  FROM NGUOITHAN)

-- 3.3. Truy vấn lồng phân cấp với toán tử ANY, SOME
-- Cú pháp của sử dụng ANY và SOME tương tự với cú pháp sử dụng toán tử ALL. 
-- ALL được sử dụng khi muốn giá trị của thuộc tính thỏa mãn với tất cả các phần tử 
-- trong tập hợp theo toán tử số học được sử dụng. Ngược lại là ANY: bất kỳ, SOME: một vài

-- Ví dụ 10: Cho biết họ tên những giáo viên có tham gia đề tài. (Sử dụng = ANY thay vì IN)
---- IN
SELECT HOTEN
FROM GIAOVIEN 
WHERE MAGV IN (SELECT MAGV 
			   FROM THAMGIADT)

---- ANY
SELECT HOTEN
FROM GIAOVIEN
WHERE MAGV = ANY(SELECT MAGV
				 FROM THAMGIADT)

----------------------------------------------------------------------------------------
-- 4. Truy vấn lồng tương quan
-- 4.1. Truy vấn lồng tương quan với EXISTS
-- Cú pháp sử dụng EXISTS: 
-- + EXISTS thường được sử dụng trong biểu thức điều kiện:
-- ... EXISTS ( SELECT ...
--				FROM ...
--              WHERE ...)
-- + EXISTS thường dùng trong câu truy vấn lồng tương quan.

-- Ví dụ 11: Cho biết các giáo viên có tham gia đề tài
SELECT HOTEN 
FROM GIAOVIEN AS GV
WHERE EXISTS(SELECT MAGV
             FROM THAMGIADT AS TGDT
			 WHERE GV.MAGV = TGDT.MAGV)

-- Ví dụ 12: Cho biết các giáo viên không có người thân
SELECT *
FROM GIAOVIEN AS GV
WHERE NOT EXISTS(SELECT *
			 FROM NGUOITHAN AS NT
			 WHERE GV.MAGV = NT.MAGV)

-- 4.2. Một số dạng khác của truy vấn lồng tương quan

-- Ví dụ 14: Cho biết những giáo viên có lương lớn hơn lương trung bình của bộ môn mà giáo viên
-- đó làm việc

SELECT *
FROM GIAOVIEN AS GV
WHERE GV.LUONG > (SELECT AVG(GVBM.LUONG)
				  FROM GIAOVIEN AS GVBM
				  WHERE GVBM.MABM = GV.MABM)

-- Ví dụ 15: Cho biết những giáo viên có lương lớn nhất
-- Cách 1: 
SELECT *
FROM GIAOVIEN 
WHERE LUONG = (SELECT MAX(LUONG)
				  FROM GIAOVIEN)

-- Cách 2: 
SELECT *
FROM GIAOVIEN AS GV1
WHERE (SELECT COUNT(*)
       FROM GIAOVIEN AS GV2
	   WHERE GV1.LUONG < GV2.LUONG) = 0

-- Ví dụ 16: Cho biết những đề tài mà giáo viên '001' không tham gia 
---- Xem thông tin bảng DETAI, THAMGIADT
SELECT *
FROM DETAI

SELECT *
FROM THAMGIADT

-- NOT EXISTS
SELECT DT.*
FROM DETAI AS DT, GIAOVIEN AS GV
WHERE GV.MAGV = '001' AND NOT EXISTS (SELECT TGDT.MADT
									  FROM THAMGIADT AS TGDT
									  WHERE TGDT.MAGV = GV.MAGV AND TGDT.MADT= DT.MADT)

-- NOT IN
SELECT DT.* 
FROM DETAI AS DT, GIAOVIEN AS GV
WHERE GV.MAGV = '001' AND DT.MADT NOT IN (SELECT TGDT.MADT
									  FROM THAMGIADT AS TGDT
									  WHERE TGDT.MAGV = GV.MAGV AND TGDT.MADT= DT.MADT) 

----------------------------------------------------------------------------------------
-- 5. Một câu truy vấn có thể giải bằng nhiều cách:

-- Ví dụ 17: Cho biết họ tên những giáo viên có vai trò quản lý về mặt chuyên môn 
-- với các giáo viên khác

-- Cách 1: EXISTS
SELECT GVQLCM.HOTEN
FROM GIAOVIEN AS GVQLCM
WHERE EXISTS (SELECT * 
			  FROM GIAOVIEN AS GV
			  WHERE GV.GVQLCM = GVQLCM.MAGV)

-- Cách 2: IN
SELECT GVQLCM.HOTEN 
FROM GIAOVIEN AS GVQLCM
WHERE GVQLCM.MAGV IN (SELECT GVQLCM 
					  FROM GIAOVIEN) 

-- Cách 3: Phép kết thông thường, cùng từ khóa DISTINCT
SELECT DISTINCT GVQLCM.HOTEN
FROM GIAOVIEN AS GVQLCM JOIN GIAOVIEN AS GV ON GV.GVQLCM = GVQLCM.MAGV

----------------------------------------------------------------------------------------
-- 6. Truy vấn lồng với các hàm kết hợp và gom nhóm

-- Ví dụ 18: Cho biết những giáo viên có lương cao nhất
-- MAX
SELECT *
FROM GIAOVIEN 
WHERE LUONG = (SELECT MAX(LUONG) FROM GIAOVIEN)

-- ALL
SELECT *
FROM GIAOVIEN 
WHERE LUONG >= ALL(SELECT LUONG
				   FROM GIAOVIEN)

-- Ví dụ 19: Cho biết những bộ môn (MABM) có đông giáo viên nhất
-- ALL
SELECT MABM
FROM GIAOVIEN 
GROUP BY MABM
HAVING COUNT(*) >= ALL(SELECT COUNT(*)
					   FROM GIAOVIEN
					   GROUP BY MABM)

-- MAX
SELECT MABM
FROM GIAOVIEN 
GROUP BY MABM
HAVING COUNT(*) = (SELECT MAX(SLGV_BM.SLGV)
				   FROM (SELECT COUNT(*) AS SLGV
				         FROM GIAOVIEN 
						 GROUP BY MABM) AS SLGV_BM)

-- Ví dụ 20: Cho biết những tên bộ môn, họ tên của trưởng bộ môn và số lượng giáo viên của
-- bộ môn có đông giáo viên nhất
SELECT BM.TENBM, TRUONGBOMON.HOTEN AS TRUONGBM, COUNT(*) AS SLGV
FROM BOMON AS BM, GIAOVIEN AS GV, GIAOVIEN AS TRUONGBOMON
WHERE BM.MABM = GV.MABM AND TRUONGBOMON.MAGV = BM.TRUONGBM
GROUP BY BM.MABM, BM.TENBM, TRUONGBOMON.HOTEN
HAVING COUNT(*) >= ALL(SELECT COUNT(*)
					   FROM GIAOVIEN AS GVBM
					   GROUP BY GVBM.MABM)

-- Ví dụ 21: Cho biết những giáo viên có lương lớn hơn mức lương trung bình của giáo viên bộ môn
-- Hệ thống thông tin mà không trực thuộc bộ môn hệ thống thông tin
SELECT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM AND BM.TENBM != N'Hệ thống thông tin'
AND LUONG > (SELECT AVG(LUONG)
			 FROM GIAOVIEN AS GVHTTT, BOMON AS BMHTTT
			 WHERE GVHTTT.MABM = BMHTTT.MABM AND BMHTTT.TENBM = N'Hệ thống thông tin')

-- Ví dụ 22: Cho biết tên đề tài có đông giáo viên tham gia nhất
-- ALL
SELECT DT.TENDT
FROM DETAI AS DT, THAMGIADT AS TGDT
WHERE DT.MADT = TGDT.MADT
GROUP BY DT.MADT, DT.TENDT
HAVING COUNT(DISTINCT TGDT.MAGV) >= ALL(SELECT COUNT(DISTINCT MAGV)
										FROM THAMGIADT
										GROUP BY MADT)

-- MAX
SELECT DT.TENDT
FROM DETAI AS DT, THAMGIADT AS TGDT 
WHERE DT.MADT = TGDT.MADT
GROUP BY DT.MADT, DT.TENDT
HAVING COUNT(TGDT.MAGV) = (SELECT MAX(DT_SLGV.SLGV)
						   FROM (SELECT COUNT(MAGV) AS SLGV
								 FROM THAMGIADT
								 GROUP BY MADT) AS DT_SLGV)

----------------------------- END -----------------------------