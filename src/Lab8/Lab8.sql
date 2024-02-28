-- Lab 8: Ràng buộc toàn vẹn và TRIGGER
USE SCHOOL_MANAGEMENT

-----------------------------------------------------------------------------------------------------
-- Cài đặt các RBTV bằng các triggers cho bài tập Quản lý đề tài bằng ngôn ngữ SQL
/* Lưu ý: Mỗi RBTV có thể cần phải cài đặt trigger trên nhiều bảng cho các thao tác khác nhau */

-- T1. Tên đề tài phải duy nhất
/* Xem thông tin bảng DETAI */
SELECT *
FROM DETAI

/* Không dùng Trigger: Dùng UNIQUE */
ALTER TABLE DETAI
ADD CONSTRAINT U_TENDT
UNIQUE(TENDT)

-- Test:
UPDATE DETAI
SET TENDT = N'HTTT quản lý các trường ĐH'
WHERE MADT = '002'

-- Drop Rule UNIQUE
ALTER TABLE DETAI
DROP CONSTRAINT U_TENDT

/* Trigger: trgTenDeTaiDuyNhat */
CREATE TRIGGER trgTenDeTaiDuyNhat
ON DETAI 
FOR UPDATE
AS 
IF UPDATE(TENDT)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED I, DETAI AS DT
				WHERE I.TENDT = DT.TENDT) )
	BEGIN
		RAISERROR(N'Lỗi: Tên đề tài phải là duy nhất',16 ,1)
		ROLLBACK
	END
END

-- Test: 
UPDATE DETAI
SET TENDT = N'HTTT quản lý các trường ĐH'
WHERE MADT = '002'

-- T2. Trưởng bộ môn phải sinh ra trước năm 1975
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN 

SELECT *
FROM BOMON

/* Trigger: trgQuyDinhTuoiTruongBoMon_BOMON */
CREATE TRIGGER trgQuyDinhTuoiTruongBoMon_BOMON
ON BOMON
FOR UPDATE
AS 
IF UPDATE(TRUONGBM)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE I.TRUONGBM = GV.MAGV
				AND YEAR(GV.NGAYSINH) >= 1975) )
	BEGIN
		RAISERROR(N'Lỗi: Trưởng bộ môn phải sinh trước năm 1975',16, 1)
		ROLLBACK
	END 
END

-- Test:
UPDATE BOMON
SET TRUONGBM = '003'
WHERE MABM = 'HTTT'

/* Trigger: trgQuyDinhTuoiTruongBoMon_GIAOVIEN */
CREATE TRIGGER trgQuyDinhTuoiTruongBoMon_GIAOVIEN
ON GIAOVIEN 
FOR UPDATE
AS 
IF UPDATE(NGAYSINH)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, BOMON AS BM
				WHERE I.MAGV = BM.TRUONGBM
				AND YEAR(I.NGAYSINH) >= 1975) )
	BEGIN
		RAISERROR(N'Lỗi: Trưởng bộ môn phải sinh trước năm 1975',16, 1)
		ROLLBACK
	END 
END

-- Test:
UPDATE GIAOVIEN
SET NGAYSINH = '1976-01-01'
WHERE MAGV = '002'

-- T3. Một bộ môn có tối thiểu 1 giáo viên nữ
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

/* Trigger: trgQuyDinhSoLuongGVNuTrongBoMon */
CREATE TRIGGER trgQuyDinhSoLuongGVNuTrongBoMon
ON GIAOVIEN 
FOR DELETE, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM DELETED D
				WHERE D.PHAI = N'Nữ'
				AND NOT EXISTS(SELECT *
						       FROM GIAOVIEN AS GV
						       WHERE GV.PHAI = N'Nữ'
							   AND GV.MABM = D.MABM)) )
	BEGIN
		RAISERROR(N'Lỗi: Một bộ môn có tối thiểu 1 giáo viên nữ',16, 1)
		ROLLBACK
	END
END

-- Drop trigger:
DROP TRIGGER trgQuyDinhSoLuongGVNuTrongBoMon

