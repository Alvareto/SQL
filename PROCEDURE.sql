-- metoda
-- function upisStudenta(JMBAG) 
-- JMBAG = student
-- upisuje studenta (JMBAG) u grupu
-- grupa koja u trenutku poziva ima najmanju popunjenost kapaciteta
-- popunjenost kapaciteta = omjer broja studenata upisanih u grupu i kapaciteta grupe
-- u slučaju više grupa ista popunjenost => leksikografski najmanja oznaka grupe
-- SUCCESS: student uspješno upisan u grupu => ažuriraj atribut brojStud u relaciji grupa
-- ERRORS:
-- "Student je već upisan u nastavnu grupu"
-- "Student ne postoji"
-- "Sve grupe su već popunjene"

IF OBJECT_ID ( 'upisStudenta', 'P' ) IS NOT NULL   
    DROP PROCEDURE upisStudenta;  
GO  

CREATE PROCEDURE upisStudenta @JMBAG char(10)
AS 
BEGIN 
	DECLARE @oznGrupa char(10);
	DECLARE @ErrorMessage nvarchar(512);

	SELECT jmbag
	FROM stud
	WHERE jmbag = @JMBAG;
	IF @@ROWCOUNT = 0 
	BEGIN
		SET @ErrorMessage = N'Student ne postoji.';
		THROW 50502, @ErrorMessage, 1;
	END

	SELECT jmbag, oznGrupa
	FROM studGrupa
	WHERE jmbag = @JMBAG;
	IF @@ROWCOUNT > 0 
	BEGIN
		SET @ErrorMessage = N'Student je već upisan u nastavnu grupu.';
		THROW 50501, @ErrorMessage, 1;
	END

	BEGIN TRY  
		SELECT TOP(1) @oznGrupa = oznGrupa --, kapacitet, brojStud, brojStud / kapacitet AS popunjenost
		FROM grupa
		WHERE brojStud < kapacitet -- not equal, since that means full
		ORDER BY (brojStud / kapacitet) ASC, oznGrupa ASC; -- first popunjenost from smallest to largest, then same lexikografski by oznGrupa
	
		IF @@ROWCOUNT = 0 
		BEGIN
			SET @ErrorMessage = N'Sve grupe su već popunjene.';
			THROW 50503, @ErrorMessage, 1;
		END
	END TRY  
	BEGIN CATCH  
		THROW
	END CATCH;

	SELECT oznGrupa 
	FROM grupa 
	WHERE oznGrupa = @oznGrupa
	
	BEGIN TRY
		BEGIN TRANSACTION UPIS;

		INSERT INTO studGrupa
		VALUES(@JMBAG, @oznGrupa);

		UPDATE grupa
		SET brojStud = brojStud + 1
		WHERE oznGrupa = @oznGrupa;

		COMMIT TRANSACTION UPIS;
	END TRY  
	BEGIN CATCH  
		ROLLBACK TRANSACTION UPIS;

		THROW;
	END CATCH;

	-- SET NOCOUNT ON;
END 
GO	

IF OBJECT_ID ( 'rasporediPoGrupama', 'P' ) IS NOT NULL   
    DROP PROCEDURE rasporediPoGrupama;  
GO  

CREATE PROCEDURE rasporediPoGrupama --@JMBAG char(10)
AS 
BEGIN 
	DECLARE @JMBAG char(10);
	DECLARE @ErrorMessage nvarchar(512);
	DECLARE @ErrorVar INT;  

	-- za svakog studenta prema abecednom redoslijedu po jednom pozove upisStudenta
	DECLARE STUD_CURSOR CURSOR
		LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR
		SELECT DISTINCT jmbag
		FROM stud;

	OPEN STUD_CURSOR
	FETCH NEXT FROM STUD_CURSOR INTO @JMBAG
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @JMBAG

		-- Save the @@ERROR before cleared.  
		BEGIN TRY
			EXECUTE upisStudenta @JMBAG
		END TRY
		BEGIN CATCH
			SELECT @ErrorVar = @@ERROR  

			IF @ErrorVar = 50503
				BEGIN
					SET @ErrorMessage = N'Nije uspjelo raspoređivanje x studenata';
					THROW 50504, @ErrorMessage, 1;
				END;
			ELSE IF @ErrorVar <> 50501 AND @ErrorVar <> 50502
				THROW;

		END CATCH
		

		FETCH NEXT FROM STUD_CURSOR INTO @JMBAG
	END
	CLOSE STUD_CURSOR
	DEALLOCATE STUD_CURSOR
END 
GO	

EXECUTE rasporediPoGrupama
