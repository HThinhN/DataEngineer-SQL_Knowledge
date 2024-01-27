-- Lab 1: Định nghĩa cấu trúc cơ sở dữ liệu bằng ngôn ngữ SQL
-- Phần 1: Viết script tạo cấu trúc và nhập dữ liệu cho tất cả các bảng trong bài tập
-- Quản lý Giáo viên tham gia đề tài

-----------------------------------------------------------------------
-- Tạo database 
CREATE DATABASE SCHOOL_MANAGEMENT
-- Sử dụng database
USE SCHOOL_MANAGEMENT
-- Drop database
DROP DATABASE SCHOOL_MANAGEMENT

-----------------------------------------------------------------------
-- Tạo tables:
CREATE TABLE GIAOVIEN
(
	MAGV char(5) NOT NULL,
	HOTEN nvarchar(40),
	LUONG float,
	PHAI nchar(3),
	NGAYSINH datetime,
	DIACHI nvarchar(50),
	GVQLCM char(5),
	MABM char(5)
	PRIMARY KEY (MAGV)
)

--ALTER TABLE GIAOVIEN
--ALTER COLUMN LUONG float

CREATE TABLE GV_DT
(
	MAGV char(5) NOT NULL,
	DIENTHOAI char(15) NOT NULL
	PRIMARY KEY(MAGV, DIENTHOAI)
)

CREATE TABLE BOMON
(
	MABM char(5) NOT NULL, 
	TENBM nvarchar(30), 
	PHONG char(5),
	DIENTHOAI char(15), 
	TRUONGBM char(5), 
	MAKHOA char(5),
	NGAYNHANCHUC datetime
	PRIMARY KEY (MABM)
)

CREATE TABLE KHOA
(
	MAKHOA char(5) NOT NULL,
	TENKHOA nvarchar(30),
	NAMTL int, 
	PHONG char(5),
	DIENTHOAI char(15), 
	TRUONGKHOA char(5),
	NGAYNHANCHUC datetime
	PRIMARY KEY (MAKHOA)
)

CREATE TABLE DETAI
(
	MADT char(5) NOT NULL,
	TENDT nvarchar(40),
	CAPQL nchar(10), 
	KINHPHI float,
	NGAYBD datetime, 
	NGAYKT datetime, 
	MACD char(5), 
	GVCNDT char(5)
	PRIMARY KEY (MADT)
)

CREATE TABLE CHUDE
(
	MACD char(5) NOT NULL,
	TENCD nvarchar(30)
	PRIMARY KEY (MACD)
)

CREATE TABLE CONGVIEC
(
	MADT char(5) NOT NULL,
	STT int NOT NULL, 
	TENCV nvarchar(40),
	NGAYBD datetime,
	NGAYKT datetime
	PRIMARY KEY (MADT, STT)
)

CREATE TABLE THAMGIADT
(
	MAGV char(5) NOT NULL,
	MADT char(5) NOT NULL,
	STT int NOT NULL,
	PHUCAP float,
	KETQUA nchar(10)
	PRIMARY KEY (MAGV, MADT, STT)
)

CREATE TABLE NGUOITHAN
(
	MAGV char(5), 
	TEN nvarchar(30),
	NGAYSINH datetime,
	PHAI nchar(3)
	PRIMARY KEY (MAGV, TEN)
)

--CREATE TRIGGER trg_CONGVIEC_AutoIncrement 
--ON CONGVIEC
--AFTER INSERT
--AS
--BEGIN
--    UPDATE CV
--    SET CV.STT = CV.STT + 1
--    FROM CONGVIEC CV
--END
--DROP TRIGGER IF EXISTS trg_CONGVIEC_AutoIncrement



--DROP TABLE GIAOVIEN
--DROP TABLE GV_DT
--DROP TABLE BOMON
--DROP TABLE KHOA
--DROP TABLE DETAI
--DROP TABLE CHUDE
--DROP TABLE GIAOVIEN
--DROP TABLE GV_DT
--DROP TABLE BOMON
--DROP TABLE KHOA
--DROP TABLE DETAI
--DROP TABLE CHUDE
--DROP TABLE CONGVIEC
--DROP TABLE THAMGIADT
--DROP TABLE NGUOITHAN


-----------------------------------------------------------------------
-- Tạo khóa ngoại giữa các bảng:
---- Bảng GIAOVIEN
ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GVQL_GV
FOREIGN KEY (GVQLCM)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GV_BM
FOREIGN KEY (MABM)
REFERENCES BOMON(MABM)

