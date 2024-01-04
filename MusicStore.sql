Q1. Who is the senior most employee based on job title?


SELECT TOP 1 *
from dbo.employee
ORDER by levels desc

Ans.- Madan

Q2. Which country have highest invoices?


select count(*) as c, billing_country
from dbo.invoice
group by billing_country
order by c desc

Ans.- USA

Q3.- What are top 3 values of total invoices?


#change the data type of total column to float
alter table dbo.invoice
alter column total float 

select Top (3) total from dbo.invoice
order by total desc

Q4.- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

select sum(total) as invoice_total, billing_city
from dbo.invoice
group by billing_city
order by invoice_total desc

Ans.- Prague (273.24 $)

Q5.- Who is the best customer whp has spent the most money?

alter table dbo.customer
alter column customer_id int

alter table dbo.invoice
alter column customer_id int

select Top (1) dbo.customer.customer_id, dbo.customer.first_name, dbo.customer.last_name, SUM(dbo.invoice.total) as total
from dbo.customer
JOIN dbo.invoice ON dbo.customer.customer_id = dbo.invoice.customer_id
group by dbo.customer.customer_id, dbo.customer.first_name, dbo.customer.last_name
order by total desc

Ans.- FrantiAjek

Q6.- Write query to return the email, first name, last name & Genre of all Rock music listners. Return your list ordered alphabetically by email starting with A

select distinct email, first_name, last_name
from dbo.customer
JOIN dbo.invoice ON dbo.customer.customer_id = dbo.invoice.customer_id
JOIN dbo.invoice_line ON dbo.invoice.invoice_id = dbo.invoice_line.invoice_id
WHERE track_id IN (
					Select track_id from dbo.track
					JOIN dbo.genre ON dbo.track.genre_id = dbo.genre.genre_id
					Where dbo.genre.name LIKE 'Rock'
					)
ORDER by email;

Q7.- Lets invite the artists who have written the most rock music in our dataset. Write a query that returns the artist name and total track count of the top 10 rock bands

Select Top (10) dbo.artist.artist_id, dbo.artist.name, Count(dbo.artist.artist_id) as Number_of_songs
from dbo.track
JOIN dbo.album ON dbo.album.album_id = dbo.track.album_id
JOIN dbo.artist ON dbo.artist.artist_id = dbo.album.artist_id
JOIN dbo.genre ON dbo.genre.genre_id = dbo.track.genre_id
Where dbo.genre.name = 'Rock'
Group by dbo.artist.artist_id, dbo.artist.name
Order By Number_of_songs desc


Q8.- Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track.
     Order by the song length with the longest songs listed first.

alter table dbo.track
alter column milliseconds int
	 
Select name, milliseconds
from dbo.track
Where milliseconds > (Select Avg(milliseconds) as avg_track_length From dbo.track)
Order by milliseconds desc

Q9.- Find How much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

With best_selling_artist As (
Select TOP (1) dbo.artist.artist_id, dbo.artist.name, 
Sum((dbo.invoice_line.unit_price) * (dbo.invoice_line.quantity) ) As total_sales
From dbo.invoice_line
Join dbo.track ON dbo.track.track_id = dbo.invoice_line.track_id
Join dbo.album ON dbo.album.album_id = dbo.track.album_id
Join dbo.artist ON dbo.artist.artist_id = dbo.album.artist_id
Group by dbo.artist.artist_id, dbo.artist.name
Order by total_sales desc)

Select c.customer_id, c.first_name, c.last_name, bsa.name,
Sum (il.unit_price*il.quantity) As amount_spent
From invoice i
Join dbo.customer c ON c.customer_id=i.customer_id
Join dbo.invoice_line il ON il.invoice_id=i.invoice_id
Join dbo.track t ON t.track_id=il.track_id
Join dbo.album alb ON alb.album_id=t.album_id
Join best_selling_artist bsa ON bsa.artist_id=alb.artist_id
Group by c.customer_id, c.first_name, c.last_name, bsa.name
Order by amount_spent desc;

Q9. We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the highest
amount of purchaces. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared 
return all genres.


With popular_genre As (
Select count (dbo.invoice_line.quantity) As purchases, dbo.customer.country, dbo.genre.name, dbo.genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY dbo.customer.country ORDER BY COUNT (dbo.invoice_line.quantity) DESC) As RowNO
From dbo.invoice_line
Join dbo.invoice ON dbo.invoice.invoice_id = dbo.invoice_line.invoice_id
Join dbo.customer ON dbo.customer.customer_id = dbo.invoice.customer_id
Join dbo.track ON dbo.track.track_id = dbo.invoice_line.track_id
Join dbo.genre ON dbo.genre.genre_id = dbo.track.genre_id
Group By dbo.customer.country, dbo.genre.name, dbo.genre.genre_id
)
Select *  From popular_genre 
Where RowNO<=1

Q10. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along
with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

With Customer_with_country AS (
Select dbo.customer.customer_id, dbo.customer.first_name, dbo.customer.last_name, dbo.invoice.billing_country, Sum(total) As total_spending,
Row_number () OVER (PARTITION BY dbo.invoice.billing_country ORDER By sum(total)  desc) As RowNo
From dbo.invoice
Join dbo.customer ON dbo.customer.customer_id = dbo.invoice.customer_id
Group By dbo.customer.customer_id, dbo.customer.first_name, dbo.customer.last_name, dbo.invoice.billing_country)
Select * From Customer_with_country where RowNo <= 1