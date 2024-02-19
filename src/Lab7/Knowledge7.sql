-- Knowledge 7: Stored Procedure và Function

-- 1. Stored Procedure (Đọc là Stored Procedure hoặc Procedure)
---- 1.1. Giới thiệu:
-- Khi chúng ta tạo một ứng dụng với Microsoft SQL Server, ngôn ngữ lập trình Transact-SQL
-- là ngôn ngữ chính giao tiếp giữa ứng dụng và database của SQL Server. Khi chúng ta tạo các
-- chương trình bằng Transact-SQL, hai phương pháp chính có thể dùng để lưu trữ và thực thi
-- cho các chương trình là:

-- + Chúng ta có thể lưu trữ các chương trình cục bộ và tạo các ứng dụng để gởi các lệnh đến SQL Server
-- và xử lý các kết quả

-- + Chúng ta có thể lưu trữ những chương trình như các stored procedure trong SQL Server và tạo ứng dụng
-- để gọi thực thi các stored procedure và xử lý các kết quả

--------------------------------------------------
-- Đặc tính của Stored-Procedure trong SQL Server:
-- + Chấp nhận những tham số vào và trả về những giá trị được chứa các tham số ra để 
-- gọi những thủ tục tạo xử lý theo lô
-- + Chứa các lệnh của chương trình để thực hiện các xử lý trong database, bao gồm các lệnh gọi các thủ tục 
-- khác thực thi
-- + Trả về các trạng thái giá trị để gọi những thủ tục hoặc thực hiện các xử lý theo lô để
-- cho biết việc thực hiện thành công hay thất bại, nếu thất bại thì lý do vì sao thất bại

--------------------------------------------------
-- Ta có thể dùng Transact-SQL EXCUTE để thực thi các stored procedure. Stored Procedure khác với
-- các hàm xử lý là giá trị trả về của chúng không chứa trong tên và chúng không được sử dụng trực 
-- tiếp trong biểu thức.

-- Stored procedure có những thuận lợi so với các chương trình Transact-SQL lưu trữ cục bộ là:

-- + Stored procedure cho phép điều chỉnh chương trình cho phù hợp: Chúng ta có chỉ tạo stored procedure
-- một lần và lưu trữ trong database một lần, trong chương trình chúng ta có thể gọi nó với số lần bất kỳ.
-- Stored procedure có thể được chỉ rõ do một người nào đó tạo ra và sự thay đổi của chúng hoàn toàn độc lập
-- với source code của chương trình

-- + Stored procedure cho phép thực thi nhanh hơn: Nếu sự xử lý yêu cầu một đoạn source code Transact-SQL khá lớn,
-- hoặc việc thực thi mang tính lặp đi lặp lại thì stored procedure thực hiện nhanh hơn việc thực hiện hàng loạt các
-- lệnh Transact-SQL. Chúng được phân tích cú pháp và tối ưu hóa trong lần thực thi đầu tiên và một phiên bản dịch của
-- chúng trong đó sẽ được lưu trong bộ nhớ để sử dụng cho lần sau, nghĩa là trong những lần thực hiện sau chúng không
-- cần phải phân tích cú pháp tối ưu lại, mà chúng sử dụng kết quả đã được biên dịch trong lần đầu tiên

-- + Stored procedure có thể làm giảm bớt vấn đề kẹt đường truyền mạng: Giả sử một xử lý mà có sử dụng hàng triệu 
-- lệnh của Transact-SQL và việc thực hiện thông qua từng dòng lệnh đơn, như vậy việc thực hiện thông qua Stored 
-- procedure sẽ tốt hơn, vì nếu không khi thực hiện chúng ta phải gửi hàng trăm lệnh đó lên mạng và điều này sẽ 
-- dẫn đến trình trạng kẹt mạng.

-- + Stored procedure có thể sử dụng trong vấn đề bảo mật của máy: vì người sử dụng có thể được phân cấp những quyền 
-- để sử dụng các stored procedure này, thậm chí họ không được phép thực thi trực tiếp những stored procedure này.

