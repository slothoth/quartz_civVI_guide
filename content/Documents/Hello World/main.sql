UPDATE Buildings SET Name = 'Congratulations' WHERE BuildingType='BUILDING_MONUMENT';


UPDATE Building_YieldChanges SET YieldChange = 10 WHERE BuildingType='BUILDING_MONUMENT' AND YieldType = 'YIELD_CULTURE';
INSERT INTO Building_YieldChanges(BuildingType, YieldType, YieldChange) VALUES
('BUILDING_MONUMENT', 'YIELD_FAITH', 5);