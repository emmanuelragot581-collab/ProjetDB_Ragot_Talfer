-- =====================================================================
-- 4_interrogation.sql : requêtes du scénario d'utilisation
-- À exécuter après 1_creation.sql, 2_contraintes.sql et 3_insertion.sql.
--
-- Scénario : Camille, responsable marketing, prépare la campagne
-- « Passe à Plus ». Elle veut faire passer des utilisateurs de la formule
-- Gratuite à Plus ou Pro, relancer les paiements échoués et récompenser
-- les meilleurs parrains. Chaque requête répond à une de ses questions.
-- =====================================================================

USE journal_vocal;
SET NAMES utf8mb4;  -- les accents sont envoyés en UTF-8, quel que soit l'outil utilisé

-- =====================================================================
-- PARTIE A. Projections et sélections (tri, DISTINCT, masques, IN, BETWEEN)
-- =====================================================================

-- A1. Les nouveaux inscrits du premier semestre 2026 (e-mail et date d'inscription),
--     du plus ancien au plus récent : la campagne leur souhaitera la bienvenue.
SELECT email, date_creation_compte
FROM utilisateur
WHERE date_creation_compte BETWEEN '2026-01-01' AND '2026-06-30 23:59:59'
ORDER BY date_creation_compte;

-- A2. Les utilisateurs qui ont une adresse Gmail : on leur proposera
--     de connecter Google Agenda (masque LIKE).
SELECT id_utilisateur, email
FROM utilisateur
WHERE email LIKE '%@gmail.com'
ORDER BY email;

-- A3. Les paiements à relancer : échoués ou en attente, du plus récent au plus ancien (IN).
SELECT id_paiement, id_abonnement, montant, date_paiement, etat_paiement
FROM paiement
WHERE etat_paiement IN ('échoué', 'en attente')
ORDER BY date_paiement DESC;

-- A4. Les utilisateurs actifs récemment : ceux qui ont dicté au moins une fois
--     en septembre ou octobre 2026, chacun une seule fois (DISTINCT + BETWEEN).
SELECT DISTINCT id_utilisateur
FROM dictee
WHERE date_heure_dictee BETWEEN '2026-09-01' AND '2026-10-31 23:59:59'
ORDER BY id_utilisateur;

-- A5. Les demandes qui parlent d'agents : ces utilisateurs sont intéressés
--     par l'offre Pro (masque LIKE sur le contenu de la demande).
SELECT id_demande, id_utilisateur, contenu_demande
FROM demande
WHERE contenu_demande LIKE '%agent%'
ORDER BY id_utilisateur;

-- =====================================================================
-- PARTIE A. Fonctions d'agrégation (GROUP BY, HAVING)
-- =====================================================================

-- G1. Nombre d'utilisateurs par formule actuelle : la taille de chaque public.
SELECT id_formule, COUNT(*) AS nb_utilisateurs
FROM utilisateur
GROUP BY id_formule
ORDER BY id_formule;

-- G2. Chiffre d'affaires encaissé par mois (paiements réussis uniquement) :
--     les mois où la campagne précédente a le mieux fonctionné.
SELECT YEAR(date_paiement) AS annee, MONTH(date_paiement) AS mois,
       COUNT(*) AS nb_paiements, SUM(montant) AS total_encaisse
FROM paiement
WHERE etat_paiement = 'réussi'
GROUP BY YEAR(date_paiement), MONTH(date_paiement)
ORDER BY annee, mois;

-- G3. Les utilisateurs les plus actifs : au moins 3 dictées au total (HAVING).
SELECT id_utilisateur, COUNT(*) AS nb_dictees, MAX(date_heure_dictee) AS derniere_dictee
FROM dictee
GROUP BY id_utilisateur
HAVING COUNT(*) >= 3
ORDER BY nb_dictees DESC;

-- G4. Les meilleurs parrains : au moins 2 filleuls. Ils recevront un mois offert
--     et deviendront les ambassadeurs de la campagne (HAVING).
SELECT id_parrain, COUNT(*) AS nb_filleuls, MIN(date_parrainage) AS premier_parrainage
FROM parrainer
GROUP BY id_parrain
HAVING COUNT(*) >= 2
ORDER BY nb_filleuls DESC;

-- G5. Montant moyen, minimum et maximum des paiements selon leur état :
--     combien représentent les paiements échoués à récupérer.
SELECT etat_paiement, COUNT(*) AS nb, ROUND(AVG(montant), 2) AS montant_moyen,
       MIN(montant) AS montant_min, MAX(montant) AS montant_max, SUM(montant) AS total
FROM paiement
GROUP BY etat_paiement
ORDER BY total DESC;
