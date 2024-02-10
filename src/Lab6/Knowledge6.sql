-- Knowledge 6: Truy vấn nâng cao
CREATE DATABASE TestDB_1
USE TestDB_1
----------------------------------------------------------------------------------------
-- 1. Các câu lệnh INSERT, UPDATE mở rộng
-- Hình thành các bảng thể hiện cho các quan hệ sau:
-- SINHVIEN (*MASV*, HOTEN, DIEMTB, HANG)
-- SINHVIENGIOI(*MASV*, HOTEN, DIEMTB)

CREATE TABLE SINHVIEN (
	MASV char(5) NOT NULL,
	HOTEN nvarchar(50),
	DIEMTB float,
	HANG int
)

ALTER TABLE SINHVIEN
ADD CONSTRAINT PK_SINHVIEN
PRIMARY KEY (MASV)

CREATE TABLE SINHVIENGIOI(
	MASV char(5) NOT NULL,
	HOTEN nvarchar(50),
	DIEMTB float
)

ALTER TABLE SINHVIENGIOI
ADD CONSTRAINT PK_SINHVIENGIOI
PRIMARY KEY (MASV)
-- Update dữ liệu: 
INSERT INTO SINHVIEN VALUES ('001', N'Nguyễn Hoàng Thịnh', 9.5, NULL)
INSERT INTO SINHVIEN VALUES ('002', N'Nguyễn Quỳnh Như', 8.5, NULL)
INSERT INTO SINHVIEN VALUES ('003', N'Nguyễn Nghiệp', 6.5, NULL)
INSERT INTO SINHVIEN VALUES ('004', N'Lê Anh Nguyên', 7.5, NULL)
INSERT INTO SINHVIEN VALUES ('005', N'Huỳnh Thị Mỹ Dung', 8, NULL)
INSERT INTO SINHVIEN VALUES ('006', N'Mai Trọng Hải', 9, NULL)
INSERT INTO SINHVIEN VALUES ('007', N'Nguyễn Đình Tuấn', 9.5, NULL)

DELETE FROM SINHVIEN
WHERE MASV = '007'

-- 1.1. UPDATE dữ liệu từ dữ liệu có sẵn

-- Ví dụ 5: Cập nhật hạng của sinh viên
UPDATE SINHVIEN
SET HANG = (SELECT COUNT(*)
			FROM SINHVIEN AS SV
			WHERE SV.DIEMTB >= SINHVIEN.DIEMTB)

-- Check:
SELECT *
FROM SINHVIEN

-- 1.2. INSERT dữ liệu vào một bảng từ một bảng có sẵn

-- Ví dụ 6: Thêm dữ liệu vào bảng SINHVIENGIOI các sinh viên 
-- trung bình từ 8.0 trở lên
INSERT INTO SINHVIENGIOI 
SELECT MASV, HOTEN, DIEMTB
FROM SINHVIEN
WHERE DIEMTB >= 8.0

-- Check: 
SELECT *
FROM SINHVIENGIOI


----------------------------------------------------------------------------------------
-- 2. Truy vấn với phép kết ngoài:
USE TestDB

CREATE TABLE LOP (
	MALOP char(5) NOT NULL,
	TENLOP char(5)
)

ALTER TABLE LOP
ADD CONSTRAINT PK_LOP
PRIMARY KEY (MALOP)

CREATE TABLE SINHVIEN (
	MASV char(5) NOT NULL,
	HOTEN nvarchar(40), 
	MALOP char(5) NOT NULL
)

ALTER TABLE SINHVIEN
ADD CONSTRAINT PK_SINHVIEN
PRIMARY KEY (MASV)

ALTER TABLE SINHVIEN
ADD CONSTRAINT FK_SINHVIEN_LOP
FOREIGN KEY (MALOP)
REFERENCES LOP

---- Insert dữ liệu

---- LOP
INSERT INTO LOP VALUES ('L1', '10A')
INSERT INTO LOP VALUES ('L2', '10B')
INSERT INTO LOP VALUES ('L3', '10C')

