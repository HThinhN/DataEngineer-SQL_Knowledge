-- Lab 7: Stored Procedure và Function
USE SCHOOL_MANAGEMENT

------------------------------------------------------------------------------------------------
-- Viết các Stored Procedure cho bài tập Quản lý Đề tài:

-- P1. Xuất ra toàn bộ danh sách giáo viên
-- Viết Stored Procedure
CREATE PROCEDURE sp_DSGV
AS
	SELECT * FROM GIAOVIEN
GO
-- Thực thi Stored Procedure:
EXEC sp_DSGV

-- P2. Tính số lượng đề tài mà một giáo viên đang thực hiện
-- Cách 1: 
-- Viết Stored Procedure
CREATE PROCEDURE sp_SLDT_GV
	@MAGV char(5),
	@SLDT int out
AS
BEGIN
	SET @SLDT = (SELECT COUNT(DISTINCT MADT) 
				 FROM THAMGIADT
				 WHERE MAGV = @MAGV)
END
GO
-- Thực thi Stored Procedure
DECLARE @SLDT int
EXEC sp_SLDT_GV '001', @SLDT out
PRINT N'Số lượng đề tài của giáo viên đó là: ' + CAST(@SLDT AS nvarchar(5))

-- Cách 2:
-- Viết Stored Procedure:
CREATE PROCEDURE sp_SLDT_GV_2
	@MAGV char(5)
AS
BEGIN
	DECLARE @SLDT int
	SET @SLDT = (SELECT COUNT(DISTINCT MADT)
				 FROM THAMGIADT
				 WHERE MAGV = @MAGV)
	PRINT N'Số lượng đề tài mà giáo viên ' + CAST(@MAGV AS nvarchar(3)) + ' đã tham gia là: ' + CAST(@SLDT AS nvarchar(5))
END
GO

-- Thực thi Storecd Procedure:
EXEC sp_SLDT_GV_2 '001'

-- Kiểm tra
SELECT COUNT(DISTINCT MADT) AS SLDT
FROM THAMGIADT
WHERE MAGV = '001'

-- P3: In thông tin chi tiết của một giáo viên (Sử dụng lệnh Print): Thông tin cá nhân, 
-- Số lượng đề tài tham gia, số lượng thân nhân của giáo viên đó.
-- Viết Stored Procedure:
CREATE PROCEDURE sp_TTCT_GV
	@MAGV char(5)
AS
BEGIN
	/* Thông tin cá nhân */
	SELECT * FROM GIAOVIEN WHERE MAGV = @MAGV
	/* Số lượng đề tài tham gia */
	DECLARE @SLDT int
	SET @SLDT = (SELECT COUNT(DISTINCT MADT)
				 FROM THAMGIADT
				 WHERE MAGV = @MAGV)
	PRINT N'Số lượng đề tài của giáo viên ' + CAST(@MAGV AS nvarchar(3)) + ' đã tham gia là: ' + CAST(@SLDT AS nvarchar(5))
	/* Số lượng thân nhân */
	DECLARE @SLTN int
	SET @SLTN = (SELECT COUNT(*)
				 FROM NGUOITHAN
				 WHERE MAGV = @MAGV)
	PRINT N'Số lượng thân nhân của giáo viên ' + CAST(@MAGV AS nvarchar(3)) + ' là: ' + CAST(@SLTN AS nvarchar(5))
END
GO
-- Thực thi Stored Procedure
EXEC sp_TTCT_GV '001'

-- P4. Kiểm tra xem một giáo viên có tồn tại hay không (dựa vào HOTEN, NGAYSINH, DIACHI)
-- Check thông tin GIAOVIEN
SELECT *
FROM GIAOVIEN 

sp_help GIAOVIEN
-- Viết Stored Procedure:
CREATE PROCEDURE sp_KTTT_GV
	@HOTEN nvarchar(80),
	@NGAYSINH datetime,
	@DIACHI nvarchar(100)
AS
BEGIN
	IF ( EXISTS(SELECT * 
				FROM GIAOVIEN
				WHERE HOTEN = @HOTEN AND NGAYSINH = @NGAYSINH
				AND DIACHI = @DIACHI))
		PRINT N'Giáo viên có tồn tại'
	ELSE
		PRINT N'Không tồn tại giáo viên này'
