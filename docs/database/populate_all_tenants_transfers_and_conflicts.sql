-- =========================================================================
-- SCRIPT OFICIAL: POBLACIÓN DE COORDENADAS, TRASLADOS, REPOSICIÓN Y CONFLICTOS
-- Generado el: 2026-11-17 03:56:10 UTC
-- Apto para ejecución local y producción Neon PostgreSQL
-- =========================================================================

BEGIN;

UPDATE branches SET city = 'Santa Cruz', latitude = -17.7833215, longitude = -63.1821408, address = 'Calle René Moreno #245, Casco Viejo' WHERE name = 'Boutique Elegance - Central';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.765812, longitude = -63.19524, address = 'Av. San Martín esq. Calle 7 Este, Equipetrol' WHERE name = 'Boutique Elegance - Equipetrol';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.75421, longitude = -63.19903, address = '4to Anillo esq. Av. San Martín, Ventura Mall Nivel 2' WHERE name = 'Boutique Elegance - Ventura Mall';
UPDATE branches SET city = 'La Paz', latitude = -16.4957, longitude = -68.1335, address = 'Av. 16 de Julio #1440, El Prado' WHERE name = 'Sucursal Central La Paz';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.5432, longitude = -63.0931, address = 'Av. El Trompillo' WHERE name = 'Sucursal Cine Center';
UPDATE branches SET city = 'Cochabamba', latitude = -17.3935, longitude = -66.157, address = 'Av. Heroínas esq. Ayacucho #120' WHERE name = 'Moda Urbana - Casco Viejo';
UPDATE branches SET city = 'Cochabamba', latitude = -17.3712, longitude = -66.1558, address = 'Av. América esq. Pando #450' WHERE name = 'Moda Urbana - América Norte';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.7725, longitude = -63.1832, address = 'Av. Monseñor Rivero #350' WHERE name = 'Boutique París - Central Monseñor Rivero';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.761, longitude = -63.1945, address = 'Av. San Martín #180, Equipetrol' WHERE name = 'Boutique París - Equipetrol Norte';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.7478, longitude = -63.1772, address = '4to Anillo y Av. Cristo Redentor' WHERE name = 'Boutique París - Las Brisas Mall';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.7538, longitude = -63.2001, address = '4to Anillo esq. San Martín' WHERE name = 'Boutique París - Ventura Mall Luxury';
UPDATE branches SET city = 'La Paz', latitude = -16.5012, longitude = -68.1325, address = 'Av. 16 de Julio #1520, El Prado' WHERE name = 'Boutique París - El Prado Central';
UPDATE branches SET city = 'La Paz', latitude = -16.512, longitude = -68.128, address = 'Av. 20 de Octubre #2100, Sopocachi' WHERE name = 'Boutique París - Sopocachi Boulevard';
UPDATE branches SET city = 'La Paz', latitude = -16.5398, longitude = -68.0864, address = 'Calle 15 de Calacoto #8020' WHERE name = 'Boutique París - Calacoto Plaza';
UPDATE branches SET city = 'La Paz', latitude = -16.5415, longitude = -68.0792, address = 'Calle Gabriel René Moreno #1250, San Miguel' WHERE name = 'Boutique París - San Miguel';
UPDATE branches SET city = 'Cochabamba', latitude = -17.375, longitude = -66.162, address = 'Av. Libertador Bolívar #890, Cala Cala' WHERE name = 'Boutique París - Cala Cala';
UPDATE branches SET city = 'Sucre', latitude = -19.0478, longitude = -65.2595, address = 'Plaza 25 de Mayo #45, Centro' WHERE name = 'Boutique París - Plaza 25 de Mayo';
UPDATE branches SET city = 'Tarija', latitude = -21.5355, longitude = -64.7296, address = 'Calle 15 de Abril esq. Campero, Barrio El Molino' WHERE name = 'Boutique París - El Molino';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.7711, longitude = -63.1815, address = 'Av. Cristo Redentor esq. 2do Anillo' WHERE name = 'Boutique Básica - El Cristo';
UPDATE branches SET city = 'Santa Cruz', latitude = -17.8055, longitude = -63.189, address = 'Av. Santos Dumont esq. 3er Anillo' WHERE name = 'Boutique Básica - Santos Dumont';

            INSERT INTO branches (id, tenant_id, name, city, address, phone, latitude, longitude, is_active, is_default, created_at, updated_at)
            SELECT '72ef94dc-b6f8-4aec-98a2-a103f7ed3f4a', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'Moda Urbana - América Norte', 'Cochabamba', 'Av. América esq. Pando #450', '4-4112233', -17.3712000, -66.1558000, true, false, NOW(), NOW()
            WHERE NOT EXISTS (SELECT 1 FROM branches WHERE name = 'Moda Urbana - América Norte' AND tenant_id = '908056c0-3ee8-42fa-9e5c-8ef3869fbc97')
            ;

            INSERT INTO branches (id, tenant_id, name, city, address, phone, latitude, longitude, is_active, is_default, created_at, updated_at)
            SELECT 'd0b70dc8-77d5-401a-8255-9b1092347188', '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a', 'Boutique Básica - El Cristo', 'Santa Cruz', 'Av. Cristo Redentor esq. 2do Anillo', '3-3445566', -17.7711000, -63.1815000, true, true, NOW(), NOW()
            WHERE NOT EXISTS (SELECT 1 FROM branches WHERE name = 'Boutique Básica - El Cristo' AND tenant_id = '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a')
            ;

            INSERT INTO branches (id, tenant_id, name, city, address, phone, latitude, longitude, is_active, is_default, created_at, updated_at)
            SELECT '114940d8-48f0-4b40-b3cb-d323f1858488', '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a', 'Boutique Básica - Santos Dumont', 'Santa Cruz', 'Av. Santos Dumont esq. 3er Anillo', '3-3778899', -17.8055000, -63.1890000, true, false, NOW(), NOW()
            WHERE NOT EXISTS (SELECT 1 FROM branches WHERE name = 'Boutique Básica - Santos Dumont' AND tenant_id = '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a')
            ;
