# Bronze (Landing + Staging)

Equivalent al "Landing/Staging" del diagrama de Denis.

Aquí van:
- `sources.yml` — declaració de les taules cru tal com arriben (Olist: `orders`, `order_items`, `customers`, `products`, `sellers`, `payments`, `reviews`, `geolocation`, `category_translation`).
- Un model `stg_<taula>.sql` per cada font: 1:1 amb l'origen, només normalitzant noms de columnes i tipus. **Sense lògica de negoci encara.**

Esborra aquest fitxer quan hi hagi contingut real.
