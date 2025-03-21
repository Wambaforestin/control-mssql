-- Mise à jour du schéma de la base de données
/*
les modifications apportées sont les suivantes :
- Ajout des contraintes de clés étrangères et de clés primaires, not null, DEFAULT CURRENT_TIMESTAMP
- base de données pour tester les requêtes : tp_mssql, (CREATE DATABASE IF NOT EXISTS tp_mssql;)
*/

CREATE TABLE parties (
    id_party INT PRIMARY KEY IDENTITY(1,1),
    title_party VARCHAR(255) NOT NULL
);

CREATE TABLE roles (
    id_role INT PRIMARY KEY IDENTITY(100,1),
    description_role VARCHAR(255) NOT NULL
);

CREATE TABLE players (
    id_player INT PRIMARY KEY IDENTITY(200,1),
    pseudo VARCHAR(255) NOT NULL
);

CREATE TABLE players_in_parties (
    id_party INT NOT NULL,
    id_player INT NOT NULL,
    id_role INT NOT NULL,
    is_alive VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_party, id_player),
    FOREIGN KEY (id_party) REFERENCES parties(id_party),
    FOREIGN KEY (id_player) REFERENCES players(id_player),
    FOREIGN KEY (id_role) REFERENCES roles(id_role)
);

CREATE TABLE turns (
    id_turn INT PRIMARY KEY IDENTITY(300,1),
    id_party INT NOT NULL,
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_party) REFERENCES parties(id_party)
);

CREATE TABLE players_play (
    id_player INT NOT NULL,
    id_turn INT NOT NULL,
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL,
    origin_position_col VARCHAR(255) NOT NULL,
    origin_position_row VARCHAR(255) NOT NULL,
    target_position_col VARCHAR(255) NOT NULL,
    target_position_row VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_player, id_turn),
    FOREIGN KEY (id_player) REFERENCES players(id_player),
    FOREIGN KEY (id_turn) REFERENCES turns(id_turn)
);
