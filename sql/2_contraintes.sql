USE journal_vocal;
SET NAMES utf8mb4;

ALTER TABLE utilisateur ADD CONSTRAINT uq_utilisateur_email UNIQUE (email);
ALTER TABLE utilisateur ADD CONSTRAINT ck_utilisateur_email
    CHECK (email LIKE '_%@_%._%');
ALTER TABLE utilisateur ALTER COLUMN date_creation_compte SET DEFAULT (CURRENT_TIMESTAMP);
ALTER TABLE utilisateur ADD CONSTRAINT ck_utilisateur_mdp
    CHECK (CHAR_LENGTH(mot_de_passe) >= 60);

ALTER TABLE formule ADD CONSTRAINT uq_formule_nom UNIQUE (nom_formule);
ALTER TABLE formule ADD CONSTRAINT ck_formule_prix
    CHECK (prix_mensuel >= 0 AND prix_annuel >= 0);
ALTER TABLE formule ADD CONSTRAINT ck_formule_prix_annuel
    CHECK (prix_annuel <= 12 * prix_mensuel);
ALTER TABLE formule ADD CONSTRAINT ck_formule_quota
    CHECK (quota_mensuel BETWEEN 1 AND 100000);
ALTER TABLE formule ALTER COLUMN acces_approfondissement SET DEFAULT FALSE;
ALTER TABLE formule ALTER COLUMN acces_agents SET DEFAULT FALSE;

ALTER TABLE abonnement ADD CONSTRAINT ck_abonnement_periodicite
    CHECK (periodicite IN ('mensuelle', 'annuelle'));
ALTER TABLE abonnement ADD CONSTRAINT ck_abonnement_dates
    CHECK (date_fin IS NULL OR date_fin > date_debut);

ALTER TABLE paiement ADD CONSTRAINT ck_paiement_montant
    CHECK (montant > 0);
ALTER TABLE paiement ADD CONSTRAINT ck_paiement_etat
    CHECK (etat_paiement IN ('en attente', 'réussi', 'échoué', 'remboursé'));
ALTER TABLE paiement ALTER COLUMN etat_paiement SET DEFAULT 'en attente';

ALTER TABLE dictee ADD CONSTRAINT ck_dictee_audio
    CHECK (chemin_audio LIKE '%.m4a' OR chemin_audio LIKE '%.mp3' OR chemin_audio LIKE '%.wav');

ALTER TABLE demande ADD CONSTRAINT uq_demande_dictee UNIQUE (id_dictee);

ALTER TABLE version_note ADD CONSTRAINT ck_version_numero
    CHECK (numero_version >= 1);

ALTER TABLE tache ADD CONSTRAINT ck_tache_etat
    CHECK (etat_tache IN ('à faire', 'en cours', 'terminée'));
ALTER TABLE tache ALTER COLUMN etat_tache SET DEFAULT 'à faire';

ALTER TABLE service ADD CONSTRAINT uq_service_nom UNIQUE (nom_service);

ALTER TABLE autoriser ADD CONSTRAINT ck_autoriser_droit
    CHECK (libelle_droit IN ('lecture', 'ajout', 'modification'));

ALTER TABLE dictee ADD CONSTRAINT ck_dictee_transcription
    CHECK (transcription IS NULL OR CHAR_LENGTH(transcription) > 0);
