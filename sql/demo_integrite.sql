-- Démo pour la vidéo : à lancer sur une base vide après 1_creation et 2_contraintes
-- les lignes marquées "refus" doivent donner une erreur, c'est voulu

USE journal_vocal;
SET NAMES utf8mb4;

-- quelques données
INSERT INTO formule (id_formule, nom_formule, prix_mensuel, prix_annuel, quota_mensuel, acces_approfondissement, acces_agents)
VALUES (1, 'Gratuite', 0, 0, 30, FALSE, FALSE),
       (2, 'Plus', 4.99, 49.90, 500, TRUE, FALSE);
INSERT INTO utilisateur (id_utilisateur, email, mot_de_passe, id_formule)
VALUES (1, 'lea.martin@mail.fr', REPEAT('h', 60), 2),
       (2, 'karim.benali@mail.fr', REPEAT('h', 60), 1);
INSERT INTO parrainer VALUES (2, 1, NOW()); -- 1 parraine 2
INSERT INTO note (id_note, titre_note, id_utilisateur) VALUES (1, 'Idée de projet', 1);
INSERT INTO version_note VALUES (1, 1, 'Première version'), (1, 2, 'Version reformulée');

-- 1. contraintes de validation
INSERT INTO utilisateur (email, mot_de_passe) VALUES ('pas-un-email', REPEAT('h', 60));       -- refus : email invalide
INSERT INTO utilisateur (email, mot_de_passe) VALUES ('lea.martin@mail.fr', REPEAT('h', 60)); -- refus : email déjà pris
INSERT INTO formule (nom_formule, prix_mensuel, prix_annuel, quota_mensuel)
VALUES ('Pro', 9.99, 150, 1000);                       -- refus : annuel plus cher que 12 mois
INSERT INTO abonnement (periodicite, date_debut, id_formule, id_utilisateur)
VALUES ('semaine', NOW(), 2, 1);                       -- refus : périodicité
INSERT INTO version_note VALUES (1, 0, 'Version zéro'); -- refus : version 0

-- 2. intégrité
INSERT INTO note (titre_note, id_utilisateur) VALUES ('Note orpheline', 999); -- refus : l'utilisateur 999 n'existe pas
INSERT INTO version_note VALUES (1, 2, 'Doublon');                            -- refus : clé déjà prise

-- 3. ON UPDATE CASCADE
UPDATE utilisateur SET id_utilisateur = 10 WHERE id_utilisateur = 1;
SELECT id_note, id_utilisateur FROM note;       -- passe à 10
SELECT id_filleul, id_parrain FROM parrainer;  -- id_parrain passe à 10

-- 4. suppressions
DELETE FROM formule WHERE id_formule = 2;       -- SET NULL
SELECT id_utilisateur, id_formule FROM utilisateur;
DELETE FROM utilisateur WHERE id_utilisateur = 10;
SELECT COUNT(*) AS notes_restantes FROM note;            -- 0
SELECT COUNT(*) AS versions_restantes FROM version_note; -- 0
SELECT id_utilisateur, email FROM utilisateur;           -- le filleul est toujours là
SELECT COUNT(*) AS parrainages_restants FROM parrainer;  -- 0
