USE [US_Fatal_Police_Shootings]
GO
/****** Object:  StoredProcedure [dbo].[KreiranjeTEMPTablice]    Script Date: 3.8.2020. 9:31:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[KreiranjeTEMPTablice]
AS
BEGIN
  SET NOCOUNT ON;
 CREATE TABLE TEMP (
   ct INT,
	race CHAR(1), 
	description VARCHAR(30), 	
	area VARCHAR(2),
	state_name VARCHAR(100),
	long FLOAT,
	lat FLOAT
);

;WITH rezultat AS (
    SELECT  r.race,r.description, COUNT(*) as ct,l.area,l.state_name, l.longitude AS long, l.latitude AS lat,
           ROW_NUMBER() OVER(PARTITION BY l.area ORDER BY COUNT(*) DESC) AS rk
		FROM [dbo].[ShootPerson] sp JOIN [dbo].[Race] r
		ON r.id=sp.fk_race
		JOIN [dbo].[Location] l
		ON sp.fk_location=l.id 
		GROUP BY r.race,r.description,l.area,l.state_name,l.longitude,l.latitude)

INSERT INTO TEMP SELECT ct, race, description, area, state_name, long, lat FROM rezultat s1 WHERE s1.rk = 1 ORDER BY state_name;

 SET NOCOUNT OFF
END
