-- Knowledge 1: Định nghĩa cấu trúc cơ sở dữ liệu bằng ngôn ngữ SQL
---- 1. Xây dựng cấu trúc cơ sở dữ liệu
--------------------------------------------------------------
--------------------------------------------------------------
------ 1.1. Cách thực thi một đoạn script trong Query Analyser: 
/*
(Trang 4 / Doc1)
*/
--------------------------------------------------------------
------ 1.2. Tạo cơ sở dữ liệu
-- Tạo database
CREATE DATABASE TestDB
-- Chọn database để thao tác
USE TestDB
-- Xóa database
-- USE QLGV
DROP DATABASE TestDB
DROP DATABASE SCHOOL_MANAGEMENT
-- Lưu ý: Refresh
--------------------------------------------------------------
------ 1.3. Tạo bảng
CREATE TABLE GIAOVIEN
(
	MAGV char (5),
	HOTEN nvarchar(40),
	LUONG float,
	PHAI nchar(3),
	NGSINH datetime,
	MANQL char(5),
	MABM char(5)
)
--------------------------------------------------------------
------ 1.4. Xóa bảng
DROP TABLE GIAOVIEN
-- Lưu ý: Refresh
---- 1. Nếu bảng đã tồn tại hoặc trong cơ sở dữ liệu có một đối tượng nào trùng
---- tên với tên bảng muốn tạo thì câu lệnh tạo bảng sẽ bị lỗi.
---- 2. Nếu bảng không tồn tại thì câu lệnh xóa bảng sẽ bị lỗi.
---- Hai quy tắc trên cũng áp dụng đối với tất cả các đối tượng khác trong cơ sở dữ
---- liệu (khóa chính, khóa ngoại, cơ sở dữ liệu, ...)
--
--------------------------------------------------------------
------ 1.5. Khai báo (tạo) khóa chính, khóa ngoại và các ràng buộc toàn vẹn khác
--------------------------------------------------------------
------ Tạo khóa chính
-------- Cách 1: Tạo khóa chính trong câu lệnh tạo bảng:
CREATE TABLE GIAOVIEN 
(
	MAGV char(5),
	HOTEN nvarchar(40),
	LUONG float,
	PHAI nchar(3),
	NGSINH datetime,
	MANQL char(5),
	MABM char(5)
	PRIMARY KEY (MAGV)
)
-------- Cách 2: Tạo khóa chính ngoài câu lệnh tạo bảng:
ALTER TABLE GIAOVIEN
ADD CONSTRAINT PK_GIAOVIEN
---------- Lưu ý: Khi tạo khóa chính cho bảng ở bên
---------- ngoài lệnh tạo bảng thì các thuộc tính của
---------- khóa chính phải được khai báo là NOT NULL
---------- trong câu lệnh tạo bản
---------- Test: 
DROP TABLE GIAOVIEN
-- => 
CREATE TABLE GIAOVIEN
(
	MAGV char(5) NOT NULL,
	HOTEN nvarchar(40),
	LUONG float,
	PHAI nchar(3),
	NGSINH datetime,
	MANQL char(5),
	MABM char(5)
)
-- => 
ALTER TABLE GIAOVIEN
ADD CONSTRAINT PK_GIAOVIEN
PRIMARY KEY (MAGV)
--------------------------------------------------------------
------ Tạo khóa ngoại
-------- Cách 1: Tạo khóa ngoại trong câu lệnh tạo bảng:
CREATE TABLE KHOA
(
	MAKHOA char(5),
	TENKHOA nvarchar(10)
	PRIMARY KEY (MAKHOA)
)
CREATE TABLE BOMON
(
	MABM char(5),
	TENBM nvarchar(10),
	PHONG char(10),
	MAKHOA char(5)
	FOREIGN KEY (MAKHOA)
	REFERENCES KHOA(MAKHOA)
)
-------- Cách 2: Tạo khóa ngoại bên ngoài câu lệnh tạo bảng:
ALTER TABLE BOMON
ADD CONSTRAINT FK_BOMON_KHOA
FOREIGN KEY (MA_KHOA)
REFERENCES KHOA(MAKHOA)
-------- Test: 
DROP TABLE BOMON
DROP TABLE KHOA
-- => 
CREATE TABLE KHOA
(
	MAKHOA char(5),
	TENKHOA nvarchar(10)
	PRIMARY KEY (MAKHOA)
)

