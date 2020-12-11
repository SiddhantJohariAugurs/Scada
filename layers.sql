create table layers (layerId int not null AUTO_INCREMENT,layerName varchar(50) not null,layerDescription varchar(1000),PRIMARY KEY(layerId));
insert into layers (layerName,layerDescription) values("First","This is the First Layer");
