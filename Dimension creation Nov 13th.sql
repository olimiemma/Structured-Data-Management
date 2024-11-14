Making the TB database a DW
As a class, let's create a small Star Schema from our tb database.

First create a new SCHEMA called tb_dw.  Notice the 2 schemas: public and tb_dw.  Go to the Query Tool for the new tb_dw schema.

In the query tool, do a select * from tb to view the columns and data again.

Which field would equate to dimensions?

Let's start with Country.  Let's create a country_dim.  Let's use Serial.  Here's the syntax:

create table tb_dw.country_dim (
country_id serial primary key,
country_name varchar(100));

Using the Serial, what objects are created automatically?  Go to the object hierarchy in the tb_dw schema.  Is there a sequence?  What is its name?  Look at the definition.

Now let's load our table.  Let's test first by running these commands:

insert into tb_dw.country_dim (country_name) values ('Test Country');
select * from tb_dw.country_dim;

Check the definition of your sequence now.  Was it what you expect?

Now insert another test Country

insert into tb_dw.country_dim (country_name)
values ('Another Test Country');

Select the data and check the sequence definition again.  Is it what you expect?

Now let's delete the dummy data

delete from tb_dw.country_dim; and check the sequence definition

Now let's load the table, what value do you think the first key will be?

insert into tb_dw.country_dim (country_name)
(select distinct country from tb order by country);

select * from tb_dw.country_dim order by country_id;

Is it okay with the lowest value being what it is?

Congrats we have a dimension table called Country_dim.

Now let's create a Gender dimension using Identity.  Let's create a code and description column.

create table tb_dw.gender_dim (
gender_id int GENERATED ALWAYS AS IDENTITY primary key,
gender_code char(1),
gender_desc varchar(10));

Note we could have used DEFAULT if we wanted to override the identity column.  Also note that Identity still creates an explicit sequence - in prior versions it did not.

Now let's load the data, but for the new 'code', let's check the distinct values?

select distinct sex from tb;

Note the values are 'male' and 'female'.  Let's make the code M and F, but we should also add another 'O' even though its not in our data.  There are many ways to do this (e.g. CASE, but let's upper the first character.  Also, let's have proper case on the description.

insert into tb_dw.gender_dim (gender_code,gender_desc)
(select distinct upper(substr(sex,1,1)), initcap(sex)
from tb order by initcap(sex));
select * from tb_dw.gender_dim;

Now let's add our 'Other' row.

insert into tb_dw.gender_dim (gender_code,gender_desc)
values ('O','Other');

Create the year_dim  like country_dim.

What are some other attributes we can add to Year and Country Dimensions?

Now that we have our dimensions, let's create our TB_FACT table.  We need to have the surrogate keys replace the value, and let's clean up some naming:

create table tb_dw.tb_fact
(country_id int references tb_dw.country_dim (country_id),
year_id int references tb_dw.year_dim (year_id),
gender_id int references tb_dw.gender_dim (gender_id),
child_disease_amt int,
adult_disease_amt int,
elderly_disease_amt int,
primary key (country_id, year_id, gender_id ));

Now let's load it, we will need to adjust, join and bring in the correct keys.

insert into tb_dw.tb_fact
(select c.country_id, y.year_id, g.gender_id, t.child, t.adult, t.elderly
from tb t, tb_dw.country_dim c, tb_dw.year_dim y, tb_dw.gender_dim g
where t.country = c.country_name
and t.year = y.year_value
and t.sex = lower(g.gender_desc));

Let's make sure we got the same amount of rows:

select count(*) from tb;
select count(*) from tb_dw.tb_fact;

Let's look at the fact table

select * from tb_dw.tb_fact order by country_id, year_id, gender_id;

I didn't know about the null amounts, let's check the source
select * from tb where child is null;

Awesome, now let's get the better describing information from the dimensions:

select c.country_name, y.year_value, g.gender_code,
f.child_disease_amt, f.adult_disease_amt, f.elderly_disease_amt
from tb_dw.tb_fact f, tb_dw.country_dim c,
tb_dw.year_dim y, tb_dw.gender_dim g
where f.country_id = c.country_id
and f.year_id = y.year_id
and f.gender_id = g.gender_id
order by c.country_name, y.year_value, g.gender_code;

Now let's run a business queries: Find Central American Countries (and the number of female adults with TB and the year) where the number of Females with TB is great then Males after 2000 for Adults.  (Do you see any potential problems or 'gotchas' with this requirement, is there any follow up questions you would ask?)

First we have to know what which Countries are in Central America and find the keys.  Is there a better way to do this with 'data in the dimension'

Only 3 Central America Countries are in our dataset.

Here is the query:

select c.country_name, y.year_value, g.gender_code,
f.adult_disease_amt
from tb_dw.tb_fact f, tb_dw.country_dim c,
tb_dw.year_dim y, tb_dw.gender_dim g
where f.country_id = c.country_id
and f.year_id = y.year_id
and f.gender_id = g.gender_id
and c.country_id in (40,37,64)
and y.year_value > 2000
and g.gender_code = 'F'
and exists
(select 1 from tb_dw.tb_fact m
where m.year_id = f.year_id
and m.country_id = f.country_id
and m.gender_id <> f.gender_id
and f.adult_disease_amt > m.adult_disease_amt)
order by c.country_name, y.year_value, g.gender_code;

Notice you need a 'Female' dataset compared to a separate Male dataset.

Only 2 years for 2 countries?  Let's check:

select c.country_name, y.year_value, g.gender_code,
f.adult_disease_amt
from tb_dw.tb_fact f, tb_dw.country_dim c,
tb_dw.year_dim y, tb_dw.gender_dim g
where f.country_id in (37,64)
and f.country_id = c.country_id
and f.year_id = y.year_id
and f.gender_id = g.gender_id
and y.year_value > 2000
order by c.country_name, y.year_value, g.gender_code;

It's right!