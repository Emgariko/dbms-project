create table if not exists Users
(
    UserId int primary key,
    Name   varchar(64) not null,
    Age    int         not null,
    Sex    boolean,
    Weight float       not null,
    Height float       not null,
    Email  varchar(64) not null,
    unique (Email)
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
    Cals      float       not null,
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
    WorkoutId     int         not null references Workouts (WorkoutId),
    unique (StartedAt, UserId),
    check (EndedAt > StartedAt)
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

-- В Postgres индексы автоматически создаются на Primary Key и вторичные ключи(unique).

-- Для ускорения фильрта по дате, ускорит запрос "Найти тренировки пользователя выполненные больше месяца назад"
create index if not exists idx_activities_startedat on Activities using btree (StartedAt);

-- Для ускорения фильтра по углеводам, ускорит запрос "Найти все продукты с высоким содержанием углеводов"
create index if not exists idx_foods_carbs on Foods using btree (Carbs);

-- Для ускорение join-а с Strategies, ускорит запросы 'Стратегия содержащая больше всего тренировок' и 'Стратегия содержащая больше всего дней'
create index if not exists idx_days_fk on Days using btree (StrategyId);