---- Bảng GV_DT
ALTER TABLE GV_DT
ADD CONSTRAINT FK_GV_DT_GV
FOREIGN KEY (MAGV)
REFERENCES GIAOVIEN(MAGV)

--ALTER TABLE GV_DT DROP
--CONSTRAINT FK_GV_DT_GV

---- Bảng BOMON
ALTER TABLE BOMON
ADD CONSTRAINT FK_BM_GV
FOREIGN KEY (TRUONGBM)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE BOMON
ADD CONSTRAINT FK_BM_K
FOREIGN KEY (MAKHOA)
REFERENCES KHOA(MAKHOA)

---- Bảng KHOA
ALTER TABLE KHOA
ADD CONSTRAINT FK_K_GV
FOREIGN KEY (TRUONGKHOA)
REFERENCES GIAOVIEN(MAGV)

---- Bảng DETAI
ALTER TABLE DETAI
ADD CONSTRAINT FK_DT_GV
FOREIGN KEY (GVCNDT)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE DETAI
ADD CONSTRAINT FK_DT_CD
FOREIGN KEY (MACD)
REFERENCES CHUDE(MACD)

---- Bảng CHUDE
---- NULL

---- Bảng CONGVIEC
ALTER TABLE CONGVIEC
ADD CONSTRAINT FK_CV_DT
FOREIGN KEY (MADT)
REFERENCES DETAI(MADT)

---- Bảng THAMGIADT
ALTER TABLE THAMGIADT
ADD CONSTRAINT FK_TGDT_GV
FOREIGN KEY (MAGV)
REFERENCES GIAOVIEN(MAGV)

ALTER TABLE THAMGIADT
ADD CONSTRAINT FK_TGDT_CV
FOREIGN KEY (MADT,STT)
REFERENCES CONGVIEC(MADT,STT)

--ALTER TABLE THAMGIADT 
--ALTER COLUMN STT int
--DROP TABLE THAMGIADT

---- Bảng NGUOITHAN
ALTER TABLE NGUOITHAN
ADD CONSTRAINT FK_NT_GV
FOREIGN KEY (MAGV)
REFERENCES GIAOVIEN(MAGV)

-----------------------------------------------------------------------
-- Tạo CONSTRAINT: 
---- Bảng GIAOVIEN
ALTER TABLE GIAOVIEN 
ADD CONSTRAINT C_PHAI
CHECK (PHAI IN ('Nam', N'Nữ'))

-----------------------------------------------------------------------
-- Nhập dữ liệu:
---- Bảng GIAOVIEN 
------ Dữ liệu khởi tạo
INSERT INTO GIAOVIEN VALUES ('001', N'Nguyễn Hoài An', 2000, 'Nam', '1973-02-15', N'25/3 Lạc Long Quân, Q.10, TP HCM', NULL, NULL),
							('002', N'Trần Trà Hương', 2500, N'Nữ', '1960-06-20', N'125 Trần Hưng Đạo, Q.1, TP HCM', NULL, NULL),
							('003', N'Nguyễn Ngọc Ánh', 2200, N'Nữ', '1975-05-11', N'12/21 Võ Văn Ngân Thủ Đức, TP HCM', NULL, NULL),
							('004', N'Trương Nam Sơn', 2300, 'Nam', '1959-06-20', N'215 Lý Thường Kiệt, TP Biên Hòa', NULL, NULL),
							('005', N'Lý Hoàng Hà', 2500, 'Nam', '1954-10-23', N'22/5 Nguyễn Xí, Q.Bình Thạnh, TP HCM', NULL, NULL),
							('006', N'Trần Bạch Tuyết', 1500, N'Nữ', '1980-05-20', N'22/11 Lý Thường Kiệt, TP Mỹ Tho', NULL, NULL),
							('007', N'Nguyễn An Trung', 2100, 'Nam', '1976-06-05', N'234 3/2, TP Biên Hòa', NULL, NULL),
							('008', N'Trần Trung Hiếu', 1800, 'Nam', '1977-08-06', N'22/11 Lý Thường Kiệt, TP Mỹ Tho',NULL, NULL),
							('009', N'Trần Hoàng Nam', 2000, 'Nam', '1975-11-22', N'234 Trấn Não, An Phú, TP HCM', NULL, NULL),
							('010', N'Phạm Nam Thanh', 1500, 'Nam', '1980-12-12', N'221 Hùng Vương, Q.5, TP HCM', NULL, NULL)
------ Dữ liệu cập nhật
-- Thiếu: GVQLCM
UPDATE GIAOVIEN 
SET GVQLCM = '002'
WHERE MAGV = '003'

