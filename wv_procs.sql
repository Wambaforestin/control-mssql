CREATE PROCEDURE SEED_DATA
    @NB_PLAYERS INT,
    @PARTY_ID INT
AS
BEGIN
    DECLARE @tour_count INT;
    DECLARE @max_tours INT;
    
    -- Récupération du nombre maximum de tours pour cette partie
    SELECT @max_tours = COUNT(*) FROM turns WHERE id_party = @PARTY_ID;
    
    -- Initiation du compteur à 0
    SET @tour_count = 0;
    
    -- Création de plusieurs tours que nécessaire
    WHILE @tour_count < @max_tours
    BEGIN
        -- Créeation d'un nouveau tour
        INSERT INTO turns (id_party, start_time, end_time)
        VALUES (@PARTY_ID, GETDATE(), DATEADD(MINUTE, 5, GETDATE()));
        
        -- Incrémentation du compteur
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
    
    -- Récupération des actions des joueurs pour ce tour
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
    
    -- Ouverture du curseur
    OPEN actions;
    
    -- Lecture de la première ligne
    FETCH NEXT FROM actions INTO @player_id, @action, @origin_position_col, @origin_position_row, @target_position_col, @target_position_row;
    
    -- si il y'a d'autre ligne
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Mise à jour de la position du joueur
        UPDATE players_play
        SET end_time = GETDATE()
        WHERE id_player = @player_id AND id_turn = @TOUR_ID;
        
        -- Lire la ligne suivant
        FETCH NEXT FROM actions INTO @player_id, @action, @origin_position_col, @origin_position_row, @target_position_col, @target_position_row;
    END;
    
    -- terminer l'action du curseur 
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
    --utilisation des polices minuscules 
    UPDATE players
    SET pseudo = LOWER(pseudo);
END;
/*
test de la procédure
-- EXEC USERNAME_TO_LOWER;
*/
