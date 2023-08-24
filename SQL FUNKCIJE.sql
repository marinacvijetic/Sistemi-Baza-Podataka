/* Funkcija koja za prosledjeni ID terapije vraca tabelu
korisnika koji idu na tu terapiju i koliko puta nedeljno*/

IF OBJECT_ID('it60g2019Projekat.KorisniciNaTerapiji', 'TF') IS NOT NULL
	DROP FUNCTION  it60g2019Projekat.KorisniciNaTerapiji

GO
CREATE FUNCTION it60g2019Projekat.KorisniciNaTerapiji
(
	@id_terapije int

)
RETURNS @Korisnici TABLE
(
	korisnik varchar(50),
	brTerapija int

)
AS
	BEGIN

		INSERT @Korisnici
			select sk.ime_sk + ' ' + sk.prz_sk, t.ucestalost_ned as 'Broj terapija na nedeljnom nivou'
			from it60g2019Projekat.ODREDJUJESE od left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on od.id_zk=zk.id_zk
												  left join it60g2019Projekat.STACIONARNIKORISNIK sk on sk.id_sk=zk.id_sk
												  left join it60g2019Projekat.TERAPIJA t on t.id_terapija=od.id_terapija
			where t.id_terapija=@id_terapije
			RETURN;

	END
GO

select korisnik, brTerapija
from it60g2019Projekat.KorisniciNaTerapiji(6)


/*Funkcija koja za prosledjeni ID lekara vraca podatak
koliko godina nakon zavrsene skole su ti lekari zavrsili
svoju specijalizaciju i koliko */

IF OBJECT_ID('it60g2019Projekat.GodineDoSpec', 'FN') IS NOT NULL
	DROP FUNCTION it60g2019Projekat.GodineDoSpec 

GO
CREATE FUNCTION it60g2019Projekat.GodineDoSpec
(
	@id_lekar int

)
RETURNS INT
AS
	BEGIN
		declare @brGod int
		declare @datumZavrsSk as date = (select dat_zavrs_sk from it60g2019Projekat.LEKAR where id_lekar=@id_lekar) 
		declare @datumSpec as date = (select datum_spec from it60g2019Projekat.LEKAR where id_lekar=@id_lekar)
		set @brGod = (DATEDIFF(year, @datumZavrsSk , @datumSpec))

		RETURN (@brGod)

	END
GO

select ime_lekar + ' ' + prz_lekar as Lekar, rad_staz as 'Radni staz', 
	   specijalizacija as Specijalizacija, it60g2019Projekat.GodineDoSpec(id_lekar) 
	   as 'Broj godina od datuma zavrsetka skole do specijalizacije'
from it60g2019Projekat.LEKAR


select it60g2019Projekat.GodineDoSpec(2) as GodineDoSpec