-- Cập nhật dữ liệu:
INSERT INTO GIAOVIEN VALUES ('013', N'Nguyễn Quỳnh Như', 2500, N'Nữ', '1978-03-02', N'67/9 Tân Lập, Q. Thủ Đức, TP HCM', NULL, 'MMT')

-- Test:
DELETE FROM GIAOVIEN
WHERE MAGV = '013'

UPDATE GIAOVIEN
SET PHAI = 'Nam'
WHERE MAGV = '013'

-- T4. Một giáo viên phải có ít nhất 1 số điện thoại
/* Xem thông tin các bảng */
SELECT *
FROM GV_DT

/* Trigger: trgQuyDinhSoLuongDienThoai_1 */
CREATE TRIGGER trgQuyDinhSoLuongDienThoai_1
ON GV_DT
FOR DELETE, UPDATE
AS
BEGIN
	IF( EXISTS(SELECT *
			   FROM DELETED D
			   WHERE NOT EXISTS(SELECT *
								FROM GV_DT
								WHERE GV_DT.MAGV = D.MAGV)) )
	BEGIN
		RAISERROR(N'Một giáo viên phải có ít nhất 1 số điện thoại',16 ,1)
		ROLLBACK
	END
END

-- Drop trigger:
DROP TRIGGER trgQuyDinhSoLuongDienThoai_1

-- Test
DELETE FROM GV_DT
WHERE MAGV = '006'

UPDATE GV_DT
SET MAGV = '001'
WHERE DIENTHOAI = '0838912112'

-- T5. Một giáo viên có tối đa 3 số điện thoại
/* Xem thông tin các bảng */
SELECT *
FROM GV_DT

/* Trigger: trgQuyDinhSoLuongDienThoai_2 */
CREATE TRIGGER QuyDinhSoLuongDienThoai_2
ON GV_DT
FOR INSERT, UPDATE
AS 
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I
				WHERE (SELECT COUNT(*)
					   FROM GV_DT 
					   WHERE MAGV = I.MAGV
					   GROUP BY MAGV) > 3) )
	BEGIN
		RAISERROR(N'Lỗi: Một giáo viên có tối đa 3 số điện thoại',16, 1)
		ROLLBACK
	END
END

-- Test: 
INSERT INTO GV_DT VALUES ('001', '0678942345')

INSERT INTO GV_DT VALUES ('003', '0678942345')

-- T6. Một bộ môn phải có tối thiểu 4 giáo viên
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

/* Trigger: trgSoLuongGiaoVienTrongBoMon */
CREATE TRIGGER trgSoLuongGiaoVienTrongBoMon
ON GIAOVIEN 
FOR DELETE, UPDATE
AS
BEGIN
	IF( EXISTS(SELECT *
			   FROM DELETED AS D
			   WHERE (SELECT COUNT(*)
					  FROM GIAOVIEN 
					  WHERE MABM = D.MABM
					  GROUP BY MABM) < 4) )
	BEGIN
		RAISERROR(N'Lỗi: Một bộ môn phải có tối thiểu 4 giáo viên',16 ,1)
		ROLLBACK
	END
END
-- Drop trigger:
DROP TRIGGER trgSoLuongGiaoVienTrongBoMon

-- Update dữ liệu để test:
INSERT INTO GIAOVIEN VALUES ('014', N'Nguyễn Quỳnh Tâm', 2500, N'Nữ', '1974-03-02', N'67/9 Tân Lập, Q. Thủ Đức, TP HCM', NULL, 'MMT')

-- Test: 
DELETE FROM GIAOVIEN WHERE MAGV = '014'

-- T7. Trưởng bộ môn phải là người lớn tuổi nhất trong bộ môn
/* Xem thông tin các bảng */
SELECT *
FROM BOMON 

SELECT *
FROM GIAOVIEN

/* Trigger: trgTruongBoMonLonTuoiNhat_BOMON */
CREATE TRIGGER trgTruongBoMonLonTuoiNhat_BOMON
ON BOMON
FOR UPDATE
AS 
IF UPDATE(TRUONGBM)
BEGIN 
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE GV.MAGV = I.TRUONGBM
				AND GV.NGAYSINH > ANY(SELECT GVBM.NGAYSINH
									  FROM GIAOVIEN AS GVBM
									  WHERE GVBM.MABM = GV.MABM
									  AND GVBM.MAGV != GV.MAGV)) )
	BEGIN
		RAISERROR(N'Lỗi: Trưởng bộ môn phải là người lớn tuổi nhất trong bộ môn',16 ,1)
		ROLLBACK
	END
