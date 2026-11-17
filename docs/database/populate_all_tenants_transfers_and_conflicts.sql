-- =========================================================================
-- SCRIPT OFICIAL: POBLACIÓN DE COORDENADAS, TRASLADOS, REPOSICIÓN Y CONFLICTOS
-- Generado el: 2026-11-17 03:09:59 UTC
-- Apto para ejecución local y producción Neon PostgreSQL
-- =========================================================================

BEGIN;

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
                    '5de32e7e-c831-4c93-bd4b-c941d43e5baf', 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8', '51433f7c-de3f-430c-a81a-063b5ed2bf72', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'requested',
                    '2026-11-16 21:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', NULL, NULL,
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('5adc442f-27a6-4ab8-a1f2-61c9a5f37bea', '5de32e7e-c831-4c93-bd4b-c941d43e5baf', '8558a408-5cae-46d7-b325-fa1d57870707', 30);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('19cbc847-fb78-4a4f-80c0-70eb868fa432', '5de32e7e-c831-4c93-bd4b-c941d43e5baf', 'b53dd6ba-c622-47ed-8bc6-c6f21c85d711', 40);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'fafe101f-a5e7-44cd-9fd2-8de83c7428ca', 'f9eb55a1-6228-4ece-b56e-92bc75cbd048', '1d6ec0b7-9a0f-4cec-8f82-71d191a5db71', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'accepted',
                    '2026-11-16 03:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', 'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-16 06:09:59.265520+00:00',
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('3eaf4995-1d73-429e-a647-640d5d15f6c2', 'fafe101f-a5e7-44cd-9fd2-8de83c7428ca', '9d228577-ef1b-4fa0-8d83-5ad38897aaf2', 25);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    '272a3aa9-d870-410f-9a30-6f9688aa6ae0', '91c320d6-bb80-4ce8-b516-19f64b80a441', 'd8083aac-0a06-48f6-8818-59f12599a8ba', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'preparing',
                    '2026-11-15 03:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', 'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-15 06:09:59.265520+00:00',
                    'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-15 13:09:59.265520+00:00', NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('c1c7f16c-fbc1-4f64-9f66-eef66f41a032', '272a3aa9-d870-410f-9a30-6f9688aa6ae0', 'efffad18-4198-4d6a-b20a-7128fa392453', 20);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('de221835-e582-4534-ae70-74486dc44450', '272a3aa9-d870-410f-9a30-6f9688aa6ae0', '6ed82f74-10f5-4478-8379-03f469df791f', 15);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    '72e13e54-1084-4f76-810a-a2f395066404', '045ac0bf-030f-4d26-8fd4-907e8a337b61', 'e19bd425-01dd-453b-8a53-8981d0f625b1', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', 'delivered',
                    '2026-11-12 03:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', 'd0757c29-439a-430b-97b4-5a6bb41484a4', '2026-11-12 06:09:59.265520+00:00',
                    'd0757c29-439a-430b-97b4-5a6bb41484a4', '2026-11-12 13:09:59.265520+00:00', 'd0757c29-439a-430b-97b4-5a6bb41484a4', '2026-11-13 03:09:59.265520+00:00',
                    'f701d2eb-9e30-49d4-bed0-e5bde288595f', '2026-11-14 03:09:59.265520+00:00'
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('6fd55450-56cf-44f0-8f44-eca41a034009', '72e13e54-1084-4f76-810a-a2f395066404', 'd8f0fe05-1cc7-4111-bded-2bacbb807e96', 50);

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '904c3245-4db8-48d6-9433-cda2006c963f', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0001', '51433f7c-de3f-430c-a81a-063b5ed2bf72', '1d6ec0b7-9a0f-4cec-8f82-71d191a5db71',
                        'EN_TRANSITO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', NULL, '2026-11-16 23:09:59.265520+00:00', NULL,
                        'Despacho intersucursal Santa Cruz Central a Equipetrol', '2026-11-16 23:09:59.265520+00:00', '2026-11-16 23:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('0d2fe518-a53f-4f58-8e32-2d97a284ff84', '904c3245-4db8-48d6-9433-cda2006c963f', '8558a408-5cae-46d7-b325-fa1d57870707', 10, NULL, '2026-11-16 23:09:59.265520+00:00')
                        ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('a02e6b41-1fb2-428d-9de3-2d1021d2bd9f', '904c3245-4db8-48d6-9433-cda2006c963f', 'b53dd6ba-c622-47ed-8bc6-c6f21c85d711', 15, NULL, '2026-11-16 23:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'c1c16f57-b292-4728-bbe2-5e7ce89e7992', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0002', '75df74b7-c0eb-45a6-a13a-8ddda9896a7f', 'd54927f1-1c7a-499a-9dfc-c6375de846a8',
                        'EN_TRANSITO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', NULL, '2026-11-16 01:09:59.265520+00:00', NULL,
                        'Reabastecimiento Las Brisas a Ventura Mall', '2026-11-16 01:09:59.265520+00:00', '2026-11-16 01:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('248ca1a9-638f-4dba-a77f-59e57fc92cd4', 'c1c16f57-b292-4728-bbe2-5e7ce89e7992', '9d228577-ef1b-4fa0-8d83-5ad38897aaf2', 8, NULL, '2026-11-16 01:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'aa92009c-b558-45d8-aa30-8c43d6599e2f', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0003', 'd8083aac-0a06-48f6-8818-59f12599a8ba', '1d078f97-710f-458d-8c1d-c623bb4f4b8d',
                        'COMPLETADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', '092722eb-cb11-4d82-b946-e8c6076ef6fd', '2026-11-14 03:09:59.265520+00:00', '2026-11-15 07:09:59.265520+00:00',
                        'Traspaso La Paz El Prado a Sopocachi', '2026-11-14 03:09:59.265520+00:00', '2026-11-15 07:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('7cd48246-8148-47f6-9919-474526341885', 'aa92009c-b558-45d8-aa30-8c43d6599e2f', 'efffad18-4198-4d6a-b20a-7128fa392453', 12, 12, '2026-11-14 03:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '84d098ea-21b8-44c7-bf5d-e5d2baacbdba', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0004', 'db8160a7-0a58-4732-b76d-f61aa9b450b8', '396b4207-3215-4c4e-a1a5-7fc6b5694340',
                        'COMPLETADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', '092722eb-cb11-4d82-b946-e8c6076ef6fd', '2026-11-12 03:09:59.265520+00:00', '2026-11-13 07:09:59.265520+00:00',
                        'Transferencia Calacoto a San Miguel verificada', '2026-11-12 03:09:59.265520+00:00', '2026-11-13 07:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('daca164a-1b4a-4876-921d-c945ba64fdf1', '84d098ea-21b8-44c7-bf5d-e5d2baacbdba', '6ed82f74-10f5-4478-8379-03f469df791f', 20, 20, '2026-11-12 03:09:59.265520+00:00')
                        ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('e7d43966-a811-48bf-9616-fa292ca3f487', '84d098ea-21b8-44c7-bf5d-e5d2baacbdba', 'd8f0fe05-1cc7-4111-bded-2bacbb807e96', 10, 10, '2026-11-12 03:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '81dd7348-0239-47b4-b67b-a8fdb32baa7e', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0005', 'e19bd425-01dd-453b-8a53-8981d0f625b1', '51433f7c-de3f-430c-a81a-063b5ed2bf72',
                        'COMPLETADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', '092722eb-cb11-4d82-b946-e8c6076ef6fd', '2026-11-10 03:09:59.265520+00:00', '2026-11-11 07:09:59.265520+00:00',
                        'Cochabamba Cala Cala a Santa Cruz Central', '2026-11-10 03:09:59.265520+00:00', '2026-11-11 07:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('3f59d1a2-5575-416a-93d8-0286609de43d', '81dd7348-0239-47b4-b67b-a8fdb32baa7e', '3aa8f659-24f3-4469-8bc4-bdac3b8e4a35', 5, 5, '2026-11-10 03:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '13b57bce-cfd5-40ff-a1bf-30e7ee0c8b2b', '1de16f02-c5c5-4b27-a1ba-9f52a183d110', 'PARIS-0006', 'eaf090b3-84b8-4f7e-a569-d193a0a9581d', '56d5d229-8a00-4ee6-aa3e-123fe985861a',
                        'CANCELADO', 'f701d2eb-9e30-49d4-bed0-e5bde288595f', NULL, '2026-11-15 03:09:59.265520+00:00', NULL,
                        'Cancelado: Sucre a Tarija suspendido por inventario', '2026-11-15 03:09:59.265520+00:00', '2026-11-15 03:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('0431849a-aee6-4348-9627-ffc3c7cc25e7', '13b57bce-cfd5-40ff-a1bf-30e7ee0c8b2b', 'd9bb918d-24a8-4103-91ae-d7b105d695b9', 14, NULL, '2026-11-15 03:09:59.265520+00:00')
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
                    'afe80dbd-64cf-4c98-977a-6d480eccb29b', 'f9eb55a1-6228-4ece-b56e-92bc75cbd048', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'requested',
                    '2026-11-17 01:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', NULL, NULL,
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('efc649ab-3c98-4055-a429-96a6fb3e3bea', 'afe80dbd-64cf-4c98-977a-6d480eccb29b', '2b064314-bb67-4322-b949-22aa8bb57d57', 20);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('80c2b255-476a-49bb-8ca1-cafc3ae7365d', 'afe80dbd-64cf-4c98-977a-6d480eccb29b', '47b764ef-5e59-4f77-8181-900d04ca0b22', 20);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'c04548b6-84c2-4fd1-bb94-5dfcbb1098c0', 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8', 'b9482bef-9c1e-4094-bbbf-160218caee09', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'preparing',
                    '2026-11-15 03:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', '9cbb8e02-a740-4676-a218-aaee1375869a', '2026-11-15 06:09:59.265520+00:00',
                    '9cbb8e02-a740-4676-a218-aaee1375869a', '2026-11-15 13:09:59.265520+00:00', NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('d8d635be-4742-4047-8800-14399df93e20', 'c04548b6-84c2-4fd1-bb94-5dfcbb1098c0', '920f8cc9-b011-4de6-8365-caf13c43abe1', 35);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'a2d45c22-9577-4063-8f5b-811e13b70dab', '91c320d6-bb80-4ce8-b516-19f64b80a441', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'delivered',
                    '2026-11-13 03:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', 'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-13 06:09:59.265520+00:00',
                    'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-13 13:09:59.265520+00:00', 'cdabe216-9d75-44f5-893e-4cb7026a4352', '2026-11-14 03:09:59.265520+00:00',
                    '11ae83a6-40c1-4d5f-a0de-1267d5f78017', '2026-11-15 03:09:59.265520+00:00'
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('1465336e-0941-4f6c-ad36-a44888a411d3', 'a2d45c22-9577-4063-8f5b-811e13b70dab', '494a0a05-5af6-4275-96ac-db412571a276', 40);
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('6559cd1a-e0b9-4c9a-8603-627674fe087d', 'a2d45c22-9577-4063-8f5b-811e13b70dab', '3764b5d1-f870-4925-99e5-77b5a13e2da9', 30);

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '3ced6363-44f6-4e7a-869f-fe5bc37f4078', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0001', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', 'b9482bef-9c1e-4094-bbbf-160218caee09',
                        'EN_TRANSITO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', NULL, '2026-11-17 00:09:59.265520+00:00', NULL,
                        'Traspaso Cochabamba Casco Viejo a América Norte', '2026-11-17 00:09:59.265520+00:00', '2026-11-17 00:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('d98ee2db-0731-47e2-b3a7-46e84f68a400', '3ced6363-44f6-4e7a-869f-fe5bc37f4078', '2b064314-bb67-4322-b949-22aa8bb57d57', 10, NULL, '2026-11-17 00:09:59.265520+00:00')
                        ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('74fa630f-7467-4e4e-8abb-b37382c96b7f', '3ced6363-44f6-4e7a-869f-fe5bc37f4078', '47b764ef-5e59-4f77-8181-900d04ca0b22', 6, NULL, '2026-11-17 00:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '717ad9dd-91e4-4cfa-951f-e5588732e364', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0002', 'b9482bef-9c1e-4094-bbbf-160218caee09', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d',
                        'COMPLETADO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'ee0acd21-8fd5-41ed-b0c8-8e38a915e871', '2026-11-14 03:09:59.265520+00:00', '2026-11-15 07:09:59.265520+00:00',
                        'Recepción de prendas de temporada en Casco Viejo', '2026-11-14 03:09:59.265520+00:00', '2026-11-15 07:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('26f1e652-e0a3-450d-bd8c-67c15bc604c6', '717ad9dd-91e4-4cfa-951f-e5588732e364', '920f8cc9-b011-4de6-8365-caf13c43abe1', 12, 12, '2026-11-14 03:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'de168431-66e6-4ed8-a455-8394d08a7278', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0003', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d', 'b9482bef-9c1e-4094-bbbf-160218caee09',
                        'COMPLETADO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', 'ee0acd21-8fd5-41ed-b0c8-8e38a915e871', '2026-11-11 03:09:59.265520+00:00', '2026-11-12 07:09:59.265520+00:00',
                        'Surtido inicial América Norte con acta de entrega', '2026-11-11 03:09:59.265520+00:00', '2026-11-12 07:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('58d3bb24-5553-49c8-8dc7-4e32674e57a4', 'de168431-66e6-4ed8-a455-8394d08a7278', '494a0a05-5af6-4275-96ac-db412571a276', 25, 25, '2026-11-11 03:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'b01b9ffb-9ff2-4c9b-a89e-80adf56c5787', '908056c0-3ee8-42fa-9e5c-8ef3869fbc97', 'MODA-0004', 'b9482bef-9c1e-4094-bbbf-160218caee09', '4c7cc455-6fc7-4b81-b285-0c43c157eb0d',
                        'CANCELADO', '11ae83a6-40c1-4d5f-a0de-1267d5f78017', NULL, '2026-11-15 03:09:59.265520+00:00', NULL,
                        'Cancelado por falta de transporte local', '2026-11-15 03:09:59.265520+00:00', '2026-11-15 03:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('25693547-5636-4a10-9858-7bbf5076de18', 'b01b9ffb-9ff2-4c9b-a89e-80adf56c5787', '3764b5d1-f870-4925-99e5-77b5a13e2da9', 8, NULL, '2026-11-15 03:09:59.265520+00:00')
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
                    '9e8e52a3-a369-4796-bf64-274ecc061932', 'e36ec7b2-8591-4904-baa1-9dd60ce4f6b8', '9c631e4b-333f-4c0c-b991-755207c817d8', '8eb4d43f-54f5-468c-a83f-8601206b85bb', 'requested',
                    '2026-11-17 02:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', NULL, NULL,
                    NULL, NULL, NULL, NULL,
                    NULL, NULL
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('0b8e8813-f94e-49f8-8ec9-bd8d0baa299b', '9e8e52a3-a369-4796-bf64-274ecc061932', '2b064314-bb67-4322-b949-22aa8bb57d57', 15);

                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    'ae434687-d737-46eb-bbfd-277b657ba94a', 'f9eb55a1-6228-4ece-b56e-92bc75cbd048', '7b653acc-8e71-41c0-862d-43b1b71e5fd0', '8eb4d43f-54f5-468c-a83f-8601206b85bb', 'delivered',
                    '2026-11-14 03:09:59.265520+00:00', '2026-11-17 03:09:59.265520+00:00', 'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-14 06:09:59.265520+00:00',
                    'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-14 13:09:59.265520+00:00', 'a6810fbc-32d7-4a66-8f78-466b53365e8a', '2026-11-15 03:09:59.265520+00:00',
                    '8eb4d43f-54f5-468c-a83f-8601206b85bb', '2026-11-16 03:09:59.265520+00:00'
                )
                ;
INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity) VALUES ('1a9e9e16-b923-4b0b-9ba7-575242f0ad56', 'ae434687-d737-46eb-bbfd-277b657ba94a', '47b764ef-5e59-4f77-8181-900d04ca0b22', 20);

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        'a8762d16-bf8b-40db-929f-82ef88dc5492', '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a', 'BASIC-0001', '9c631e4b-333f-4c0c-b991-755207c817d8', '7b653acc-8e71-41c0-862d-43b1b71e5fd0',
                        'EN_TRANSITO', '8eb4d43f-54f5-468c-a83f-8601206b85bb', NULL, '2026-11-16 22:09:59.265520+00:00', NULL,
                        'Traspaso de stock de El Cristo a Santos Dumont', '2026-11-16 22:09:59.265520+00:00', '2026-11-16 22:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('8fea6921-8a0e-449f-ae0d-81ff73dc07df', 'a8762d16-bf8b-40db-929f-82ef88dc5492', '2b064314-bb67-4322-b949-22aa8bb57d57', 5, NULL, '2026-11-16 22:09:59.265520+00:00')
                        ;

                    INSERT INTO inventory_transfers (
                        id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                        status, requested_by, received_by, requested_at, received_at,
                        notes, created_at, updated_at
                    ) VALUES (
                        '9fb8fb91-cc88-4023-9199-6f47e53c4baf', '58a4611b-58a0-4f7f-a7b9-5ed5ad4e7d9a', 'BASIC-0002', '7b653acc-8e71-41c0-862d-43b1b71e5fd0', '9c631e4b-333f-4c0c-b991-755207c817d8',
                        'COMPLETADO', '8eb4d43f-54f5-468c-a83f-8601206b85bb', '8eb4d43f-54f5-468c-a83f-8601206b85bb', '2026-11-15 03:09:59.265520+00:00', '2026-11-16 07:09:59.265520+00:00',
                        'Retorno de prendas Santos Dumont a El Cristo', '2026-11-15 03:09:59.265520+00:00', '2026-11-16 07:09:59.265520+00:00'
                    )
                    ;

                        INSERT INTO inventory_transfer_items (id, transfer_id, variant_id, quantity, received_quantity, created_at)
                        VALUES ('78db6265-5f95-482f-b385-bf8b62e25363', '9fb8fb91-cc88-4023-9199-6f47e53c4baf', '47b764ef-5e59-4f77-8181-900d04ca0b22', 10, 10, '2026-11-15 03:09:59.265520+00:00')
                        ;
DELETE FROM sale_items WHERE sale_id IN (SELECT id FROM sales WHERE tenant_id = '17eeb457-a34c-47a4-8826-5d9e03d1dfe5' AND (cash_reference LIKE 'CONFLICT:%' OR cash_reference = 'EN_CONFLICTO'));
DELETE FROM sales WHERE tenant_id = '17eeb457-a34c-47a4-8826-5d9e03d1dfe5' AND (cash_reference LIKE 'CONFLICT:%' OR cash_reference = 'EN_CONFLICTO');

                INSERT INTO sales (
                    id, tenant_id, branch_id, user_id, client_sale_id, is_offline, status,
                    payment_method, payment_status, cash_reference, subtotal, discount_amount,
                    total_amount, currency, created_at, updated_at
                ) VALUES (
                    '6ce39b94-9173-4792-9894-db33e6d3c71c', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '5fb4df9a-93f4-4658-86e2-d08bc1254163', '84ebbc73-43f7-4ce9-a657-7c141088f848', 'c7ffff01-29cd-42e6-bc71-a3ffce91af07', true, 'completed',
                    'cash', 'pending', 'CONFLICT:INSUFFICIENT_STOCK', 327.0, 0,
                    327.0, 'BOB', '2026-11-16 21:09:59.265520+00:00', '2026-11-16 21:09:59.265520+00:00'
                )
                ;

                INSERT INTO sale_items (
                    id, tenant_id, sale_id, variant_id, quantity, unit_price,
                    line_total, product_id, product_name, variant_sku, size_id, color_id
                ) VALUES (
                    '0b6c94aa-f7a8-456e-8f2f-ab4a4c7175c8', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '6ce39b94-9173-4792-9894-db33e6d3c71c', '09619d8d-d335-4bd7-957e-2991c7d6e88b', 3, 109.0,
                    327.0, '9b3fcfac-2911-4a22-b01c-5477ff90c4c5', 'Jealous 21 Women''s BFF Printed White Top', 'MYN-7194', 'ddef951a-963a-42fe-8b2e-4f80d8b9c398', '6d6075bc-f828-4e06-9f85-8bdae72bbe54'
                )
                ;

                INSERT INTO sync_operations (id, tenant_id, client_operation_id, operation_type, payload, status, synced_at, created_at)
                VALUES ('2ecc7827-07cf-40bd-99c2-4eca42cc2bff', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '737e9925-27c9-491f-a2fe-f6274470fc61', 'OFFLINE_SALE', '{"conflict": true, "reason": "insufficient_stock"}', 'FAILED', '2026-11-16 21:09:59.265520+00:00', '2026-11-16 21:09:59.265520+00:00')
                ;

                INSERT INTO sales (
                    id, tenant_id, branch_id, user_id, client_sale_id, is_offline, status,
                    payment_method, payment_status, cash_reference, subtotal, discount_amount,
                    total_amount, currency, created_at, updated_at
                ) VALUES (
                    '31406047-3d94-4277-90a1-67ec9dafb8af', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '82f766d1-36b7-4081-bdf7-7190a77fed9f', '84ebbc73-43f7-4ce9-a657-7c141088f848', 'f89b13a8-92d8-4b9c-9dab-a6cc72546526', true, 'completed',
                    'cash', 'pending', 'CONFLICT:INSUFFICIENT_STOCK', 308.0, 0,
                    308.0, 'BOB', '2026-11-16 13:09:59.265520+00:00', '2026-11-16 13:09:59.265520+00:00'
                )
                ;

                INSERT INTO sale_items (
                    id, tenant_id, sale_id, variant_id, quantity, unit_price,
                    line_total, product_id, product_name, variant_sku, size_id, color_id
                ) VALUES (
                    'd91c74f2-3522-4baf-b1f7-873479f6db5c', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '31406047-3d94-4277-90a1-67ec9dafb8af', '0cef5d47-6f9a-4229-9ce9-a2e1d041cd58', 2, 154.0,
                    308.0, '62d5e6b8-afe8-4462-abea-ecf4ebfc883a', 'Scullers For Her Women Printed Navy Blue Shirt', 'MYN-27877', 'ddef951a-963a-42fe-8b2e-4f80d8b9c398', '70a68380-e05d-46d8-a9ba-b420a7bc4665'
                )
                ;

                INSERT INTO sync_operations (id, tenant_id, client_operation_id, operation_type, payload, status, synced_at, created_at)
                VALUES ('a00de8d2-e276-4a4a-b003-7f85d88fd0ea', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '51c078e8-cca2-46fb-a9ae-2395c152e4ca', 'OFFLINE_SALE', '{"conflict": true, "reason": "insufficient_stock"}', 'FAILED', '2026-11-16 13:09:59.265520+00:00', '2026-11-16 13:09:59.265520+00:00')
                ;

                INSERT INTO sales (
                    id, tenant_id, branch_id, user_id, client_sale_id, is_offline, status,
                    payment_method, payment_status, cash_reference, subtotal, discount_amount,
                    total_amount, currency, created_at, updated_at
                ) VALUES (
                    'aa0a63f0-dfcc-4b37-868d-39a46f168988', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '8ba6f37b-10d8-4fde-8b39-a1eee44f1922', '84ebbc73-43f7-4ce9-a657-7c141088f848', '0c97a75e-fa09-4440-b98a-cb52e3b75726', true, 'completed',
                    'cash', 'pending', 'EN_CONFLICTO', 94.0, 0,
                    94.0, 'BOB', '2026-11-16 01:09:59.265520+00:00', '2026-11-16 01:09:59.265520+00:00'
                )
                ;

                INSERT INTO sale_items (
                    id, tenant_id, sale_id, variant_id, quantity, unit_price,
                    line_total, product_id, product_name, variant_sku, size_id, color_id
                ) VALUES (
                    'f8fc3d37-cd5c-47cf-b423-712ad9bc39a3', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', 'aa0a63f0-dfcc-4b37-868d-39a46f168988', '01bd53d3-e8e9-4b6a-92d8-b59ebc9f66b7', 1, 94.0,
                    94.0, 'ea59a360-7a0e-4f26-90e4-71a71df164e0', 'Arrow Woman Olive Top', 'MYN-39729', 'ddef951a-963a-42fe-8b2e-4f80d8b9c398', '6cb4b77c-e822-4bce-8eaa-58fc8ca7b589'
                )
                ;

                INSERT INTO sync_operations (id, tenant_id, client_operation_id, operation_type, payload, status, synced_at, created_at)
                VALUES ('92693cee-09cb-4c55-83cc-81245a9a7ec0', '17eeb457-a34c-47a4-8826-5d9e03d1dfe5', '2cfba443-c993-4ae6-9f3b-65a8b78337b2', 'OFFLINE_SALE', '{"conflict": true, "reason": "insufficient_stock"}', 'FAILED', '2026-11-16 01:09:59.265520+00:00', '2026-11-16 01:09:59.265520+00:00')
                ;

COMMIT;
