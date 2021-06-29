# PTR
## Laboratory Work Nr 3.
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
This goal of the project was to create message broker with the possibility to publisj and subscribe to it. 
Publisher will serve laboratory work nr 2. For subscriber should be created client.
The message broker consist of:
* Connection Workers - responible for handling the connection from the publisher and subscribers;
* Topic Supervisor - creates new worker for each new topic;
* Topic Worker - has a queue of messages related to the topic;
* Publisher Memory - responsible for saving the topics and send mwssages to the specific topic worker;
* Subscriber Memory - serves as a proxy between the topic worker and connection worker for the specific topic;

## Technologies
The project is created in erlang with the help of:
* shotgun library - download events from the stream;
* rebar3 package manager - building program;
* jsx library - library for json parsing;

[Video](https://utm-my.sharepoint.com/:v:/g/personal/alexandru_osadcenco_isa_utm_md/EXOut2cIIY1Ii5Ej2kVx1ugBwMtiG-4j6vDyzs9f4NDr4w?e=CIDGDK)

## Architecture Diagram
![photo_2021-06-29_15-30-22](https://user-images.githubusercontent.com/19310230/123797624-0e156a80-d8ef-11eb-8d28-02264f14f0db.jpg)