END

-- Drop Trigger trgQuyDinhTuoiTruongBoMon_BOMON để test:
DROP TRIGGER trgQuyDinhTuoiTruongBoMon_BOMON

-- Test:
UPDATE BOMON 
SET TRUONGBM = '002'
WHERE MABM = 'HTTT'

/* Trigger: trgTruongBoMonLonTuoiNhat_GIAOVIEN */
CREATE TRIGGER trgTruongBoMonLonTuoiNhat_GIAOVIEN
ON GIAOVIEN
FOR UPDATE
AS
IF UPDATE(NGAYSINH)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, BOMON AS BM
				WHERE I.MAGV = BM.TRUONGBM
				AND I.NGAYSINH > ANY(SELECT GVBM.NGAYSINH
								     FROM GIAOVIEN AS GVBM
									 WHERE GVBM.MAGV != I.MAGV
									 AND GVBM.MABM = I.MABM)) )
	BEGIN
		RAISERROR(N'Lỗi: Trưởng bộ môn phải là người lớn tuổi nhất trong bộ môn',16 ,1)
		ROLLBACK
	END
END

-- Drop một vài trigger để test:
DROP TRIGGER trgQuyDinhTuoiTruongBoMon_GIAOVIEN
DROP TRIGGER trgSoLuongGiaoVienTrongBoMon

-- Test:
UPDATE GIAOVIEN 
SET NGAYSINH = '2000-10-10'
WHERE MAGV = '002'

-- T8. Nếu một giáo viên đã là trưởng bộ môn thì giáo viên đó không làm người
-- quản lý chuyên môn.
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

SELECT *
FROM BOMON

/* Trigger: trgQuyDinhTruongBoMon_GVQLCM_BOMON */
CREATE TRIGGER trgQuyDinhTruongBoMon_GVQLCM_BOMON
ON BOMON
FOR UPDATE
AS
IF UPDATE(TRUONGBM)
BEGIN 
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE I.TRUONGBM = GV.GVQLCM
				AND I.MABM = GV.MABM) )
	BEGIN
		RAISERROR(N'Lỗi: Nếu một giáo viên đã là trưởng bộ môn thì giáo viên đó không làm người quản lý chuyên môn', 16, 1)
		ROLLBACK
	END 
END

-- Update dữ liệu để test:
INSERT INTO GIAOVIEN VALUES ('015', N'Nguyễn Lê Tuấn', 2000, 'Nam', '1999-05-05', N'13/2, TP Kon Tum', '005', 'VLDT')

-- Test:
UPDATE BOMON
SET TRUONGBM = '005'
WHERE MABM = 'VLDT'

/* Trigger: trgQuyDinhTruongBoMon_GVQLCM_GIAOVIEN */
CREATE TRIGGER trgQuyDinhTruongBoMon_GVQLCM_GIAOVIEN
ON GIAOVIEN 
FOR UPDATE
AS 
IF UPDATE(GVQLCM)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, BOMON AS BM, GIAOVIEN AS GV
				WHERE GV.MAGV = BM.TRUONGBM
				AND I.GVQLCM = GV.MAGV) )
	BEGIN
		RAISERROR(N'Lỗi: Nếu một giáo viên đã là trưởng bộ môn thì giáo viên đó không làm người quản lý chuyên môn',16 ,1)
		ROLLBACK
	END
END

-- Test:
UPDATE GIAOVIEN
SET GVQLCM = '001'
WHERE MAGV = '013'

-- T9. Giáo viên và giáo viên quản lý chuyên môn của giáo viên đó phải thuộc về 1 bộ môn.
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

/* Trigger: trgQuyDinhGV_GVQLCM */
CREATE TRIGGER trgQuyDinhGV_GVQLCM
ON GIAOVIEN
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE I.GVQLCM = GV.MAGV
				AND I.MABM != GV.MABM) )
	BEGIN
		RAISERROR('Lỗi: Giáo viên và giáo viên quản lý chuyên môn của giáo viên đó phải thuộc về 1 bộ môn',16 ,1)
		ROLLBACK
	END