UPDATE GIAOVIEN 
SET GVQLCM = '004'
WHERE MAGV = '006'

UPDATE GIAOVIEN 
SET GVQLCM = '007'
WHERE MAGV IN ('008', '010')

UPDATE GIAOVIEN 
SET GVQLCM = '001'
WHERE MAGV = '009'

-- Thiếu: MABM
UPDATE GIAOVIEN
SET MABM = 'MMT'
WHERE MAGV IN ('001', '009')

UPDATE GIAOVIEN 
SET MABM = 'HTTT'
WHERE MAGV IN ('002', '003')

UPDATE GIAOVIEN 
SET MABM = 'VS'
WHERE MAGV IN ('004', '006')

UPDATE GIAOVIEN 
SET MABM = 'VLDT'
WHERE MAGV IN ('005')

UPDATE GIAOVIEN 
SET MABM = 'HPT'
WHERE MAGV IN ('007','008','010')

------ Check:
SELECT *
FROM GIAOVIEN

------ Drop:
DELETE FROM GIAOVIEN

---- Bảng GV_DT
------ Dữ liệu khởi tạo
INSERT INTO GV_DT VALUES
	('001', '0838912112'),
    ('001', '0903123123'),
    ('002', '0913454545'),
    ('003', '0838121212'),
    ('003', '0903656565'),
    ('003', '0937125125'),
    ('006', '0937888888'),
    ('008', '0653717171'),
    ('008', '0913232323')
------ Check:
SELECT *
FROM GV_DT
------ Drop:
DELETE FROM GV_DT

---- Bảng BOMON
------ Dữ liệu khởi tạo
INSERT INTO BOMON VALUES 
	('CNTT', N'Công nghệ tri thức', 'B15', '0838126126', NULL, NULL, NULL),
    ('HHC', N'Hóa hữu cơ', 'B44', '0838222222', NULL, NULL, NULL),
    ('HL', N'Hóa lý', 'B42', '0838878787', NULL, NULL, NULL),
    ('HPT', N'Hóa phân tích', 'B43', '0838777777', '007', NULL, '2007-10-15'),
    ('HTTT', N'Hệ thống thông tin', 'B13', '0838125125', '002', NULL, '2004-09-20'),
    ('MMT', N'Mạng máy tính', 'B16', '0838676767', '001', NULL, '2005-05-15'),
    ('SH', N'Sinh hóa', 'B33', '0838898989', NULL, NULL, NULL),
    ('VLDT', N'Vật lý điện tử', 'B23', '0838234234', NULL, NULL, NULL),
    ('VLUD', N'Vật lý ứng dụng', 'B24', '0838909090', '005', NULL, '2006-02-18'),
    ('VS', N'Vi sinh', 'B32', '083454545', '004', NULL, '2007-01-01')

------ Dữ liệu cập nhật
-- Thiếu: MAKHOA
UPDATE BOMON
SET MAKHOA = 'CNTT'
WHERE MABM IN ('CNTT', 'HTTT', 'MMT')

UPDATE BOMON
SET MAKHOA = 'HH'
WHERE MABM IN ('HHC', 'HL', 'HPT')

UPDATE BOMON
SET MAKHOA = 'SH'
WHERE MABM IN ('SH', 'VS')

UPDATE BOMON
SET MAKHOA = 'VL'
WHERE MABM IN ('VLDT', 'VLUD')

------ Check:
SELECT *
FROM BOMON

------ Drop:
DELETE FROM BOMON

---- Bảng KHOA
------ Dữ liệu khởi tạo
INSERT INTO KHOA VALUES
	('CNTT', N'Công nghệ thông tin', 1995, 'B11', '0838123456', '002', '2005-02-20'),
    ('HH', N'Hóa học', 1980, 'B41', '0838456456', '007', '2001-10-15'),
    ('SH', N'Sinh học', 1980, 'B31', '0838454545', '004', '2000-10-11'),
    ('VL', N'Vật lý', 1976, 'B21', '0838223223', '005', '2003-09-18')

------ Check:
SELECT *
FROM KHOA