END
GO

-- Thực thi Stored Procedure:
EXEC sp_KTTT_GV N'Nguyễn Hoàng Thịnh', '2002-03-13', N'505/1 Kinh Duong Vuong, Q. Bình Tân, TP HCM'

EXEC sp_KTTT_GV N'Lê Anh Nguyên', '2002-04-19', N'Không quan tâm'

-- P5. Kiểm tra quy định của một giáo viên: Chỉ được thực hiện các đề tài mà bộ môn của giáo viên
-- đó làm chủ nhiệm
-- Xem thông tin các bảng:
SELECT *
FROM DETAI

-- Viết Stored Procedure:
CREATE PROCEDURE sp_KTQD_GV
	@MAGV char(5)
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM THAMGIADT AS TGDT, GIAOVIEN AS GVCNDT, DETAI AS DT, GIAOVIEN AS GV
				WHERE TGDT.MAGV = @MAGV AND TGDT.MADT = DT.MADT
				AND DT.GVCNDT = GVCNDT.MAGV AND GVCNDT.MABM = GV.MABM
				AND GV.MAGV = @MAGV))
		PRINT N'Giáo viên ' + CAST(@MAGV AS nvarchar(3)) + N' không thực hiện đúng quy định'
	ELSE
		PRINT N'Giáo viên ' + CAST(@MAGV AS nvarchar(3)) + N' thực hiện đúng quy định'
END
GO
-- Thực thi Stored Procedure:
EXEC sp_KTQD_GV '001'
EXEC sp_KTQD_GV '002'
EXEC sp_KTQD_GV '003'
EXEC sp_KTQD_GV '004'
EXEC sp_KTQD_GV '005'
EXEC sp_KTQD_GV '006'
EXEC sp_KTQD_GV '007'
EXEC sp_KTQD_GV '008'
EXEC sp_KTQD_GV '009'
EXEC sp_KTQD_GV '010'
EXEC sp_KTQD_GV '011'
EXEC sp_KTQD_GV '012'

DROP PROCEDURE sp_KTQD_GV

-- P6. Thực hiện thêm một phân công cho giáo viên thực hiện một công việc của đề tài:
-- + Kiểm tra thông tin đầu vào hợp lệ: Giáo viên phải tồn tại, công việc phải tồn tại,
-- thời gian tham gia phải >0 (Thay bằng thời gian tham gia phải nằm trong NGAYBD và NGAYKT)
-- + Giáo viên chỉ tham gia đề tài cùng bộ môn với giáo viên làm chủ nhiệm đề tài đó

-- Xem thông tin các bảng:
SELECT *
FROM CONGVIEC

SELECT *
FROM DETAI

SELECT *
FROM GIAOVIEN 

-- Viết Stored Procedure:
CREATE PROCEDURE sp_PCCV_GV
	@MAGV char(5), 
	@MADT char(5),
	@STT int,
	@NGAYTG datetime
AS
BEGIN
	/* Kiểm tra thông tin đầu vào hợp lệ*/
	-- Giáo viên phải tồn tại
	IF ( NOT EXISTS(SELECT *
				    FROM GIAOVIEN AS GV
				    WHERE GV.MAGV = @MAGV))
		PRINT N'Giáo viên không tồn tại'
	ELSE
		-- Công việc phải tồn tại
		IF ( NOT EXISTS(SELECT *
					     FROM CONGVIEC AS CV
						 WHERE CV.MADT = @MADT
						 AND CV.STT = @STT))
			PRINT N'Công việc không tồn tại'
		ELSE
			-- Ngày tham gia phải hợp lệ
			IF ( NOT EXISTS(SELECT *
							FROM CONGVIEC AS CV
							WHERE CV.MADT = @MADT AND CV.STT = @STT
							AND @NGAYTG BETWEEN CV.NGAYBD AND CV.NGAYKT))
				PRINT N'Ngày tham gia không hợp lệ'
			ELSE
				-- Giáo viên chỉ tham gia đề tài cùng bộ môn với giáo viên làm chủ nhiệm đề tài đó
				IF ( NOT EXISTS(SELECT *
								FROM GIAOVIEN AS GV, DETAI AS DT, GIAOVIEN AS GVCNDT
								WHERE GV.MAGV = @MAGV AND GV.MABM = GVCNDT.MABM
								AND GVCNDT.MAGV = DT.GVCNDT AND DT.MADT = @MADT))
					PRINT N'Đề tài giáo viên tham gia không hợp lệ'
				ELSE
					PRINT N'Giáo viên có thể thực hiện công việc của đề tài này'		 
