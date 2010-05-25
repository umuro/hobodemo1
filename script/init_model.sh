script/generate hobo_model_resource Boat name:string sail_number:string
script/generate hobo_model_resource BoatClass name:string description:text no_of_crew_members:integer
script/generate hobo_model_resource Country name:string code:string
script/generate hobo_model_resource Course name:string
script/generate hobo_model_resource CourseArea name:string
script/generate hobo_model_resource CourseType name:string
script/generate hobo_model_resource CrewMember name:string isaf_id:string birthdate:date skipper:boolean remarks:text
script/generate hobo_model_resource Equipment serial:string
script/generate hobo_model_resource EquipmentType name:string description:text
script/generate hobo_model_resource Fleet color:string
script/generate hobo_model_resource NewsItem title:string body:text status:string
script/generate hobo_model_resource Participation date_entered:date date_measured:date measured_passed:boolean insured:boolean paid:boolean status:string
script/generate hobo_model_resource Regatta name:string start_date:date end_date:date description:text
script/generate hobo_model_resource ScheduledRace number:integer status:string planned_date:datetime actual_date:datetime
script/generate hobo_model_resource Spot name:string order:integer
script/generate hobo_model_resource SpotType name:string order:integer