END

-- Test:
UPDATE GIAOVIEN 
SET GVQLCM = '006'
WHERE MAGV = '002'

-- T10. Mỗi giáo viên chỉ có tối đa 1 vợ chồng
/* Xem thông tin các bảng */
SELECT *
FROM NGUOITHAN

SELECT *
FROM GIAOVIEN

/* Chỉnh sửa thông tin bảng để phù hợp với đề bài */
ALTER TABLE NGUOITHAN
ADD QUANHE nvarchar(15)

/* Trigger: trgQuyDinhQuanHeVoChong */
CREATE TRIGGER trgQuyDinhQuanHeVoChong
ON NGUOITHAN
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I
				WHERE I.QUANHE = N'Vợ chồng'
				AND EXISTS(SELECT *
						   FROM NGUOITHAN AS NT
						   WHERE I.MAGV = NT.MAGV
						   AND I.TEN != NT.TEN
						   AND NT.QUANHE = N'Vợ chồng')) )
	BEGIN
		RAISERROR(N'Lỗi: Mỗi giáo viên chỉ có tối đa 1 vợ chồng',16 ,1)
		ROLLBACK
	END
END

-- Update dữ liệu để test 
UPDATE NGUOITHAN
SET QUANHE = N'Vợ chồng'
WHERE PHAI = N'Nữ'
AND MAGV = '001'

-- Test:
INSERT INTO NGUOITHAN VALUES ('001', N'Thu', '1994-01-01', N'Nữ', N'Vợ chồng')

-- T11. Giáo viên là Nam thì chỉ có vợ là Nữ hoặc ngược lại.
/* Xem thông tin các bảng */
SELECT *
FROM NGUOITHAN

SELECT *
FROM GIAOVIEN

/* Trigger: trgQuyDinhGioiTinhVoChong_NGUOITHAN */
CREATE TRIGGER trgQuyDinhGioiTinhVoChong_NGUOITHAN
ON NGUOITHAN
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE GV.MAGV = I.MAGV 
				AND I.QUANHE = N'Vợ chồng'
				AND I.PHAI = GV.PHAI) )
	BEGIN
		RAISERROR(N'Lỗi: Giáo viên là Nam thì chỉ có vợ là Nữ hoặc ngược lại',16, 1)
		ROLLBACK
	END 
END 

-- Test: 
UPDATE NGUOITHAN
SET PHAI = 'Nam'
WHERE MAGV = '001'

INSERT INTO NGUOITHAN VALUES ('006', N'Tùng', '1992-01-02', N'Nữ', N'Vợ chồng')

/* Trigger: trgQuyDinhGioiTinhVoChong_GIAOVIEN */
CREATE TRIGGER trgQuyDinhGioiTinhVoChong_GIAOVIEN
ON GIAOVIEN 
FOR UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, NGUOITHAN AS NT
				WHERE I.MAGV = NT.MAGV
				AND I.PHAI = NT.PHAI
				AND NT.QUANHE = N'Vợ chồng') )
	BEGIN
		RAISERROR(N'Lỗi: Giáo viên là Nam thì chỉ có vợ là Nữ hoặc ngược lại',16 ,1)
		ROLLBACK
	END 
END

-- Test:
UPDATE GIAOVIEN
SET PHAI = N'Nữ'
WHERE MAGV = '001'

-- T12. Nếu thân nhân có quan hệ là "con gái" hoặc "con trai" với giáo viên thì năm sinh của giáo 
-- viên phải nhỏ hơn năm sinh của thân nhân.
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

SELECT *
FROM NGUOITHAN

/* Trigger: trgQuyDinhGiaoVienVaConCai_NGUOITHAN */
CREATE TRIGGER trgQuyDinhGiaoVienVaConCai_NGUOITHAN
ON NGUOITHAN
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE (I.QUANHE = N'Con gái' OR I.QUANHE = N'Con trai')
				AND I.MAGV = GV.MAGV AND YEAR(GV.NGAYSINH) >= YEAR(I.NGAYSINH)) )
	BEGIN
		RAISERROR(N'Lỗi: Năm sinh của giáo viên phải nhỏ hơn năm sinh của con cái',16 ,1)
		ROLLBACK
	END
