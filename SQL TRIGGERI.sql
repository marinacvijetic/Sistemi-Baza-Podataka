/*Trigger nad tabelom LEK koji se okida kada se pokusa
unos leka ciji je rok upotrebe istekao, odnosno proverava se
datum isteka roka koji se unosi za lek. Ukoliko je datum
trenutni datum, ili datum koji je prosao, podize se Error i
printuje se odgovarajuca poruka */

IF OBJECT_ID('it60g2019Projekat.RokLeka', 'TR') IS NOT NULL
	DROP TRIGGER it60g2019Projekat.RokLeka

GO
CREATE TRIGGER it60g2019Projekat.RokLeka
ON it60g2019Projekat.LEK
INSTEAD OF INSERT, UPDATE 
AS
	BEGIN
		IF UPDATE(rok_upotrebe)
			BEGIN
				declare @stariRok date = (select rok_upotrebe from deleted)
				declare @noviRok date = (select rok_upotrebe from inserted)
				declare @trenutniDatum date = cast(SYSDATETIME() AS DATE)

				IF @stariRok != @noviRok and @stariRok is not null
					BEGIN
						IF(@noviRok <= @trenutniDatum )
							BEGIN
								declare @msg as nvarchar(200) = 'Error u %s trigger-u!'
								select @msg = FORMATMESSAGE(@msg, N'RokLeka')
								RAISERROR(@msg, 16, 0) WITH NOWAIT;
								PRINT 'Nije moguce evidentirati lek ciji je rok upotrebe istekao!' 

							END
						ELSE
							BEGIN
								update it60g2019Projekat.LEK
								set rok_upotrebe = @noviRok
								where id_lek = (select id_lek from inserted)

							END


					END
				ELSE IF (@stariRok is null)
					BEGIN
					IF(@noviRok > @trenutniDatum )
						BEGIN
									declare @naziv_leka varchar(50) = (select naziv_leka from inserted)
									declare @rok_upotrebe date = (select rok_upotrebe from inserted)
									declare @opis_leka varchar(100) = (select opis_leka from inserted)
									declare @id_proizvodjac int = (select id_proizvodjac from inserted)
									declare @zamena_lek int = (select zamena_lek from inserted)
									insert into it60g2019Projekat.LEK (naziv_leka, rok_upotrebe, opis_leka, id_proizvodjac, zamena_lek) values 
									(@naziv_leka, @rok_upotrebe, @opis_leka, @id_proizvodjac, @zamena_lek)

									PRINT 'Unos torke izvrsen'
						END
					ELSE
						BEGIN
							declare @msg1 as nvarchar(200) = 'Error u %s trigger-u!'
							select @msg1 = FORMATMESSAGE(@msg1, N'RokLeka')
							RAISERROR(@msg1, 16, 0) WITH NOWAIT;
							PRINT 'Nije moguce evidentirati lek ciji je rok upotrebe istekao!' 
						END

					END


			END

	END
GO

select * from it60g2019Projekat.LEK

--TEST TRIGGER INSERT
delete from it60g2019Projekat.LEK
where naziv_leka = 'BRUFEN'

insert into it60g2019Projekat.LEK (naziv_leka, rok_upotrebe, opis_leka, id_proizvodjac, zamena_lek)
values('BRUFEN', '2022-07-02', 'Ibuprofen tableta protiv bolova.', 1, 5)

--TEST TRIGGER UPDATE
update it60g2019Projekat.LEK 
set rok_upotrebe = '2022-06-02'
where id_lek=1



/*Trigger nad tabelom PROPISUJESE koji obezbeđuje da 
datum propisivanja leka mora biti isti kao i datum pregleda
na kom je lek propisan, a ukoliko nije, upis nije dozvoljen.
Na taj nacin je osigurano da lek ne moze biti propisan mimo pregleda.
Shodno tome, neophodan je još jedan triger nad tabelom 
IZDAJESE koji će obezbediti ogranicenje za uskladjivanje 
datuma i prilikom izdavanja recepta za te lekove. */

IF OBJECT_ID('it60g2019Projekat.UskladiDatumProp', 'TR') IS NOT NULL
	DROP TRIGGER it60g2019Projekat.UskladiDatumProp

