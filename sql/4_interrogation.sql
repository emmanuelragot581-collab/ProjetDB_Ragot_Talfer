USE journal_vocal;
SET NAMES utf8mb4;

-- A1 : e-mail et date d'inscription des utilisateurs inscrits au 1er semestre 2026
SELECT email, date_creation_compte
FROM utilisateur
WHERE date_creation_compte BETWEEN '2026-01-01' AND '2026-06-30 23:59:59'
ORDER BY date_creation_compte;

-- A2 : utilisateurs qui ont une adresse Gmail
SELECT id_utilisateur, email
FROM utilisateur
WHERE email LIKE '%@gmail.com'
ORDER BY email;

-- A3 : paiements échoués ou en attente, du plus récent au plus ancien
SELECT id_paiement, id_abonnement, montant, date_paiement, etat_paiement
FROM paiement
WHERE etat_paiement IN ('échoué', 'en attente')
ORDER BY date_paiement DESC;

-- A4 : utilisateurs qui ont fait une dictée en septembre ou octobre 2026
SELECT DISTINCT id_utilisateur
FROM dictee
WHERE date_heure_dictee BETWEEN '2026-09-01' AND '2026-10-31 23:59:59'
ORDER BY id_utilisateur;

-- A5 : demandes qui parlent d'agents
SELECT id_demande, id_utilisateur, contenu_demande
FROM demande
WHERE contenu_demande LIKE '%agent%'
ORDER BY id_utilisateur;

-- G1 : nombre d'utilisateurs par formule
SELECT id_formule, COUNT(*) AS nb_utilisateurs
FROM utilisateur
GROUP BY id_formule
ORDER BY id_formule;

-- G2 : chiffre d'affaires par mois (paiements réussis)
SELECT YEAR(date_paiement) AS annee, MONTH(date_paiement) AS mois,
       COUNT(*) AS nb_paiements, SUM(montant) AS total_encaisse
FROM paiement
WHERE etat_paiement = 'réussi'
GROUP BY YEAR(date_paiement), MONTH(date_paiement)
ORDER BY annee, mois;

-- G3 : utilisateurs qui ont fait au moins 3 dictées
SELECT id_utilisateur, COUNT(*) AS nb_dictees, MAX(date_heure_dictee) AS derniere_dictee
FROM dictee
GROUP BY id_utilisateur
HAVING COUNT(*) >= 3
ORDER BY nb_dictees DESC;

-- G4 : parrains qui ont au moins 2 filleuls
SELECT id_parrain, COUNT(*) AS nb_filleuls, MIN(date_parrainage) AS premier_parrainage
FROM parrainer
GROUP BY id_parrain
HAVING COUNT(*) >= 2
ORDER BY nb_filleuls DESC;

-- G5 : montant moyen, minimum, maximum et total des paiements par état
SELECT etat_paiement, COUNT(*) AS nb, ROUND(AVG(montant), 2) AS montant_moyen,
       MIN(montant) AS montant_min, MAX(montant) AS montant_max, SUM(montant) AS total
FROM paiement
GROUP BY etat_paiement
ORDER BY total DESC;

-- J1 : e-mails des utilisateurs de la formule Gratuite
SELECT u.id_utilisateur, u.email, u.date_creation_compte
FROM utilisateur u
INNER JOIN formule f ON f.id_formule = u.id_formule
WHERE f.nom_formule = 'Gratuite'
ORDER BY u.date_creation_compte;

-- J2 : nombre de dictées de chaque utilisateur Gratuit, même ceux qui n'en ont pas
SELECT u.id_utilisateur, u.email, COUNT(d.id_dictee) AS nb_dictees
FROM utilisateur u
INNER JOIN formule f ON f.id_formule = u.id_formule
LEFT JOIN dictee d ON d.id_utilisateur = u.id_utilisateur
WHERE f.nom_formule = 'Gratuite'
GROUP BY u.id_utilisateur, u.email
ORDER BY nb_dictees DESC, u.id_utilisateur;

