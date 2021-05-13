select * from dbo.Kills_Deaths_And_Entertainment 


/* 1.Identify the map with highest number of kills and death separately  */
select top 1[map_description],
            KILLS= sum(cast([kills] AS int))
from        dbo.Kills_Deaths_And_Entertainment   
group by    map_description 
ORDER BY    sum(cast([kills] AS int))DESC
 
 
 
select top 1 [map_description],
           DEATH= sum(cast([deaths] AS int))
from       dbo.Kills_Deaths_And_Entertainment   
group by   map_description 
ORDER BY   sum(cast([deaths] AS int))DESC


/*  2. Identify the weapon with highest kill and death separately for the result maps from Q1.  */
select top 1 weapon_class , KILLS= sum(cast([kills] AS int))
from   dbo.Kills_Deaths_And_Entertainment 
where  [map_description] in ( select top 1[map_description]
                              from       dbo.Kills_Deaths_And_Entertainment   
                              group by    map_description 
                              ORDER BY    sum(cast([kills] AS int))DESC
                              )
group by weapon_class                               
order by sum(cast([kills] AS int))desc


select top 1 weapon_class , DEATHS= sum(cast([deaths] AS int))
from   dbo.Kills_Deaths_And_Entertainment 
where  [map_description] in ( select top 1[map_description]
                              from       dbo.Kills_Deaths_And_Entertainment   
                              group by    map_description 
                              ORDER BY    sum(cast([deaths] AS int))DESC
                              )
group by weapon_class                               
order by sum(cast([deaths] AS int))desc


/* 3. Add a column to the table by the name of 'kd_ratio' : kd_ratio=kills/deaths */
select * ,
       kd_ratio = case 
                      when cast([deaths] AS float) =0 then 0 else
                     cast (cast([kills] AS float) /cast([deaths] as float) as decimal(10,4))
                      end
from   dbo.Kills_Deaths_And_Entertainment 

/* 4.Find mean, median, minimum, maximum, standard deviation for kills, deaths, kd_ratio at map and weapon class level
report with accuracy upto two decimal places.. */


select DISTINCT X.[map_description],X.[weapon_class]
       ,Y.Min_death,Y.Min_kill,Y.Min_kd_ratio
	   ,Y.Max_Map_death,Y.Max_Map_kill,Y.Max_kd_ratio
	   ,Y.Mean_death,Y.Mean_kill,Y.Mean_kd_ratio
	   ,X.median_death,X.median_kills,X.median_kd_ratio
	   ,ISNULL(Y.std_death,0) AS std_death,ISNULL(Y.std_kill,0) as std_kill,ISNULL(Y.std_kd_ratio,0) as std_kd_ratio
	   
from
(
		Select  [map_description],[weapon_class]
					   , cast(PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY death) OVER (partition by [map_description],[weapon_class])as decimal(10,2))  as median_death
					  , cast(PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY kills) OVER (partition by [map_description],[weapon_class])as decimal(10,2))  as median_kills
					   , cast(PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY kd_ratio) OVER (partition by [map_description],[weapon_class]) as decimal(10,2)) as median_kd_ratio
		from 


		(
		select map_description,
			   weapon_class,cast([deaths] AS Float) as death,
				kd_ratio = case 
							  when cast([deaths] AS float) =0 then 0 else
							 cast (cast([kills] AS float) /cast([deaths] as float) as decimal(10,4))
							  end,
							  cast([kills] AS Float) as kills
		from [dbo].[kills_deaths_and_entertainment]
		) A
) as X
INNER JOIN 
(
		SELECT  map_description,
       weapon_class,
      
		cast(MIN( cast([deaths] AS Float))
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Min_death,
		cast(MIN(cast([kills] AS Float) )
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Min_kill,
		
		cast(MIN(case 
                      when cast([deaths] AS float) =0 then 0 else
                     cast (cast([kills] AS float) /cast([deaths] as float) as decimal(10,4))
                      end)
                      
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Min_kd_ratio,
		cast(MAX( cast([deaths] AS Float))
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Max_Map_death,
		cast(MAX(cast([kills] AS Float) )
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Max_Map_kill,
		cast(MAX(case 
                      when cast([deaths] AS float) =0 then 0 else
                     cast (cast([kills] AS float) /cast([deaths] as float) as decimal(10,4))
                      end)
                      
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Max_kd_ratio,
		
		cast(AVG( cast([deaths] AS Float))
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Mean_death,
		cast(AVG(cast([kills] AS Float) )
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Mean_kill,
		cast(AVG(case 
                      when cast([deaths] AS float) =0 then 0 else
                     cast (cast([kills] AS float) /cast([deaths] as float) as decimal(10,4))
                      end)
                      
		over(partition by [map_description],[weapon_class])as decimal(8,2)) as Mean_kd_ratio,
		
		
		cast(stdev( cast([deaths] AS Float)) 
		over(partition by [map_description],[weapon_class]) as decimal(8,2)) as std_death,
		cast(stdev(cast([kills] AS Float) )
		over(partition by [map_description],[weapon_class]) as decimal(8,2)) as std_kill,
		cast(stdev(case 
                      when cast([deaths] AS float) =0 then 0 else
                     cast (cast([kills] AS float) /cast([deaths] as float) as decimal(10,4))
                      end)
                      
		over(partition by [map_description],[weapon_class]) as decimal(8,2)) as std_kd_ratio
		
		
		
		from dbo.Kills_Deaths_And_Entertainment 
) AS Y
ON X.[map_description]=Y.[map_description]
AND X.[weapon_class]=Y.[weapon_class]

/* 5.Identify all primary weapon under 'assault' class */
select   distinct weapon_description
from dbo.Kills_Deaths_And_Entertainment 
where weapon_class = 'Assault'
and   weapon_group = 'Primary'
