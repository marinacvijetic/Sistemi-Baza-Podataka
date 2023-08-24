
/* SQL upit - prikaz broja pregleda koji su izvrseni u periodu
od 01.01.2022. do 01.05.2022. ukljucujuci i te datume, grupisanih
prema tipu pregleda. Prikazani su samo tipovi pregleda ciji je broj
pregleda veci od 0. */
go
declare @pocetniDatum date = '2022-01-01'
declare @krajnjiDatum date = '2022-05-01'
select count(rbr_pregled) as "Broj pregleda", tp.naziv_tipa as "Tip pregleda"
from it60g2019Projekat.PREGLED p left join it60g2019Projekat.TIPPREGLEDA tp on p.id_tipa_pr = tp.id_tipa_pr
where datum_pregleda between @pocetniDatum and @krajnjiDatum
group by tp.naziv_tipa
having count(rbr_pregled) > 0
go


/* SQL upit - prikaz lekova koji su propisani, korisnicima na pregledu,
kao i zamena za taj lek, datum kada je lek propisan, datum kada je recept
za lek izdat i korisnik kome je recept izdat. Ukoliko zamena za lek ne postoji, to je i 
naznaceno. Takodje je prikazana i informacija o doktoru koji je propisao lek i izdao recept.
Podaci su sortirani rastuce prema datumu izdavanja recepta.*/
select l.naziv_leka as Lek, IIF(l.zamena_lek is null, 'Lek nema zamenu', z.naziv_leka) as "Zamena za lek", datum_prop as "Datum kada je lek propisan",
	   datum_izd as "Datum kada je recept za lek izdat", sk.ime_sk + ' ' + sk.prz_sk as Korisnik, lk.ime_lekar + ' ' + lk.prz_lekar as Lekar
from it60g2019Projekat.IZDAJESE izd left join it60g2019Projekat.LEK l on izd.id_lek=l.id_lek
									left join it60g2019Projekat.LEK z on z.id_lek = l.zamena_lek
									left join it60g2019Projekat.PROPISUJESE prop on prop.rbr_pregled=izd.rbr_pregled
									left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on izd.id_zk=zk.id_zk
									left join it60g2019Projekat.STACIONARNIKORISNIK sk on zk.id_sk=sk.id_sk
									left join it60g2019Projekat.PREGLED pr on izd.rbr_pregled = pr.rbr_pregled
									left join it60g2019Projekat.LEKAR lk on pr.id_lekar = lk.id_lekar
order by datum_izd asc


/*SQL upit - Prikaz korisnika kojima je prepisana terapija cija je ucestalost na nedeljnom nivou veca
od prosecne ili jednaka (terapija se primenjuje 3 ili vise puta nedeljno) naziv te terapije, ukupan broj SVIH
terapija koje su prepisane tom korisniku (terap.br).*/

go
declare @avgUcestalost numeric(8,2) = (select avg(ucestalost_ned) from it60g2019Projekat.TERAPIJA)
select sk.ime_sk + ' ' + sk.prz_sk as Korisnik, t.naziv_terap as Terapija, terap.br as 'Broj odredjenih terapija'
from it60g2019Projekat.ODREDJUJESE od left join it60g2019Projekat.TERAPIJA t on od.id_terapija= t.id_terapija
									  left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on od.id_zk=zk.id_zk
									  left join it60g2019Projekat.STACIONARNIKORISNIK sk on zk.id_sk=sk.id_sk
									  join (select id_zk, count(id_terapija) br from it60g2019Projekat.ODREDJUJESE group by id_zk) terap on terap.id_zk = od.id_zk
where t.ucestalost_ned >= @avgUcestalost
go

/*SQL upit - Prikaz terapija na kojima se koristi vise od jednog leka, koje sadrze
slovo O u svom nazivu, i gde se koristi veca ili jednaka kolicina leka od prosecne kolicine leka
samo za one lekove cija je jedinica mere izrazena u miligramima (mg), kao i broj
korisnika kojima su te terapije odredjene*/
go
declare @avgKol numeric(8,2) = (select avg(kolicina) from it60g2019Projekat.KORISTISE where jedinica_mere='mg')
select @avgKol as 'Prosecna kolicina leka koja se koristi na terapijama'
select t.naziv_terap as Terapija, count(k.id_lek) as 'Broj lekova koji se koriste na terapiji', k.kolicina as 'Kolicina', 
	   k.jedinica_mere as 'Jedinica mere', count(od.id_zk) as 'Broj korisnika kojima je ta terapija odredjena'
from it60g2019Projekat.KORISTISE k left join it60g2019Projekat.TERAPIJA t on k.id_terapija=t.id_terapija 
								   left join it60g2019Projekat.ODREDJUJESE od on od.id_terapija=k.id_terapija
where t.naziv_terap like '%o%'and k.kolicina >= @avgKol and k.jedinica_mere = 'mg'
group by t.naziv_terap, k.kolicina,k.jedinica_mere
go


/*SQL upit - prikaz godina do isteka roka lekova koji se koriste na terapijama
koje su odredjene korisnicima, kao i zamene za te lekove i broj godina do isteka njihovog roka upotrebe
za lekove ciji su proizvodjaci GALENIKA, ZDRAVLJE, TORLAK, PHARMAS I ALVOGEN PHARM */
select l.naziv_leka, DATEDIFF(year, cast(SYSDATETIME() as date), convert(varchar, l.rok_upotrebe)) 'Broj godina do isteka roka upotrebe leka', 
	   IIF(l.zamena_lek is not null, z.naziv_leka, 'Lek nema zamenu') as Zamena, 
	   IIF(l.zamena_lek is not null, cast(DATEDIFF(year, cast(SYSDATETIME() as date),  cast(z.rok_upotrebe as varchar)) as varchar), 'Nema informacije o isteku roka upotrebe leka') as 'Broj godina do isteka roka upotrebe zamene'
FROM it60g2019Projekat.ODREDJUJESE od left join it60g2019Projekat.KORISTISE k on od.id_terapija = k.id_terapija
									  left join it60g2019Projekat.LEK l on k.id_lek=l.id_lek
									  left join it60g2019Projekat.LEK z on z.id_lek = l.zamena_lek
where l.id_proizvodjac in (select id_proizvodjac from it60g2019Projekat.PROIZVODJACLEKA where naziv_proiz in ('Galenika', 'Zdravlje', 'Torlak', 'PharmaS', 'Alvogen Pharm'))

