-- =====================================================================
-- 2_contraintes.sql : contraintes de validation (à exécuter après 1_creation.sql)
-- Chaque contrainte renvoie à une règle de gestion (RG) du README §2.2.
-- Cas du cours couverts : UNIQUE, NOT NULL (MODIFY), DEFAULT,
-- CHECK par énumération (IN), par intervalle (BETWEEN, >=), par masque (LIKE),
-- et CHECK sur une ligne (comparaison entre deux colonnes).
-- =====================================================================

USE journal_vocal;
SET NAMES utf8mb4;  -- les accents sont envoyés en UTF-8, quel que soit l'outil utilisé

-- UTILISATEUR -----------------------------------------------------------
-- RG : « Un utilisateur possède un compte personnel identifié par une adresse e-mail »
ALTER TABLE utilisateur ADD CONSTRAINT uq_utilisateur_email UNIQUE (email);
ALTER TABLE utilisateur ADD CONSTRAINT ck_utilisateur_email
    CHECK (email LIKE '_%@_%._%');
-- La date de création du compte est celle de l'inscription si elle n'est pas donnée
ALTER TABLE utilisateur ALTER COLUMN date_creation_compte SET DEFAULT (CURRENT_TIMESTAMP);
-- Un mot de passe haché fait au moins 60 caractères (bcrypt)
ALTER TABLE utilisateur ADD CONSTRAINT ck_utilisateur_mdp
    CHECK (CHAR_LENGTH(mot_de_passe) >= 60);

-- FORMULE ---------------------------------------------------------------
-- RG : « Une formule possède un prix mensuel, un prix annuel et un quota mensuel »
-- RG : « La formule gratuite a un prix mensuel et un prix annuel nuls »
ALTER TABLE formule ADD CONSTRAINT uq_formule_nom UNIQUE (nom_formule);
ALTER TABLE formule ADD CONSTRAINT ck_formule_prix
    CHECK (prix_mensuel >= 0 AND prix_annuel >= 0);
-- Contrainte sur une ligne : l'abonnement annuel ne coûte pas plus que 12 mois
ALTER TABLE formule ADD CONSTRAINT ck_formule_prix_annuel
    CHECK (prix_annuel <= 12 * prix_mensuel);
ALTER TABLE formule ADD CONSTRAINT ck_formule_quota
    CHECK (quota_mensuel BETWEEN 1 AND 100000);
-- RG : « Une formule peut donner accès ou non à l'approfondissement / aux agents »
ALTER TABLE formule ALTER COLUMN acces_approfondissement SET DEFAULT FALSE;
ALTER TABLE formule ALTER COLUMN acces_agents SET DEFAULT FALSE;

-- ABONNEMENT ------------------------------------------------------------
-- RG : « Un utilisateur peut souscrire selon une périodicité mensuelle ou annuelle »
ALTER TABLE abonnement ADD CONSTRAINT ck_abonnement_periodicite
    CHECK (periodicite IN ('mensuelle', 'annuelle'));
-- RG : « Un abonnement possède une date de début et peut avoir une date de fin »
ALTER TABLE abonnement ADD CONSTRAINT ck_abonnement_dates
    CHECK (date_fin IS NULL OR date_fin > date_debut);

-- PAIEMENT --------------------------------------------------------------
-- RG : « un paiement possède un montant, une date et un état »
ALTER TABLE paiement ADD CONSTRAINT ck_paiement_montant
    CHECK (montant > 0);
ALTER TABLE paiement ADD CONSTRAINT ck_paiement_etat
    CHECK (etat_paiement IN ('en attente', 'réussi', 'échoué', 'remboursé'));
ALTER TABLE paiement ALTER COLUMN etat_paiement SET DEFAULT 'en attente';

-- DICTÉE ----------------------------------------------------------------
-- Le fichier audio est un fichier .m4a, .mp3 ou .wav
ALTER TABLE dictee ADD CONSTRAINT ck_dictee_audio
    CHECK (chemin_audio LIKE '%.m4a' OR chemin_audio LIKE '%.mp3' OR chemin_audio LIKE '%.wav');

-- DEMANDE ---------------------------------------------------------------
-- RG : « Une dictée peut être associée à une demande » : au plus une demande par dictée (0,1)
ALTER TABLE demande ADD CONSTRAINT uq_demande_dictee UNIQUE (id_dictee);

-- VERSION_NOTE ----------------------------------------------------------
-- RG : « Chaque modification importante […] constitue une nouvelle version » : numérotées à partir de 1
ALTER TABLE version_note ADD CONSTRAINT ck_version_numero
    CHECK (numero_version >= 1);

-- TÂCHE -----------------------------------------------------------------
-- RG : « Une tâche possède un intitulé, un état »
ALTER TABLE tache ADD CONSTRAINT ck_tache_etat
    CHECK (etat_tache IN ('à faire', 'en cours', 'terminée'));
ALTER TABLE tache ALTER COLUMN etat_tache SET DEFAULT 'à faire';

-- SERVICE ---------------------------------------------------------------
-- RG : « Une connexion à un service externe […] concerne un service identifié »
ALTER TABLE service ADD CONSTRAINT uq_service_nom UNIQUE (nom_service);

-- AUTORISER -------------------------------------------------------------
-- RG : « les droits accordés sont définis séparément pour la lecture, l'ajout et la modification »
ALTER TABLE autoriser ADD CONSTRAINT ck_autoriser_droit
    CHECK (libelle_droit IN ('lecture', 'ajout', 'modification'));

-- DICTÉE (suite) --------------------------------------------------------
-- Une transcription, une fois faite, n'est jamais vide
ALTER TABLE dictee ADD CONSTRAINT ck_dictee_transcription
    CHECK (transcription IS NULL OR CHAR_LENGTH(transcription) > 0);
