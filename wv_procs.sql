CREATE PROCEDURE SEED_DATA
    @NB_PLAYERS INT,
    @PARTY_ID INT
AS
BEGIN
    DECLARE @tour_count INT;
    DECLARE @max_tours INT;
    
    -- Récupérer le nombre maximum de tours pour cette partie
    SELECT @max_tours = COUNT(*) FROM turns WHERE id_party = @PARTY_ID;
    
    -- Initialiser le compteur à 0
    SET @tour_count = 0;
    
    -- Créer autant de tours que nécessaire
    WHILE @tour_count < @max_tours
    BEGIN
        -- Créer un nouveau tour
        INSERT INTO turns (id_party, start_time, end_time)
        VALUES (@PARTY_ID, GETDATE(), DATEADD(MINUTE, 5, GETDATE()));
        
        -- Incrémenter le compteur
        SET @tour_count = @tour_count + 1;
    END;
END;
/*
test de la procédure
-- EXEC SEED_DATA 5, 1;
*/

CREATE PROCEDURE COMPLETE_TOUR
    @TOUR_ID INT,
    @PARTY_ID INT
AS
BEGIN
    DECLARE @player_id INT;
    DECLARE @action VARCHAR(10);
    DECLARE @origin_position_col VARCHAR(255);
    DECLARE @origin_position_row VARCHAR(255);
    DECLARE @target_position_col VARCHAR(255);
    DECLARE @target_position_row VARCHAR(255);
    
    -- Récupérer les actions des joueurs pour ce tour
    DECLARE actions CURSOR FOR
    SELECT 
        id_player,
        action,
        origin_position_col,
        origin_position_row,
        target_position_col,
        target_position_row
    FROM players_play
    WHERE id_turn = @TOUR_ID;
    
    -- Ouvrir le curseur
    OPEN actions;
    
    -- Lire la première ligne
    FETCH NEXT FROM actions INTO @player_id, @action, @origin_position_col, @origin_position_row, @target_position_col, @target_position_row;
    
    -- Tant qu'il y a des lignes à lire
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Mettre à jour la position du joueur
        UPDATE players_play
        SET end_time = GETDATE()
        WHERE id_player = @player_id AND id_turn = @TOUR_ID;
        
        -- Lire la ligne suivante
        FETCH NEXT FROM actions INTO @player_id, @action, @origin_position_col, @origin_position_row, @target_position_col, @target_position_row;
    END;
    
    -- Fermer le curseur
    CLOSE actions;
    DEALLOCATE actions;
END;
/*
test de la procédure
-- EXEC COMPLETE_TOUR 1, 1;
*/

CREATE PROCEDURE USERNAME_TO_LOWER
AS
BEGIN
    -- Mettre les noms des joueurs en minuscule
    UPDATE players
    SET pseudo = LOWER(pseudo);
END;
/*
test de la procédure
-- EXEC USERNAME_TO_LOWER;
*/