---- SINHVIEN
INSERT INTO SINHVIEN VALUES ('01', 'A', 'L1')
INSERT INTO SINHVIEN VALUES ('02', 'B', 'L2')
INSERT INTO SINHVIEN VALUES ('03', 'C', 'L2')
INSERT INTO SINHVIEN VALUES ('04', 'D', 'L1')
INSERT INTO SINHVIEN VALUES ('05', 'E', 'L1')

-- Yêu cầu: Cho biết sĩ số của mỗi lớp

-- 2.1. Inner joins (Kết bằng):
-- Phép kết Inner joins giữa 2 bảng A và B -> là một bảng C = 
-- {các bộ trong đó mỗi bộ là sự kết hợp của các bộ trong A với các bộ trong B sao cho
-- điều kiện kết được thỏa mãn}

-- C1: JOIN
SELECT *
FROM SINHVIEN AS SV JOIN LOP AS L ON SV.MALOP = L.MALOP

-- C2: Sử dụng điều kiện kết ở mệnh đề WHERE
SELECT *
FROM SINHVIEN AS SV, LOP AS L
WHERE SV.MALOP = L.MALOP

---- Tính sĩ số của lớp: 
SELECT L.TENLOP, COUNT(*) AS SISO 
FROM SINHVIEN AS SV JOIN LOP AS L ON SV.MALOP = L.MALOP
GROUP BY L.TENLOP

---- Nhận xét: Sĩ số của lớp 10C (bằng 0) không được xuất ra, vì thông tin lớp 10C
---- đã bị mất sau phép kết bằng. Do vậy với phép kết bằng thì những bộ không thỏa mãn 
---- điều kiện kết sẽ được loại bỏ. Nếu muốn xuất hiện -> Sử dụng phép kết ngoài.

-- 2.2. Right (Outer) joins (Kết phải)
-- Phép kết Right Outer joins giữa 2 bảng A và B -> là một bảng C = {các bộ trong đó 
-- mỗi bộ là sự kết hợp của các bộ trong A với các bộ trong B sao cho điều kiện kết 
-- được thỏa mãn} + {các bộ còn lại trong B mà không thỏa điều kiện kết với bất kỳ một
-- bộ trong A nào)

-- => Thực hiện phép kết Right (Outer) joins giữa SINHVIEN và LOP
SELECT * 
FROM SINHVIEN AS SV RIGHT JOIN LOP AS L ON SV.MALOP = L.MALOP

-- Nhận xét: Thông tin về lớp 10C vẫn được giữ lại sau phép kết phải


---- Tính sĩ số của lớp: 
SELECT L.TENLOP, COUNT(SV.MASV) AS SISO
FROM SINHVIEN AS SV RIGHT JOIN LOP AS L ON SV.MALOP = L.MALOP
GROUP BY L.TENLOP

---- Nhận xét: Sĩ số của các lớp không có học sinh (10C) vẫn được xuất ra (vì phép kết không
---- mất thông tin về lớp)

-- 2.3. Left (Outer) joins (Kết trái)
-- Phép kết Left (Outer) joins giữa 2 bảng A và B -> là một bảng C = {các bộ trong đó
-- mỗi bộ là sự kết hợp của các bộ trong A với các bộ trong B sao cho điều kiện kết được thỏa 
-- mãn} + {các bộ còn lại trong A mà không thỏa điều kiện kết với một bộ bất kỳ trong B nào)

-- 2.4. Full (Outer) joins
-- Phép kết Full Outer joins giữa 2 bảng A và B -> là một bảng C = {các bộ trong đó mỗi bộ là
-- sự kết hợp của các bộ trong A với các bộ trong B sao cho điều kiện kết được thỏa mãn} + 
-- {các bộ còn lại trong A mà không thỏa điều kiện kết với một bộ bất kỳ trong B nào} + 
-- {các bộ còn lại trong B mà không thỏa điều kiện kết với bất kỳ một bộ A nào}

-- Insert dữ liệu để thấy rõ hơn
ALTER TABLE SINHVIEN DROP 
CONSTRAINT FK_SINHVIEN_LOP

INSERT INTO SINHVIEN VALUES ('06', 'F', 'L4')

SELECT *
FROM SINHVIEN AS SV FULL JOIN LOP AS L ON SV.MALOP = L.MALOP

