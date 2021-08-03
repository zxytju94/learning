# 语法介绍

>  注意事项：
>
>  - SQL 语句对大小写不敏感。SELECT 等效于 select。
>  - 字符串需要加**引号**，数字字符默认用数字表示。字符串内的内容对大小写敏感
>  - 通配符 % 与 * 相似，匹配0个以上的字符，- 与 . 相似代表一个字符



## 搜索查找

### 查询
#### SELECT

筛选表中某列值

```sql
SELECT 列名称 FROM 表名称
SELECT * FROM 表名称
```

<u>星号(\*)是选取所有列的快捷方式</u>

"person"表

| Id   | LastName | FirstName | Address        | City     |
| ---- | -------- | --------- | -------------- | -------- |
| 1    | Adams    | John      | Oxford Street  | London   |
| 2    | Bush     | George    | Fifth Avenue   | New York |
| 3    | Carter   | Thomas    | Changan Street | Beijing  |

```sql
SELECT LastName,FirstName FROM Persons
```

结果

| LastName | FirstName |
| -------- | --------- |
| Adams    | John      |
| Bush     | George    |
| Carter   | Thomas    |



### 条件查询

**条件查询语法**
```sql
SELECT column, another_column, …
FROM mytable
WHERE condition
    AND/OR another_condition
    AND/OR …;
```

#### WHERE

有条件地从表中选取数据，将 `WHERE` 子句添加到 `SELECT` 语句

```sql
SELECT 列名称 FROM 表名称 WHERE 列 运算符 值
```

|                操作符                 |                             描述                             |
| :-----------------------------------: | :----------------------------------------------------------: |
|                   =                   |                             等于                             |
|               <> 或 !=                |                            不等于                            |
|                   >                   |                             大于                             |
|                   <                   |                             小于                             |
|                  >=                   |                           大于等于                           |
|                  <=                   |                           小于等于                           |
| BETWEEN a AND b / NOT BETWEEN a AND b |                在某个范围内 / 不在某个范围内                 |
|           LIKE  /  NOT LIKE           | 搜索某种模式（模糊查询）<br />LIKE 没有用通配符%等价于 =<br />NOT LIKE 没用通配符等价于 != |
|        IN(...)  / NOT IN(...)         |                  在列表...内 /  不在列表内                   |

"Persons" 表

| LastName | FirstName | Address        | City     | Year |
| -------- | --------- | -------------- | -------- | ---- |
| Adams    | John      | Oxford Street  | London   | 1970 |
| Bush     | George    | Fifth Avenue   | New York | 1975 |
| Carter   | Thomas    | Changan Street | Beijing  | 1980 |
| Gates    | Bill      | Xuanwumen 10   | Beijing  | 1985 |

```sql
SELECT * FROM Persons WHERE City='Beijing'
```

结果：

| LastName | FirstName | Address        | City    | Year |
| -------- | --------- | -------------- | ------- | ---- |
| Carter   | Thomas    | Changan Street | Beijing | 1980 |
| Gates    | Bill      | Xuanwumen 10   | Beijing | 1985 |

注：WHERE后面跟的是一个逻辑表达式，即后面的数值是否为ture或非零。可以用 NOT a % 2 表示a为偶数。



#### AND & OR 

AND 和 OR 可在 WHERE 子语句中把两个或多个条件结合起来。

如果第一个条件和第二个条件都成立，则 AND 运算符显示一条记录。

如果第一个条件和第二个条件中只要有一个成立，则 OR 运算符显示一条记录。

原始的表 (用在例子中的)：

| LastName | FirstName | Address        | City     |
| -------- | --------- | -------------- | -------- |
| Adams    | John      | Oxford Street  | London   |
| Bush     | George    | Fifth Avenue   | New York |
| Carter   | Thomas    | Changan Street | Beijing  |
| Carter   | William   | Xuanwumen 10   | Beijing  |

```sql
SELECT * FROM Persons WHERE FirstName='Thomas' AND LastName='Carter'
```

结果：