UPDATE products SET provider_id = 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8' WHERE id = '3578146c-06b1-4070-970d-9989266178ef' AND provider_id IS NULL;
UPDATE products SET provider_id = 'f9eb55a1-6228-4ece-b56e-92bc75cbd048' WHERE id = 'e9acf75d-6d5a-4925-81e3-9eb470be65be' AND provider_id IS NULL;
UPDATE products SET provider_id = '91c320d6-bb80-4ce8-b516-19f64b80a441' WHERE id = 'eead2eac-263d-478a-98dc-b944f99b02b8' AND provider_id IS NULL;
UPDATE products SET provider_id = '045ac0bf-030f-4d26-8fd4-907e8a337b61' WHERE id = '0893e12b-7f07-4bc1-8554-beec468da9db' AND provider_id IS NULL;
UPDATE products SET provider_id = 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8' WHERE id = '8ac7df37-728b-4984-9484-cd594ce38d43' AND provider_id IS NULL;
UPDATE products SET provider_id = 'f9eb55a1-6228-4ece-b56e-92bc75cbd048' WHERE id = '555be9f5-2b76-450a-96b4-365a2c20e9a2' AND provider_id IS NULL;
UPDATE products SET provider_id = '91c320d6-bb80-4ce8-b516-19f64b80a441' WHERE id = 'a052ad6d-6d63-4196-acc6-c87af05d6979' AND provider_id IS NULL;
UPDATE products SET provider_id = '045ac0bf-030f-4d26-8fd4-907e8a337b61' WHERE id = '755daa5e-2969-4f72-b02b-15d918f1ae09' AND provider_id IS NULL;
UPDATE products SET provider_id = 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8' WHERE id = '0cc8b90b-e360-4820-8c65-6163b45429d7' AND provider_id IS NULL;
DELETE FROM inventory_transfers WHERE tenant_id = '1de16f02-c5c5-4b27-a1ba-9f52a183d110';
DELETE FROM replenishment_requests WHERE branch_id IN (SELECT id FROM branches WHERE tenant_id = '1de16f02-c5c5-4b27-a1ba-9f52a183d110');

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    '540cbef7-3508-4afd-b52f-936f6428df07', 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8', '51433f7c-de3f-430c-a81a-063b5ed2bf72', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'requested',
                    '2026-11-16 21:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', NULL, NULL,
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('d435680f-554c-424b-95fa-1a2cb2f00a4e', '540cbef7-3508-4afd-b52f-936f6428df07', '8558a408-5cae-46d7-b325-fa1d57870707', 30);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('d95ba85f-6104-4962-bbf1-e7f38d15959e', '540cbef7-3508-4afd-b52f-936f6428df07', 'b53dd6ba-c622-47ed-8bc6-c6f21c85d711', 40);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    '665d032e-8502-419d-b61a-515e4274d50e', 'f9eb55a1-6228-4ece-b56e-92bc75cbd048', '1d6ec0b7-9a0f-4cec-8f82-71d191a5db71', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'accepted',
                    '2026-11-16 03:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', 'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-16 06:56:10.331362+00:00',
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('b25a4219-6762-47c6-bd91-a77e52af688f', '665d032e-8502-419d-b61a-515e4274d50e', '9d228577-ef1b-4fa0-8d83-5ad38897aaf2', 25);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'f132e505-bc73-4dbf-ac5c-247c17bbb7b7', '91c320d6-bb80-4ce8-b516-19f64b80a441', 'd8083aac-0a06-48f6-8818-59f12599a8ba', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'preparing',
                    '2026-11-15 03:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', 'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-15 06:56:10.331362+00:00',
                    'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-15 13:56:10.331362+00:00', NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('575231ad-beff-45fa-9931-5128174343b6', 'f132e505-bc73-4dbf-ac5c-247c17bbb7b7', 'efffad18-4198-4d6a-b20a-7128fa392453', 20);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('6d59237c-7378-4b04-8dfc-7724f45abc7a', 'f132e505-bc73-4dbf-ac5c-247c17bbb7b7', '6ed82f74-10f5-4478-8379-03f469df791f', 15);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'd4965935-56ff-405e-9642-0ffb083d6ace', '045ac0bf-030f-4d26-8fd4-907e8a337b61', 'e19bd425-01dd-453b-8a53-8981d0f625b1', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'delivered',
                    '2026-11-12 03:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', 'd0757c29-439a-430b-97b4-5a6bb41484a4', '2026-11-12 06:56:10.331362+00:00',
                    'd0757c29-439a-430b-97b4-5a6bb41484a4', '2026-11-12 13:56:10.331362+00:00', 'd0757c29-439a-430b-97b4-5a6bb41484a4', '2026-11-13 03:56:10.331362+00:00',
                    'f701d2eb-9e30-49d4-bed0-e5bde288595f', '2026-11-14 03:56:10.331362+00:00'
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('f27ee317-8321-40e8-a18e-efdf0556f5d7', 'd4965935-56ff-405e-9642-0ffb083d6ace', 'd8f0fe05-1cc7-4111-bded-2bacbb807e96', 50);

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '54438676-11c7-4d53-8a25-509af38c001b', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0001', '51433f7c-de3f-430c-a81a-063b5ed2bf72', '1d6ec0b7-9a0f-4cec-8f82-71d191a5db71',
                        'EN_TRANSITO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', NULL, '2026-11-16 23:56:10.331362+00:00', NULL,
                        'Despacho intersucursal Santa Cruz Central a Equipetrol', '2026-11-16 23:56:10.331362+00:00', '2026-11-16 23:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('3be5e5e1-bc45-4d2e-8759-eba6ca667990', '54438676-11c7-4d53-8a25-509af38c001b', '8558a408-5cae-46d7-b325-fa1d57870707', 10, NULL, '2026-11-16 23:56:10.331362+00:00')
                        ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('9d0b642a-d275-450b-b801-124f87f16882', '54438676-11c7-4d53-8a25-509af38c001b', 'b53dd6ba-c622-47ed-8bc6-c6f21c85d711', 15, NULL, '2026-11-16 23:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'b823fe84-beb7-40ef-ba0c-2d2cbf4d7780', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0002', '75df74b7-c0eb-45a6-a13a-8ddda9896a7f', 'd54927f1-1c7a-499a-9dfc-c6375de846a8',
                        'EN_TRANSITO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', NULL, '2026-11-16 01:56:10.331362+00:00', NULL,
                        'Reabastecimiento Las Brisas a Ventura Mall', '2026-11-16 01:56:10.331362+00:00', '2026-11-16 01:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('0a25e9b5-7a6b-4289-a245-bd277f782edd', 'b823fe84-beb7-40ef-ba0c-2d2cbf4d7780', '9d228577-ef1b-4fa0-8d83-5ad38897aaf2', 8, NULL, '2026-11-16 01:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '446ac824-fb32-4998-b4f2-540f0b221c33', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0003', 'd8083aac-0a06-48f6-8818-59f12599a8ba', '1d078f97-710f-458d-8c1d-c623bb4f4b8d',
                        'COMPLETADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', '092722eb-cb11-4d82-b946-e8c6076ef6fd', '2026-11-14 03:56:10.331362+00:00', '2026-11-15 07:56:10.331362+00:00',
                        'Traspaso La Paz El Prado a Sopocachi', '2026-11-14 03:56:10.331362+00:00', '2026-11-15 07:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('26441580-1ca4-48ac-ba26-bb722ed4e628', '446ac824-fb32-4998-b4f2-540f0b221c33', 'efffad18-4198-4d6a-b20a-7128fa392453', 12, 12, '2026-11-14 03:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'f10d1dfe-6254-4e58-a9f6-add3fdd0afc3', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0004', 'db8160a7-0a58-4732-b76d-f61aa9b450b8', '396b4207-3215-4c4e-a1a5-7fc6b5694340',
                        'COMPLETADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', '092722eb-cb11-4d82-b946-e8c6076ef6fd', '2026-11-12 03:56:10.331362+00:00', '2026-11-13 07:56:10.331362+00:00',
                        'Transferencia Calacoto a San Miguel verificada', '2026-11-12 03:56:10.331362+00:00', '2026-11-13 07:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('3d4bbe7a-597d-4d82-95a2-9a24500f2f5e', 'f10d1dfe-6254-4e58-a9f6-add3fdd0afc3', '6ed82f74-10f5-4478-8379-03f469df791f', 20, 20, '2026-11-12 03:56:10.331362+00:00')
                        ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('66b16bf1-371a-48dc-90d0-3a1a634aa5cd', 'f10d1dfe-6254-4e58-a9f6-add3fdd0afc3', 'd8f0fe05-1cc7-4111-bded-2bacbb807e96', 10, 10, '2026-11-12 03:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'a568bc74-fa35-4212-afc2-cf57ccbd0d14', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0005', 'e19bd425-01dd-453b-8a53-8981d0f625b1', '51433f7c-de3f-430c-a81a-063b5ed2bf72',
                        'COMPLETADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', '092722eb-cb11-4d82-b946-e8c6076ef6fd', '2026-11-10 03:56:10.331362+00:00', '2026-11-11 07:56:10.331362+00:00',
                        'Cochabamba Cala Cala a Santa Cruz Central', '2026-11-10 03:56:10.331362+00:00', '2026-11-11 07:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('29507f53-2966-460e-b08c-af2203ed7a60', 'a568bc74-fa35-4212-afc2-cf57ccbd0d14', '3aa8f659-24f3-4469-8bc4-bdac3b8e4a35', 5, 5, '2026-11-10 03:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '1c608f69-972a-4825-b2b1-74a2821ff912', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0006', 'eaf090b3-84b8-4f7e-a569-d193a0a9581d', '56d5d229-8a00-4ee6-aa3e-123fe985861a',
                        'CANCELADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', NULL, '2026-11-15 03:56:10.331362+00:00', NULL,
                        'Cancelado: Sucre a Tarija suspendido por inventario', '2026-11-15 03:56:10.331362+00:00', '2026-11-15 03:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('ffba6d22-9494-4f86-b8ba-6be5e2456a8b', '1c608f69-972a-4825-b2b1-74a2821ff912', 'd9bb918d-24a8-4103-91ae-d7b105d695b9', 14, NULL, '2026-11-15 03:56:10.331362+00:00')
                        ;
UPDATE products SET provider_id = 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8' WHERE id = 'e33bc329-b703-479c-9d65-415288100383' AND provider_id IS NULL;
UPDATE products SET provider_id = 'f9eb55a1-6228-4ece-b56e-92bc75cbd048' WHERE id = 'ce500f67-e4a9-4f5e-8c3e-cdc213cea459' AND provider_id IS NULL;
UPDATE products SET provider_id = '91c320d6-bb80-4ce8-b516-19f64b80a441' WHERE id = '9b85ffc0-28bb-4db0-a706-9d21c113f774' AND provider_id IS NULL;
UPDATE products SET provider_id = '045ac0bf-030f-4d26-8fd4-907e8a337b61' WHERE id = '02b4f2cc-6775-4f60-af0e-90179b56d4c6' AND provider_id IS NULL;
UPDATE products SET provider_id = 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8' WHERE id = '8b028a5d-a7af-4a69-bcae-bcfd166f90a3' AND provider_id IS NULL;
UPDATE products SET provider_id = 'f9eb55a1-6228-4ece-b56e-92bc75cbd048' WHERE id = '1a73ac6c-2387-4eba-8497-b1592bed1061' AND provider_id IS NULL;
UPDATE products SET provider_id = '91c320d6-bb80-4ce8-b516-19f64b80a441' WHERE id = '71c901a4-bcaa-4e57-99df-bb0b57521024' AND provider_id IS NULL;
UPDATE products SET provider_id = '045ac0bf-030f-4d26-8fd4-907e8a337b61' WHERE id = '004f791c-1d52-4d20-9be9-caf0ef0857fb' AND provider_id IS NULL;
DELETE FROM inventory_transfers WHERE tenant_id = '908056c0-3ee8-42fa-9e5c-8ef3869fbc97';
DELETE FROM replenishment_requests WHERE branch_id IN (SELECT id FROM branches WHERE tenant_id = '908056c0-3ee8-42fa-9e5c-8ef3869fbc97');

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'e1c26881-5f34-4aab-ae11-10f657819d79', 'f9eb55a1-6228-4ece-b56e-92bc75cbd048', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'requested',
                    '2026-11-17 01:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', NULL, NULL,
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('97da5e32-13b7-4770-9408-4c711f94373b', 'e1c26881-5f34-4aab-ae11-10f657819d79', '2b064314-bb67-4322-b949-22aa8bb57d57', 20);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('60e64a88-dc66-4a15-a6d3-b82e16645a2c', 'e1c26881-5f34-4aab-ae11-10f657819d79', '47b764ef-5e59-4f77-8181-900d04ca0b22', 20);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    '6641bd71-1db9-4633-ba63-a9493e5adfb4', 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8', 'b9482bef-9c1e-4094-bbbf-160218caee09', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'preparing',
                    '2026-11-15 03:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', '9cbb8e02-a740-4676-a218-aaee1375869a', '2026-11-15 06:56:10.331362+00:00',
                    '9cbb8e02-a740-4676-a218-aaee1375869a', '2026-11-15 13:56:10.331362+00:00', NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('5c4f23dc-016b-443a-973d-67a6f44c271a', '6641bd71-1db9-4633-ba63-a9493e5adfb4', '920f8cc9-b011-4de6-8365-caf13c43abe1', 35);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    '6fe95b7e-5259-460f-b33f-d6add3688a49', '91c320d6-bb80-4ce8-b516-19f64b80a441', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'delivered',
                    '2026-11-13 03:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', 'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-13 06:56:10.331362+00:00',
                    'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-13 13:56:10.331362+00:00', 'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-14 03:56:10.331362+00:00',
                    '11ae83a6-40c1-4d5f-a0de-1267d5f78017', '2026-11-15 03:56:10.331362+00:00'
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('ea3e53ab-a52f-411f-acf8-40afe37885ac', '6fe95b7e-5259-460f-b33f-d6add3688a49', '494a0a05-5af6-4275-96ac-db412571a276', 40);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('d86f5451-43bc-4b05-9e86-367287380bf9', '6fe95b7e-5259-460f-b33f-d6add3688a49', '3764b5d1-f870-4925-99e5-77b5a13e2da9', 30);

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '93502c0c-0f71-473b-ae4e-067e266b12e1', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0001', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', 'b9482bef-9c1e-4094-bbbf-160218caee09',
                        'EN_TRANSITO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', NULL, '2026-11-17 00:56:10.331362+00:00', NULL,
                        'Traspaso Cochabamba Casco Viejo a América Norte', '2026-11-17 00:56:10.331362+00:00', '2026-11-17 00:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('e70cc9f9-0736-4f38-b4ef-940c649b0462', '93502c0c-0f71-473b-ae4e-067e266b12e1', '2b064314-bb67-4322-b949-22aa8bb57d57', 10, NULL, '2026-11-17 00:56:10.331362+00:00')
                        ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('ee093859-5145-46bf-929f-d1fbc6eb09ea', '93502c0c-0f71-473b-ae4e-067e266b12e1', '47b764ef-5e59-4f77-8181-900d04ca0b22', 6, NULL, '2026-11-17 00:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '8f980274-8ef3-4ecc-9541-da079361aab1', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0002', 'b9482bef-9c1e-4094-bbbf-160218caee09', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d',
                        'COMPLETADO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'ee0acd21-8fd5-41ed-b0c8-8e38a915e871', '2026-11-14 03:56:10.331362+00:00', '2026-11-15 07:56:10.331362+00:00',
                        'Recepción de prendas de temporada en Casco Viejo', '2026-11-14 03:56:10.331362+00:00', '2026-11-15 07:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('611898a1-85f7-4273-a63f-939c5998b9a2', '8f980274-8ef3-4ecc-9541-da079361aab1', '920f8cc9-b011-4de6-8365-caf13c43abe1', 12, 12, '2026-11-14 03:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '3d06c0b4-1bd2-46af-b4a4-7f8b859cf8ba', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0003', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', 'b9482bef-9c1e-4094-bbbf-160218caee09',
                        'COMPLETADO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'ee0acd21-8fd5-41ed-b0c8-8e38a915e871', '2026-11-11 03:56:10.331362+00:00', '2026-11-12 07:56:10.331362+00:00',
                        'Surtido inicial América Norte con acta de entrega', '2026-11-11 03:56:10.331362+00:00', '2026-11-12 07:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('aee5a45d-43b6-43f6-b1d8-99232ba568d6', '3d06c0b4-1bd2-46af-b4a4-7f8b859cf8ba', '494a0a05-5af6-4275-96ac-db412571a276', 25, 25, '2026-11-11 03:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '72bd9beb-7e22-4e83-8eef-bd959147f594', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0004', 'b9482bef-9c1e-4094-bbbf-160218caee09', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d',
                        'CANCELADO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', NULL, '2026-11-15 03:56:10.331362+00:00', NULL,
                        'Cancelado por falta de transporte local', '2026-11-15 03:56:10.331362+00:00', '2026-11-15 03:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('f78a14b3-4c52-40fe-be7f-3e1258016dc9', '72bd9beb-7e22-4e83-8eef-bd959147f594', '3764b5d1-f870-4925-99e5-77b5a13e2da9', 8, NULL, '2026-11-15 03:56:10.331362+00:00')
                        ;
UPDATE products SET provider_id = 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8' WHERE id = 'e33bc329-b703-479c-9d65-415288100383' AND provider_id IS NULL;
UPDATE products SET provider_id = 'f9eb55a1-6228-4ece-b56e-92bc75cbd048' WHERE id = '8b028a5d-a7af-4a69-bcae-bcfd166f90a3' AND provider_id IS NULL;
UPDATE products SET provider_id = '91c320d6-bb80-4ce8-b516-19f64b80a441' WHERE id = '71c901a4-bcaa-4e57-99df-bb0b57521024' AND provider_id IS NULL;
DELETE FROM inventory_transfers WHERE tenant_id = '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a';
DELETE FROM replenishment_requests WHERE branch_id IN (SELECT id FROM branches WHERE tenant_id = '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a');

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'bf47bc92-b870-4029-b755-d50b7ac64111', 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8', '9c631e4b-333f-4c0c-b991-755207c817d8', '8eb4d43f-54f5-468c-a83f-8601206b85bb', 'requested',
                    '2026-11-17 02:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', NULL, NULL,
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('d8cfeb2a-a8a9-476f-ab80-898649005204', 'bf47bc92-b870-4029-b755-d50b7ac64111', '2b064314-bb67-4322-b949-22aa8bb57d57', 15);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'f7d03fa7-df02-42ee-8d87-b5250a7e87c1', 'f9eb55a1-6228-4ece-b56e-92bc75cbd048', '7b653acc-8e71-41c0-862d-43b1b71e5fd0', '8eb4d43f-54f5-468c-a83f-8601206b85bb', 'delivered',
                    '2026-11-14 03:56:10.331362+00:00', '2026-11-17 03:56:10.331362+00:00', 'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-14 06:56:10.331362+00:00',
                    'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-14 13:56:10.331362+00:00', 'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-15 03:56:10.331362+00:00',
                    '8eb4d43f-54f5-468c-a83f-8601206b85bb', '2026-11-16 03:56:10.331362+00:00'
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('2f1db549-8d9e-4efa-adb3-600f1c119e05', 'f7d03fa7-df02-42ee-8d87-b5250a7e87c1', '47b764ef-5e59-4f77-8181-900d04ca0b22', 20);

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '5df86a8f-b439-4e5f-b596-d8e25d03d9b9', '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a', 'BASIC-0001', '9c631e4b-333f-4c0c-b991-755207c817d8', '7b653acc-8e71-41c0-862d-43b1b71e5fd0',
                        'EN_TRANSITO', '8eb4d43f-54f5-468c-a83f-8601206b85bb', NULL, '2026-11-16 22:56:10.331362+00:00', NULL,
                        'Traspaso de stock de El Cristo a Santos Dumont', '2026-11-16 22:56:10.331362+00:00', '2026-11-16 22:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('ef7573df-9b6e-4951-bb5b-402e2e36e3cc', '5df86a8f-b439-4e5f-b596-d8e25d03d9b9', '2b064314-bb67-4322-b949-22aa8bb57d57', 5, NULL, '2026-11-16 22:56:10.331362+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'd8740379-8eb2-46b6-a416-5c5dde5d4786', '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a', 'BASIC-0002', '7b653acc-8e71-41c0-862d-43b1b71e5fd0', '9c631e4b-333f-4c0c-b991-755207c817d8',
                        'COMPLETADO', '8eb4d43f-54f5-468c-a83f-8601206b85bb', '8eb4d43f-54f5-468c-a83f-8601206b85bb', '2026-11-15 03:56:10.331362+00:00', '2026-11-16 07:56:10.331362+00:00',
                        'Retorno de prendas Santos Dumont a El Cristo', '2026-11-15 03:56:10.331362+00:00', '2026-11-16 07:56:10.331362+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('a6f55969-db21-40e4-a552-e43b2b39f90e', 'd8740379-8eb2-46b6-a416-5c5dde5d4786', '47b764ef-5e59-4f77-8181-900d04ca0b22', 10, 10, '2026-11-15 03:56:10.331362+00:00')
                        ;
DELETE FROM sale_items WHERE sale_id IN (SELECT id FROM sales WHERE tenant_id = '17eeb457-a34c-47a4-8826-5d9e03d1dfe5' AND (cash_reference LIKE 'CONFLICT:%' OR cash_reference = 'EN_CONFLICTO'));
DELETE FROM sales WHERE tenant_id = '17eeb457-a34c-47a4-8826-5d9e03d1dfe5' AND (cash_reference LIKE 'CONFLICT:%' OR cash_reference = 'EN_CONFLICTO');

                INSERT INTO sales (
                    id, tenant_id, branch_id, user_id, client_sale_id, is_offline, status,
                    payment_method, payment_status, cash_reference, subtotal, discount_amount,
                    total_amount, currency, created_at, updated_at
                ) VALUES (
                    '976c2522-51eb-4253-8397-ad10f930e378', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '5fb4df9a-93f4-4658-86e2-d08bc1254163', '84ebbc73-43f7-4ce9-a657-7c141088f848', 'dfee8185-d708-44b6-a35a-eb842ede379c', true, 'completed',
                    'cash', 'pending', 'CONFLICT:INSUFFICIENT_STOCK', 327.0, 0,
                    327.0, 'BOB', '2026-11-16 21:56:10.331362+00:00', '2026-11-16 21:56:10.331362+00:00'
                )
                ;

                INSERT INTO sale_items (
                    id, tenant_id, sale_id, variant_id, quantity, unit_price,
                    line_total, product_id, product_name, variant_sku, size_id, color_id
                ) VALUES (
                    'd7c0e1ee-f199-4f75-a48f-3685367f4109', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '976c2522-51eb-4253-8397-ad10f930e378', '09619d8d-d335-4bd7-957e-2991c7d6e88b', 3, 109.0,
                    327.0, '9b3fcfac-2911-4a22-b01c-5477ff90c4c5', 'Jealous 21 Women''s BFF Printed White Top', 'MYN-7194', 'ddef951a-963a-42fe-8b2e-4f80d8b9c398', '6d6075bc-f828-4e06-9f85-8bdae72bbe54'
                )
                ;

                INSERT INTO sync_operations (id, tenant_id, client_operation_id, operation_type, payload, status, synced_at, created_at)
                VALUES ('d9843211-41d9-4b52-8b95-7604839f112a', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', 'f2d4dba8-e3bc-4197-82c2-7314607875f0', 'OFFLINE_SALE', '{"conflict": true, "reason": "insufficient_stock"}', 'FAILED', '2026-11-16 21:56:10.331362+00:00', '2026-11-16 21:56:10.331362+00:00')
                ;

                INSERT INTO sales (
                    id, tenant_id, branch_id, user_id, client_sale_id, is_offline, status,
                    payment_method, payment_status, cash_reference, subtotal, discount_amount,
                    total_amount, currency, created_at, updated_at
                ) VALUES (
                    '74cb6f27-858b-4b87-ba73-c4f8497fb69b', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '82f766d1-36b7-4081-bdf7-7190a77fed9f', '84ebbc73-43f7-4ce9-a657-7c141088f848', '0b0edcc2-9773-45ba-802f-cbee6c8e4e92', true, 'completed',
                    'cash', 'pending', 'CONFLICT:INSUFFICIENT_STOCK', 308.0, 0,
                    308.0, 'BOB', '2026-11-16 13:56:10.331362+00:00', '2026-11-16 13:56:10.331362+00:00'
                )
                ;

                INSERT INTO sale_items (
                    id, tenant_id, sale_id, variant_id, quantity, unit_price,
                    line_total, product_id, product_name, variant_sku, size_id, color_id
                ) VALUES (
                    'efd6fd87-440c-4936-acc4-1ef5438e74e0', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '74cb6f27-858b-4b87-ba73-c4f8497fb69b', '0cef5d47-6f9a-4229-9ce9-a2e1d041cd58', 2, 154.0,
                    308.0, '62d5e6b8-afe8-4462-abea-ecf4ebfc883a', 'Scullers For Her Women Printed Navy Blue Shirt', 'MYN-27877', 'ddef951a-963a-42fe-8b2e-4f80d8b9c398', '70a68380-e05d-46d8-a9ba-b420a7bc4665'
                )
                ;

                INSERT INTO sync_operations (id, tenant_id, client_operation_id, operation_type, payload, status, synced_at, created_at)
                VALUES ('ca3545a9-83f1-4608-a728-900bb75069ec', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', 'c65792d6-ac5e-4f2e-9d9a-bca37347a381', 'OFFLINE_SALE', '{"conflict": true, "reason": "insufficient_stock"}', 'FAILED', '2026-11-16 13:56:10.331362+00:00', '2026-11-16 13:56:10.331362+00:00')
                ;

                INSERT INTO sales (
                    id, tenant_id, branch_id, user_id, client_sale_id, is_offline, status,
                    payment_method, payment_status, cash_reference, subtotal, discount_amount,
                    total_amount, currency, created_at, updated_at
                ) VALUES (
                    '2f871dea-2e96-44f5-a891-30a1ac17bd24', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '8ba6f37b-10d8-4fde-8b39-a1eee44f1922', '84ebbc73-43f7-4ce9-a657-7c141088f848', '31d8222c-7976-4787-abe6-ea946a40ff06', true, 'completed',
                    'cash', 'pending', 'EN_CONFLICTO', 94.0, 0,
                    94.0, 'BOB', '2026-11-16 01:56:10.331362+00:00', '2026-11-16 01:56:10.331362+00:00'
                )
                ;

                INSERT INTO sale_items (
                    id, tenant_id, sale_id, variant_id, quantity, unit_price,
                    line_total, product_id, product_name, variant_sku, size_id, color_id
                ) VALUES (
                    '00eec020-58d0-44e3-8771-25e62f74528b', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '2f871dea-2e96-44f5-a891-30a1ac17bd24', '01bd53d3-e8e9-4b6a-92d8-b59ebc9f66b7', 1, 94.0,
                    94.0, 'ea59a360-7a0e-4f26-90e4-71a71df164e0', 'Arrow Woman Olive Top', 'MYN-39729', 'ddef951a-963a-42fe-8b2e-4f80d8b9c398', '6cb4b77c-e822-4bce-8eaa-58fc8ca7b589'
                )
                ;

                INSERT INTO sync_operations (id, tenant_id, client_operation_id, operation_type, payload, status, synced_at, created_at)
                VALUES ('71f46c71-7619-4c2c-86a6-9ed3d85ae196', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '196e95dc-8f2e-47e9-9301-25c20b1177c8', 'OFFLINE_SALE', '{"conflict": true, "reason": "insufficient_stock"}', 'FAILED', '2026-11-16 01:56:10.331362+00:00', '2026-11-16 01:56:10.331362+00:00')
                ;

COMMIT;