GO
CREATE TRIGGER it60g2019Projekat.UskladiDatumProp 
ON it60g2019Projekat.PROPISUJESE
INSTEAD OF INSERT
AS
	BEGIN
		IF UPDATE(datum_prop)
			BEGIN
				declare @id_zk int = (select id_zk from inserted)
				declare @rbrpregled int = (select rbr_pregled from inserted)
				declare @datumPregled date = (select datum_pregleda from it60g2019Projekat.PREGLED where rbr_pregled=@rbrpregled and id_zk=@id_zk)
				declare @datum_prop date = (select datum_prop from inserted)

				IF(@datumPregled != @datum_prop)
					PRINT 'Lek mora biti propisan istog datuma kada je pregled izvrsen. Datum pregleda: ' + cast(@datumPregled as varchar)
				ELSE
					BEGIN
						declare @id_lek int = (select id_lek from inserted)
						insert into it60g2019Projekat.PROPISUJESE
						values (@id_lek, @rbrpregled, @id_zk, @datum_prop)
						PRINT 'Unos je izvrsen.'

					END

			END

	END
GO

select * from it60g2019Projekat.PROPISUJESE
select * from it60g2019Projekat.PREGLED

insert into it60g2019Projekat.PREGLED (datum_pregleda, opis, id_zk, id_tipa_pr, id_lekar)
values('2022-06-02', 'opis', 24, 1, 1)

delete from it60g2019Projekat.PREGLED
where id_zk=24

delete from it60g2019Projekat.PROPISUJESE
where id_zk=24 and rbr_pregled=21
--TEST TRIGGER INSERT
insert into it60g2019Projekat.PROPISUJESE
values(6, 21, 24, '2022-06-02' )



/*Triger nad tabelom IZDAJESE koji uskladjuje datume izdavanja recepta
i propisivanja leka sa datumom pregleda. Takodje se proverava da li se
prilikom navodjenja vrednosti torke unosi onaj lek koji je propisan na pregledu*/

IF OBJECT_ID('it60g2019Projekat.UskladiDatumIzd', 'TR') IS NOT NULL
	DROP TRIGGER it60g2019Projekat.UskladiDatumIzd

GO 
CREATE TRIGGER it60g2019Projekat.UskladiDatumIzd
ON it60g2019Projekat.IZDAJESE
INSTEAD OF INSERT
AS
	BEGIN
		IF UPDATE(id_recept)
			BEGIN
				declare @id_zk int = (select id_zk from inserted)
				declare @rbrpregled int = (select rbr_pregled from inserted)
				declare @datumProp date = (select datum_prop from it60g2019Projekat.PROPISUJESE where id_zk=@id_zk and rbr_pregled= @rbrpregled)
				declare @datum_izd date = (select datum_izd from inserted)

				IF(@datum_izd != @datumProp)
					BEGIN
						PRINT 'Recept za lek moze biti izdat samo na dan kada je lek propisan, a to je datum pregleda: ' + cast(@datumProp as varchar)
					END
				ELSE 
					BEGIN
						declare @id_recept int = (select id_recept from inserted)
						declare @lekProvera int = (select id_lek from it60g2019Projekat.PROPISUJESE where rbr_pregled=@rbrpregled and id_zk=@id_zk)
						declare @id_lek int = (select id_lek from inserted)

						IF(@id_lek != @lekProvera)
							BEGIN
								PRINT 'Lek koji se unosi eksplicitno nije isti lek koji je propisan na pregledu.'
							END
						ELSE
							BEGIN
								INSERT INTO it60g2019Projekat.IZDAJESE
								values(@id_zk, @rbrpregled, @id_lek, @id_recept, @datum_izd)
								PRINT 'Unos izvrsen.' 
							END

					END


			END


	END
GO

select * from it60g2019Projekat.IZDAJESE
select * from it60g2019Projekat.PROPISUJESE

delete from it60g2019Projekat.IZDAJESE 
where id_zk=24 and rbr_pregled=21 and id_lek=6
--PROVERA TRIGGERA
insert into it60g2019Projekat.IZDAJESE
values(24, 21, 7, 11, '2022-07-02')