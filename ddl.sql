create table Users(
    UserId int primary key,
    Name varchar(64) not null,
    Age int not null,
    Sex boolean,
    Weight float not null,
    Height float not null,
    Email varchar(64) not null
);

create table Logs(
    LogId int primary key,
    LogDateTime timestamptz not null,
    Weight float not null,
    Height float not null,
    UserId int not null references Users(UserId)
);

create table Meals(
    MealId int primary key,
    MealTitle varchar(32) not null,
    HappenedAt timestamptz not null,
    UserId int not null references Users(UserId),
    unique (HappenedAt, UserId)
);

create table Foods(
    FoodId int primary key,
    FoodTitle varchar(32) not null,
    Cal float not null,
    Carbs float not null,
    Protein float not null,
    Fat float not null,
    OwnerId int not null references Users(UserId)
);

create table MealsFoodsAmount(
    MealId int not null references Meals(MealId),
    FoodId int not null references Foods(FoodId),
    Amount float not null,
    Weight float not null,
    primary key (MealId, FoodId)
);

create table Workouts(
    WorkoutId int primary key,
    WorkoutTitle varchar(32) not null,
    Description text not null,
    OwnerId int not null references Users(UserId)
);

create table Activities(
    ActivityId int primary key,
    ActivityTitle varchar(32) not null,
    StartedAt timestamptz not null,
    EndedAt timestamptz not null,
    UserId int not null references Users(UserId),
    WorkoutId int not null references Workouts(WorkoutId)
);

create table Strategies(
    StrategyId int primary key,
    StrategyTitle varchar(32) not null,
    OwnerId int not null references Users(UserId)
);

create table UsersStrategies(
    UserId int not null primary key references Users(UserId),
    StrategyId int not null references Strategies(StrategyId)
);

create table Days(
    DayId int primary key,
    DayNumber int not null,
    DayTitle varchar(32) not null,
    StrategyId int not null references Strategies(StrategyId)
);

create table DaysWorkoutsOrder(
    DayId int not null references Days(DayId),
    WorkoutId int not null references Workouts(WorkoutId),
    SeqNumber int not null,
    primary key (DayId, WorkoutId)
);

create table DaysFoodsAmount(
    DayId int not null references Days(DayId),
    FoodId int not null references Foods(FoodId),
    Amount float not null,
    Weight float not null,
    primary key (DayId, FoodId)
);