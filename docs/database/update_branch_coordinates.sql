-- Script seguro para corregir coordenadas de sucursales en Local y Neon
-- No altera IDs, llaves foráneas ni pedidos existentes.

-- ==============================================================================
-- 1. BOUTIQUE ELEGANCE (Santa Cruz, La Paz, Cochabamba)
-- ==============================================================================

-- Santa Cruz - Central (Casco Viejo)
UPDATE branches
SET latitude = -17.7833215, longitude = -63.1821408, city = 'Santa Cruz',
    address = 'Calle René Moreno #245, Casco Viejo'
WHERE name ILIKE '%Elegance%Central%' OR (city ILIKE '%Santa Cruz%' AND is_default = TRUE);

-- Santa Cruz - Equipetrol
UPDATE branches
SET latitude = -17.7658120, longitude = -63.1952400, city = 'Santa Cruz',
    address = 'Av. San Martín esq. Calle 7 Este, Equipetrol'
WHERE name ILIKE '%Elegance%Equipetrol%';

-- Santa Cruz - Ventura Mall
UPDATE branches
SET latitude = -17.7542100, longitude = -63.1990300, city = 'Santa Cruz',
    address = '4to Anillo esq. Av. San Martín, Ventura Mall Nivel 2'
WHERE name ILIKE '%Elegance%Ventura%';

-- Santa Cruz - Cine Center
UPDATE branches
SET latitude = -17.7985000, longitude = -63.1812000, city = 'Santa Cruz',
    address = 'Av. El Trompillo, Centro Comercial Cine Center'
WHERE name ILIKE '%Cine Center%';

-- Santa Cruz - Sucursal Norte
UPDATE branches
SET latitude = -17.7490000, longitude = -63.1670000, city = 'Santa Cruz',
    address = 'Av. Banzer entre 4to y 5to Anillo'
WHERE name ILIKE '%Norte Santa Cruz%';

-- La Paz - Sucursal Central La Paz
UPDATE branches
SET latitude = -16.4957000, longitude = -68.1335000, city = 'La Paz',
    address = 'Av. 16 de Julio #1440, El Prado'
WHERE name ILIKE '%Central La Paz%';

-- Cochabamba - Sucursal Centro Cochabamba
UPDATE branches
SET latitude = -17.3935000, longitude = -66.1570000, city = 'Cochabamba',
    address = 'Av. Heroínas esq. Ayacucho #120'
WHERE name ILIKE '%Centro Cochabamba%';


-- ==============================================================================
-- 2. MODA URBANA (Cochabamba)
-- ==============================================================================

UPDATE branches
SET latitude = -17.3935000, longitude = -66.1570000, city = 'Cochabamba',
    address = 'Av. Heroínas esq. Ayacucho #120'
WHERE name ILIKE '%Moda Urbana%';


-- ==============================================================================
-- 3. BOUTIQUE PARÍS S.R.L. (Multiciudad: SCZ, LPZ, CBB, TJA, SCR)
-- ==============================================================================

-- Santa Cruz
UPDATE branches
SET latitude = -17.7712000, longitude = -63.1825000, city = 'Santa Cruz',
    address = 'Av. Monseñor Rivero #320'
WHERE name ILIKE '%París%Monseñor Rivero%';

UPDATE branches
SET latitude = -17.7620000, longitude = -63.1965000, city = 'Santa Cruz',
    address = 'Calle 8 Oeste, Equipetrol Norte'
WHERE name ILIKE '%París%Equipetrol Norte%';

UPDATE branches
SET latitude = -17.7510000, longitude = -63.1780000, city = 'Santa Cruz',
    address = 'Av. Cristo Redentor 4to Anillo, Nivel 1'
WHERE name ILIKE '%París%Las Brisas%';

UPDATE branches
SET latitude = -17.7542100, longitude = -63.1990300, city = 'Santa Cruz',
    address = '4to Anillo y Av. San Martín, Nivel 2'
WHERE name ILIKE '%París%Ventura Mall%';

-- La Paz
UPDATE branches
SET latitude = -16.5385000, longitude = -68.0835000, city = 'La Paz',
    address = 'Av. Ballivián entre calles 15 y 16, Calacoto'
WHERE name ILIKE '%París%Calacoto%';

UPDATE branches
SET latitude = -16.5410000, longitude = -68.0790000, city = 'La Paz',
    address = 'Calle Gabriel René Moreno, Bloque E'
WHERE name ILIKE '%París%San Miguel%';

UPDATE branches
SET latitude = -16.5120000, longitude = -68.1280000, city = 'La Paz',
    address = 'Av. 20 de Octubre esq. Guachalla'
WHERE name ILIKE '%París%Sopocachi%';

-- Cochabamba
UPDATE branches
SET latitude = -17.3750000, longitude = -66.1620000, city = 'Cochabamba',
    address = 'Av. Libertador Bolívar esq. América'
WHERE name ILIKE '%París%Cala Cala%';

UPDATE branches
SET latitude = -17.3910000, longitude = -66.1550000, city = 'Cochabamba',
    address = 'Av. Ballivián (El Prado) #840'
WHERE name ILIKE '%París%El Prado Central%';

-- Sucre
UPDATE branches
SET latitude = -19.0480000, longitude = -65.2590000, city = 'Sucre',
    address = 'Calle Calvo #112 frente a Plaza Principal'
WHERE name ILIKE '%París%Plaza 25%';

-- Tarija
UPDATE branches
SET latitude = -21.5355000, longitude = -64.7296000, city = 'Tarija',
    address = 'Calle 15 de Abril esq. Campero, Barrio El Molino'
WHERE name ILIKE '%París%El Molino%' OR (name ILIKE '%París%' AND (city ILIKE '%Tarija%' OR name ILIKE '%Tarija%'));
