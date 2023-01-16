--  drop all tables
drop table if exists Users cascade;
drop table if exists Logs cascade;
drop table if exists Meals cascade;
drop table if exists Foods cascade;
drop table if exists MealsFoodsAmount cascade;
drop table if exists Workouts cascade;
drop table if exists Activities cascade;
drop table if exists Strategies cascade;
drop table if exists UsersStrategies cascade;
drop table if exists Days cascade;
drop table if exists DaysWorkoutsOrder cascade;
drop table if exists DaysFoodsAmount cascade;


create table if not exists Users
(
    UserId int primary key,
    Name   varchar(64) not null,
    Age    int         not null,
    Sex    boolean,
    Weight float       not null,
    Height float       not null,
    Email  varchar(64) not null
);

create table if not exists Logs
(
    LogId       int primary key,
    LogDateTime timestamptz not null,
    Weight      float       not null,
    Height      float       not null,
    UserId      int         not null references Users (UserId),
    unique (LogDateTime, UserId)
);

create table if not exists Meals
(
    MealId     int primary key,
    MealTitle  varchar(32) not null,
    HappenedAt timestamptz not null,
    UserId     int         not null references Users (UserId),
    unique (HappenedAt, UserId)
);

create table if not exists Foods
(
    FoodId    int primary key,
    FoodTitle varchar(32) not null,
    Cal       float       not null,
    Carbs     float       not null,
    Protein   float       not null,
    Fat       float       not null,
    OwnerId   int         not null references Users (UserId)
);

create table if not exists MealsFoodsAmount
(
    MealId int   not null references Meals (MealId),
    FoodId int   not null references Foods (FoodId),
    Amount float not null,
    Weight float not null,
    primary key (MealId, FoodId)
);

create table if not exists Workouts
(
    WorkoutId    int primary key,
    WorkoutTitle varchar(32) not null,
    Description  text        not null,
    OwnerId      int         not null references Users (UserId)
);

create table if not exists Activities
(
    ActivityId    int primary key,
    ActivityTitle varchar(32) not null,
    StartedAt     timestamptz not null,
    EndedAt       timestamptz not null,
    UserId        int         not null references Users (UserId),
    WorkoutId     int         not null references Workouts (WorkoutId)
);

create table if not exists Strategies
(
    StrategyId    int primary key,
    StrategyTitle varchar(32) not null,
    OwnerId       int         not null references Users (UserId)
);

create table if not exists UsersStrategies
(
    UserId     int not null primary key references Users (UserId),
    StrategyId int not null references Strategies (StrategyId)
);

create table if not exists Days
(
    DayId      int primary key,
    DayNumber  int         not null,
    DayTitle   varchar(32) not null,
    StrategyId int         not null references Strategies (StrategyId)
);

create table if not exists DaysWorkoutsOrder
(
    DayId     int not null references Days (DayId),
    WorkoutId int not null references Workouts (WorkoutId),
    SeqNumber int not null,
    primary key (DayId, SeqNumber)
);

create table if not exists DaysFoodsAmount
(
    DayId  int   not null references Days (DayId),
    FoodId int   not null references Foods (FoodId),
    Amount float not null,
    Weight float not null,
    primary key (DayId, FoodId)
);