-- J3 : paiements échoués avec l'e-mail de l'abonné et sa formule
SELECT p.id_paiement, p.date_paiement, p.montant, u.email, f.nom_formule, a.periodicite
FROM paiement p
INNER JOIN abonnement a ON a.id_abonnement = p.id_abonnement
INNER JOIN utilisateur u ON u.id_utilisateur = a.id_utilisateur
INNER JOIN formule f ON f.id_formule = a.id_formule
WHERE p.etat_paiement = 'échoué'
ORDER BY p.date_paiement DESC;

-- J4 : e-mail de chaque parrain et de son filleul
SELECT par.email AS email_parrain, fil.email AS email_filleul, pr.date_parrainage
FROM parrainer pr
INNER JOIN utilisateur par ON par.id_utilisateur = pr.id_parrain
INNER JOIN utilisateur fil ON fil.id_utilisateur = pr.id_filleul
ORDER BY email_parrain, pr.date_parrainage;

-- J5 : nombre d'utilisateurs par service, même les services jamais connectés
SELECT s.nom_service, COUNT(DISTINCT a.id_utilisateur) AS nb_utilisateurs
FROM service s
LEFT JOIN autoriser a ON a.id_service = s.id_service
GROUP BY s.id_service, s.nom_service
ORDER BY nb_utilisateurs DESC;

-- N1 : utilisateurs Gratuit qui ont connecté un agenda (Apple ou Google)
SELECT id_utilisateur, email
FROM utilisateur
WHERE id_formule = (SELECT id_formule FROM formule WHERE nom_formule = 'Gratuite')
  AND id_utilisateur IN (SELECT a.id_utilisateur
                         FROM autoriser a
                         INNER JOIN service s ON s.id_service = a.id_service
                         WHERE s.nom_service IN ('Calendrier Apple', 'Google Agenda'));

-- N2 : utilisateurs qui n'ont jamais pris d'abonnement
SELECT u.id_utilisateur, u.email
FROM utilisateur u
WHERE NOT EXISTS (SELECT *
                  FROM abonnement a
                  WHERE a.id_utilisateur = u.id_utilisateur)
ORDER BY u.id_utilisateur;

-- N3 : anciens abonnés qui n'ont plus d'abonnement en cours
SELECT id_utilisateur, email
FROM utilisateur
WHERE id_utilisateur IN (SELECT id_utilisateur FROM abonnement WHERE date_fin IS NOT NULL)
  AND id_utilisateur NOT IN (SELECT id_utilisateur FROM abonnement WHERE date_fin IS NULL);

-- N4 : utilisateur qui a fait le plus de dictées
SELECT id_utilisateur, COUNT(*) AS nb_dictees
FROM dictee
GROUP BY id_utilisateur
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM dictee GROUP BY id_utilisateur);

-- N5 : utilisateurs Gratuit qui dictent plus qu'au moins un abonné Plus
SELECT d.id_utilisateur, COUNT(*) AS nb_dictees
FROM dictee d
WHERE d.id_utilisateur IN (SELECT u.id_utilisateur
                           FROM utilisateur u
                           INNER JOIN formule f ON f.id_formule = u.id_formule
                           WHERE f.nom_formule = 'Gratuite')
GROUP BY d.id_utilisateur
HAVING COUNT(*) > ANY (SELECT COUNT(*)
                       FROM dictee d2
                       INNER JOIN utilisateur u2 ON u2.id_utilisateur = d2.id_utilisateur
                       INNER JOIN formule f2 ON f2.id_formule = u2.id_formule
                       WHERE f2.nom_formule = 'Plus'
                       GROUP BY d2.id_utilisateur)
ORDER BY nb_dictees DESC;

-- N6 : projets qui ont des sous-projets
SELECT p.id_projet, p.intitule_projet, p.id_utilisateur
FROM projet p
WHERE EXISTS (SELECT *
              FROM decomposer dc
              WHERE dc.id_projet_parent = p.id_projet)
ORDER BY p.id_utilisateur;

-- Requête étudiée (plans d'exécution) : e-mails des utilisateurs Gratuit qui ont dicté en octobre 2026
SELECT DISTINCT u.email
FROM formule f
INNER JOIN utilisateur u ON u.id_formule = f.id_formule
INNER JOIN dictee d ON d.id_utilisateur = u.id_utilisateur
WHERE f.nom_formule = 'Gratuite'
  AND d.date_heure_dictee BETWEEN '2026-10-01' AND '2026-10-31 23:59:59';
