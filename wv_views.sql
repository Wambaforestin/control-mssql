-- vue 1
CREATE VIEW ALL_PLAYERS AS 
SELECT 
    players.pseudo AS nom_du_joueur,
    COUNT(DISTINCT players_in_parties.id_party) AS nombre_de_parties_jouees,
    COUNT(DISTINCT players_play.id_turn) AS nombre_de_tours_joues,
    MIN(turns.start_time) AS date_heure_premiere_participation,
    MAX(players_play.end_time) AS date_heure_derniere_action
FROM players
JOIN players_in_parties ON players.id_player = players_in_parties.id_player
JOIN players_play ON players.id_player = players_play.id_player
JOIN turns ON players_play.id_turn = turns.id_turn
GROUP BY players.pseudo;

-- vue 2
CREATE VIEW ALL_PLAYERS_ELAPSED_GAME AS
SELECT 
    players.pseudo AS nom_du_joueur,
    parties.title_party AS nom_de_la_partie,
    COUNT(DISTINCT players_in_parties.id_player) AS nombre_de_participants,
    MIN(players_play.start_time) AS date_heure_premiere_action,
    MAX(players_play.end_time) AS date_heure_derniere_action,
    DATEDIFF(SECOND, MIN(players_play.start_time), MAX(players_play.end_time)) AS nb_de_secondes_passees_dans_la_partie
FROM players
JOIN players_in_parties ON players.id_player = players_in_parties.id_player
JOIN players_play ON players.id_player = players_play.id_player
JOIN turns ON players_play.id_turn = turns.id_turn
JOIN parties ON turns.id_party = parties.id_party
GROUP BY players.pseudo, parties.title_party;

-- vue 3
CREATE VIEW ALL_PLAYERS_ELAPSED_TOUR AS
SELECT 
    players.pseudo AS nom_du_joueur,
    parties.title_party AS nom_de_la_partie,
    turns.id_turn AS numero_du_tour,
    turns.start_time AS date_heure_debut_du_tour,
    players_play.start_time AS date_heure_prise_decision,
    DATEDIFF(SECOND, turns.start_time, players_play.start_time) AS nb_de_secondes_passees_dans_le_tour
FROM players
JOIN players_in_parties ON players.id_player = players_in_parties.id_player
JOIN players_play ON players.id_player = players_play.id_player
JOIN turns ON players_play.id_turn = turns.id_turn
JOIN parties ON turns.id_party = parties.id_party;

-- vue 4
CREATE VIEW ALL_PLAYERS_STATS AS
SELECT 
    players.pseudo AS nom_du_joueur,
    roles.description_role AS role,
    parties.title_party AS nom_de_la_partie,
    COUNT(DISTINCT players_play.id_turn) AS nb_de_tours_joues_par_le_joueur,
    COUNT(DISTINCT turns.id_turn) AS nb_total_de_tours_de_la_partie,
    CASE 
        WHEN roles.description_role = 'loup' THEN 'villageois'
        ELSE 'loup'
    END AS vainqueur,
    AVG(DATEDIFF(SECOND, turns.start_time, players_play.start_time)) AS temps_moyen_de_prise_de_decision
FROM players
JOIN players_in_parties ON players.id_player = players_in_parties.id_player
JOIN players_play ON players.id_player = players_play.id_player
JOIN turns ON players_play.id_turn = turns.id_turn
JOIN parties ON turns.id_party = parties.id_party
JOIN roles ON players_in_parties.id_role = roles.id_role
GROUP BY players.pseudo, roles.description_role, parties.title_party;
