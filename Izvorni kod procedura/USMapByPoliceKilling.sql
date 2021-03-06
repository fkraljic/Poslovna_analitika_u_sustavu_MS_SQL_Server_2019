USE [US_Fatal_Police_Shootings]
GO
/****** Object:  StoredProcedure [dbo].[USMapByPoliceRaceKilling]    Script Date: 3.8.2020. 9:32:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USMapByPoliceRaceKilling]
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @query nvarchar(max) =  
  N'SELECT * FROM TEMP'
	
  EXECUTE sp_execute_external_script @language = N'R',  
                                     @script = N' 
	library(RODBC)
	library(ggplot2)
	library("maps")
	library(ggmap)
	library(mapdata)

	raceDB <- InputDataSet

	#getting states data
	states <- map_data("state")
	states <- data.frame(states)

	raceDB <- data.frame(
	  raceDB$ct,
	  raceDB$race,
	  raceDB$description,
	  raceDB$area,
	  raceDB$state_name,
	  raceDB$long,
	  raceDB$lat
	)
	names(raceDB)<-c("ct","race","desc","area","region","long1","lat1")

	numberOfCasesByRacePerState <- merge(raceDB,states,by="region")
	numberOfCasesByRacePerState <- numberOfCasesByRacePerState[order(numberOfCasesByRacePerState$group,numberOfCasesByRacePerState$order),]
	a <- as.numeric(factor(numberOfCasesByRacePerState$race))

	p <- ggplot(data = numberOfCasesByRacePerState) + 
	  geom_polygon(aes(x = long, y = lat, fill = a, group = group), color = "white") +
	  geom_text(data=numberOfCasesByRacePerState, aes(long1, lat1, label = race), size=9,color="yellow", fontface = "bold")+
	  geom_text(data=numberOfCasesByRacePerState, aes(long1, lat1, label = race), size=9,color="yellow")+
	  coord_fixed(1.3) +
	  guides(fill=FALSE)	

	png(filename="C:/Users/Fabijan/Desktop/Diplomski/US_Map_killings_by_race_in_state2.png", width=1600, height=900, units = "px")
	p <- p + labs(title = "Most fatal cases by race by US state")
	p <- p + theme(plot.title = element_text(size=24))
	p <- p + theme(axis.text=element_text(size=14),
            axis.title=element_text(size=14))
	plot(p)
	dev.off();
   ',  
   @input_data_1 = @query

 SET NOCOUNT OFF
END
