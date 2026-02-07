-- V1: Create base tables for Academy, Sport, Team, User, and Player
-- Multi-tenant isolation enforced by academy_id
-- Immutable identity numbers for all entities

-- Academy table with immutable academy_number
CREATE TABLE academy (
    id BIGSERIAL PRIMARY KEY,
    academy_number BIGINT NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT academy_number_immutable CHECK (academy_number > 0)
);

CREATE INDEX idx_academy_number ON academy(academy_number);
CREATE INDEX idx_academy_created_at ON academy(created_at);

-- Academy branding settings
CREATE TABLE academy_branding (
    id BIGSERIAL PRIMARY KEY,
    academy_id BIGINT NOT NULL,
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    theme_settings JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_academy_branding_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_academy_branding_academy UNIQUE (academy_id)
);

CREATE INDEX idx_academy_branding_academy_id ON academy_branding(academy_id);

-- Sport within academy with immutable sport_unit_number
CREATE TABLE sport (
    id BIGSERIAL PRIMARY KEY,
    academy_id BIGINT NOT NULL,
    sport_unit_number BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sport_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_sport_academy_unit_number UNIQUE (academy_id, sport_unit_number),
    CONSTRAINT sport_unit_number_immutable CHECK (sport_unit_number > 0)
);

CREATE INDEX idx_sport_academy_id ON sport(academy_id);
CREATE INDEX idx_sport_unit_number ON sport(sport_unit_number);
CREATE INDEX idx_sport_academy_unit_number ON sport(academy_id, sport_unit_number);

-- Team within sport with immutable team_unit_number
CREATE TABLE team (
    id BIGSERIAL PRIMARY KEY,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    team_unit_number BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_team_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_team_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_team_sport_unit_number UNIQUE (sport_id, team_unit_number),
    CONSTRAINT team_unit_number_immutable CHECK (team_unit_number > 0)
);

CREATE INDEX idx_team_sport_id ON team(sport_id);
CREATE INDEX idx_team_academy_id ON team(academy_id);
CREATE INDEX idx_team_unit_number ON team(team_unit_number);
CREATE INDEX idx_team_sport_unit_number ON team(sport_id, team_unit_number);

-- User table with immutable user_number
CREATE TABLE app_user (
    id BIGSERIAL PRIMARY KEY,
    user_number BIGINT NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_number_immutable CHECK (user_number > 0)
);

CREATE INDEX idx_user_number ON app_user(user_number);
CREATE INDEX idx_user_email ON app_user(email);
CREATE INDEX idx_user_active ON app_user(is_active);

-- User role assignments (multi-tenant aware)
CREATE TABLE user_role (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    academy_id BIGINT,
    sport_id BIGINT,
    team_id BIGINT,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE CASCADE,
    CONSTRAINT chk_user_role_valid CHECK (
        (academy_id IS NOT NULL) OR
        (sport_id IS NOT NULL) OR
        (team_id IS NOT NULL)
    )
);

CREATE INDEX idx_user_role_user_id ON user_role(user_id);
CREATE INDEX idx_user_role_academy_id ON user_role(academy_id);
CREATE INDEX idx_user_role_sport_id ON user_role(sport_id);
CREATE INDEX idx_user_role_team_id ON user_role(team_id);

-- User membership to academies, sports, teams
CREATE TABLE user_membership (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    academy_id BIGINT,
    sport_id BIGINT,
    team_id BIGINT,
    membership_type VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT fk_user_membership_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_membership_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_membership_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_membership_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE CASCADE,
    CONSTRAINT chk_user_membership_valid CHECK (
        (academy_id IS NOT NULL) OR
        (sport_id IS NOT NULL) OR
        (team_id IS NOT NULL)
    )
);

CREATE INDEX idx_user_membership_user_id ON user_membership(user_id);
CREATE INDEX idx_user_membership_academy_id ON user_membership(academy_id);
CREATE INDEX idx_user_membership_sport_id ON user_membership(sport_id);
CREATE INDEX idx_user_membership_team_id ON user_membership(team_id);
CREATE INDEX idx_user_membership_active ON user_membership(is_active);