CREATE TABLE BOMON
(
	MABM char(5),
	TENBM nvarchar(10),
	PHONG char(10),
	MAKHOA char(5)
)
-- => 
ALTER TABLE BOMON
ADD CONSTRAINT FK_BOMON_KHOA
FOREIGN KEY (MAKHOA)
REFERENCES KHOA(MAKHOA)
--------------------------------------------------------------
------ Tạo ràng buộc miền giá trị
ALTER TABLE GIAOVIEN
ADD CONSTRAINT C_PHAI
CHECK (PHAI IN ('Nam', N'Nữ'))
--------------------------------------------------------------
------ Tạo ràng buộc duy nhất (khóa ứng viên)
ALTER TABLE GIAOVIEN
ADD CONSTRAINT U_HOTEN
UNIQUE (HOTEN)
--------------------------------------------------------------
------ Xóa ràng buộc khóa chính, khóa ngoại hoặc miền giá trị
------ Xóa ràng buộc khóa chính
ALTER TABLE GIAOVIEN DROP
CONSTRAINT PK_GIAOVIEN
-------- Test: 
DROP TABLE GIAOVIEN
-- => 
CREATE TABLE GIAOVIEN
(
	MAGV char(5) NOT NULL,
	HOTEN nvarchar(40),
	LUONG float,
	PHAI nchar(3),
	NGSINH datetime,
	MANQL char(5),
	MABM char(5)
)
-- => 
ALTER TABLE GIAOVIEN
ADD CONSTRAINT PK_GIAOVIEN
PRIMARY KEY (MAGV)
-- =>
ALTER TABLE GIAOVIEN DROP
CONSTRAINT PK_GIAOVIEN
------ Xóa ràng buộc khóa ngoại
ALTER TABLE BOMON DROP
CONSTRAINT FK_BOMON_KHOA
--------------------------------------------------------------
------ 1.6. Thêm, xóa thuộc tính của bảng
------ Thêm thuộc tính:
ALTER TABLE GIAOVIEN
ADD DIACHI nvarchar(20)
------ Xóa thuộc tính:
ALTER TABLE GIAOVIEN
DROP COLUMN DIACHI
------ Sửa thuộc tính: (Sửa kiểu dữ liệu mới)
ALTER TABLE GIAOVIEN
ALTER COLUMN DIACHI nvarchar(100)
--------------------------------------------------------------
------ 1.7. Xóa bảng
DROP TABLE GIAOVIEN
------ Lưu ý các trường hợp xóa bảng có liên quan đến khóa ngoại:
------ Quy tắc chung: Nếu bảng bị tham chiếu bởi khoá ngoại thì không xoá được
------ Hệ quả:
------ 1. Nếu không có tham chiếu vòng (khoá vòng) thì tiến hành xóa bảng chứa khóa ngoại trước 
------ sau đó rồi xóa bảng còn lại, hoặc xóa khóa ngoại rồi sau đó tiến hành xóa các bảng
------ 2. Nếu có khóa vòng thì xóa một khóa để mất khóa vòng rồi tiến hành làm
------ như trường hợp 1
---- Đề các ví dụ: (Trang 13/ Doc 1) 
---- Ví dụ 1:
---- Test: 
DROP TABLE GIAOVIEN
DROP TABLE BOMON
DROP TABLE KHOA
-- => Tạo bảng 
CREATE TABLE GIAOVIEN
(
	MAGIAOVIEN char(5) NOT NULL,
	HOTEN nvarchar(40),
	NGAYSINH datetime,
	GIOITINH nchar(3),
	MABOMON char(5)
	PRIMARY KEY (MAGIAOVIEN)
)

CREATE TABLE BOMON
(
	MABOMON char(5) NOT NULL,
	TENBOMON nvarchar(40),
	NAMTHANHLAP int,
	MAKHOA char(5)
	PRIMARY KEY (MABOMON)
)

CREATE TABLE KHOA
(
	MAKHOA char(5) NOT NULL, 
	TENKHOA nvarchar(40),
	NAMTHANHLAP datetime
	PRIMARY KEY (MAKHOA)
)
-- => Tạo ràng buộc khóa ngoại
ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GIAOVIEN_BOMON
FOREIGN KEY (MABOMON)
REFERENCES BOMON(MABOMON)

ALTER TABLE BOMON
ADD CONSTRAINT FK_BOMON_KHOA
FOREIGN KEY (MAKHOA)
REFERENCES KHOA(MAKHOA)
-- => Xoá bảng: 
-- Cách 1: Ở ví dụ này thì nếu muốn xóa bảng thì phải xóa theo thứ tự từ GIAOVIEN -> BOMON -> KHOA
DROP TABLE GIAOVIEN
DROP TABLE BOMON
DROP TABLE KHOA
-- Cách 2: Nếu muốn xóa bảng mà không cần quan tâm thứ tự thì cần phải xóa các khóa ngoại trước
ALTER TABLE GIAOVIEN DROP
CONSTRAINT FK_GIAOVIEN_BOMON

