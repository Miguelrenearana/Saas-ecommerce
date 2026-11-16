-- Script seguro para corregir coordenadas de sucursales en Local y Neon
-- No altera IDs, llaves foráneas ni pedidos existentes.

-- Santa Cruz - Central (Casco Viejo)
UPDATE branches
SET latitude = -17.7833215, longitude = -63.1821408, city = 'Santa Cruz',
    address = 'Calle René Moreno #245, Casco Viejo'
WHERE name ILIKE '%Elegance%Central%' OR (city ILIKE '%Santa Cruz%' AND is_default = TRUE);

-- Santa Cruz - Equipetrol
UPDATE branches
SET latitude = -17.7658120, longitude = -63.1952400, city = 'Santa Cruz',
    address = 'Av. San Martín esq. Calle 7 Este, Equipetrol'
WHERE name ILIKE '%Equipetrol%';

-- Santa Cruz - Ventura Mall
UPDATE branches
SET latitude = -17.7542100, longitude = -63.1990300, city = 'Santa Cruz',
    address = '4to Anillo esq. Av. San Martín, Ventura Mall Nivel 2'
WHERE name ILIKE '%Ventura%';

-- Cochabamba - Casco Viejo / Centro
UPDATE branches
SET latitude = -17.3935000, longitude = -66.1570000, city = 'Cochabamba',
    address = 'Av. Heroínas esq. Ayacucho #120'
WHERE name ILIKE '%Moda Urbana%' OR name ILIKE '%Centro Cochabamba%' OR city ILIKE '%Cochabamba%';

-- La Paz - El Prado / Central
UPDATE branches
SET latitude = -16.4957000, longitude = -68.1335000, city = 'La Paz',
    address = 'Av. 16 de Julio #1440, El Prado'
WHERE name ILIKE '%Central La Paz%' OR city ILIKE '%La Paz%';

-- Tarija - El Molino
UPDATE branches
SET latitude = -21.5355000, longitude = -64.7296000, city = 'Tarija',
    address = 'Calle 15 de Abril esq. Campero, Barrio El Molino'
WHERE name ILIKE '%París%' OR name ILIKE '%Tarija%' OR city ILIKE '%Tarija%';