END

-- Update dữ liệu để test:
UPDATE NGUOITHAN 
SET QUANHE = N'Con gái'
WHERE TEN = 'Vy'

-- Test:
UPDATE NGUOITHAN 
SET NGAYSINH = '1945-01-01'
WHERE TEN = 'Vy'

INSERT INTO NGUOITHAN VALUES ('001', N'Toàn', '1970-02-01','Nam' , N'Con trai') 

/* Trigger: trgQuyDinhGiaoVienVaConCai_GIAOVIEN */
CREATE TRIGGER trgQuyDinhGiaoVienVaConCai_GIAOVIEN
ON GIAOVIEN 
FOR UPDATE
AS 
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, NGUOITHAN AS NT
				WHERE I.MAGV = NT.MAGV
				AND (NT.QUANHE = N'Con gái' OR NT.QUANHE = N'Con trai')
				AND YEAR(I.NGAYSINH) >= YEAR(NT.NGAYSINH)) )
	BEGIN
		RAISERROR(N'Lỗi: Năm sinh của giáo viên phải nhỏ hơn năm sinh của con cái',16 ,1)
		ROLLBACK
	END 
END 
-- Drop một vài trigger để test:
DROP TRIGGER trgTruongBoMonLonTuoiNhat_GIAOVIEN

-- Test:
UPDATE GIAOVIEN
SET NGAYSINH = '2000-10-10'
WHERE MAGV = '001'

-- T13. Một giáo viên chỉ làm chủ nhiệm tối đa 3 đề tài.
/* Xem thông tin các bảng */
SELECT *
FROM DETAI

/* Trigger: trgQuyDinhSoLuongDeTaiChuNhiem */
CREATE TRIGGER trgQuyDinhSoLuongDeTaiChuNhiem
ON DETAI
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I
				WHERE (SELECT COUNT(*)
					   FROM DETAI AS DT
					   WHERE I.GVCNDT = DT.GVCNDT
					   GROUP BY DT.GVCNDT) > 3) )
	BEGIN
		RAISERROR(N'Lỗi: Một giáo viên chỉ làm chủ nhiệm tối đa 3 đề tài',16 ,1)
		ROLLBACK
	END
END

-- Update dữ liệu để test:
INSERT INTO DETAI VALUES ('008', N'HTTT quản lý các nhà sách', N'Trường', 50, '2007-01-02' , '2007-10-10', 'QLGD', '002')

-- Test:
INSERT INTO DETAI VALUES ('009', N'HTTT quản lý các trung tâm thương mại', N'Trường', 150, '2006-01-02' , '2008-10-10', 'QLGD', '002')

-- T14. Một đề tài phải có ít nhất một công việc.
/* Xem thông tin các bảng */
SELECT *
FROM CONGVIEC

/* Trigger: trgQuyDinhSoLuongCongViecToiThieu */
CREATE TRIGGER trgQuyDinhSoLuongCongViecToiThieu
ON CONGVIEC
FOR DELETE, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM DELETED AS D
				WHERE NOT EXISTS(SELECT *
								 FROM CONGVIEC AS CV
								 WHERE CV.MADT = D.MADT)) )
	BEGIN
		RAISERROR(N'Lỗi: Một đề tài phải có ít nhất một công việc',16 ,1)
		ROLLBACK
	END
END

-- Update dữ liệu để test: 
INSERT INTO CONGVIEC VALUES ('008', 1, N'Xác định yêu cầu', '2006-10-10', '2007-05-08')

-- Test:
DELETE FROM CONGVIEC WHERE MADT = '008'

-- T15. Lương của giáo viên phải nhỏ hơn lương người quản lý của giáo viên đó.
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN 