--------------------------------------------------
---- 1.2. Cú pháp:
-- Một Stored procedure được định nghĩa gồm những thành phần chính sau:
-- + Tên của Stored Procedure
-- + Các tham số input/output
-- + Thân của Stored Procedure: Bao gồm các lệnh của Transact-SQL dùng để thực thi procedure

-- Một Stored procedure được tạo bằng lệnh CREATE PROCEDURE, và có thể thay đổi bằng cách dùng
-- lệnh ALTER PROCEDURE, và có thể xóa bằng cách dùng lệnh DROP PROCEDURE trong lập lệnh của 
-- Transact-SQL

--------------------------------------------------
-- Tạo Procedure:
-- CREATE PROCEDURE procedure_name
--		{@parameter data_type input/output} /Các biến tham số vào ra/
-- AS
-- BEGIN
--		[Khai báo các biến cho xử lý]
--		{Các câu lệnh Transact-SQL}
-- END

--------------------------------------------------
-- Một số lưu ý khi viết Stored Procedure:

/*1. Khai báo biến */
-- DECLARE @parameter_name data_type

/*2. Gán giá trị cho biến */
-- SET @parameter_name = value
-- SELECT @parameter_name = column FROM ...

/*3. In thông báo ra màn hình */
-- PRINT N'Chuỗi thông báo unicode'

/*4. Thông báo lỗi */
-- RAISERROR(N'Nội dung thông báo lỗi', 16, 1)

-- severity (Độ nghiêm trọng) (0-25): 16
-- state: Số nguyên chỉ trạng thái lỗi 

/*5. Lệnh rẽ nhánh */
-- IF (điều kiện có thể sử dụng câu truy vấn con và từ khóa EXISTS)
-- BEGIN
--			{Các lệnh nếu thỏa điều kiện / nếu chỉ có 1 lệnh thì không cần BEGIN ... END)
-- END

/* 6. Lệnh rẽ nhánh có ELSE */
-- IF (điều kiện có thể sử dụng cau truy vấn con và từ khóa EXISTS)
-- BEGIN
--			{Các lệnh nếu thỏa điều kiện / nếu chỉ có 1 lệnh thì không cần BEGIN ... END)
-- END
-- ELSE
-- BEGIN
--			{Các lệnh nếu thỏa điều kiện / nếu chỉ có 1 lệnh thì không cần BEGIN ... END)
-- END

/* 7. Vòng lặp WHITE (Lưu ý: Không có vòng lặp FOR) */
-- WHILE (điều kiện)
-- BEGIN
--			{Các lệnh nếu thỏa điều kiện / nếu chỉ có 1 lệnh thì không cần BEGIN ... END)
-- END

------------------------------------------------------------------------
-- Thực thi procedure:
-- Stored procedure không tham số: EXEC procedure_name 
-- Stored procedure có tham số: EXEC procedure_name Para1_value Para2_value, ... 

---------------------------------------------------------------------------------------
---- 1.3. Ví dụ:
USE SCHOOL_MANAGEMENT
-- Ví dụ 1: Viết Stored Procedure tính tổng 2 số:
-- Viết Stored Procedure:
CREATE PROCEDURE sp_Tong 
	@Num1 int,
	@Num2 int,
	@Sum int out
AS 
	SET @Sum = @Num1 + @Num2
GO

-- Thực thi Stored Procedure:
DECLARE @Sum int
EXEC sp_Tong 1, -2, @Sum out
PRINT @Sum

-- Ví dụ 2: Viết Stored Procedure tính tổng các số chẵn từ m -> n: 
-- Viết Stored Procedure:
CREATE PROCEDURE sp_TongChanMN 
	@m int,
	@n int