----------------------------------------------------------------------------------------
-- 3. Cấu trúc CASE:
USE SCHOOL_MANAGEMENT
-- 3.1. Cấu trúc 1: 
-- CASE input_expression 
--      WHEN when_expression THEN result_expression
--				[ ... n ]
--		[
--				ELSE else_result_expression
--		]
-- END

-- Ví dụ 7: Cho biết họ tên các giáo viên và năm về hưu
SELECT GV.HOTEN, 
(CASE GV.PHAI
	  WHEN 'Nam' THEN YEAR(GV.NGAYSINH) + 60
	  ELSE YEAR(GV.NGAYSINH) + 55
 END
) AS NAMVEHUU
FROM GIAOVIEN AS GV

-- Or 
SELECT GV.HOTEN, 
(CASE GV.PHAI
	  WHEN 'Nam' THEN YEAR(GV.NGAYSINH) + 60
	  WHEN N'Nữ' THEN YEAR(GV.NGAYSINH) + 55
 END
) AS NAMVEHUU
FROM GIAOVIEN AS GV

-- Ví dụ 8: Cho biết họ tên các giáo viên đã đến tuổi về hưu 
-- (nam 60 tuổi, nữ 55 tuổi)
SELECT GV.HOTEN AS GIAOVIENVEHUU
FROM GIAOVIEN AS GV
WHERE YEAR(GETDATE()) - YEAR(GV.NGAYSINH) >= (CASE GV.PHAI
												   WHEN 'Nam' THEN 60
												   ELSE 55
											  END) 

-- 3.1. Cấu trúc 2:

-- CASE
--      WHEN Boolean_expression THEN result_expression
--			 [ ... n ]
--		[
--			 ELSE
--		]
-- END

USE TestDB_1
-- Ví dụ 9: Cho biết sinh viên và xếp loại học lực của sinh viên
-- Xem thông tin bảng: 
SELECT * 
FROM SINHVIEN

-- Thực hiện: 
SELECT *,
(CASE
	  WHEN DIEMTB >= 8 THEN N'Giỏi'
	  WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN N'Khá'
	  ELSE N'Trung bình'
 END) AS XEPLOAIHOCLUC
FROM SINHVIEN 

----------------------------------------------------------------------------------------
-- 4. Tổng hợp dữ liệu sử dụng COMPUTE, COMPUTE BY, GROUP BY, CUBE, GROUP BY ROLLUP
USE SCHOOL_MANAGEMENT
-- 4.1. COMPUTE (SQL đã không còn hỗ trợ)
-- Sử dụng để tổng hợp dữ liệu của các bảng

-- Ví dụ 1: Cho biết các giáo viên, tổng lương, lương trung bình, min, max 
-- của tất cả các giáo viên
SELECT MAGV, HOTEN, SUM(LUONG) AS TONGLUONG, AVG(LUONG) AS LUONGTB, 
MIN(LUONG) AS LUONGMIN, MAX(LUONG) AS LUONGMAX
FROM GIAOVIEN
GROUP BY MAGV, HOTEN 

-- 4.2. COMPUTE BY (SQL đã không còn hỗ trợ)

-- Ví dụ 2: Cho biết tổng lương, lương trung bình của từng bộ môn
SELECT MABM, SUM(LUONG) AS TONGLUONG, AVG(LUONG) AS LUONGTB
FROM GIAOVIEN 
GROUP BY MABM
ORDER BY SUM(LUONG) DESC

-- 4.3. GROUP BY ... WITH CUBE

CREATE DATABASE TestDB_3
USE TestDB_3

CREATE TABLE ITEM(
	ITEMID int NOT NULL,
	ITEMNAME nvarchar(20),
	COLOR nvarchar(20), 
	QUANTITY int
)

ALTER TABLE ITEM 
ADD CONSTRAINT PK_ITEM
PRIMARY KEY (ITEMID)

INSERT INTO ITEM VALUES (1, 'Table', 'Blue', 124)
INSERT INTO ITEM VALUES (2, 'Table', 'Red', 223)
INSERT INTO ITEM VALUES (3, 'Chair', 'Blue', 101)
INSERT INTO ITEM VALUES (4, 'Chair', 'Red', 210)