END
GO

-- Thực thi Stored Procedure:
-- Giáo viên không tồn tại
EXEC sp_PCCV_GV '018', '001', 1, '2008-01-01'
-- Công việc không tồn tại
EXEC sp_PCCV_GV '001', '001', 6, '2008-01-01'
-- Thời gian tham gia không hợp lệ
EXEC sp_PCCV_GV '001', '001', 1, '2009-01-01'
-- Đề tài giáo viên tham gia không cùng bộ môn với người chủ nhiệm
EXEC sp_PCCV_GV '001', '001', 1, '2008-01-01'
-- Giáo viên có thể thực hiện đề tài này
EXEC sp_PCCV_GV '003', '001', 1, '2008-01-01'

-- P7. Thực hiện xóa một giáo viên theo mã. Nếu giáo viên có thông tin liên quan
-- (Có thân nhân, có làm đề tài ... ) thì báo lỗi.
-- Xem thông tin các bảng:
SELECT *
FROM GIAOVIEN
	
-- Update dữ liệu để xóa:
INSERT INTO GIAOVIEN VALUES ('013', N'Lê Anh Nguyên', 1800, 'Nam', '2002-04-19', N'56/1 An Dương Vương, Q.5, TP HCM', NULL, 'VS')

-- Viết Stored Procedure:
CREATE PROCEDURE sp_XOA_GV
	@MAGV char(5)
AS
BEGIN
	/* Thân nhân */
	IF ( EXISTS(SELECT *
				FROM NGUOITHAN 
				WHERE MAGV = @MAGV))
		PRINT N'Lỗi! Giáo viên có thông tin về thân nhân'
	ELSE
		/* Tham gia đề tài */
		IF ( EXISTS(SELECT *
					FROM THAMGIADT
					WHERE MAGV = @MAGV))
		PRINT N'Lỗi! Giáo viên có tham gia làm đề tài'
		ELSE
			/* Các thông tin liên quan khác */
			IF ( EXISTS(SELECT *
						FROM BOMON AS BM, KHOA AS K, DETAI AS DT
						WHERE BM.TRUONGBM = @MAGV 
						OR K.TRUONGKHOA = @MAGV
						OR DT.GVCNDT = @MAGV))
				PRINT N'Lỗi! Giáo viên có một vài thông tin liên quan ở các bảng khác'
			ELSE
				BEGIN
					DELETE FROM GIAOVIEN WHERE MAGV = @MAGV
					PRINT N'Đã xóa giáo viên có mã giáo viên là '+ CAST(@MAGV AS nvarchar(3)) 
				END
END
GO

-- Thực thi Stored Procedure:
EXEC sp_XOA_GV '002'

EXEC sp_XOA_GV '013'

DROP PROCEDURE sp_XOA_GV
-- Check:
SELECT *
FROM GIAOVIEN

-- P8. In ra danh sách giáo viên của một phòng ban nào đó cùng với số lượng đề tài mà giáo viên
-- tham gia, số thân nhân, số giáo viên mà giáo viên đó quản lý nếu có, ...
-- Viết Stored Procedure:
CREATE PROCEDURE sp_DSGV_BM
	@MABM char(5)
AS 
BEGIN
	SELECT GV.MAGV, GV.HOTEN, COUNT(DISTINCT TGDT.MADT) AS SLDT, COUNT(DISTINCT NT.TEN) AS SLNT, COUNT(DISTINCT GVDQL.MAGV) AS SLNDQL
	FROM GIAOVIEN AS GV LEFT JOIN THAMGIADT AS TGDT ON GV.MAGV = TGDT.MAGV
	LEFT JOIN NGUOITHAN AS NT ON NT.MAGV = GV.MAGV LEFT JOIN GIAOVIEN AS GVDQL ON GV.MAGV = GVDQL.GVQLCM
	WHERE GV.MABM = @MABM
	GROUP BY GV.MAGV, GV.HOTEN
