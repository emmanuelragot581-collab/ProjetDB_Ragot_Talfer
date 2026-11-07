USE journal_vocal;
SET NAMES utf8mb4;

-- données de test
INSERT INTO formule (id_formule, nom_formule, prix_mensuel, prix_annuel, quota_mensuel, acces_approfondissement, acces_agents)
VALUES (1, 'Gratuite', 0, 0, 30, FALSE, FALSE),
       (2, 'Plus', 4.99, 49.90, 500, TRUE, FALSE);
INSERT INTO utilisateur (id_utilisateur, email, mot_de_passe, id_formule)
VALUES (1, 'lea.martin@mail.fr', REPEAT('h', 60), 2),
       (2, 'karim.benali@mail.fr', REPEAT('h', 60), 1);
INSERT INTO parrainer VALUES (2, 1, NOW());
INSERT INTO note (id_note, titre_note, id_utilisateur) VALUES (1, 'Idée de projet', 1);
INSERT INTO version_note VALUES (1, 1, 'Première version'), (1, 2, 'Version reformulée');

-- contraintes de validation (doivent échouer)
INSERT INTO utilisateur (email, mot_de_passe) VALUES ('pas-un-email', REPEAT('h', 60));
INSERT INTO utilisateur (email, mot_de_passe) VALUES ('lea.martin@mail.fr', REPEAT('h', 60));
INSERT INTO formule (nom_formule, prix_mensuel, prix_annuel, quota_mensuel)
VALUES ('Pro', 9.99, 150, 1000);
INSERT INTO abonnement (periodicite, date_debut, id_formule, id_utilisateur)
VALUES ('semaine', NOW(), 2, 1);
INSERT INTO version_note VALUES (1, 0, 'Version zéro');

-- clé étrangère et clé primaire (doivent échouer)
INSERT INTO note (titre_note, id_utilisateur) VALUES ('Note orpheline', 999);
INSERT INTO version_note VALUES (1, 2, 'Doublon');

-- ON UPDATE CASCADE
UPDATE utilisateur SET id_utilisateur = 10 WHERE id_utilisateur = 1;
SELECT id_note, id_utilisateur FROM note;
SELECT id_filleul, id_parrain FROM parrainer;

-- suppressions (ON DELETE)
DELETE FROM formule WHERE id_formule = 2;
SELECT id_utilisateur, id_formule FROM utilisateur;
DELETE FROM utilisateur WHERE id_utilisateur = 10;
SELECT COUNT(*) AS notes_restantes FROM note;
SELECT COUNT(*) AS versions_restantes FROM version_note;
SELECT id_utilisateur, email FROM utilisateur;
SELECT COUNT(*) AS parrainages_restants FROM parrainer;
