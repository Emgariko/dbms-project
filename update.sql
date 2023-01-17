-- Запись в журнал о весе и росте
-- Уровень изоляции транзацкии - RU, т.к. чтений нету
create or replace function writeLog(
    LogId_ int,
    Weight_ float,
    Height_ float,
    UserId_ int
)
    returns bool
    language plpgsql
as
$$
begin
    insert into Logs(LogId, LogDateTime, Weight, Height, UserId) values (LogId_, now(), Weight_, Height_, UserId_);
    return true;
end;
$$;

-- Запись в журнал о весе и росте
select writeLog(21, 80.5, 180, 1);

-- Создание пользователя
-- Уровень изоляции транзацкии - RC, так как есть чтение из Logs
create or replace function createUser(
    UserId_ int,
    Name_ varchar(64),
    Age_ int,
    Sex_ boolean,
    Weight_ float,
    Height_ float,
    Email_ varchar(64)
)
    returns bool
    language plpgsql
as
$$
declare
    idx int;
begin
    idx = (select max(LogId) + 1 from Logs);
    insert into Users(UserId, Name, Age, Sex, Weight, Height, Email)
    values (UserId_, Name_, Age_, Sex_, Weight_, Height_, Email_);

    perform writeLog(idx, Weight_, Height_, UserId_);

    return true;
end;
$$;

-- Создание пользователя
select createUser(7, 'Тестов Кейс Валидович', 18, true, 80.5, 180, 'test@testcase.ru');

-- utility function
-- Уровень изоляции транзацкии - RC
create or replace function checkStrategy(
    UserId_ int
)
    returns bool
    language plpgsql
as
$$
begin
    return exists(
            select StrategyId
            from UsersStrategies
            where UserId = UserId_
        );
end;
$$;

-- Поменять/указать стратегию пользователю
-- Уровень изоляции транзацкии - RC, RU не подойдет, но RC подойдет
create or replace function setStrategy(
    UserId_ int,
    StrategyId_ int
)
    returns bool
    language plpgsql
as
$$
begin
    if (checkStrategy(UserId_)) then
        update UsersStrategies set StrategyId = StrategyId_ where UserId = UserId_;
    else
        insert into UsersStrategies(UserId, StrategyId) values (UserId_, StrategyId_);
    end if;

    return true;
end;
$$;

-- Добавление стратегии пользователю
select setStrategy(7, 1);
-- Изменение стратегии пользователя
select setStrategy(7, 1);

-- Поменять данные о теле пользователя
-- Уровень изоляции транзацкии - RC
create or replace function changeBodyData(
    UserId_ int,
    Weight_ float,
    Height_ float
)
    returns bool
    language plpgsql
as
$$
declare
    idx int;
begin
    idx = (select max(LogId) + 1 from Logs);
    update Users set Weight = Weight_, Height = Height_ where UserId = UserId_;

    perform writeLog(idx, Weight_, Height_, UserId_);

    return true;
end;
$$;

-- Изменение данных о теле пользователя, вес и рост пишутся в Logs
select ChangeBodyData(7, 80.5, 180);

-- Создать продукт
create or replace function createFood(
    FoodId_ int,
    FoodTitle_ varchar(32),
    Cals_ float,
    Carbs_ float,
    Protein_ float,
    Fat_ float,
    OwnerId_ int
)
    returns bool
    language plpgsql
as
$$
begin
    insert into Foods(FoodId, FoodTitle, Cals, Carbs, Protein, Fat, OwnerId)
    values (FoodId_, FoodTitle_, Cals_, Carbs_, Protein_, Fat_, OwnerId_);

    return true;
end;
$$;

-- Создание продукта
select CreateFood(16, 'Хлеб белый', 265, 49.1, 9.2, 3.2, 7);

-- utility function
-- Уровень изоляции транзацкии - RC
create or replace function checkFood(
    FoodId_ int
)
    returns bool
    language plpgsql
as
$$
begin
    return exists(
                   select FoodId
                   from MealsFoodsAmount
                   where FoodId = FoodId_
               )
        or
           exists(
                   select FoodId
                   from DaysFoodsAmount
                   where FoodId = FoodId_
               );
end;
$$;

-- Изменить продукт
-- Уровень изоляции транзацкии - RC, RU не подходит
create or replace function changeFood(
    FoodId_ int,
    FoodTitle_ varchar(32),
    Cals_ float,
    Carbs_ float,
    Protein_ float,
    Fat_ float,
    UserId_ int
)
    returns bool
    language plpgsql
as
$$
begin
    if (checkFood(FoodId_)) then
        return false;
    else
        update Foods set FoodTitle = FoodTitle_, Cals = Cals_, Carbs = Carbs_, Protein = Protein_, Fat = Fat_, OwnerId = UserId_ where FoodId = FoodId_;
    end if;

    return true;
end;
$$;

-- Изменение продукта, изменение успешно, потому что продукт еще нигде не использовался
select ChangeFood(16, 'Хлеб пшеничнй', 270, 49.5, 10.4, 3.4, 7);

insert into MealsFoodsAmount(MealId, FoodId, Amount, Weight) values (1, 16, 1, 100);
-- Изменение продукта, изменение не успешно, потому что продукт уже добавлен в прием пищи
select ChangeFood(16, 'Хлеб пшеничнй измененный', 270, 49.5, 10.4, 3.4, 7);