-- Player table with immutable global player system number
CREATE TABLE player (
    id BIGSERIAL PRIMARY KEY,
    player_system_number BIGINT NOT NULL UNIQUE,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT player_system_number_immutable CHECK (player_system_number > 0)
);

CREATE INDEX idx_player_system_number ON player(player_system_number);
CREATE INDEX idx_player_name ON player(last_name, first_name);

-- Player links to academies, sports, teams, positions, events with history
CREATE TABLE player_academy_link (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT fk_player_academy_link_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_academy_link_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE
);

CREATE INDEX idx_player_academy_link_player_id ON player_academy_link(player_id);
CREATE INDEX idx_player_academy_link_academy_id ON player_academy_link(academy_id);
CREATE INDEX idx_player_academy_link_active ON player_academy_link(is_active);

-- Historical version table for player academy links
CREATE TABLE player_academy_link_history (
    id BIGSERIAL PRIMARY KEY,
    player_academy_link_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL,
    left_at TIMESTAMP WITH TIME ZONE,
    version_number INTEGER NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id BIGINT,
    CONSTRAINT fk_player_academy_link_history_link FOREIGN KEY (player_academy_link_id) REFERENCES player_academy_link(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_academy_link_history_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_academy_link_history_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_academy_link_history_user FOREIGN KEY (changed_by_user_id) REFERENCES app_user(id) ON DELETE SET NULL
);

CREATE INDEX idx_player_academy_link_history_link_id ON player_academy_link_history(player_academy_link_id);
CREATE INDEX idx_player_academy_link_history_player_id ON player_academy_link_history(player_id);
CREATE INDEX idx_player_academy_link_history_academy_id ON player_academy_link_history(academy_id);

CREATE TABLE player_sport_link (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT fk_player_sport_link_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_sport_link_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_sport_link_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE
);

CREATE INDEX idx_player_sport_link_player_id ON player_sport_link(player_id);
CREATE INDEX idx_player_sport_link_sport_id ON player_sport_link(sport_id);
CREATE INDEX idx_player_sport_link_academy_id ON player_sport_link(academy_id);
CREATE INDEX idx_player_sport_link_active ON player_sport_link(is_active);

CREATE TABLE player_sport_link_history (
    id BIGSERIAL PRIMARY KEY,
    player_sport_link_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL,
    left_at TIMESTAMP WITH TIME ZONE,
    version_number INTEGER NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id BIGINT,
    CONSTRAINT fk_player_sport_link_history_link FOREIGN KEY (player_sport_link_id) REFERENCES player_sport_link(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_sport_link_history_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_sport_link_history_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_sport_link_history_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_sport_link_history_user FOREIGN KEY (changed_by_user_id) REFERENCES app_user(id) ON DELETE SET NULL
);

CREATE INDEX idx_player_sport_link_history_link_id ON player_sport_link_history(player_sport_link_id);
CREATE INDEX idx_player_sport_link_history_player_id ON player_sport_link_history(player_id);

CREATE TABLE player_team_link (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT fk_player_team_link_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE
);

CREATE INDEX idx_player_team_link_player_id ON player_team_link(player_id);
CREATE INDEX idx_player_team_link_team_id ON player_team_link(team_id);
CREATE INDEX idx_player_team_link_sport_id ON player_team_link(sport_id);
CREATE INDEX idx_player_team_link_academy_id ON player_team_link(academy_id);
CREATE INDEX idx_player_team_link_active ON player_team_link(is_active);

CREATE TABLE player_team_link_history (
    id BIGSERIAL PRIMARY KEY,
    player_team_link_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL,
    left_at TIMESTAMP WITH TIME ZONE,
    version_number INTEGER NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id BIGINT,
    CONSTRAINT fk_player_team_link_history_link FOREIGN KEY (player_team_link_id) REFERENCES player_team_link(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_history_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_history_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_history_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_history_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_team_link_history_user FOREIGN KEY (changed_by_user_id) REFERENCES app_user(id) ON DELETE SET NULL
);

CREATE INDEX idx_player_team_link_history_link_id ON player_team_link_history(player_team_link_id);
CREATE INDEX idx_player_team_link_history_player_id ON player_team_link_history(player_id);
