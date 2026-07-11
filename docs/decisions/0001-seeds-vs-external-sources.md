# 0001 — Seeds vs external sources per a la capa Bronze

Estat: Acceptat
Data: 2026-07-11

## Context

El dataset Olist arriba com a 9 CSVs. Vuit són taules transaccionals (comandes, ítems, pagaments, reviews, clients, productes, venedors, geolocalització), amb desenes de milers a més d'un milió de files, i representen dades que en un entorn real es recarregarien periòdicament des dels sistemes font. La novena (`product_category_name_translation`) és un simple diccionari de traducció de 71 files que no prové de cap sistema transaccional i no canvia mai. dbt necessita que totes acabin sent "taules" consultables des de `sources.yml`/models, però no totes haurien d'entrar-hi de la mateixa manera.

## Decisió

Les 8 taules transaccionals es declaren a `sources.yml` amb `meta.external_location`, apuntant DuckDB directament als CSV originals (equivalent local a una taula externa sobre un data lake). Només `product_category_name_translation` es carrega com a `dbt seed`.

## Alternatives considerades

- **Totes 9 com a seeds**: descartat. `dbt seed` és per a dades de referència petites i estàtiques que es mantenen al repo; carregar-hi taules de centenars de milers de files és un anti-patró reconegut (infla el repo, viola el propòsit de l'eina, i no reflecteix com s'ingesten dades transaccionals reals).
- **Totes 9 com a external sources**: descartat per a la taula de traducció. És exactament el cas d'ús que `seed` sí que cobreix bé (petita, estàtica, mantinguda a mà), i fer-la external només per coherència no aporta res.

## Conseqüències

- Les 8 taules grans no es distribueixen al repo Git (mida i llicència de Kaggle): qui cloni el repo ha de descarregar-se el dataset i posar-lo a `data/raw/` abans de poder córrer `dbt build` — documentat al README.
- La taula de traducció sí viu al repo (com a `seeds/product_category_name_translation.csv`), versionada com qualsevol altre fitxer de codi.
- Si en el futur alguna de les 8 taules "grans" es convertís en petita i estàtica (poc probable aquí), caldria replantejar-se si continua tenint sentit com a external source o si val la pena passar-la a seed.