END
GO

-- Thực thi Stored Procedure
EXEC sp_DSGV_BM 'HTTT'

DROP PROCEDURE sp_DSGV_BM
-- Check:
SELECT *
FROM GIAOVIEN

SELECT *
FROM THAMGIADT

SELECT *
FROM NGUOITHAN

--P9. Kiểm tra quy định của 2 giáo viên a, b: Nếu a là trưởng bộ môn của b thì lương của a phải cao hơn lương của b.
-- (a, b: Mã giáo viên) 
-- Viết Stored Procedure:
CREATE PROCEDURE sp_KTQD
	@MAGV_a char(5), 
	@MAGV_b char(5)
AS 
BEGIN
	IF ( EXISTS(SELECT *
				FROM GIAOVIEN AS GV_A, BOMON AS BM, GIAOVIEN AS GV_B
				WHERE GV_A.MAGV = @MAGV_a AND GV_A.MAGV = BM.TRUONGBM
				AND GV_B.MAGV = @MAGV_b AND GV_A.LUONG > GV_B.LUONG))
		PRINT N'Đúng quy định: Nếu a là trưởng bộ môn của b thì lương của a phải cao hơn lương của b'
	ELSE
		PRINT N'Trái quy định: Nếu a là trưởng bộ môn của b thì lương của a phải cao hơn lương của b'
END
GO 

-- Thực thi Stored Procedure:
EXEC sp_KTQD '002', '012'
EXEC sp_KTQD '002', '003'

DROP PROCEDURE sp_KTQD
-- Check thông tin:
SELECT *
FROM GIAOVIEN 

SELECT *
FROM BOMON

-- P10: Khi thêm một giáo viên cần kiểm tra các quy định: Không trùng tên, tuổi > 18, lương > 0.
-- Check thông tin các bảng:
sp_help GIAOVIEN
-- Viết Stored Procedure:
CREATE PROCEDURE sp_KTQD_iGV
	@HOTEN nvarchar(80),
	@TUOI int,
	@LUONG float
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM GIAOVIEN 
				WHERE HOTEN = @HOTEN))
		PRINT N'Trái quy định! Giáo viên bị trùng tên'
	ELSE
		IF (@TUOI <= 18)
			PRINT N'Trái quy định! Giáo viên có tuổi <= 18'
		ELSE
			IF (@LUONG <= 0) 
				PRINT N'Trái quy định! Giáo viên có lương <= 0'
			ELSE
				PRINT N'Đúng quy định! Có thể thực hiện thêm giáo viên'
END
GO

-- Thực thi Stored Procedure:
EXEC sp_KTQD_iGV N'Nguyễn Hoàng Thịnh', 19, 1000
EXEC sp_KTQD_iGV N'Nguyễn Hoàng Nguyên', 17, 1000
EXEC sp_KTQD_iGV N'Nguyễn Hoàng Nguyên', 19, 0

-- P11. Mã giáo viên được phát sinh tự động theo quy tắc: Nếu đã có giáo viên 001, 002, 003 thì
-- MAGV của giáo viên mới sẽ là 004. Nếu đã có giáo viên 001, 002, 005 thì MAGV của giáo viên
-- mới là 003
-- Knowledge: 
DECLARE @MAGV_NEW int
SET @MAGV_NEW = (SELECT MAX(CAST (MAGV as INT))
				 FROM GIAOVIEN)

DECLARE @MAGV_char char(3)
SET @MAGV_char = '0' + CAST(@MAGV_NEW AS char(2))
PRINT @MAGV_char

