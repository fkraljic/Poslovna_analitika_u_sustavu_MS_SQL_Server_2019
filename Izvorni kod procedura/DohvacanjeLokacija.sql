USE [US_Fatal_Police_Shootings]
GO
/****** Object:  StoredProcedure [dbo].[generiranje_modela]    Script Date: 3.8.2020. 9:29:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[generiranje_modela] (@trained_model varbinary(max) OUTPUT)
AS

DECLARE @inquery nvarchar(max) = 
				N'SELECT sp.mental_illness,sc.manner_of_death,sc.armed,sp.age,r.gender,r.race,l.area,l.city,sc.thread_level,sc.flee FROM [dbo].[ShootPerson] sp
                JOIN [dbo].[ShootingCircumstances] sc ON sc.id=sp.fk_shooting_circ
                JOIN [dbo].[Race] r ON sp.fk_race=r.id
                JOIN [dbo].[Location] l ON l.id=sp.fk_location'
				

BEGIN
    EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'

databaseTable <- InputData

table <- data.frame(
                databaseTable$age,
                databaseTable$manner_of_death,
                databaseTable$armed,
                databaseTable$gender,
                databaseTable$race,
                databaseTable$area,
                databaseTable$mental_illness,
                databaseTable$thread_level,
                databaseTable$flee,
                databaseTable$city
                )

names(table) <- c("age", "manner", "armed", "gender", "race", "state", "sings", "thread", "flee", "city")
table

model <- glm(formula = sings ~ age + manner + armed + gender + city + state + race + thread + flee, data = table, family = quasibinomial)
model

trained_model <- as.raw(serialize(model, NULL));
'
    , @input_data_1 = @inquery
    , @input_data_1_name = N'InputData'
	, @params = N'@trained_model varbinary(max) OUTPUT'
    , @trained_model = @trained_model OUTPUT;
END;
