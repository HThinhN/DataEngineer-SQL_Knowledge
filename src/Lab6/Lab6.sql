-- Lab 6: Truy vấn nâng cao
USE SCHOOL_MANAGEMENT

----------------------------------------------------------------------------------------
-- Yêu cầu: Viết các câu truy vấn cho bài tập Quản lý đề tài bằng ngôn ngữ SQL

-- Q75. Cho biết họ tên giáo viên và tên bộ môn họ làm trưởng bộ môn nếu có
SELECT GV.HOTEN, BM.TENBM AS TRUONGBM
FROM GIAOVIEN AS GV LEFT JOIN BOMON AS BM 
ON GV.MAGV = BM.TRUONGBM

-- Q76. Cho danh sách tên bộ môn và họ tên trưởng bộ môn đó nếu có
SELECT BM.TENBM, GV.HOTEN AS TRUONGBM
FROM BOMON AS BM LEFT JOIN GIAOVIEN AS GV
ON BM.TRUONGBM = GV.MAGV

-- Q77. Cho danh sách tên giáo viên và các đề tài giáo viên đó chủ nhiệm
-- nếu có
SELECT GV.HOTEN, DT.TENDT AS DTCN
FROM GIAOVIEN AS GV LEFT JOIN DETAI AS DT 
ON GV.MAGV = DT.GVCNDT

-- Q78. Xuất ra thông tin của giáo viên (MAGV, HOTEN) và mức lương của giáo viên. Mức lương
-- được xếp theo quy tắc: Lương của giáo viên < $1800: "THẤP"; Từ $1800 đến $2200: "TRUNG BÌNH";
-- Lương > $2200: "CAO".
SELECT MAGV, HOTEN, 
(CASE 
		WHEN LUONG < 1800 THEN N'Thấp'
		WHEN 1800 <= LUONG AND LUONG <= 2200 THEN N'Trung bình'
		ELSE 'Cao'
 END) AS MUCLUONG
FROM GIAOVIEN 

-- Q79. Xuất ra thông tin giáo viên (MAGV, HOTEN) và xếp hạng dựa vào mức lương. Nếu giáo viên 
-- có lương cao nhất thì hạng là 1
SELECT GV.MAGV, GV.HOTEN, LUONG, (SELECT COUNT(*)
							      FROM GIAOVIEN AS GVK
								  WHERE GV.LUONG <= GVK.LUONG
								  AND GV.MAGV != GVK.MAGV) AS HANG
FROM GIAOVIEN AS GV 

-- Q80. Xuất ra thông tin thu nhập của giáo viên. Thu nhập của giáo viên được tính bằng 
-- LUONG + PHUCAP. Nếu giáo viên là trưởng bộ môn thì PHUCAP là 300, và giáo viên là
-- trưởng khoa thì PHUCAP là 600
SELECT GV.MAGV, GV.HOTEN, GV.LUONG,
MAX(CASE 
	  WHEN GV.MAGV = BM.TRUONGBM AND GV.MAGV = K.TRUONGKHOA THEN LUONG + 900
	  WHEN GV.MAGV = BM.TRUONGBM THEN LUONG + 300
	  WHEN GV.MAGV = K.TRUONGKHOA THEN LUONG + 600
	  ELSE LUONG
    END) AS THUNHAP
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
GROUP BY GV.MAGV, GV.HOTEN, GV.LUONG

-- Có giáo viên nào vừa là trưởng khoa vừa là trưởng bộ môn thì thêm điều kiện là oke
SELECT GV.MAGV
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
WHERE GV.MAGV = BM.TRUONGBM AND GV.MAGV = K.TRUONGKHOA

-- Q81. Xuất ra năm mà giáo viên dự kiến sẽ nghỉ hưu với quy định: Tuổi nghỉ hưu của Nam
-- là 60, của Nữ là 55.
SELECT MAGV, HOTEN, 
(CASE PHAI
		WHEN 'Nam' THEN YEAR(NGAYSINH) + 60
		ELSE YEAR(NGAYSINH) + 55
 END) AS NAMNGHIHUU
FROM GIAOVIEN

---------------------------------------------------------------------------------------------
-- Q82. Cho biết danh sách tất cả giáo viên (MAGV, HOTEN) và họ tên giáo viên là quản lý
-- chuyên môn của họ
SELECT GV.MAGV, GV.HOTEN, NQL.HOTEN
FROM GIAOVIEN AS GV LEFT JOIN GIAOVIEN AS NQL 
ON GV.GVQLCM = NQL.MAGV

