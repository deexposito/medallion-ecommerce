# Silver (Capa Semàntica)

Equivalent a la "Capa Semàntica" del diagrama de Denis.

Aquí van els models que consoliden les taules `stg_*` de bronze en un model
relacional net i amb lògica de negoci: joins, deduplicació, regles de
negoci (p.ex. estat d'una comanda, definició de "client actiu"), claus
consistents entre entitats (`dim_customers`, `dim_products`, `dim_sellers`,
`fct_orders`, `fct_order_items`, `fct_payments`, `fct_reviews`...).

Independent de d'on venia cada dada originalment — aquí ja parlem el
llenguatge del negoci, no el de cada sistema font.

Esborra aquest fitxer quan hi hagi contingut real.