ALTER TABLE BOMON DROP 
CONSTRAINT FK_BOMON_KHOA
-- => Từ đó có thể tráo đổi thứ tự xóa thoải mái
DROP TABLE BOMON
DROP TABLE KHOA
DROP TABLE GIAOVIEN

---- Ví dụ 2:
-- => Tạo bảng
CREATE TABLE GIAOVIEN
(
	MAGIAOVIEN char(5) NOT NULL,
	HOTEN nvarchar(40),
	NGAYSINH datetime,
	GIOITINH nchar(3),
	MABOMON char(5)
	PRIMARY KEY (MAGIAOVIEN)
)

CREATE TABLE BOMON
(
	MABOMON char(5) NOT NULL,
	TENBOMON nvarchar(40),
	NAMTHANHLAP int,
	MAKHOA char(5)
	PRIMARY KEY (MABOMON)
)

CREATE TABLE TRUONG_BOMON
(
	MABOMON char(5) NOT NULL,
	NGAYBATDAU datetime NOT NULL,
	NGAYKETTHUC datetime NOT NULL,
	TRUONG_BOMON char(5)
	PRIMARY KEY (MABOMON,NGAYBATDAU)
)
-- => Tạo ràng buộc khóa ngoại
ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GIAOVIEN_BOMON
FOREIGN KEY (MABOMON)
REFERENCES BOMON(MABOMON)

ALTER TABLE TRUONG_BOMON
ADD CONSTRAINT FK_TRUONG_BOMON_BOMON
FOREIGN KEY (MABOMON)
REFERENCES BOMON(MABOMON)

ALTER TABLE TRUONG_BOMON
ADD CONSTRAINT FK_TRUONG_BOMON_GIAOVIEN
FOREIGN KEY (TRUONG_BOMON)
REFERENCES GIAOVIEN(MAGIAOVIEN)
-- => Xóa bảng: 
-- Cách 1: Ở ví dụ này thì nếu muốn xóa bảng thì cần phải xóa theo thứ tự 
-- TRUONG_BOMON -> GIAOVIEN -> BOMON
DROP TABLE TRUONG_BOMON
DROP TABLE GIAOVIEN
DROP TABLE BOMON

-- Cách 2: Nếu muốn xóa không theo thứ tự nào thì chỉ việc xóa hết khóa ngoại, còn nếu 
-- muốn xóa theo 1 thứ tự nhất định thì ta có thể xóa các khóa ngoại làm ảnh hưởng tới nó
-- (Ví dụ: TRUONG_BOMON -> BOMON -> GIAOVIEN)
DROP TABLE TRUONG_BOMON

ALTER TABLE GIAOVIEN DROP
CONSTRAINT FK_GIAOVIEN_BOMON

DROP TABLE BOMON
DROP TABLE GIAOVIEN

------ Ví dụ 3: 
-- => Tạo bảng
CREATE TABLE GIAOVIEN
(
	MAGIAOVIEN char(5) NOT NULL,
	HOTEN nvarchar(40),
	NGAYSINH datetime,
	GIOITINH nchar(3),
	MABOMON char(5)
	PRIMARY KEY (MAGIAOVIEN)
)

CREATE TABLE BOMON
(
	MABOMON char(5) NOT NULL,
	TENBOMON nvarchar(40),
	NAMTHANHLAP int,
	NGUOISANGLAP char(5),
	MAKHOA char(5)
	PRIMARY KEY (MABOMON)
)

CREATE TABLE KHOA
(
	MAKHOA char(5) NOT NULL, 
	TENKHOA nvarchar(40),
	NAMTHANHLAP datetime, 
	NGUOISANGLAP char(5)
	PRIMARY KEY (MAKHOA)
)
-- => Tạo ràng buộc khóa ngoại
ALTER TABLE GIAOVIEN 
ADD CONSTRAINT FK_GIAOVIEN_BOMON
FOREIGN KEY (MABOMON)
REFERENCES BOMON(MABOMON)

ALTER TABLE BOMON
ADD CONSTRAINT FK_BOMON_GIAOVIEN
FOREIGN KEY (NGUOISANGLAP)
REFERENCES GIAOVIEN(MAGIAOVIEN)

ALTER TABLE BOMON
ADD CONSTRAINT FK_BOMON_KHOA
FOREIGN KEY (MAKHOA)
REFERENCES KHOA(MAKHOA)

ALTER TABLE KHOA
ADD CONSTRAINT FK_KHOA_GIAOVIEN
FOREIGN KEY (NGUOISANGLAP)
REFERENCES GIAOVIEN(MAGIAOVIEN)