/* Trigger: trgQuyDinhLuongGV_GVQLCM */
CREATE TRIGGER trgQuyDinhLuongGV_GVQLCM
ON GIAOVIEN 
FOR INSERT, UPDATE
AS
BEGIN 
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE (I.GVQLCM = GV.MAGV
				AND I.LUONG > GV.LUONG) OR (I.MAGV = GV.GVQLCM
				AND I.LUONG < GV.LUONG)) )
	BEGIN
		RAISERROR(N'Lỗi: Lương của giáo viên phải nhỏ hơn lương người quản lý của giáo viên đó',16 ,1)
		ROLLBACK
	END 
END

-- Drop trigger:
DROP TRIGGER trgQuyDinhLuongGV_GVQLCM

-- Test: 
UPDATE GIAOVIEN
SET LUONG = 2000
WHERE MAGV = '002'

UPDATE GIAOVIEN
SET LUONG = 3000
WHERE MAGV = '003'

-- T16. Lương của trưởng bộ môn phải lớn hơn lương của các giáo viên trong bộ môn.
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

SELECT *
FROM BOMON

/* Trigger: trgQuyDinhLuongTruongBMVaGiaoVien_GIAOVIEN */
CREATE TRIGGER trgQuyDinhLuongTruongBMVaGiaoVien_GIAOVIEN
ON GIAOVIEN
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, BOMON AS BM, GIAOVIEN AS TRUONGBM
				WHERE (I.MAGV = BM.TRUONGBM
				AND I.LUONG < ANY(SELECT LUONG
								  FROM GIAOVIEN
								  WHERE MABM = I.MABM))
				OR (I.MABM = TRUONGBM.MABM AND TRUONGBM.MAGV = BM.TRUONGBM
				AND I.LUONG > TRUONGBM.LUONG) ))
	BEGIN
		RAISERROR(N'Lỗi: Lương của trưởng bộ môn phải lớn hơn lương của các giáo viên trong bộ môn',16 ,1)
		ROLLBACK
	END
END
-- Update dữ liệu đê test:
UPDATE GIAOVIEN 
SET LUONG = 1800
WHERE MAGV = '013'

UPDATE GIAOVIEN 
SET LUONG = 1800
WHERE MAGV = '014'

-- Test:
UPDATE GIAOVIEN 
SET LUONG = 2300
WHERE MAGV = '014'

UPDATE GIAOVIEN 
SET LUONG = 1500
WHERE MAGV = '001'

/* Trigger: trgQuyDinhLuongTruongBMVaGiaoVien_BOMON */
CREATE TRIGGER trgQuyDinhLuongTruongBMVaGiaoVien_BOMON
ON BOMON
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE I.TRUONGBM = GV.MAGV
				AND GV.LUONG < ANY(SELECT LUONG
				                   FROM GIAOVIEN
								   WHERE MABM = GV.MABM
								   AND MAGV != GV.MAGV) ))
	BEGIN
		RAISERROR(N'Lỗi: Lương của trưởng bộ môn phải lớn hơn lương của các giáo viên trong bộ môn',16 ,1)
		ROLLBACK
	END							
END

-- Drop một vài trigger để test:
DROP TRIGGER trgTruongBoMonLonTuoiNhat_BOMON

-- Test
UPDATE BOMON
SET TRUONGBM = '013'
WHERE MABM = 'MMT'

-- T17. Bộ môn ban nào cũng phải có trưởng bộ môn và trưởng bộ môn phải là một giáo viên trong bộ môn đó (Sửa đề)
/* Xem thông tin các bảng */
SELECT *
FROM BOMON 

SELECT *
FROM GIAOVIEN 

/* Trigger: trgQuyDinhTruongBoMon_BOMON */
CREATE TRIGGER trgQuyDinhTruongBoMon_BOMON
ON BOMON 
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE (I.TRUONGBM = GV.MAGV AND GV.MABM != I.MABM)
				OR (I.TRUONGBM IS NULL)) )
	BEGIN
		RAISERROR('Bộ môn ban nào cũng phải có trưởng bộ môn và trưởng bộ môn phải là một giáo viên trong bộ môn',16 ,1)
		ROLLBACK
	END
END

-- Drop trigger:
DROP TRIGGER trgQuyDinhTruongBoMon_BOMON