---- Bảng DETAI
------ Dữ liệu khởi tạo
INSERT INTO DETAI VALUES
	('001', N'HTTT quản lý các trường ĐH', N'ĐHQG', 20, '2007-10-20', '2008-10-20', NULL, '002'),
    ('002', N'HTTT quản lý giáo vụ cho một Khoa', N'Trường', 20, '2000-10-12', '2001-10-12', NULL, '002'),
    ('003', N'Nghiên cứu chế tạo sợi Nanô Platin', N'ĐHQG', 300, '2008-05-15', '2010-05-15', NULL, '005'),
    ('004', N'Tạo vật liệu sinh học bằng màng ối người', N'Nhà nước', 100, '2007-01-01', '2009-12-31', NULL, '004'),
    ('005', N'Ứng dụng hóa học xanh', N'Trường', 200, '2003-10-10', '2004-12-10', NULL, '007'),
    ('006', N'Nghiên cứu tế bào gốc', N'Nhà nước', 4000, '2006-10-20', '2009-10-20', NULL, '004'),
    ('007', N'HTTT quản lý thư viện ở các trường ĐH', N'Trường', 20, '2009-05-10', '2010-05-10', NULL, '001');

------ Dữ liệu cập nhật
-- Thiếu: MACD
UPDATE DETAI
SET MACD = 'QLGD'
WHERE MADT IN ('001', '002', '007')

UPDATE DETAI
SET MACD = 'NCPT'
WHERE MADT IN ('003', '004', '006')

UPDATE DETAI
SET MACD = 'UDCN'
WHERE MADT IN ('005')

------ Check:
SELECT *
FROM DETAI

------ Drop:
DELETE FROM DETAI

---- Bảng CHUDE
------Dữ liệu khởi tạo
INSERT INTO CHUDE VALUES
	('NCPT', N'Nghiên cứu phát triển'),
	('QLGD', N'Quản lý giáo dục'),
	('UDCN', N'Ứng dụng công nghệ')

------ Check:
SELECT *
FROM CHUDE

---- Bảng CONGVIEC
------ Dữ liệu khởi tạo
INSERT INTO CONGVIEC VALUES
	('001', 1, N'Khởi tạo và lập kế hoạch','2007-10-20', '2008-10-20'),
    ('001', 2, N'Xác định yêu cầu', '2008-12-21', '2008-03-21'),
    ('001', 3, N'Phân tích hệ thống', '2008-03-22', '2008-05-22'),
    ('001', 4, N'Thiết kế hệ thống', '2008-05-23', '2008-06-23'),
    ('001', 5, N'Cài đặt thử nghiệm', '2008-06-24', '2008-10-20'),
    ('002', 1, N'Khởi tạo và lập kế hoạch', '2009-05-10', '2009-07-10'),
    ('002', 2, N'Xác định yêu cầu', '2009-07-11', '2009-10-11'),
	('002', 3, N'Phân tích hệ thống', '2009-10-12', '2009-12-20'),
	('002', 4, N'Thiết kế hệ thống', '2009-12-21', '2010-03-22'),
	('002', 5, N'Cài đặt thử nghiệm', '2010-03-23', '2010-05-10'),
	('006', 1, N'Lấy mẫu', '2006-10-20', '2007-02-20'),
	('006', 2, N'Nuôi cấy', '2007-02-21', '2008-08-21')

------ Check:
SELECT *
FROM CONGVIEC

---- Bảng THAMGIADT
------ Dữ liệu khởi tạo
INSERT INTO THAMGIADT VALUES
	('001', '002', 1, 0.0, NULL),
	('001', '002', 2, 2.0, NULL),
	('002', '001', 4, 2.0, N'Đạt'),
	('003', '001', 1, 1.0, N'Đạt'),
	('003', '001', 2, 0.0, N'Đạt'),
	('003', '001', 4, 1.0, N'Đạt'),
	('003', '002', 2, 0.0, NULL),
	('004', '006', 1, 0.0, N'Đạt'),
	('004', '006', 2, 1.0, N'Đạt'),
	('006', '006', 2, 1.5, N'Đạt'),
	('009', '002', 3, 0.5, NULL),
	('009', '002', 4, 1.5, NULL)

------ Check:
SELECT *
FROM THAMGIADT

------ Drop:
DELETE FROM THAMGIADT

---- Bảng NGUOITHAN
------ Dữ liệu khởi tạo
INSERT INTO NGUOITHAN VALUES
	('001', N'Hùng', '1990-01-14', 'Nam'),
	('001', N'Thủy', '1994-12-14', N'Nữ'),
	('003', N'Hà', '1998-09-14', N'Nữ'),
	('003', N'Thu', '1998-09-14', N'Nữ'),
	('007', N'Mai', '2003-03-14', N'Nữ'),
	('007', N'Vy', '2000-02-14', N'Nữ'),
	('008', N'Nam', '1991-05-14', 'Nam'),
	('009', N'An', '1996-08-14', 'Nam'),
	('010', N'Nguyệt', '2006-01-14', N'Nữ')

------ Check:
SELECT *
FROM NGUOITHAN