| LastName | FirstName | Address        | City    |
| -------- | --------- | -------------- | ------- |
| Carter   | Thomas    | Changan Street | Beijing |

```sql
SELECT * FROM Persons WHERE (FirstName='Thomas' OR FirstName='William')  AND LastName='Carter'
```

结果：

| LastName | FirstName | Address        | City    |
| -------- | --------- | -------------- | ------- |
| Carter   | Thomas    | Changan Street | Beijing |
| Carter   | William   | Xuanwumen 10   | Beijing |

### 查询结果过滤

#### DISTINCT 

在筛选的结果中删除重复项

```sql
SELECT DISTINCT 列名称 FROM 表名称
```

"Orders"表：

| Company  | OrderNumber |
| -------- | ----------- |
| IBM      | 3532        |
| W3School | 2356        |
| Apple    | 4698        |
| W3School | 6953        |

```sql
SELECT DISTINCT Company FROM Orders 
```

结果：

| Company  |
| -------- |
| IBM      |
| W3School |
| Apple    |

`GROUP BY`也会返回唯一行，不过可以对具有相同属性值的行做一些统计计算，比如求和等。



#### ORDER BY

对结果集进行排序，默认按照升序进行排列

如果想用降序，用DESC关键字，升序用ASC关键字

```sql
SELECT column, another_column, …
FROM mytable
WHERE condition(s)
ORDER BY column ASC/DESC
```

Orders 表:

| Company  | OrderNumber |
| -------- | ----------- |
| IBM      | 3532        |
| W3School | 2356        |
| Apple    | 4698        |
| W3School | 6953        |

- 按照字母顺序显示公司名称

```sql
SELECT Company, OrderNumber FROM Orders ORDER BY Company
```

结果：

| Company  | OrderNumber |
| -------- | ----------- |
| Apple    | 4698        |
| IBM      | 3532        |
| W3School | 6953        |
| W3School | 2356        |

- 以字母顺序显示公司名称（Company），并以数字顺序显示顺序号（OrderNumber）：

```sql
SELECT Company, OrderNumber FROM Orders ORDER BY Company, OrderNumber
```

结果：

| Company  | OrderNumber |
| -------- | ----------- |
| Apple    | 4698        |
| IBM      | 3532        |
| W3School | 2356        |
| W3School | 6953        |

- 以逆字母顺序显示公司名称，并以数字顺序显示序号

```sql
SELECT Company, OrderNumber FROM Orders ORDER BY Company DESC, OrderNumber ASC
```

结果：

| Company  | OrderNumber |
| -------- | ----------- |
| W3School | 2356        |
| W3School | 6953        |
| IBM      | 3532        |
| Apple    | 4698        |



#### LIMIT & OFFSET

`LIMIT` 和 `OFFSET` 子句通常和`ORDER BY` 语句一起使用，当我们对整个结果集排序之后，我们可以` LIMIT`来指定只返回多少行结果，用 `OFFSET`来指定从哪一行开始返回。

```sql
SELECT column, another_column, …
FROM mytable
WHERE condition(s)
ORDER BY column ASC/DESC
LIMIT num_limit OFFSET num_offset;
```

按上映年份最新上线的4部电影

```sql
SELECT * FROM Movies ORDER BY Year DESC LIMIT 4 OFFSET 0
```

上面OFFSET 0 可以省略

##### TOP

SQL Server中支持TOP子句，表示要返回的记录的数目。但并非所有数据库都支持TOP子句。

```sql
SELECT TOP number|percent column_name(s)
FROM table_name
```

它与 LIMIT 等价，其中百分比可以写为  `TOP 50 PERCENT`



### SELECT 综合条件查询

本节是SELECT查询语法小总结

```sql
SELECT column, another_column, …
FROM mytable
WHERE condition(s)
ORDER BY column ASC/DESC
LIMIT num_limit OFFSET num_offset;
```



### 多表联合查询

#### INNER JOIN

在现实数据库中往往包含一组相关的数据表，这些表一般会符合数据库范式*(normalization)*