-- Drop trigger để test:
DROP TRIGGER trgQuyDinhTruongBoMon_GVQLCM_BOMON
DROP TRIGGER trgQuyDinhLuongTruongBMVaGiaoVien_BOMON

-- Test:
UPDATE BOMON
SET TRUONGBM = NULL
WHERE MABM = 'HTTT'

UPDATE BOMON 
SET TRUONGBM = '015'
WHERE MABM = 'MMT'

/* Trigger: trgQuyDinhTruongBoMon_GIAOVIEN */
CREATE TRIGGER trgQuyDinhTruongBoMon_GIAOVIEN
ON GIAOVIEN
FOR UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, BOMON AS BM
				WHERE I.MAGV = BM.TRUONGBM
				AND I.MABM <> BM.MABM) )
	BEGIN
		RAISERROR(N'Lỗi: Bộ môn ban nào cũng phải có trưởng bộ môn và trưởng bộ môn phải là một giáo viên trong bộ môn',16 ,1)
		ROLLBACK
	END
END

-- Drop một vài trigger để test:
DROP TRIGGER trgQuyDinhLuongTruongBMVaGiaoVien_GIAOVIEN

-- Test:
UPDATE GIAOVIEN
SET MABM = 'MMT'
WHERE MAGV = '002'

-- T18. Một giáo viên chỉ quản lý tối đa 3 giáo viên khác 
/* Xem thông tin các bảng */
SELECT *
FROM GIAOVIEN

/* Trigger: trgQuyDinhSLGVDuocQuanLy */
CREATE TRIGGER trgQuyDinhSLGVDuocQuanLy
ON GIAOVIEN 
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, GIAOVIEN AS GV
				WHERE I.GVQLCM = GV.MAGV
				AND (SELECT COUNT(*)
					 FROM GIAOVIEN
					 WHERE GV.MAGV = GVQLCM
					 GROUP BY GVQLCM) > 3) )
	BEGIN
		RAISERROR(N'Lỗi: Một giáo viên chỉ quản lý tối đa 3 giáo viên khác',16 ,1)
		ROLLBACK
	END
END 

-- Drop một vài trigger để test:
DROP TRIGGER trgQuyDinhTruongBoMon_GVQLCM_GIAOVIEN

-- Update dữ liệu để test:
INSERT INTO GIAOVIEN VALUES ('016', N'Lê Anh Nguyên', 1900, 'Nam', '2002-04-19', N'10/2 Kapakơlơng, TP Kon Tum', NULL, 'MMT') 

UPDATE GIAOVIEN 
SET GVQLCM = '001'
WHERE MAGV = '013'

UPDATE GIAOVIEN 
SET GVQLCM = '001'
WHERE MAGV = '014'

-- Test:
UPDATE GIAOVIEN 
SET GVQLCM = '001'
WHERE MAGV = '016'

INSERT INTO GIAOVIEN VALUES ('017', N'Lê Anh Tú', 1900, 'Nam', '2000-03-12', N'10/2 Kapakơlơng, TP Kon Tum', '001', 'MMT') 

-- T19. Giáo viên chỉ tham gia những đề tài mà giáo viên chủ nhiệm đề tài là người cùng bộ môn với giáo viên đó
/* Xem thông tin các bảng */
SELECT *
FROM THAMGIADT

/* Trigger: trgQuyDinhThamGiaDeTai */
CREATE TRIGGER trgQuyDinhThamGiaDeTai
ON THAMGIADT
FOR INSERT, UPDATE
AS
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED AS I, DETAI AS DT, GIAOVIEN AS CNDT, GIAOVIEN AS GV
				WHERE I.MAGV = GV.MAGV AND I.MADT = DT.MADT 
				AND DT.GVCNDT = CNDT.MAGV AND GV.MABM != CNDT.MABM) )
	BEGIN
		RAISERROR(N'Lỗi: Giáo viên chỉ tham gia những đề tài mà giáo viên chủ nhiệm đề tài là người cùng bộ môn với giáo viên đó',16 ,1)
		ROLLBACK
	END
END

-- Test: 
INSERT INTO THAMGIADT VALUES ('001', '005', 1, 1 ,NULL)

---------------------------------------------- END ----------------------------------------------