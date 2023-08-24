/*Procedura koja za prosledjeni id korisnika vraca koja ispitivanja sadrzi
uput koji je izdat tom korisniku*/

IF OBJECT_ID('it60g2019Projekat.KorisnikUputProc', 'P') IS NOT NULL
	DROP PROC it60g2019Projekat.KorisnikUputProc

GO
CREATE PROC it60g2019Projekat.KorisnikUputProc

	@id_sk int --id_sk prosledjujem 20 jer njegov uput sadrzi 6 ispitivanja
			   -- id_sk prosledjujem 6 jer njegov uput ima 3 ispitivanja
			   --id_sk prosledjujem 5 jer njegov uput ima 3 ispitivanja
AS 
	BEGIN
		declare @BrIspitivanje as int
		set @BrIspitivanje = (select count(id_ispitivanje) 
							  from it60g2019Projekat.SADRZI sd left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on sd.id_zk=zk.id_zk
															   left join it60g2019Projekat.STACIONARNIKORISNIK sk on sk.id_sk=zk.id_sk
							  where sk.id_sk=@id_sk)
		declare @imePrzKor as varchar(70) = (select ime_sk + ' ' + prz_sk from it60g2019Projekat.STACIONARNIKORISNIK where id_sk=@id_sk)
		declare @nazivIspitivanja as varchar(50)
		declare @rbr int = 1

		IF(@BrIspitivanje > 0)
			BEGIN
				PRINT 'Korisnik ' + @imePrzKor + ' ciji je ID=' + cast(@id_sk as varchar) + ', ima uput koji sadrzi sledeca ispitivanja ' 
				
				DECLARE IspitivanjaCur CURSOR FOR
					select i.naziv_isp
					from it60g2019Projekat.SADRZI sd left join it60g2019Projekat.ISPITIVANJE i on sd.id_ispitivanje = i.id_ispitivanje
													 left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on zk.id_zk=sd.id_zk
													 left join it60g2019Projekat.STACIONARNIKORISNIK sk on sk.id_sk=zk.id_sk
					where sk.id_sk=@id_sk
				OPEN IspitivanjaCur
					fetch next from IspitivanjaCur into @nazivIspitivanja
						
						WHILE @@FETCH_STATUS=0
							BEGIN
								PRINT cast(@rbr as varchar) + ', ' + @nazivIspitivanja

								fetch next from IspitivanjaCur into @nazivIspitivanja
								set @rbr=@rbr+1

							END
	

				CLOSE IspitivanjaCur
				DEALLOCATE IspitivanjaCur

			END
		ELSE
			PRINT 'Korisnik ' + @imePrzKor + ' nije upucen na dodatna ispitivanja.' 

	END

exec it60g2019Projekat.KorisnikUputProc 20




/*Procedura koja za prosledjeni id lekara izlistava korisnike koje je taj
lekar pregledao i listu lekova koje je prepisao tom korisniku*/

IF OBJECT_ID('it60g2019Projekat.LekarKorisnik', 'P') IS NOT NULL
	DROP PROC it60g2019Projekat.LekarKorisnik

GO
CREATE PROC it60g2019Projekat.LekarKorisnik 

	@id_lekar int 

AS 
	BEGIN
		IF(@id_lekar not in (select id_lekar from it60g2019Projekat.LEKAR))
			BEGIN
				PRINT 'Lekar sa prosledjenim ID-jem ne postoji.'
				RETURN;

			END
		declare @brPregledanih int = (select count(id_zk) from it60g2019Projekat.PREGLED where id_lekar=@id_lekar)
		declare @lekar varchar(50) = (select ime_lekar + ' ' + prz_lekar from it60g2019Projekat.LEKAR where id_lekar=@id_lekar)
		declare @korisnik varchar(50)
		declare @propisaniLek varchar(50)
		declare @brPropLekova int;
		declare @id_sk int;
		declare @rbr1 int =1
		declare @rbr2 int =1

		IF(@brPregledanih > 0)
			BEGIN
				PRINT 'Lekar ' + @lekar + ' ciji je ID=' + cast(@id_lekar as varchar) +  ' je pregledao sledece korisnike: '

				DECLARE KorisnikCur CURSOR FOR
					select sk.id_sk, sk.ime_sk + ' ' + sk.prz_sk
					from it60g2019Projekat.PREGLED p left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on p.id_zk=zk.id_zk
													 left join it60g2019Projekat.STACIONARNIKORISNIK sk on zk.id_sk=sk.id_sk
					where p.id_lekar = @id_lekar

				OPEN KorisnikCur
					fetch next from KorisnikCur into @id_sk, @korisnik
						WHILE @@FETCH_STATUS = 0
							BEGIN
								PRINT '		' + cast(@rbr1 as varchar) + '. ' + @korisnik 

								set @brPropLekova = (select count(p.id_lek) 
													 from it60g2019Projekat.PROPISUJESE p left join it60g2019Projekat.LEK l on p.id_lek=l.id_lek
																						  left join it60g2019Projekat.PREGLED pr on p.rbr_pregled=pr.rbr_pregled
																						  left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on zk.id_zk=p.id_zk
																						  left join it60g2019Projekat.STACIONARNIKORISNIK sk on sk.id_sk=zk.id_sk
													 where sk.id_sk = @id_sk and pr.id_lekar = @id_lekar)


								DECLARE PropisaniLekoviCur CURSOR FOR 
									select l.naziv_leka 
									from it60g2019Projekat.PROPISUJESE p left join it60g2019Projekat.LEK l on p.id_lek=l.id_lek
																		 left join it60g2019Projekat.PREGLED pr on p.rbr_pregled=pr.rbr_pregled
																		 left join it60g2019Projekat.ZDRAVSTVENIKARTON zk on zk.id_zk=p.id_zk
																		 left join it60g2019Projekat.STACIONARNIKORISNIK sk on sk.id_sk=zk.id_sk
									where sk.id_sk = @id_sk 

								OPEN PropisaniLekoviCur
									fetch next from PropisaniLekoviCur into @propisaniLek
									IF(@brPropLekova>0)
										BEGIN
												WHILE @@FETCH_STATUS=0
													BEGIN
															PRINT '			' + cast(@rbr2 as varchar) + '. ' + @propisaniLek

															fetch next from PropisaniLekoviCur into @propisaniLek
															set @rbr2 = @rbr2+1
								
													END
													
										END
									ELSE
										PRINT '			Nema propisanih lekova korisniku.'

								CLOSE PropisaniLekoviCur
								DEALLOCATE PropisaniLekoviCur

								fetch next from KorisnikCur into @id_sk, @korisnik
								set @rbr1 = @rbr1+1 

							END

				CLOSE KorisnikCur
				DEALLOCATE KorisnikCur
				

			END
		ELSE 
			PRINT 'Lekar nije pregledao ni jednog korisnika.'


	END

exec it60g2019Projekat.LekarKorisnik 1