数据库范式是**数据表设计的规范**，在范式规范下，数据库里每个表存储的重复数据降到最少（这有助于数据的一致性维护），同时在数据库范式下，表和表之间不再有很强的数据耦合，可以**独立的增长** (ie. 比如汽车引擎的增长和汽车的增长是完全独立的).

范式带来了很多好处，但随着数据表的分离，意味着我们要查询多个数据属性时，需要更复杂的SQL语句，也就是本节开始介绍的**多表连接技术**。

主键(primary key)，在一般关系数据表中，有一个属性列设置为 **主键(primary key)**。主键是唯一标识一条数据，不会重复（和身份证号码一样）。一般常见的auto-incrementing integer(自增ID，每写入一行数据ID+1, 当然字符串，hash值等只要是每条数据是唯一的也可以设为主键。

```sql
SELECT column, another_table_column, …
FROM mytable （主表）
INNER JOIN another_table （要连接的表）
    ON mytable.id = another_table.id (想象一下刚才讲的主键连接，两个相同的连成1条)
WHERE condition(s)
ORDER BY column, … ASC/DESC
LIMIT num_limit OFFSET num_offset;
```

通过ON条件描述的关联关系；INNER JOIN先将两个数据表连接到一起。两个表中如果通过ID互相找不到的数据将会舍弃。此时，你可以将连表后的数据看作两个表的合并。再在此基础上进行原来的操作。

还有一个理解`INNER JOIN`的方式，就是把 `INNER JOIN` 想成两个集合的交集。        

<img src="http://www.xuesql.cn/static/img/0b46f21fbe096b639ff3bd4b0b338744eaf8acc7.png" alt="img" style="zoom:67%;" />

`INNER JOIN` 可以简写做 `JOIN`. 两者是相同的意思，但我们还是会继续写作  `INNER JOIN` 以便和后面的  `LEFT JOIN`， `RIGHT JOIN`等相比较.        

注意关键字在 FROM my_table 后，添加 

`INNER JOIN another_table ON my_table.Id = another_table.Id`



#### OUTER JOIN

**INNER JOIN**只会保留两个表都存在的数据，这看起来意味着一些数据的丢失，在某些场景下有问题。

本节要介绍的左连接`LEFT JOIN`,右连接`RIGHT JOIN` 和 全连接`FULL JOIN`. 

```sql
SELECT column, another_column, …
FROM mytable
INNER/LEFT/RIGHT/FULL JOIN another_table
    ON mytable.id = another_table.matching_id
WHERE condition(s)
ORDER BY column, … ASC/DESC
LIMIT num_limit OFFSET num_offset;
```

**LEFT  JOIN**

![img](http://www.xuesql.cn/static/img/leftjoin.png)

**RIGHT  JOIN**

![img](http://www.xuesql.cn/static/img/rightjoin.png)

**FULL  JOIN**

![img](http://www.xuesql.cn/static/img/fulljoin.jpeg)

将两个表数据进行one to one连接，保留A或B的原有行，如果某一行在另一个表不存在，会用 NULL来填充结果数据。

注意， FROM A LEFT JOIN B 和 FROM B RIGHT JOIN A 中，除了表头顺序可能不一样，其他内容是一样的。

#### NULL

特殊关键字NULL，在数据库中，NULL表达的是 "无"的概念，或者说没有东西。没有必要的情况下，我们应该尽量减少 `NULL`的使用。

如果某个字段你没有填写到数据库，很可能就会出现`NULL` 。所有一个常见的方式就是为字段设置`默认值`，比如 数字的默认值设置为0，字符串设置为 "" 字符串。但是在一些`NULL` 表示它本来含义的场景，需要注意是否设置默认值还是保持`NULL`。        

可以用`IS NULL`和 `IS NOT NULL` 来选在某个字段是否等于 `NULL`。

```sql
SELECT column, another_column, …
FROM mytable
WHERE column IS/IS NOT NULL
AND/OR another_condition
```



### 使用表达式

可以对SQL中出现col_name（属性名）的地方，添加表达式进行计算或处理。

表达式可以对 数字运算，对字符串运算，也可以在表达式中只包含常量不包含col_name(如：SELECT 1+1）

每一种数据库（mysql，sqlserver等）都有自己的一套函数，包含常用的数字，字符串，时间等处理过程.具体需要参看相关文档。

####  AS 表达式别名 Alias

表达式如果长了则很难一下子读懂，所以SQL提供了AS关键字，给表达式取一个别名。

```sql
SELECT col_expression AS expr_description, …
FROM mytable;
```

普通的属性列甚至是表（table）都可以取一个别名，这让SQL更容易理解。如

```sql
SELECT column AS better_column_name, …
FROM a_long_widgets_table_name AS mywidgets
INNER JOIN widget_sales
  ON mywidgets.id = widget_sales.widget_id;
```



#### 统计函数

这些统计函数可以帮助我们回答以下问题："Pixar公司生产了多少电影？"， 或 "每一年的票房冠军是谁?"。

```sql
SELECT AGG_FUNC(column_or_expression) AS aggregate_description, …
FROM mytable
WHERE constraint_expression;
```

常见的统计函数

| Function                                  | Description                                                  |
| ----------------------------------------- | ------------------------------------------------------------ |
| **COUNT(*****)**, **COUNT(***column***)** | 计数！COUNT(*) 统计数据行数<br />COUNT(column) 统计column非NULL的行数. |
| **MIN(***column***)**                     | 找column最小的一行.                                          |
| **MAX(***column***)**                     | 找column最大的一行.                                          |
| **AVG(***column*)                         | 对column所有行取平均值.                                      |
| **SUM(***column***)**                     | 对column所有行求和.                                          |



#### GROUP BY 分组统计

`GROUP BY` 数据分组语法可以按某个col_name对数据进行分组。如：`GROUP BY Year`指对数据按年份分组，        相同年份的分到一个组里。

```sql
用分组的方式统计
SELECT AGG_FUNC(column_or_expression) AS aggregate_description, …
FROM mytable
WHERE constraint_expression
GROUP BY column;
```

在GROUP BY分组语法中，我们知道数据库是先对数据做`WHERE`，然后对结果做分组。

如果我们要对分组完的数据再筛选出几条如何办？   （想一下按年份统计电影票房，要筛选出>100万的年份？）



#### HAVING  分组后条件

```sql
SELECT group_by_column, AGG_FUNC(column_expression) AS aggregate_result_alias, …
FROM mytable
WHERE condition
GROUP BY column
HAVING group_condition;
```

`HAVING` 和 `WHERE` 语法一样，只不过**作用的结果集**不一样。

小贴士：如果你不用`GROUP BY`语法, 简单的`WHERE`就够用了.        



### 查询执行顺序

完整的SELECT查询

```sql
SELECT DISTINCT column, AGG_FUNC(column_or_expression), …
FROM mytable
    JOIN another_table
      ON mytable.column = another_table.column
    WHERE constraint_expression
    GROUP BY column
    HAVING constraint_expression
    ORDER BY column ASC/DESC
    LIMIT count OFFSET COUNT;
```

执行顺序：

1. FROM 和 JOIN  先合并表
2. WHERE  数据筛选
3. GROUP BY  对之前的数据进行分组，也就意味着其他数据在分组后丢弃
4. HAVING   如果使用GROUP分组，将在分组完再次筛选，AS别名将不能用
5. SELECT  对col进行简单筛选或计算
6. DISTINCT  重排
7. ORDER BY  排序
8. LIMIT/OFFSET  截取

在写SQL的时候，可以灵活组合套用，例如有如下两个表：

Movies

| Id   | Title     | Director      | Year | Length_minutes |
| ---- | --------- | ------------- | ---- | -------------- |
| 1    | Toy Story | John Lasseter | 1995 | 81             |

Table: boxoffice

| Movie_id | Rating | Domestic_sales | International_sales |
| -------- | ------ | -------------- | ------------------- |
| 5        | 8.2    | 380843261      | 555900000           |

找出每部电影和单部电影销售冠军之间的销售差，列出电影名，销售额差额

SELECT Title, 
(**SELECT** max(Domestic_sales + International_sales) **FROM** Boxoffice)-Domestic_sales - International_sales
FROM Movies
JOIN Boxoffice ON Movies.id = Boxoffice.Movie_id
GROUP BY id





## 修改数据

### INSERT INFO

用于插入新的行

INSERT INFO ... VALUES (...)

```sql
INSERT INFO mytable VALUES (value1, value2, ...)
INSERT INFO table_name (col_1, col_2, ...) VALUES (value1, value2)
```

如果选择插入单独的行，则没有值的可能会用NULL填充



### UPDATE

修改表中的数据

```sql
UPDATE mytable SET col_name = new_value
	WHERE condition
```

用新的值来替换符合条件的旧值



### DELETE

删除表中的行

```sql
DELETE FROM mytable
	WHERE condition
```

注意：可以用 DELETE * FROM table_name 来删除所有的行，但表是保留的。但表的结构、属性、索引都是完整的。



## 宏观操作（表格级以上）

### UNION

UNION 操作符用于**合并**两个或多个 SELECT 语句的结果集

```sql
SELECT column_name(s) FROM table_name1
UNION
SELECT column_name(s) FROM table_name2
```

`注释`：默认地，UNION 操作符选取不同的值。如果允许重复的值，请使用 UNION ALL。



### SELECT INTO

**SQL SELECT INTO 语句可用于创建表的备份复件。**

```sql
SELECT column_name(s)
INTO new_table_name [IN externaldatabase] 
FROM old_tablename
```

FROM后面可以添加诸如WHERE的条件语句



### CREATE DATABASE

**CREATE DATABASE** 用于创建数据库

```sql
CREATE DATABASE database_name
```



### CREATE TABLE

**CREATE TABLE** 语句用于创建数据库中的表

```sql
CREATE TABLE 表名称
(
列名称1 数据类型,
列名称2 数据类型,
列名称3 数据类型,
....
)
```

数据类型(data_type)规定了可容纳何种数据类型。

| 数据类型                                                     | 描述                                                         |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| integer(size) <br />int(size) <br />smallint(size) <br />tinyint(size) | 仅容纳整数。在括号内规定数字的最大位数。                     |
| decimal(size,d) <br />numeric(size,d)                        | 容纳带有小数的数字。 <br />"size" 规定数字的最大位数。"d" 规定小数点右侧的最大位数。 |
| char(size)                                                   | 容纳固定长度的字符串（可容纳**字母、数字以及特殊字符**）。 <br />在括号中规定字符串的长度。 |
| varchar(size)                                                | 容纳可变长度的字符串（可容纳**字母、数字以及特殊的字符**）。<br />在括号中规定字符串的最大长度。 |
| date(yyyymmdd)                                               | 容纳日期。                                                   |



### VIEW

VIEW是视图，即可视化的表。

视图包含行和列，是一个真实的表。可以向视图中添加函数、WHERE、以及JOIN语句。

语法

```sql
CREATE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition
```

更新视图：

```sql
SQL CREATE OR REPLACE VIEW Syntax
CREATE OR REPLACE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition
```

撤销视图：

```sql
SQL DROP VIEW Syntax
DROP VIEW view_name
```



### DATE

DATE 与日期有关。

MySQL的一些内建日期函数：

| 函数                                                         | 描述                                |
| ------------------------------------------------------------ | ----------------------------------- |
| [NOW()](https://www.w3school.com.cn/sql/func_now.asp)        | 返回当前的日期和时间                |
| [CURDATE()](https://www.w3school.com.cn/sql/func_curdate.asp) | 返回当前的日期                      |
| [CURTIME()](https://www.w3school.com.cn/sql/func_curtime.asp) | 返回当前的时间                      |
| [DATE()](https://www.w3school.com.cn/sql/func_date.asp)      | 提取日期或日期/时间表达式的日期部分 |
| [EXTRACT()](https://www.w3school.com.cn/sql/func_extract.asp) | 返回日期/时间按的单独部分           |
| [DATE_ADD()](https://www.w3school.com.cn/sql/func_date_add.asp) | 给日期添加指定的时间间隔            |
| [DATE_SUB()](https://www.w3school.com.cn/sql/func_date_sub.asp) | 从日期减去指定的时间间隔            |
| [DATEDIFF()](https://www.w3school.com.cn/sql/func_datediff_mysql.asp) | 返回两个日期之间的天数              |
| [DATE_FORMAT()](https://www.w3school.com.cn/sql/func_date_format.asp) | 用不同的格式显示日期/时间           |

MySQL 使用下列数据类型在数据库中存储日期或日期/时间值：

- DATE - 格式 YYYY-MM-DD
- DATETIME - 格式: YYYY-MM-DD HH:MM:SS
- TIMESTAMP - 格式: YYYY-MM-DD HH:MM:SS
- YEAR - 格式 YYYY 或 YY

SQL Server 使用下列数据类型在数据库中存储日期或日期/时间值：

- DATE - 格式 YYYY-MM-DD
- DATETIME - 格式: YYYY-MM-DD HH:MM:SS
- SMALLDATETIME - 格式: YYYY-MM-DD HH:MM:SS
- TIMESTAMP - 格式: 唯一的数字




## SQL约束

约束用于限制加入表的数据的类型。

可以在创建表时规定约束（通过 **CREATE TABLE** 语句），或者在表创建之后也可以（通过 **ALTER TABLE **语句）。

`ALTER TABLE` 语句用于在已有的表中添加、修改或删除列。

约束的命名：例如约束名称为con_name

在创建时：

```mysql
CREATE TABLE mytable
(
First_col int NOT NULL,
Second_col varchar(255) NOT NULL,
Third_col varchar(255),
CONSTRAINT constraint_name xxx
)
```

表创建之后的添加

```mysql
ALTER TABLE mytable
ADD CONSTRAINT constraint_name xxx
```

撤销约束

```mysql
ALTER TABLE mytable
DROP CONSTRAINT constraint_name
```



### NOT NULL

约束列不接受NULL值，即强制字段始终包含值。如果不向字段添加值，就无法更新插入或更新信息。

举例：下面的SQL语句强制`“Id_P”`和`"LastName"`列不接受NULL值。

```sql
CREATE TABLE Persons
(
Id_P int NOT NULL,
LastName varchar(255) NOT NULL,
FirstName varchar(255),
Address varchar(255),
City varchar(255)
)
```



### UNIQUE

标识每一行的唯一标示符，如Id。它与`PRIMARY KEY`约束提供了唯一性的保证。

1. 如果在创建表的时候进行约束：

   MySQL的语法

   ```mysql
   CREATE TABLE Persons 
   (
   Id_P int NOT NULL,
   LastName varchar(255) NOT NULL,
   FirstName varchar(255),
   Address varchar(255),
   City varchar(255),
   UNIQUE (Id_P)
   )
   ```

   SQL Server / Oracle / MS Access的语法

   ```sql
   CREATE TABLE Persons
   (
   Id_P int NOT NULL UNIQUE,
   LastName varchar(255) NOT NULL,
   FirstName varchar(255),
   Address varchar(255),
   City varchar(255)
   )
   ```

   

2. 如果在表创建后添加约束：

   ```mysql
   ALTER TABLE Persons
   ADD UNIQUE (Id_P)
   ```

   如果要定义多个约束：

   ```mysql
   ALTER TABLE Persons
   ADD CONSTRAINT uc_PersonID UNIQUE (Id_P, LastName)
   ```

   

3. 删除约束：

   ```mysql
   ALTER TABLE Persons
   DROP INDEX uc_PersonID
   ```

   

### PRIMARY KEY

PRIMARY KEY 约束唯一标识

我们在创建表的时候可以使用

```mysql
PRIMARY KEY (Id_P)
```

```sql
Id_P int NOT NULL PRIMARY KEY
```

来定义约束

其余的和UNIQUE相同

请注意，每个表可以有多个 UNIQUE 约束，但是每个表只能有一个 PRIMARY KEY 约束。



### FOREIGN KEY

一个表中的 `FOREIGN KEY` 可以指向另一个表中的 `PRIMARY KEY`。它可以译为外键。

```mysql
FOREIGN KEY (Id_P) REFERENCES Persons(Id_P)
```

```sql
Id_P int FOREIGN KEY REFERENCES Persons(Id_P)
```

可以看出，在声明的时候，需要在原有基础上加上 `REFERENCES`。

约束用于预防破坏表之间连接的动作。

也能防止非法数据插入外键列，因为它必须是它指向的那个表中的值之一。



### CHECK

`CHECK`约束用于限制列中的值的范围

如果对单个列定义 `CHECK` 约束，那么该列只允许特定的值。

如果对一个表定义 `CHECK` 约束，那么此约束会在特定的列中对值进行限制。

```mysql
CHECK (Id_P>0)
```

```sql
Id_P int NOT NULL CHECK (Id_P>0)
```

如果需要命名CHECK约束，以及为多个列定义 CHECK 约束，使用如下：

```mysql
CONSTRAINT chk_Person CHECK (Id_P > 0 AND City = "Sandnes")
```

上面将约束命名为chk_Person， 如果撤销约束用

```mysql
ALTER TABLE Persons
DROP CONSTRAINT chk_Person
```



### DEFAULT

用于向列中插入默认值。

如果没有规定其他的值，会将默认值添加到所有的新纪录。

```mysql
City varchar(255) DEFAULT 'Sandnes'
```

也可以使用GETDATE()

```mysql
OrderDate date DEFAULT GETDATE()
```

如已存在对 "City" 列的约束，使用：

```mysql
ALTER TABLE Persons
ALTER City SET DEFAULT 'SANDNES'
```

```sql
ALTER TABLE Persons
ALTER COLUMN City SET DEFAULT 'SANDNES'
```

撤销：

```mysql
ALTER TABLE Persons
ALTER City DROP DEFAULT
```

```sql
ALTER TABLE Persons
ALTER COLUMN City DROP DEFAULT
```



### CREATE INDEX

```sql
CREATE 'UNIQUE' INDEX index_name
ON table_name (column_name 'DESC')
```

如果添加了 `UNIQUE` 关键字，则意味着两个行不能拥有相同的索引值。

如果添加了 `DESC` 关键字，则表示以降序索引某个列的值。



### INCREMENT

在每次插入新记录时，自动地创建主键字段的值。

假设 P_Id 被选择为主键，且开始的值是1，每条记录新增1。

```sql
P_Id int NOT NULL AUTO_INCREMENT,
```







## SQL 函数

**SQL拥有很多可用于计数和计算的内建函数。**

```sql
SELECT function(列) FROM 表
```



### 合计函数

Aggregate 函数的操作面向一系列的值，并返回一个单一的值。

| 函数         | 描述             |
| ----------- | ---------------- |
| AVG(column) | 返回某列的平均值 |
| COUNT(column) | 返回某列的行数（不包括NULL） |
| COUNT(*) | 返回被选行数 |
| FIRST/LAST(column) | 返回指定域中第一个/最后一个记录的值 |
| MAX/MIN(column) | 返回某列的最高/低值 |
| StDev(column) | 返回指定域的标准偏差 |
| StDevP(column) | 返回指定域的标准差 |
| SUM(column) | 返回某列的总和 |
| Var(column) | 求一组数据的方差 |
| VarP(column) | 求一组数据的总体方差 |



### 标量函数

Scalar 函数的操作面向某个单一的值，并返回基于输入值的一个单一的值。

| 函数                    | 描述                                   |
| ----------------------- | -------------------------------------- |
| UCASE(c)                | 将某个域转换为大写                     |
| LCASE(c)                | 将某个域转换为小写                     |
| MID(c,start[,end])      | 从某个文本域提取字符                   |
| LEN(c)                  | 返回某个文本域的长度                   |
| INSTR(c,char)           | 返回在某个文本域中指定字符的数值位置   |
| LEFT(c,number_of_char)  | 返回某个被请求的文本域的左侧部分       |
| RIGHT(c,number_of_char) | 返回某个被请求的文本域的右侧部分       |
| ROUND(c,decimals)       | 对某个数值域进行指定小数位数的四舍五入 |
| MOD(x,y)                | 返回除法操作的余数                     |
| NOW()                   | 返回当前的系统日期                     |
| FORMAT(c,format)        | 改变某个域的显示方式                   |
| DATEDIFF(d,date1,date2) | 用于执行日期计算                       |





[一个自学网站](http://www.xuesql.cn/) 包含基础的课程，高级课程付费

[w3school SQL学习网站](https://www.w3school.com.cn/sql/) 作为补充资料进行了解

自测可以用 leetcode

## 快速查找/总结

| 语句                                                         | 语法                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| AND / OR                                                     | SELECT column_name(s)  	FROM table_name  	WHERE condition  	AND\|OR condition |
| ALTER TABLE (add column)                                     | ALTER TABLE table_name  ADD column_name datatype             |
| ALTER TABLE (drop column)                                    | ALTER TABLE table_name  DROP COLUMN column_name              |
| AS (alias for column)                                        | SELECT column_name AS column_alias  FROM table_name          |
| AS (alias for table)                                         | SELECT column_name 	FROM table_name AS table_alias        |
| BETWEEN                                                      | SELECT column_name(s)  	FROM table_name  	WHERE column_name  	BETWEEN value1 AND value2 |
| CREATE DATABASE                                              | CREATE DATABASE database_name                                |
| CREATE INDEX                                                 | CREATE INDEX index_name  	ON table_name (column_name)     |
| CREATE TABLE                                                 | CREATE TABLE table_name  	(  	column_name1 data_type,  	column_name2 data_type,  	.......  	) |
| CREATE UNIQUE INDEX                                          | CREATE UNIQUE INDEX index_name  	ON table_name (column_name) |
| CREATE VIEW                                                  | CREATE VIEW view_name AS  	SELECT column_name(s)  	FROM table_name  	WHERE condition |
| DELETE FROM                                                  | DELETE FROM table_name   	(**Note:** Deletes the entire table!!)     *or* 	DELETE FROM table_name  	WHERE condition |
| DROP DATABASE                                                | DROP DATABASE database_name                                  |
| DROP INDEX                                                   | DROP INDEX table_name.index_name                             |
| DROP TABLE                                                   | DROP TABLE table_name                                        |
| GROUP BY                                                     | SELECT column_name1,SUM(column_name2)  	FROM table_name  	GROUP BY column_name1 |
| HAVING                                                       | SELECT column_name1,SUM(column_name2)  	FROM table_name  	GROUP BY column_name1  	HAVING SUM(column_name2) condition value |
| IN                                                           | SELECT column_name(s)  	FROM table_name  	WHERE column_name  	IN (value1,value2,..) |
| INSERT INTO                                                  | INSERT INTO table_name  	VALUES (value1, value2,....)                *or* 	INSERT INTO table_name  	(column_name1, column_name2,...)  	VALUES (value1, value2,....) |
| LIKE                                                         | SELECT column_name(s)  	FROM table_name  	WHERE column_name  	LIKE pattern |
| ORDER BY                                                     | SELECT column_name(s)  	FROM table_name  	ORDER BY column_name [ASC\|DESC] |
| SELECT                                                       | SELECT column_name(s)  	FROM table_name                   |
| SELECT *                                                     | SELECT *  	FROM table_name                                |
| SELECT DISTINCT                                              | SELECT DISTINCT column_name(s)  	FROM table_name          |
| SELECT INTO  	(used to create backup copies of  	tables) | SELECT *  	INTO new_table_name  	FROM original_table_name*or* 	SELECT column_name(s)  	INTO new_table_name  	FROM original_table_name |
| TRUNCATE TABLE  	(deletes only the data inside  	the table) | TRUNCATE TABLE table_name                                    |
| UPDATE                                                       | UPDATE table_name  	SET column_name=new_value  	[, column_name=new_value]  	WHERE column_name=some_value |
| WHERE                                                        | SELECT column_name(s)  	FROM table_name  	WHERE condition |