-- Q83. Cho biết danh sách tất cả các bộ môn (MABM, TENBM), tên trưởng bộ môn cùng số lượng
-- giáo viên của mỗi bộ môn
SELECT BM.MABM, BM.TENBM, TRUONGBM.HOTEN AS TRUONGBM, COUNT(GV.MAGV) AS SLGV
FROM BOMON AS BM LEFT JOIN GIAOVIEN AS TRUONGBM ON BM.TRUONGBM = TRUONGBM.MAGV  
LEFT JOIN GIAOVIEN AS GV ON GV.MABM = BM.MABM
GROUP BY BM.MABM, BM.TENBM, TRUONGBM.HOTEN

-- Q84. Cho biết danh sách tất cả các giáo viên nam và thông tin các công việc mà họ
-- đã tham gia
-- Xem thông tin các bảng:
SELECT *
FROM GIAOVIEN 

SELECT *
FROM CONGVIEC

SELECT *
FROM THAMGIADT
-- Update dữ liệu
INSERT INTO GIAOVIEN VALUES ('012', N'Nguyễn Hoàng Thịnh', 3000, 'Nam', '2002-03-13', '505/1 Kinh Dương Vương, Q. Bình Tân, TP HCM', NULL, 'HTTT')
-- Thực hiện:
SELECT GV.MAGV, GV.HOTEN, CV.*
FROM GIAOVIEN AS GV LEFT JOIN THAMGIADT AS TGDT ON GV.MAGV = TGDT.MAGV LEFT JOIN CONGVIEC AS CV ON CV.MADT = TGDT.MADT AND CV.STT = TGDT.STT
WHERE GV.PHAI = 'Nam'

-- Q85. Cho biết danh sách tất cả các giáo viên và thông tin các công việc thuộc đề tài 001 mà họ tham gia
SELECT DISTINCT GV.MAGV, GV.HOTEN, CV.*
FROM GIAOVIEN AS GV LEFT JOIN THAMGIADT AS TGDT 
ON GV.MAGV = TGDT.MAGV AND TGDT.MADT = '001' LEFT JOIN CONGVIEC AS CV ON CV.MADT = TGDT.MADT 
AND CV.STT = TGDT.STT 

-- Q86. Cho biết thông tin các trưởng bộ môn (magv, hoten) đã về hưu trước năm 2014. Biết rằng độ tuổi về hưu
-- của giáo viên nam là 60 còn giáo viên nữ là 55 (Sửa đề)
SELECT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MAGV = BM.TRUONGBM
AND (CASE GV.PHAI
		   WHEN N'Nữ' THEN 55
		   WHEN 'Nam' THEN 60
	 END) <= 2014 - YEAR(GV.NGAYSINH) 

-- Q87. Cho biết thông tin các trưởng khoa (magv) và năm họ sẽ về hưu
SELECT GV.*, 
(CASE GV.PHAI
	   WHEN N'Nữ' THEN YEAR(NGAYSINH) + 55
	   ELSE YEAR(NGAYSINH) + 60
 END) AS NAMVEHUU
FROM GIAOVIEN AS GV, KHOA AS K
WHERE GV.MAGV = K.TRUONGKHOA

-- Q88. Tạo bảng DANHSACHTHIDUA(MAGV, SODTDAT, DANHHIEU) gồm thông tin mã giáo viên, số đề tài
-- họ tham gia đạt kết quả và danh hiệu thi đua:
-- a. Insert dữ liệu cho bảng này (để trống cột danh hiệu)
-- b. Dựa và cột SODTDAT (Số lượng đề tài tham gia có kết quả là "Đạt") để cập nhật dữ liệu cho
-- cột danh hiệu theo quy định:
-- i. SODTDAT = 0 thì danh hiệu N'Chưa hoàn thành nhiệm vụ'
-- ii. 1 <= SODTDAT <= 2 thì danh hiệu N'Hoàn thành nhiệm vụ'
-- iii. 3 <= SODTDAT <= 5 thì danh hiệu N'Tiên tiến'
-- iv. SODTDAT >= 6 thì danh hiệu N'Lao động xuất sắc'

-- Create table DANHSACHTHIDUA
CREATE TABLE DANHSACHTHIDUA(
	MAGV char(5) NOT NULL, 
	SODTDAT int,
	DANHHIEU nvarchar(30)
)

ALTER TABLE DANHSACHTHIDUA
ADD CONSTRAINT PK_DANHSACHTHIDUA
PRIMARY KEY (MAGV)

ALTER TABLE DANHSACHTHIDUA
ADD CONSTRAINT FK_DANHSACHTHIDUA_GIAOVIEN
FOREIGN KEY (MAGV)
REFERENCES GIAOVIEN

