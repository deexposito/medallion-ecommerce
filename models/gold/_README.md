# Gold (Dominis i Explotació/Consum)

Equivalent a "Dominis de dades / Productes de dades" del diagrama de Denis.

Aquí van els *data marts* per domini de negoci, pensats directament per al
consum (Power BI). Proposta de dominis per a aquest projecte (a validar/
ajustar quan es conegui bé el model Silver):

- `mart_sales` — vendes, ingressos, comandes per període/categoria/regió.
- `mart_customer_experience` — reviews, satisfacció, temps d'entrega percebut.
- `mart_logistics` — temps d'enviament, venedors, rendiment logístic.

Cada mart respon a un cas d'ús concret de consum, no a la lògica general
de negoci (això ja es resol a Silver).

Esborra aquest fitxer quan hi hagi contingut real.