-- => Xóa bảng: 
---- Lưu ý: Lúc này không thể thực hiện xóa theo thứ tự mà chưa thực hiện xóa khóa ngoại nào được (Lý do: 
---- Nếu bạn tưởng tượng thì bạn có thể thấy các khóa ngoại giữa các bảng đã tạo thành vòng nên không thể 
---- xóa được)
---- Nên chỉ có duy nhất 1 cách là phải thực hiện xóa hết khóa ngoại hay xóa một vài khóa ngoại để có thể 
---- Ví dụ ta có thể xóa 2 khóa ngoại để có thể xóa được theo thứ tự như sau: 
---- GIAOVIEN -> BOMON -> KHOA 
ALTER TABLE KHOA DROP
CONSTRAINT FK_KHOA_GIAOVIEN

ALTER TABLE BOMON DROP
CONSTRAINT FK_BOMON_GIAOVIEN

DROP TABLE GIAOVIEN
DROP TABLE BOMON
DROP TABLE KHOA
--------------------------------------------------------------
------ 1.8. Một số cú pháp hỗ trợ xem thông tin
-- Xem cấu trúc bảng
SP_HELP GIAOVIEN
-- Xem thông tin khóa chính của bảng
SP_PKEYS GIAOVIEN
-- Xem thông tin khóa ngoại của bảng
SP_FKEYS GIAOVIEN
--------------------------------------------------------------
------ 1.9. Một số điểm lưu ý: 
-- Có thể xem rõ ở (Trang 14 / Doc 1)
--------------------------------------------------------------
--------------------------------------------------------------
---- 2. Nhập dữ liệu 
------ 2.1. Cú pháp để nhập một dòng dữ liệu vào một bảng
-- Bảng GIAOVIEN: GIAOVIEN(MAGIAOVIEN(*), HOTEN, NGAYSINH, GIOITINH, MABOMON) 
-------- Cú pháp nhập dữ liệu không tường minh: 
INSERT INTO GIAOVIEN VALUES ('GV01', N'Nguyễn Hoàng Thịnh', '2002-03-13', 'Nam', NULL)
-- Check: 
SELECT *
FROM GIAOVIEN
-- Lưu ý: Người nhập phải biết trình tự các cột của bảng để truyền giá trị cho đúng
-------- Cú pháp nhập dữ liệu tường minh:
-- Đầy đủ giá trị
INSERT INTO GIAOVIEN (MAGIAOVIEN, HOTEN, NGAYSINH, GIOITINH, MABOMON) VALUES
('GV02', N'Nguyễn Quỳnh Như', '1995-07-03', N'Nữ', NULL)
-- Thiếu MABOMON
INSERT INTO GIAOVIEN (MAGIAOVIEN, HOTEN, NGAYSINH, GIOITINH) VALUES
('GV03', N'Huỳnh Thị Mỹ Dung', '1968-11-12', N'Nữ')
-- Check: 
SELECT *
FROM GIAOVIEN
-- Lưu ý:  Các giá trị đưa vào phải tương ứng với các thuộc tính đã khai báo.
-------- Nhập dữ liệu từ một nguồn có sẳn:
INSERT INTO NHANVIEN SELECT * FROM NHANVIEN
-- Test
CREATE TABLE NHANVIEN 
(
	MANV char(5),
	HOTEN nvarchar(40),
	NGAYSINH datetime,
	GIOITINH nchar(3)
)

INSERT INTO NHANVIEN VALUES ('NV01', N'Nguyễn Hoàng Thịnh', '2002-03-13', 'Nam')
INSERT INTO NHANVIEN VALUES ('NV02', N'Nguyễn Quỳnh Như', '1995-07-03', N'Nữ')
-- Check lần 1: 
SELECT *
FROM NHANVIEN
-- 
INSERT INTO NHANVIEN SELECT * FROM NHANVIEN
-- Check lần 2: 
SELECT *
FROM NHANVIEN
-- Drop table: 
DROP TABLE NHANVIEN
--------------------------------------------------------------
------ 2.2. Nhập dữ liệu chuỗi, ngày tháng
-------- Nhập dữ liệu Unicode:
-- Thêm kí tự N trước chuổi Unicode
-- Nhập dữ liệu ngày tháng: Định dạng: 'mm/dd/yyyy'
-- Nhập một bộ dữ liệu có 1 giá trị là NULL
INSERT INTO GIAOVIEN VALUES ('GV05',
N'Nguyễn Văn Trường', '12/30/1994','Nam',NULL)
-- Check: 
SELECT * 
FROM GIAOVIEN
--------------------------------------------------------------
------ 2.3. Nhập dữ liệu khi có ràng buộc khóa ngoại







