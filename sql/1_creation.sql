SET NAMES utf8mb4;

DROP DATABASE IF EXISTS journal_vocal;
CREATE DATABASE journal_vocal;
USE journal_vocal;

CREATE TABLE formule (
    id_formule              INT AUTO_INCREMENT PRIMARY KEY,
    nom_formule             VARCHAR(100)  NOT NULL,
    prix_mensuel            DECIMAL(8,2)  NOT NULL,
    prix_annuel             DECIMAL(8,2)  NOT NULL,
    quota_mensuel           INT           NOT NULL,
    acces_approfondissement BOOLEAN       NOT NULL,
    acces_agents            BOOLEAN       NOT NULL
);

CREATE TABLE service (
    id_service  INT AUTO_INCREMENT PRIMARY KEY,
    nom_service VARCHAR(100) NOT NULL
);

CREATE TABLE utilisateur (
    id_utilisateur       INT AUTO_INCREMENT PRIMARY KEY,
    email                VARCHAR(254) NOT NULL,
    mot_de_passe         VARCHAR(255) NOT NULL,
    date_creation_compte DATETIME     NOT NULL,
    id_formule           INT          NULL,
    CONSTRAINT fk_utilisateur_formule FOREIGN KEY (id_formule)
        REFERENCES formule (id_formule)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE parrainer (
    id_filleul      INT      NOT NULL PRIMARY KEY,
    id_parrain      INT      NOT NULL,
    date_parrainage DATETIME NOT NULL,
    CONSTRAINT fk_parrainer_filleul FOREIGN KEY (id_filleul)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_parrainer_parrain FOREIGN KEY (id_parrain)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE abonnement (
    id_abonnement  INT AUTO_INCREMENT PRIMARY KEY,
    periodicite    VARCHAR(10) NOT NULL,
    date_debut     DATETIME    NOT NULL,
    date_fin       DATETIME    NULL,
    id_formule     INT         NULL,
    id_utilisateur INT         NOT NULL,
    CONSTRAINT fk_abonnement_formule FOREIGN KEY (id_formule)
        REFERENCES formule (id_formule)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_abonnement_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE paiement (
    id_paiement   INT AUTO_INCREMENT PRIMARY KEY,
    montant       DECIMAL(8,2) NOT NULL,
    date_paiement DATETIME     NOT NULL,
    etat_paiement VARCHAR(20)  NOT NULL,
    id_abonnement INT          NOT NULL,
    CONSTRAINT fk_paiement_abonnement FOREIGN KEY (id_abonnement)
        REFERENCES abonnement (id_abonnement)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE dictee (
    id_dictee         INT AUTO_INCREMENT PRIMARY KEY,
    date_heure_dictee DATETIME     NOT NULL,
    chemin_audio      VARCHAR(255) NOT NULL,
    transcription     TEXT         NULL,
    id_utilisateur    INT          NOT NULL,
    CONSTRAINT fk_dictee_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE demande (
    id_demande      INT AUTO_INCREMENT PRIMARY KEY,
    contenu_demande TEXT NOT NULL,
    id_utilisateur  INT  NOT NULL,
    id_dictee       INT  NULL,
    CONSTRAINT fk_demande_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_demande_dictee FOREIGN KEY (id_dictee)
        REFERENCES dictee (id_dictee)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE note (
    id_note        INT AUTO_INCREMENT PRIMARY KEY,
    titre_note     VARCHAR(500) NOT NULL,
    id_dictee      INT          NULL,
    id_utilisateur INT          NOT NULL,
    CONSTRAINT fk_note_dictee FOREIGN KEY (id_dictee)
        REFERENCES dictee (id_dictee)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_note_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE version_note (
    id_note         INT  NOT NULL,
    numero_version  INT  NOT NULL,
    contenu_version TEXT NOT NULL,
    PRIMARY KEY (id_note, numero_version),
    CONSTRAINT fk_version_note FOREIGN KEY (id_note)
        REFERENCES note (id_note)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE projet (
    id_projet        INT AUTO_INCREMENT PRIMARY KEY,
    intitule_projet  VARCHAR(500) NOT NULL,
    id_utilisateur   INT          NOT NULL,
    CONSTRAINT fk_projet_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE decomposer (
    id_sous_projet   INT NOT NULL PRIMARY KEY,
    id_projet_parent INT NOT NULL,
    CONSTRAINT fk_decomposer_sous_projet FOREIGN KEY (id_sous_projet)
        REFERENCES projet (id_projet)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_decomposer_parent FOREIGN KEY (id_projet_parent)
        REFERENCES projet (id_projet)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tache (
    id_tache       INT AUTO_INCREMENT PRIMARY KEY,
    intitule_tache VARCHAR(500) NOT NULL,
    etat_tache     VARCHAR(30)  NOT NULL,
    id_utilisateur INT          NOT NULL,
    id_projet      INT          NULL,
    CONSTRAINT fk_tache_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tache_projet FOREIGN KEY (id_projet)
        REFERENCES projet (id_projet)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE autoriser (
    id_utilisateur INT         NOT NULL,
    id_service     INT         NOT NULL,
    libelle_droit  VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_utilisateur, id_service, libelle_droit),
    CONSTRAINT fk_autoriser_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_autoriser_service FOREIGN KEY (id_service)
        REFERENCES service (id_service)
        ON DELETE CASCADE ON UPDATE CASCADE
);