-- Ví dụ 3: Tổng hợp số lượng của các item theo tên và màu, theo từng tên,
-- theo từng màu, tổng số item
SELECT ITEMNAME, COLOR, SUM(QUANTITY) AS TONGSOLUONG
FROM ITEM
GROUP BY ITEMNAME, COLOR WITH CUBE

-- Nhận xét:
-- Group by n thuộc tính -> sẽ thống kê theo 2^n tiêu chí
-- Những thống kê mà không có dữ liệu sẽ không được xuất ra

-- 4.4. GROUP BY ... WITH ROLLUP

-- Ví dụ 4: Tổng hợp số lượng của các item theo từng tên và màu, theo từng tên,
-- tổng số item
SELECT ITEMNAME, COLOR, SUM(QUANTITY) AS TONGSOLUONG
FROM ITEM
GROUP BY ITEMNAME, COLOR WITH ROLLUP

-- Theo từng màu và tên
SELECT ITEMNAME, COLOR, SUM(QUANTITY) AS TONGSOLUONG
FROM ITEM
GROUP BY COLOR, ITEMNAME WITH ROLLUP


----------------------------------------------------------------------------------------
-- 5. GROUP BY ... WITH CUBE | ROLLUP với GROUPING

---- 5.1. Trường hợp 1: 
SELECT *
FROM ITEM

INSERT INTO ITEM VALUES (5, 'XYZ', 'Red', 225)

-- Ví dụ 10a: Cho biết số lượng item ứng với (mỗi tên, mỗi màu), (từng tên), (từng màu)
SELECT ITEMNAME, COLOR, SUM(QUANTITY) AS TONGLUONG
FROM ITEM 
GROUP BY ITEMNAME, COLOR WITH CUBE

---- 5.2. Trường hợp 2 (Sửa dữ liệu) -> Vấn đề ???
UPDATE ITEM
SET ITEMNAME = NULL
WHERE ITEMID = 5

SELECT ITEMNAME, COLOR, SUM(QUANTITY) AS TONGLUONG
FROM ITEM 
GROUP BY ITEMNAME, COLOR WITH CUBE

-- Nhận xét: Không phân biết giá trị NULL ở đây hiểu là gì: là tên bằng NULL hay ý nghĩa là
-- tên bất kỳ => Giải pháp: Sử dụng Grouping để xác định

---- 5.3. Sử dụng GROUPING

-- Cú pháp: GROUPING(<tên thuộc tính>)
-- => Grouping nhằm kiểm tra xem giá trị của một thuộc tính ở kết quả của câu truy vấn
-- là do dữ liệu thực sự hay là do câu truy vấn tự phát sinh

-- Cụ thể:
-- + Nếu Grouping giá trị của thuộc tính tên (itemname) là 1 -> Giá trị NULL xuất hiện do 
-- mệnh đề CUBE => ý nghĩa là tên bất kỳ (do câu truy vấn tự phát sinh)
-- + Nếu Grouping giá trịnh của thuộc tính tên (itemname) là 0 -> Giá trị NULL có ý nghĩa 
-- là tên của item đó là NULL (do dữ liệu thực sự: itemname là NULL).

-- => Ví dụ:
-- Xem thông tin bảng:
SELECT *
FROM ITEM

SELECT ITEMNAME, COLOR, SUM(QUANTITY) AS TONGLUONG,
GROUPING (ITEMNAME) 'CHECK'
FROM ITEM 
GROUP BY ITEMNAME, COLOR WITH CUBE

----------------------------------------------------------------------------------------
-- 6. Sử dụng CASE ... END với Grouping
SELECT (CASE 
			 WHEN ITEMNAME IS NULL AND GROUPING(ITEMNAME) = 1 THEN N'Tên bất kỳ'
			 ELSE ITEMNAME
		END) AS ITEMNAME, 
	   (CASE
			 WHEN COLOR IS NULL AND GROUPING(COLOR) = 1 THEN N'Màu bất kỳ'
			 ELSE COLOR
	    END) AS COLOR, SUM(QUANTITY) AS TONGSOLUONG 
FROM ITEM 
GROUP BY ITEMNAME, COLOR WITH CUBE

------------------------------------- END -------------------------------------
