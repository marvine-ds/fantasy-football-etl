-- Create database
CREATE DATABASE IF NOT EXISTS fantasy_football;
USE fantasy_football;

-- ======================
-- Teams table
-- ======================
CREATE TABLE teams (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(50) NOT NULL,
    strength INT NOT NULL,
    attack_strength INT NOT NULL,
    defence_strength INT NOT NULL
);

-- ======================
-- Players table
-- ======================
CREATE TABLE players (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    team_id INT NOT NULL,
    position INT NOT NULL,
    cost DECIMAL(4,1) NOT NULL,
    status VARCHAR(20) NOT NULL,
    minutes INT DEFAULT 0,
    total_points INT DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- ======================
-- Events (Gameweeks) table
-- ======================
CREATE TABLE events (
    event_id INT PRIMARY KEY,
    gameweek INT NOT NULL,
    deadline_time DATETIME NOT NULL,
    finished BOOLEAN NOT NULL,
    average_points INT
);

-- ======================
-- Fact table: Player gameweek stats
-- ======================
CREATE TABLE player_gameweek_stats (
    player_id INT NOT NULL,
    event_id INT NOT NULL,
    points INT NOT NULL,
    minutes INT NOT NULL,

    PRIMARY KEY (player_id, event_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);