-- a. Insert dữ liệu cho bảng này (để trống cột danh hiệu)
INSERT INTO DANHSACHTHIDUA VAlUES ('001', NULL, NULL)
INSERT INTO DANHSACHTHIDUA VAlUES ('002', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('003', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('004', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('005', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('006', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('007', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('008', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('009', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('010', NULL, NULL) 
INSERT INTO DANHSACHTHIDUA VAlUES ('011', NULL, NULL)
INSERT INTO DANHSACHTHIDUA VAlUES ('012', NULL, NULL)

SELECT *
FROM THAMGIADT

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '001' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '001'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '002' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '002'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '003' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '003'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '004' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '004'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '005' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '005'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '006' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '006'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '007' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '007'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '008' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '008'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '009' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '009'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '010' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '010'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '011' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '011'

UPDATE DANHSACHTHIDUA
SET SODTDAT = (SELECT COUNT(*)
			   FROM THAMGIADT AS TGDT
			   WHERE TGDT.MAGV = '012' AND TGDT.KETQUA = N'Đạt')
WHERE MAGV = '012'

SELECT *
FROM DANHSACHTHIDUA

-- b. Dựa và cột SODTDAT (Số lượng đề tài tham gia có kết quả là "Đạt") để cập nhật dữ liệu cho
-- cột danh hiệu theo quy định:
-- i. SODTDAT = 0 thì danh hiệu N'Chưa hoàn thành nhiệm vụ'
-- ii. 1 <= SODTDAT <= 2 thì danh hiệu N'Hoàn thành nhiệm vụ'
-- iii. 3 <= SODTDAT <= 5 thì danh hiệu N'Tiên tiến'
-- iv. SODTDAT >= 6 thì danh hiệu N'Lao động xuất sắc'

UPDATE DANHSACHTHIDUA
SET DANHHIEU = (SELECT (CASE 
							 WHEN SODTDAT = 0 THEN N'Chưa hoàn thành nhiệm vụ'
							 WHEN (1 <= SODTDAT) AND (SODTDAT <= 2) THEN N'Hoàn thành nhiệm vụ'
							 WHEN (3 <= SODTDAT) AND (SODTDAT <= 5) THEN N'Tiên tiến'
							 ELSE N'Lao động xuất sắc'
						END))

SELECT *
FROM DANHSACHTHIDUA

-- Q89. Cho biết magv, họ tên và mức lương các giáo viên nữ của khoa "Công nghệ thông tin". (Phần 1)
-- (Phần tiếp theo sẽ được tách riêng vì cú pháp COMPUTE đã không còn được hỗ trợ)
-- Mức lương trung bình, mức lương lớn nhất và nhỏ nhất của các giáo viên này. (Phần 2)

-- Phần 1: 
SELECT GV.MAGV, GV.HOTEN, GV.LUONG
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA
AND K.TENKHOA = N'Công nghệ thông tin' AND GV.PHAI = N'Nữ'

-- Phần 2: 
SELECT K.TENKHOA AS GV_NU, AVG(GV.LUONG) AS MUCLUONGTB, MAX(GV.LUONG) AS MUCLUONGLN, MIN(GV.LUONG) AS MUCLUONGNN
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA
AND K.TENKHOA = N'Công nghệ thông tin' AND GV.PHAI = N'Nữ'
GROUP BY K.TENKHOA 

-- Q90. Cho biết MAKHOA, TENKHOA, số lượng giáo viên từng khoa (Phần 1)
-- Số lượng giáo viên trung bình, lớn nhất và nhỏ nhất của các khoa này (Phần 2)

-- Phần 1:
SELECT K.MAKHOA, K.TENKHOA, COUNT(DISTINCT GV.MAGV) AS SLGV
FROM KHOA AS K, BOMON AS BM, GIAOVIEN AS GV
WHERE K.MAKHOA = BM.MAKHOA AND BM.MABM = GV.MABM
GROUP BY K.MAKHOA, K.TENKHOA

-- Phần 2:
SELECT K.MAKHOA, K.TENKHOA, AVG(THONGTIN.SLGV) AS SLTB, MAX(THONGTIN.SLGV) AS SLLN, MIN(THONGTIN.SLGV) AS SLNN
FROM KHOA AS K, BOMON AS BM, GIAOVIEN AS GV, (SELECT COUNT(DISTINCT GV.MAGV) AS SLGV
											  FROM KHOA AS K, BOMON AS BM, GIAOVIEN AS GV
											  WHERE K.MAKHOA = BM.MAKHOA AND BM.MABM = GV.MABM
											  GROUP BY K.MAKHOA, K.TENKHOA) AS THONGTIN
WHERE K.MAKHOA = BM.MAKHOA AND BM.MABM = GV.MABM
GROUP BY K.MAKHOA, K.TENKHOA

-- Q91. Cho biết danh sách các tên chủ đề, kinh phí cho chủ đề (là kinh phí cấp cho các đê tài
-- thuộc chủ đề), tổng kinh phí, kinh phí lớn nhất và nhỏ nhất cho các chủ đề
-- Xem thông tin các bảng:
SELECT *
FROM CHUDE

SELECT *
FROM DETAI

-- Thực hiện:
SELECT DT.TENDT, CD.TENCD, DT.KINHPHI,SUM(THONGTIN.KINHPHI) AS TKP,
MAX(THONGTIN.KINHPHI) AS KPLN, MIN(THONGTIN.KINHPHI) AS KPNN 
FROM CHUDE AS CD, DETAI AS DT, (SELECT KINHPHI
								FROM DETAI) AS THONGTIN
WHERE CD.MACD = DT.MACD
GROUP BY DT.TENDT, CD.TENCD, DT.KINHPHI

-- Q92. Cho biết madt, tendt, kinh phí đề tài, mức kinh phí tổng và trung bình của
-- các đề tài này theo từng giáo viên chủ nhiệm
-- Xem thông tin các bảng:
SELECT *
FROM DETAI

-- Update dữ liệu để test:
UPDATE DETAI 
SET KINHPHI = 30
WHERE GVCNDT = '002' AND MADT = '001'

SELECT DT.GVCNDT, DT.MADT, DT.TENDT, DT.KINHPHI, SUM(THONGTIN.TKP) AS TONGKINHPHI , AVG(THONGTIN.KPTB) AS KINHPHITB
FROM DETAI AS DT, (SELECT GVCNDT, SUM(KINHPHI) AS TKP, AVG(KINHPHI) AS KPTB
			       FROM DETAI 
				   GROUP BY GVCNDT) AS THONGTIN
WHERE DT.GVCNDT = THONGTIN.GVCNDT
GROUP BY DT.GVCNDT, DT.MADT, DT.TENDT, DT.KINHPHI

SELECT GVCNDT, SUM(KINHPHI) AS TKP, AVG(KINHPHI) AS KPTB
FROM DETAI 
GROUP BY GVCNDT

-- Q93. Cho biết madt, tendt, kinh phí đề tài, mức kinh phí tổng và trung bình của các đề tài này
-- theo từng cấp độ đề tài.
-- Xem thông tin các bảng:
SELECT *
FROM DETAI

-- Thực hiện:
SELECT DT.CAPQL, DT.MADT, DT.TENDT, DT.KINHPHI, SUM(THONGTIN.TKP) AS TKP, AVG(THONGTIN.KPTB) AS KPTB
FROM DETAI AS DT, (SELECT CAPQL, SUM(KINHPHI) AS TKP, AVG(KINHPHI) AS KPTB
				   FROM DETAI 
				   GROUP BY CAPQL) AS THONGTIN
WHERE THONGTIN.CAPQL = DT.CAPQL
GROUP BY DT.CAPQL, DT.MADT, DT.TENDT, DT.KINHPHI

-- Q94. Tổng hợp số lượng các đề tài theo (cấp độ, chủ đề), theo (cấp độ), theo (chủ đề)
-- Xem thông tin các bảng:
SELECT *
FROM DETAI

-- Thực hiện
---- Theo (cấp độ, chủ đề)
SELECT (CASE
			 WHEN GROUPING(DT.CAPQL) = 0 THEN DT.CAPQL
			 WHEN GROUPING(DT.CAPQL) = 1 THEN N'Cấp độ quản lý bất kỳ'
		END) AS CAPQL
, (CASE
			 WHEN GROUPING(CD.TENCD) = 0 THEN CD.TENCD
			 WHEN GROUPING(CD.TENCD) = 1 THEN N'Chủ đề bất kỳ'
   END) AS TENCD, COUNT(*) AS SLDT
FROM DETAI AS DT, CHUDE AS CD
WHERE DT.MACD = CD.MACD
GROUP BY DT.CAPQL, CD.TENCD WITH CUBE

---- Theo (cấp độ)
SELECT (CASE
			 WHEN GROUPING(DT.CAPQL) = 0 THEN DT.CAPQL
			 WHEN GROUPING(DT.CAPQL) = 1 THEN N'Cấp độ quản lý bất kỳ'
		END) AS CAPQL
, (CASE
			 WHEN GROUPING(CD.TENCD) = 0 THEN CD.TENCD
			 WHEN GROUPING(CD.TENCD) = 1 THEN N'Chủ đề bất kỳ'
   END) AS TENCD, COUNT(*) AS SLDT
FROM DETAI AS DT, CHUDE AS CD
WHERE DT.MACD = CD.MACD
GROUP BY CD.TENCD, DT.CAPQL WITH ROLLUP

---- Theo (chủ đề) bất kỳ
SELECT (CASE
			 WHEN GROUPING(CD.TENCD) = 0 THEN CD.TENCD
			 WHEN GROUPING(CD.TENCD) = 1 THEN N'Chủ đề bất kỳ'
   END) AS TENCD,
       (CASE
			 WHEN GROUPING(DT.CAPQL) = 0 THEN DT.CAPQL
			 WHEN GROUPING(DT.CAPQL) = 1 THEN N'Cấp độ quản lý bất kỳ'
		END) AS CAPQL, COUNT(*) AS SLDT
FROM DETAI AS DT, CHUDE AS CD
WHERE DT.MACD = CD.MACD
GROUP BY DT.CAPQL, CD.TENCD WITH ROLLUP

-- Q95. Tổng hợp mức lương tổng của các giáo viên theo (bộ môn, phái), theo (bộ môn)
---- Theo (bộ môn, phái)
SELECT (CASE 
			 WHEN GROUPING(BM.TENBM) = 0 THEN BM.TENBM
			 WHEN GROUPING(BM.TENBM) = 1 THEN N'Bộ môn bất kỳ'
		END) AS BOMON, 
	   (CASE
			 WHEN GROUPING(GV.PHAI) = 0 THEN GV.PHAI
			 WHEN GROUPING(GV.PHAI) = 1 THEN N'Phái bất kỳ'
	    END) AS PHAI, SUM(GV.LUONG) AS TONGLUONG
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM
GROUP BY BM.TENBM, GV.PHAI WITH CUBE

---- Theo (bộ môn)
SELECT (CASE 
			 WHEN GROUPING(BM.TENBM) = 0 THEN BM.TENBM
			 WHEN GROUPING(BM.TENBM) = 1 THEN N'Bộ môn bất kỳ'
		END) AS BOMON, 
	   (CASE
			 WHEN GROUPING(GV.PHAI) = 0 THEN GV.PHAI
			 WHEN GROUPING(GV.PHAI) = 1 THEN N'Phái bất kỳ'
	    END) AS PHAI, SUM(GV.LUONG) AS TONGLUONG
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM
GROUP BY GV.PHAI, BM.TENBM WITH ROLLUP

-- Q96. Tổng hợp số lượng các giáo viên của khoa CNTT theo (bộ môn, lương), theo (bộ môn), theo (lương).
-- Theo (bộ môn, lương): 0 ở LUONG đại diện cho lương bất kỳ
SELECT (CASE
			 WHEN GROUPING(BM.TENBM) = 0 THEN BM.TENBM
			 WHEN GROUPING(BM.TENBM) = 1 THEN N'Bộ môn bất kỳ'
		END) AS BOMON, 
	   (CASE
			 WHEN GROUPING(GV.LUONG) = 0 THEN GV.LUONG
			 WHEN GROUPING(GV.LUONG) = 1 THEN 0
		END) AS LUONG, COUNT(*) AS SLGV
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = 'CNTT'
GROUP BY BM.TENBM, GV.LUONG WITH CUBE

-- Theo (bộ môn)
SELECT (CASE
			 WHEN GROUPING(BM.TENBM) = 0 THEN BM.TENBM
			 WHEN GROUPING(BM.TENBM) = 1 THEN N'Bộ môn bất kỳ'
		END) AS BOMON, 
	   (CASE
			 WHEN GROUPING(GV.LUONG) = 0 THEN GV.LUONG
			 WHEN GROUPING(GV.LUONG) = 1 THEN 0
		END) AS LUONG, COUNT(*) AS SLGV
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = 'CNTT'
GROUP BY GV.LUONG, BM.TENBM WITH ROLLUP

-- Theo (lương)
SELECT (CASE
			 WHEN GROUPING(BM.TENBM) = 0 THEN BM.TENBM
			 WHEN GROUPING(BM.TENBM) = 1 THEN N'Bộ môn bất kỳ'
		END) AS BOMON, 
	   (CASE
			 WHEN GROUPING(GV.LUONG) = 0 THEN GV.LUONG
			 WHEN GROUPING(GV.LUONG) = 1 THEN 0
		END) AS LUONG, COUNT(*) AS SLGV
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = 'CNTT'
GROUP BY BM.TENBM, GV.LUONG WITH ROLLUP

---------------------------------------- END ----------------------------------------