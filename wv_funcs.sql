CREATE FUNCTION random_position(@rows INT, @cols INT)
RETURNS @result TABLE (row_val INT, col_val INT)
AS
BEGIN
    -- Créer une table temporaire avec toutes les positions possibles
    WITH Positions AS (
        SELECT 
            a.number AS row_val,
            b.number AS col_val
        FROM 
            (SELECT TOP (@rows) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number 
             FROM master.dbo.spt_values) a
        CROSS JOIN
            (SELECT TOP (@cols) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number 
             FROM master.dbo.spt_values) b
    )
    -- On utilise un tri basé sur des colonnes existantes pour avoir une forme de pseudo-aléatoire
    INSERT INTO @result (row_val, col_val)
    SELECT TOP 1 p.row_val, p.col_val
    FROM Positions p
    WHERE NOT EXISTS (
        SELECT 1
        FROM players_play pp
        WHERE 
            pp.origin_position_row = CAST(p.row_val AS VARCHAR) AND 
            pp.origin_position_col = CAST(p.col_val AS VARCHAR)
        UNION
        SELECT 1
        FROM players_play pp
        WHERE 
            pp.target_position_row = CAST(p.row_val AS VARCHAR) AND 
            pp.target_position_col = CAST(p.col_val AS VARCHAR)
    )
    ORDER BY 
        CHECKSUM(p.row_val * 17 + p.col_val * 31); 
    
    RETURN;
END;

/*Test de la fonction
SELECT * FROM random_position(5, 5);
*/

CREATE FUNCTION random_role()
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @role NVARCHAR(50);
    DECLARE @total_players INT;
    DECLARE @total_wolves INT;
    DECLARE @total_villagers INT;
    
    SELECT @total_players = COUNT(*) FROM players_in_parties;
    SELECT @total_wolves = COUNT(*) FROM players_in_parties pip
    JOIN roles r ON pip.id_role = r.id_role
    WHERE r.description_role = 'loup';
    SELECT @total_villagers = COUNT(*) FROM players_in_parties pip
    JOIN roles r ON pip.id_role = r.id_role
    WHERE r.description_role = 'villageois';
    
    -- Si moins de 25% de loups, attribuer un loup, sinon un villageois, c'est notre réflexion
    IF (@total_wolves * 4 <= @total_players)
        SET @role = 'loup';
    ELSE
        SET @role = 'villageois';
    
    RETURN @role;
END;

/* Test de la fonction
SELECT dbo.random_role();
*/

CREATE FUNCTION get_the_winner(@partyid INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        players.pseudo AS nom_du_joueur,
        roles.description_role AS role,
        parties.title_party AS nom_de_la_partie,
        COUNT(DISTINCT players_play.id_turn) AS nb_de_tours_joues_par_le_joueur,
        COUNT(DISTINCT turns.id_turn) AS nb_total_de_tours_de_la_partie,
        AVG(DATEDIFF(SECOND, turns.start_time, players_play.start_time)) AS temps_moyen_de_prise_de_decision
    FROM
        players
    JOIN players_in_parties ON players.id_player = players_in_parties.id_player
    JOIN players_play ON players.id_player = players_play.id_player
    JOIN turns ON players_play.id_turn = turns.id_turn
    JOIN parties ON turns.id_party = parties.id_party
    JOIN roles ON players_in_parties.id_role = roles.id_role
    WHERE
        parties.id_party = @partyid
    GROUP BY
        players.pseudo, roles.description_role, parties.title_party
);

/*
Test de la fonction
SELECT * FROM get_the_winner(1);
*/