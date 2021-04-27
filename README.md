# PTR
## Laboratory Work Nr 2.
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
This goal of the project is to store engagement, sentiment scores and Tweet in a database. 
I separated my system in 2 groups of workers: static and dynamic. The first one has only one duplicate, the second one can be dynamically added and deleted.
Static part consists of:
* Filter - responsable for filtering messages and sending them to the agregator and to 2 types of routers - engagement router and sentiment router.
* Agregator - responsable for data agregation from filter, engagement worker and sentiment worker;
* Batcher - responsable for collecting dat into chunks of 128 elements and sending them to the Database;
* Database - stores data into ets database
For scalability I used pool of workers which starts other dynamic workers as:
* Reader - reader.erl
* Router - worker_router.erl
* Scaler - worker_scaler.erl
* Supervisor - worker_supervisor.erl
* Worker - sentinel_worker.erl

## Technologies
The project is created in erlang with the help of:
* shotgun library - download events from the stream;
* rebar3 package manager - building program;
* jsx library - library for json parsing;
* ets - erlang database;

[Video](https://utm-my.sharepoint.com/:v:/g/personal/alexandru_osadcenco_isa_utm_md/EaNLt_zrz2dCikr-lwKGbPgBUQQ0ejMxY52vFJxGVCdXIQ?e=bXWcy0)