AS
BEGIN
	DECLARE @Sum int
	DECLARE @i int
	SET @Sum = 0 
	SET @i = @m
	WHILE (@i <= @n)
	BEGIN 
		IF (@i % 2 = 0)
			SET @Sum = @Sum + @i
		SET @i = @i + 1
	END
	DECLARE @SumStr nvarchar(50)
	SET @SumStr = CAST(@Sum AS nvarchar(50))
	PRINT N'Tổng số chẵn từ m -> n là: ' + @SumStr
	
END
GO

DROP PROCEDURE sp_TongChanMN
-- Thực thi Stored Procedure
EXEC sp_TongChanMN 1,20

-- Ví dụ 3: Viết Stored Procedure kiểm tra sự tồn tại của giáo viên theo mã
-- Viết Stored Procedure
CREATE PROCEDURE sp_KiemTraGVTonTai
	@MAGV char(5)
AS
BEGIN
	IF (EXISTS (SELECT * FROM GIAOVIEN WHERE MAGV = @MAGV))
		PRINT N'Giáo viên tồn tại'
	ELSE 
		PRINT N'Không tồn tại giáo viên ' + @MAGV + '!'
END
GO


-- Thực thi Stored Procedure
EXEC sp_KiemTraGVTonTai '002'

EXEC sp_KiemTraGVTonTai '015'

DROP PROCEDURE  sp_KiemTraGVTonTai

-- Ví dụ 4: Viết Stored Procedure xuất ra danh sách giáo viên của một bộ môn
-- Viết Stored Procedure:
CREATE PROCEDURE sp_DSGVBM 
	@MABM char(5)
AS
BEGIN
	IF (EXISTS (SELECT * FROM GIAOVIEN WHERE MABM = @MABM))
		BEGIN
			PRINT N'Danh sách giáo viên của bộ môn ' + @MABM + ' (Xem bên Results)'
			SELECT * FROM GIAOVIEN WHERE MABM = @MABM
		END
	ELSE
		PRINT N'Không tồn tại bộ môn này!'
END
GO

-- Thực thi Stored Procedure:
EXEC sp_DSGVBM 'HTTT'
EXEC sp_DSGVBM 'T'

DROP PROCEDURE sp_DSGVBM

----------------------------------------------------------------------------------
-- 2. Function
-- 2.1. Giới thiệu

-- Trong SQL Server, ta có thể viết hàm và lấy giá trị trả về. Các dạng hàm có thể viết như sau:
-- + Hàm trả về giá trị vô hướng (scalar value): varchar, int, ...
-- + Hàm trả về giá trị là bảng tạm (inline table-valued): table 

-- 2.2. Cú pháp:

-- Tạo hàm:
-- CREATE FUNCTION function_name ( [@parameter_name parameter_data_type])
-- RETURNS [return Data-type] 
-- AS
-- BEGIN
--		RETURN ([scalar value])
-- END

-- Tạo hàm trả về bảng (table):
-- CREATE FUNCTION function_name ( [@parameter_name parameter_data_type])
-- RETURNS table
-- AS
-- BEGIN
--		RETURN [select command]
-- END

-- 2.3. Ví dụ:
-- Ví dụ 5: Viết hàm tính tuổi dựa vào ngày sinh
-- Viết hàm:
CREATE FUNCTION f_TinhTuoi (@NGAYSINH datetime)
RETURNS int
AS
BEGIN
	RETURN YEAR(GETDATE()) - YEAR(@NGAYSINH)
END
-- Thực thi hàm:
PRINT dbo.f_TinhTuoi('1/1/2000')

SELECT MAGV, dbo.f_TinhTuoi(NGAYSINH) AS TUOI
FROM GIAOVIEN

-- Ví dụ 6: Viết hàm lấy danh sách giáo viên bộ môn HTTT
-- Viết hàm:
CREATE FUNCTION f_DSGV_HTTT ()
RETURNS table
AS
	RETURN (SELECT * FROM GIAOVIEN WHERE MABM = 'HTTT') 
GO

-- Kiểm tra:
SELECT *
FROM dbo.f_DSGV_HTTT()

DROP FUNCTION f_DSGV_HTTT

--------------------------------------- END ---------------------------------------