SELECT MAX(CAST (MAGV as INT)
FROM GIAOVIEN

-- Xóa để test:
SELECT *
FROM GIAOVIEN

SELECT *
FROM THAMGIADT

SELECT *
FROM DANHSACHTHIDUA

DELETE FROM THAMGIADT WHERE MAGV = '011'
DELETE FROM DANHSACHTHIDUA WHERE MAGV = '011'
DELETE FROM GIAOVIEN WHERE MAGV = '011'
-- Viết Stored Procedure:
CREATE PROCEDURE sp_PSMGV
AS
BEGIN
	DECLARE @i int
	SET @i = 0
	DECLARE @MAGV_int int
	SET @MAGV_int = (SELECT MAX(CAST (MAGV as INT))
				     FROM GIAOVIEN)
	WHILE (@i <= @MAGV_int)
	BEGIN
		SET @i = @i + 1
		IF ( EXISTS(SELECT *
					FROM GIAOVIEN 
					WHERE MAGV = @i))
			CONTINUE
		ELSE
			BEGIN
				IF (@i < 10)
					PRINT N'Mã giáo viên được phát sinh tự động sẽ là: 00' + CAST(@i AS nvarchar(1)) 
				ELSE
					PRINT N'Mã giáo viên được phát sinh tự động sẽ là: 0' + CAST(@i AS nvarchar(2)) 
				SET @i = @MAGV_int + 1
			END
	END
END
GO

-- Thực thi Stored Procedure:
EXEC sp_PSMGV

DROP PROCEDURE sp_PSMGV

------------------------------------ Bài tập về nhà --------------------------------------
CREATE DATABASE QLKS
USE QLKS

CREATE TABLE PHONG 
(
	MAPHONG int NOT NULL,
	TINHTRANG nvarchar(10),
	LOAIPHONG nvarchar(10),
	DONGIA float
)

ALTER TABLE PHONG
ADD CONSTRAINT PK_PHONG
PRIMARY KEY (MAPHONG)

CREATE TABLE KHACH 
(
	MAKH int NOT NULL,
	HOTEN nvarchar(30),
	DIACHI nvarchar(40),
	DIENTHOAI nvarchar(15)
)

ALTER TABLE KHACH
ADD CONSTRAINT PK_KHACH
PRIMARY KEY (MAKH)

CREATE TABLE DATPHONG
(
	MADP int NOT NULL,
	MAKH int NOT NULL,
	MAPHONG int NOT NULL,
	NGAYDP datetime,
	NGAYTP datetime,
	THANHTIEN float
)

ALTER TABLE DATPHONG
ADD CONSTRAINT PK_DATPHONG
PRIMARY KEY (MADP)

ALTER TABLE DATPHONG
ADD CONSTRAINT FK_DATPHONG_PHONG
FOREIGN KEY (MAPHONG)
REFERENCES PHONG(MAPHONG)

ALTER TABLE DATPHONG
ADD CONSTRAINT FK_DATPHONG_KHACH
FOREIGN KEY (MAKH)
REFERENCES KHACH(MAKH)

INSERT INTO PHONG VALUES (1, N'Rảnh', N'Vip', 200000)
INSERT INTO PHONG VALUES (2, N'Rảnh', N'Thường', 150000)

INSERT INTO KHACH VALUES (1, N'Nguyễn Hoàng Thịnh', N'10 Trường Chinh, TP. Kon Tum', '0854555879') 

---- Đề bài: Xem tại Doc7 (Trang 11 - 13)
----------------------- /* spDatPhong */ -----------------------
-- Viết Stored Procedure:
CREATE PROCEDURE sp_DatPhong
	@MAKH int,
	@MAPHONG int, 
	@NGAYDP datetime
AS
BEGIN
	DECLARE @FLAG int
	SET @FLAG = 1
	/* Mã đặt phòng là số nguyên và phát sinh tự động */
	DECLARE @MADP int
	SET @MADP = 0

	DECLARE @MADP_MAX int
	SET @MADP_MAX = (SELECT MAX(MADP)
					 FROM DATPHONG)
	
	IF @MADP_MAX IS NULL 
		SET @MADP_MAX = 1

	WHILE (@MADP <= @MADP_MAX)
	BEGIN
		SET @MADP = @MADP + 1
		IF ( EXISTS(SELECT *
					FROM DATPHONG
					WHERE MADP = @MADP))
			CONTINUE
		ELSE
			BEGIN
				PRINT N'Mã đặt phòng phát sinh: ' + CAST(@MADP AS nvarchar(2))
				BREAK
			END
	END

	/* Kiểm tra mã khách hàng hợp lệ */
	IF (NOT EXISTS(SELECT *
				   FROM KHACH
				   WHERE MAKH = @MAKH))
		BEGIN
			SET @FLAG = 0
			PRINT N'Mã khách hàng không hợp lệ'
		END
	/* Kiễm tra mã phòng hợp lệ */
	IF (NOT EXISTS(SELECT *
				   FROM PHONG
				   WHERE MAPHONG = @MAPHONG))
		BEGIN
			SET @FLAG = 0
			PRINT N'Mã phòng chưa hợp lệ'
		END

	/* Kiểm tra tình trạng phòng */
	IF ( EXISTS(SELECT *
				FROM PHONG
				WHERE MAPHONG = @MAPHONG
				AND TINHTRANG = N'Bận'))
		BEGIN
			SET @FLAG = 0
			PRINT N'Phòng đã có khách đặt'
		END
	/* Ghi nhận thông tin đặt phòng */
	IF (@FLAG = 1) 
	BEGIN
		INSERT INTO DATPHONG VALUES (@MADP, @MAKH, @MAPHONG, @NGAYDP, NULL, NULL)
		UPDATE PHONG
		SET TINHTRANG = N'Bận'
		WHERE MAPHONG = @MAPHONG
	END
	ELSE
		PRINT N'Thông tin không hợp lệ! Phòng chưa được đặt'
END
GO

-- Thực thi Stored Procedure:
-- Lỗi 1: Mã KH không hợp lệ
EXEC sp_DatPhong 3, 1, '2024-10-04'

-- Lỗi 2: Mã phòng không hợp lệ
EXEC sp_DatPhong 1, 4, '2024-10-04'

-- Lỗi 3: Tình trạng phòng là bận
EXEC sp_DatPhong 1, 3, '2024-10-04'

-- Thực hiện thành công: 
EXEC sp_DatPhong 1, 1, '2024-01-04'

-- Update thông tin: 
INSERT INTO PHONG VALUES (3, N'Bận', N'Thường', 150000)
-- Kiểm tra thông tin:
SELECT *
FROM DATPHONG

SELECT *
FROM PHONG

DROP PROCEDURE sp_DatPhong

DECLARE @MADP int
SET @MADP = (SELECT MAX(MADP)
			 FROM DATPHONG)

IF @MADP IS NULL 
	SET @MADP = 1

PRINT @MADP

----------------------- /* spTraPhong */ -----------------------
-- Viết Stored Procedure:
CREATE PROCEDURE spTraPhong
	@MADP int,
	@MAKH int
AS 
BEGIN
	DECLARE @FLAG int
	SET @FLAG = 1

	DECLARE @MAPHONG int 
	SET @MAPHONG = (SELECT DP.MAPHONG
					FROM DATPHONG AS DP
					WHERE DP.MADP = @MADP
					AND DP.MAKH = @MAKH)
	/* Kiểm tra tính hợp lệ của mã đặt phòng, mã khách hàng */
	IF (NOT EXISTS(SELECT *
				   FROM DATPHONG
				   WHERE MAKH = @MAKH
				   AND MADP = @MADP))
		BEGIN
			PRINT N'Mã đặt phòng hay mã khách hàng không hợp lệ'
			SET @FLAG = 0
		END
	
	/* Ngày trả phòng chính là ngày hiện hành */
	DECLARE @NGAYTP datetime
	SET @NGAYTP = GETDATE()

	/* Tiền thanh toán */
	DECLARE @TIENTT float
	SET @TIENTT = (SELECT DAY(GETDATE()) - DAY(NGAYDP)
				   FROM DATPHONG
				   WHERE MADP = @MADP) * 
				  (SELECT DONGIA
				   FROM PHONG AS P,DATPHONG AS DP
				   WHERE P.MAPHONG = @MAPHONG)
	/* Cập nhật tình trạng */
	IF @FLAG = 1
	BEGIN
		PRINT N'Số tiền cần phải trả là: ' + CAST(@TIENTT AS nvarchar(20))
		UPDATE PHONG
		SET TINHTRANG = N'Rảnh'
		WHERE MAPHONG = @MAPHONG
	END
END
GO

-- Thực thi Stored Procedure:
EXEC spTraPhong 1,1

------------------------------ END ------------------------------