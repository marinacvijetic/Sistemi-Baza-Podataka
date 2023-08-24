
IF OBJECT_ID('it60g2019Projekat') IS NOT NULL
DROP SCHEMA it60g2019Projekat
GO
CREATE SCHEMA it60g2019Projekat
GO 

DROP SEQUENCE it60g2019Projekat.StacK_SEQ

CREATE SEQUENCE it60g2019Projekat.StacK_SEQ as INT
	START WITH 1
	MINVALUE 1
	INCREMENT BY 1
	NO CYCLE;


IF OBJECT_ID('it60g2019Projekat.STACIONARNIKORISNIK', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.STACIONARNIKORISNIK

CREATE TABLE it60g2019Projekat.STACIONARNIKORISNIK
(
	id_sk INT NOT NULL,
	ime_sk VARCHAR(20) NOT NULL,
	prz_sk VARCHAR(30) NOT NULL,
	adresa_sk VARCHAR(100) NOT NULL,
	telefon_sk VARCHAR(10) NOT NULL,
	datum_rodj DATE NOT NULL,
	CONSTRAINT PK_StacionarniKorisnik PRIMARY KEY (id_sk)
);

ALTER TABLE it60g2019Projekat.STACIONARNIKORISNIK
	ADD CONSTRAINT DFT_StacionarniKorisnik_IdSk DEFAULT (next value for it60g2019Projekat.StacK_SEQ) for id_sk;





DROP SEQUENCE it60g2019Projekat.ZdrK_SEQ

CREATE SEQUENCE it60g2019Projekat.ZdrK_SEQ as INT
	START WITH 1
	MINVALUE 1
	INCREMENT BY 1
	NO CYCLE;


IF OBJECT_ID('it60g2019Projekat.ZDRAVSTVENIKARTON', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.ZDRAVSTVENIKARTON

CREATE TABLE it60g2019Projekat.ZDRAVSTVENIKARTON
(
	id_zk INT NOT NULL,
	datum_kreiranja DATE NOT NULL,
	napomena VARCHAR(100) CONSTRAINT DFT_ZdravstveniKarton_napomena DEFAULT(''),

	id_sk INT NOT NULL,
	CONSTRAINT FK_ZdravstveniKarton_StacionarniKorisnik FOREIGN KEY (id_sk)
		REFERENCES it60g2019Projekat.STACIONARNIKORISNIK (id_sk),
	CONSTRAINT PF_ZdravstveniKarton PRIMARY KEY (id_zk),
	CONSTRAINT UQ_ZdravstveniKarton_idSk UNIQUE (id_sk)	
);

ALTER TABLE it60g2019Projekat.ZDRAVSTVENIKARTON
	ADD CONSTRAINT DFT_ZdravstveniKarton_IdZk DEFAULT (next value for it60g2019Projekat.ZdrK_SEQ) for id_zk;



IF OBJECT_ID('it60g2019Projekat.LEKAR', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.LEKAR

CREATE TABLE it60g2019Projekat.LEKAR 
(
	id_lekar INT NOT NULL IDENTITY,
	ime_lekar VARCHAR(30) NOT NULL,
	prz_lekar VARCHAR(30) NOT NULL,
	adresa_lekar VARCHAR(50) NOT NULL,
	br_tel_lekar VARCHAR(10) NOT NULL,
	dat_zavrs_sk DATE NOT NULL,
	rad_staz INT NOT NULL,
	stepen_str_spr VARCHAR(20) NOT NULL,
	specijalizacija VARCHAR(40) NOT NULL,
	datum_spec DATE NOT NULL,
	CONSTRAINT PK_Lekar PRIMARY KEY(id_lekar),
	CONSTRAINT CHK_Lekar_RadStaz CHECK(rad_staz > 0)
);




IF OBJECT_ID('it60g2019Projekat.TIPPREGLEDA', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.TIPPREGLEDA

CREATE TABLE it60g2019Projekat.TIPPREGLEDA
(
	id_tipa_pr INT NOT NULL IDENTITY,
	naziv_tipa VARCHAR(30) NOT NULL,
	CONSTRAINT PK_TipPregleda PRIMARY KEY(id_tipa_pr)
);




IF OBJECT_ID('it60g2019Projekat.PREGLED', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.PREGLED

CREATE TABLE it60g2019Projekat.PREGLED
(
	rbr_pregled INT NOT NULL IDENTITY,
	datum_pregleda DATE NOT NULL,
	opis VARCHAR(100) CONSTRAINT DFT_Pregled_opis DEFAULT(''),

	id_zk INT NOT NULL,
	id_tipa_pr INT NOT NULL,
	id_lekar INT NOT NULL,
	CONSTRAINT FK_Pregled_ZdravstveniKarton FOREIGN KEY(id_zk)
		REFERENCES it60g2019Projekat.ZDRAVSTVENIKARTON (id_zk),
	CONSTRAINT FK_Pregled_TipPregleda FOREIGN KEY (id_tipa_pr)
		REFERENCES it60g2019Projekat.TIPPREGLEDA (id_tipa_pr),
	CONSTRAINT FK_Pregled_Lekar FOREIGN KEY (id_lekar)
		REFERENCES it60g2019Projekat.LEKAR (id_lekar),
	CONSTRAINT PK_PREGLED PRIMARY KEY (id_zk, rbr_pregled)
);




IF OBJECT_ID('it60g2019Projekat.SPECIJALISTA', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.SPECIJALISTA

CREATE TABLE it60g2019Projekat.SPECIJALISTA
(
	id_spec INT NOT NULL IDENTITY,
	naziv_spec VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Specijalista PRIMARY KEY (id_spec)
);




IF OBJECT_ID('it60g2019Projekat.UPUT', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.UPUT

CREATE TABLE it60g2019Projekat.UPUT
(
	rbr_uput INT NOT NULL IDENTITY,
	datum_izdavanja DATE NOT NULL,
	opis VARCHAR(100) CONSTRAINT DFT_Uput_opis DEFAULT(''),

	id_zk INT NOT NULL,
	rbr_pregled INT NOT NULL,
	id_spec INT NOT NULL,
	CONSTRAINT FK_Uput_Pregled FOREIGN KEY (id_zk,rbr_pregled)
		REFERENCES it60g2019Projekat.PREGLED (id_zk, rbr_pregled),
	CONSTRAINT FK_Uput_Specijalista FOREIGN KEY (id_spec)
		REFERENCES it60g2019Projekat.SPECIJALISTA (id_spec),
	CONSTRAINT PK_Uput PRIMARY KEY (id_zk, rbr_pregled, rbr_uput)
);




IF OBJECT_ID('it60g2019Projekat.ISPITIVANJE', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.ISPITIVANJE

CREATE TABLE it60g2019Projekat.ISPITIVANJE
(
	id_ispitivanje INT NOT NULL IDENTITY,
	naziv_isp VARCHAR(30) NOT NULL,
	opis VARCHAR(100) CONSTRAINT DFT_Ispitivanje_opis DEFAULT(''),
	CONSTRAINT PK_Ispitivanje PRIMARY KEY (id_ispitivanje)
);




IF OBJECT_ID('it60g2019Projekat.SADRZI', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.SADRZI

CREATE TABLE it60g2019Projekat.SADRZI
(
	id_zk INT NOT NULL,
	rbr_pregled INT NOT NULL,
	rbr_uput INT NOT NULL,
	id_ispitivanje INT NOT NULL,
	CONSTRAINT FK_Sadrzi_Uput FOREIGN KEY (id_zk, rbr_pregled, rbr_uput)
		REFERENCES it60g2019Projekat.UPUT (id_zk, rbr_pregled, rbr_uput),
	CONSTRAINT FK_Sadrzi_Ispitivanje FOREIGN KEY (id_ispitivanje)
		REFERENCES it60g2019Projekat.ISPITIVANJE (id_ispitivanje),
	CONSTRAINT PK_Sadrzi PRIMARY KEY (id_zk, rbr_pregled, rbr_uput, id_ispitivanje)
);




IF OBJECT_ID('it60g2019Projekat.TERAPIJA', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.TERAPIJA

CREATE TABLE it60g2019Projekat.TERAPIJA
(
	id_terapija INT NOT NULL IDENTITY,
	naziv_terap VARCHAR(30) NOT NULL,
	ucestalost_ned INT NOT NULL CONSTRAINT CHK_Terapija_ucestalostNed CHECK(0 < ucestalost_ned and ucestalost_ned < 8),
	opis VARCHAR(100) CONSTRAINT DFT_Terapija_opis DEFAULT(''),
	CONSTRAINT PK_Terapija PRIMARY KEY (id_terapija)
);



IF OBJECT_ID('it60g2019Projekat.ODREDJUJESE', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.ODREDJUJESE

CREATE TABLE it60g2019Projekat.ODREDJUJESE
(
	id_zk INT NOT NULL,
	rbr_pregled INT NOT NULL,
	id_terapija INT NOT NULL,
	CONSTRAINT FK_OdredjujeSe_Pregled FOREIGN KEY(id_zk, rbr_pregled)
		REFERENCES it60g2019Projekat.PREGLED (id_zk,rbr_pregled),
	CONSTRAINT FK_OdredjujeSe_Terapija FOREIGN KEY (id_terapija)
		REFERENCES it60g2019Projekat.TERAPIJA (id_terapija),
	CONSTRAINT PK_OdredjujeSe PRIMARY KEY (id_zk, rbr_pregled, id_terapija)
);



IF OBJECT_ID('it60g2019Projekat.PROIZVODJACLEKA', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.PROIZVODJACLEKA

CREATE TABLE it60g2019Projekat.PROIZVODJACLEKA
(
	id_proizvodjac INT NOT NULL IDENTITY,
	naziv_proiz VARCHAR(30) NOT NULL,
	adresa_proiz VARCHAR(50) NOT NULL,
	telefon_proiz VARCHAR(10) NOT NULL,
	CONSTRAINT PK_ProizvodjacLeka PRIMARY KEY (id_proizvodjac)
);


--TABELA SA REKURZIJOM
IF OBJECT_ID('it60g2019Projekat.LEK', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.LEK

CREATE TABLE it60g2019Projekat.LEK
(
	id_lek INT NOT NULL IDENTITY,
	naziv_leka VARCHAR(30) NOT NULL,
	rok_upotrebe DATE NOT NULL,
	opis_leka VARCHAR(100) NOT NULL,

	id_proizvodjac INT NOT NULL, 
	CONSTRAINT FK_Lek_ProizvodjacLeka FOREIGN KEY (id_proizvodjac)
		REFERENCES it60g2019Projekat.PROIZVODJACLEKA (id_proizvodjac),
	CONSTRAINT PK_Lek PRIMARY KEY (id_lek)
);




--PRE DODAVANJA OBELEZJA I POSTAVLJANJA OGRANICENJA FOREIGN KEY ZA ZAMENU
--IZVRSAVAM INSERT LEKOVA BEZ ZAMENE

--NAKNADNO DODAJEM OBELEZJE ZA ZAMENU ZATIM IZVRSAVAM UPDATE GDE SETUJEM VREDNOSTI ZAMENA
ALTER TABLE it60g2019Projekat.LEK
	ADD zamena_lek int

--NA KRAJU POSTAVLJAM OGRANICENJE STRANOG KLJUCA 
ALTER TABLE it60g2019Projekat.LEK
	ADD CONSTRAINT FK_Lek_Zamena FOREIGN KEY (zamena_lek)
		REFERENCES it60g2019Projekat.LEK (id_lek)





IF OBJECT_ID('it60g2019Projekat.KORISTISE', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.KORISTISE

CREATE TABLE it60g2019Projekat.KORISTISE
(
	id_lek INT NOT NULL,
	id_terapija INT NOT NULL,
	kolicina NUMERIC(8,2) NOT NULL,
	jedinica_mere VARCHAR(10) NOT NULL,
	CONSTRAINT FK_KoristiSe_Lek FOREIGN KEY(id_lek)
		REFERENCES it60g2019Projekat.LEK (id_lek),
	CONSTRAINT FK_KoristiSe_Terapija FOREIGN KEY (id_terapija)
		REFERENCES it60g2019Projekat.TERAPIJA (id_terapija),
	CONSTRAINT PK_KoristiSe PRIMARY KEY (id_lek, id_terapija)
);







IF OBJECT_ID('it60g2019Projekat.RECEPT', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.RECEPT

CREATE TABLE it60g2019Projekat.RECEPT
(
	id_recept INT NOT NULL IDENTITY,
	kolicina_pak INT NOT NULL,
	doziranje_mg NUMERIC(8,2) NOT NULL,
	obnovljiv BIT NOT NULL,
	uputstvo_za_upotrebu VARCHAR(100) NOT NULL,
	CONSTRAINT PK_Recept PRIMARY KEY (id_recept)
);



IF OBJECT_ID('it60g2019Projekat.PROPISUJESE', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.PROPISUJESE

CREATE TABLE it60g2019Projekat.PROPISUJESE
(
	id_lek INT NOT NULL,
	rbr_pregled INT NOT NULL,
	id_zk INT NOT NULL,
	datum_prop DATE NOT NULL,
	CONSTRAINT FK_PropisujeSe_Pregled FOREIGN KEY (id_zk, rbr_pregled)
		REFERENCES it60g2019Projekat.PREGLED (id_zk, rbr_pregled),
	CONSTRAINT FK_PropisujeSe_Lek FOREIGN KEY (id_lek)
		REFERENCES it60g2019Projekat.LEK (id_lek),
	CONSTRAINT PK_PropisujeSe PRIMARY KEY (id_zk, rbr_pregled, id_lek)
);




IF OBJECT_ID('it60g2019Projekat.IZDAJESE', 'U') IS NOT NULL
	DROP TABLE it60g2019Projekat.IZDAJESE

CREATE TABLE it60g2019Projekat.IZDAJESE
(
	id_zk INT NOT NULL, 
	rbr_pregled INT NOT NULL,
	id_lek INT NOT NULL,
	id_recept INT NOT NULL,
	datum_izd DATE NOT NULL,
	CONSTRAINT FK_IzdajeSe_PropisujeSe FOREIGN KEY(id_zk,rbr_pregled,id_lek)
		REFERENCES it60g2019Projekat.PROPISUJESE(id_zk,rbr_pregled,id_lek),
	CONSTRAINT FK_IzdajeSe_Recept FOREIGN KEY (id_recept) 
		REFERENCES it60g2019Projekat.RECEPT(id_recept),
	CONSTRAINT PK_IzdajeSe PRIMARY KEY (id_zk, rbr_pregled, id_lek, id_recept)
);