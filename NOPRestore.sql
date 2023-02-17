SELECT @@SERVERNAME
SELECT SERVERPROPERTY('ServerName')

DECLARE @TrueDate VARCHAR(Max)
    SET @TrueDate = (
                    SELECT CAST(RIGHT('0' + CAST(DATEPART(MONTH, GETDATE()) AS varchar), 2) +
                                RIGHT('0' + CAST(DATEPART(DAY, GETDATE()) AS varchar), 2) +
                                CAST(DATEPART(YEAR, GETDATE()) AS varchar) AS numeric(10, 0))
                    )
DECLARE @DiskFile VARCHAR(MAX)
    SET @DiskFile = CONCAT(N'\\summerhall\DEVOPS\Summerhall-SQL01\azureDBs\aznopcommerce_', @TrueDate, '.bak')
    USE [nopcommerce]
    USE [master]
    IF @@SERVERNAME = 'DEV-SQL07\NOP'
        BEGIN
            ALTER DATABASE [nopcommerce] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
            RESTORE DATABASE [nopcommerce]
                FROM DISK = @DiskFile
                WITH FILE = 1
                , MOVE N'nopcommerce' TO N'F:\NOP\DATA\nopcommerce.mdf'
                , MOVE N'nopcommerce_log' TO N'E:\NOP\LOG\nopcommerce_log.LDF'
                , NOUNLOAD, REPLACE
                , STATS = 5
            ALTER DATABASE [nopcommerce] SET MULTI_USER ALTER DATABASE [nopcommerce] SET RECOVERY SIMPLE WITH NO_WAIT
--check that sqlsvc_intranet has read permissions on db
            USE [nopcommerce]
--GO
            CREATE USER [sqlsvc_intranetdev] FOR LOGIN [sqlsvc_intranetdev]
--GO
            USE [nopcommerce]
--GO
            ALTER ROLE [db_datareader] ADD MEMBER [sqlsvc_intranetdev]
--GO
        END
    ELSE
        BEGIN
            PRINT 'YOU ALMOST RESTORED ON A NON-QA SERVER!!!!!'
            RETURN
        END
GO

