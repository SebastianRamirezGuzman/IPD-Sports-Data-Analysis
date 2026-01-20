-- Análisis Temporal: 

select	top 1 Year(try_convert(date, FECHA_INICIO, 103)) Año_Mayor_Actividad, 
		count(EVENTO) as Nro_Actividad
		from dbo.Data_DeportistasEventos
		group by Year(try_convert(date, FECHA_INICIO, 103))
		Order by count(EVENTO) desc;  

-- Participación por Medallas: 

select	Deportista,
		PUESTO,
		Especialidad,
		EVENTO, 
		PAIS_EVENTO,
		FEDERACION
		from dbo.Data_DeportistasEventos
		where lower(PUESTO) in ('oro', 'plata', 'bronce');

-- Conteo por Medallas:

select	sum(case when Puesto = 'Oro' then 1 else 0 END) as Oro, 
		sum(case when Puesto = 'Plata' then 1 else 0 END) as Plata, 
		sum(case when Puesto = 'Bronce' then 1 else 0 END) as Bronce
		from dbo.Data_DeportistasEventos

-- Participación por Deporte: 

select TOP 5 count(evento),
			FEDERACION
		from dbo.Data_DeportistasEventos
		group by FEDERACION 
		order by count(evento) desc


-- Deportistas Calificados: 

select top 1 DEPORTISTA,
			 FEDERACION,
			 count(evento) as Participacion_Eventos_Internacionales
			 from dbo.Data_DeportistasEventos
			 group by DEPORTISTA, FEDERACION
			 order by count(evento) desc; 

-- Top de Ubicación de Eventos: 

select top 3 PAIS_EVENTO,
			 count(evento) as Eventos_Internacionales
			 from dbo.Data_DeportistasEventos
			 group by PAIS_EVENTO
			 order by count(evento) desc; 


-- Participación según Especialidad 

select	Top 10 ESPECIALIDAD, 
		count(EVENTO) as Total_Participaciones
		from dbo.Data_DeportistasEventos 
		group by ESPECIALIDAD
		order by COUNT(evento) desc;

-- Desempeño por Federación 

WITH CTE_Desempeño
as (
select	Deportista, 
		Federacion,
		Sum(case when lower(Puesto) in ('oro', 'plata', 'bronce') then 1 else 0 end) as Total_Medallas
		from dbo.Data_DeportistasEventos
		group by DEPORTISTA, FEDERACION

), 
CTE_Ranking as (
select	Deportista, 
		Federacion,	
		Total_Medallas, 
		sum(Total_Medalla) over (Partition by FEDERACION) as Total_Federacion, 
		ROW_NUMBER () over (Partition by Federacion order by Total_Medallas desc) as ranking_federacion
		from CTE_Desempeño 
) 
Select	DEPORTISTA,
		FEDERACION,
		Total_Medalla,
		Total_Federacion, 
		round((try_CAST(Total_Medalla as float) / Nullif(Total_Federacion,0)) * 100,2) as Porcentaje_Contribuccion
		from CTE_Ranking
		where ranking_federacion = 1 
		order by Porcentaje_Contribuccion desc; 

-- Identificación de países con participación única por federación

WITH CTE_Pais
as (
select	PAIS_EVENTO,
		FEDERACION
		from dbo.Data_DeportistasEventos
		where PAIS_EVENTO != 'PERU' 
),
CTE_Conteo_Federacion 
as ( 
select	Federacion, 
		PAIS_EVENTO, 
		count(*) as Valor_Total, 
		row_number () over (Partition by Federacion order by count(*) desc) as ranking
		from CTE_Pais
		group by Federacion, Pais_Evento 
)
select	Federacion,
		PAIS_EVENTO,
		Valor_Total
		from CTE_conteo_federacion 
		where valor_total = 1



