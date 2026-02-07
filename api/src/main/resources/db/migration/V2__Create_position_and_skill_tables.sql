-- V2: Create positions and skills tables
-- Positions per sport, skills per sport, skill sets reusable, skill requirements per position

-- Positions per sport
CREATE TABLE position (
    id BIGSERIAL PRIMARY KEY,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    description TEXT,
    display_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_position_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_position_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_position_sport_name UNIQUE (sport_id, name)
);

CREATE INDEX idx_position_sport_id ON position(sport_id);
CREATE INDEX idx_position_academy_id ON position(academy_id);
CREATE INDEX idx_position_display_order ON position(sport_id, display_order);

-- Player position assignments (with history)
CREATE TABLE player_position (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    position_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unassigned_at TIMESTAMP WITH TIME ZONE,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT fk_player_position_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_position FOREIGN KEY (position_id) REFERENCES position(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE
);

CREATE INDEX idx_player_position_player_id ON player_position(player_id);
CREATE INDEX idx_player_position_position_id ON player_position(position_id);
CREATE INDEX idx_player_position_sport_id ON player_position(sport_id);
CREATE INDEX idx_player_position_academy_id ON player_position(academy_id);
CREATE INDEX idx_player_position_active ON player_position(is_active);

CREATE TABLE player_position_history (
    id BIGSERIAL PRIMARY KEY,
    player_position_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    position_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE NOT NULL,
    unassigned_at TIMESTAMP WITH TIME ZONE,
    is_primary BOOLEAN NOT NULL,
    version_number INTEGER NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id BIGINT,
    CONSTRAINT fk_player_position_history_assignment FOREIGN KEY (player_position_id) REFERENCES player_position(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_history_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_history_position FOREIGN KEY (position_id) REFERENCES position(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_history_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_history_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_player_position_history_user FOREIGN KEY (changed_by_user_id) REFERENCES app_user(id) ON DELETE SET NULL
);

CREATE INDEX idx_player_position_history_assignment_id ON player_position_history(player_position_id);
CREATE INDEX idx_player_position_history_player_id ON player_position_history(player_id);

-- Skill sets (reusable across sports/academies)
CREATE TABLE skill_set (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_skill_set_name ON skill_set(name);

-- Skills per sport (linked to skill sets)
CREATE TABLE skill (
    id BIGSERIAL PRIMARY KEY,
    skill_set_id BIGINT,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    skill_category VARCHAR(100),
    measurement_unit VARCHAR(50),
    display_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_skill_skill_set FOREIGN KEY (skill_set_id) REFERENCES skill_set(id) ON DELETE SET NULL,
    CONSTRAINT fk_skill_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_skill_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_skill_sport_name UNIQUE (sport_id, name)
);

CREATE INDEX idx_skill_skill_set_id ON skill(skill_set_id);
CREATE INDEX idx_skill_sport_id ON skill(sport_id);
CREATE INDEX idx_skill_academy_id ON skill(academy_id);
CREATE INDEX idx_skill_display_order ON skill(sport_id, display_order);

-- Skill requirements per position
CREATE TABLE position_skill_requirement (
    id BIGSERIAL PRIMARY KEY,
    position_id BIGINT NOT NULL,
    skill_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT true,
    priority_level INTEGER,
    target_value DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_position_skill_requirement_position FOREIGN KEY (position_id) REFERENCES position(id) ON DELETE CASCADE,
    CONSTRAINT fk_position_skill_requirement_skill FOREIGN KEY (skill_id) REFERENCES skill(id) ON DELETE CASCADE,
    CONSTRAINT fk_position_skill_requirement_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_position_skill_requirement_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_position_skill_requirement UNIQUE (position_id, skill_id)
);

CREATE INDEX idx_position_skill_requirement_position_id ON position_skill_requirement(position_id);
CREATE INDEX idx_position_skill_requirement_skill_id ON position_skill_requirement(skill_id);
CREATE INDEX idx_position_skill_requirement_sport_id ON position_skill_requirement(sport_id);
CREATE INDEX idx_position_skill_requirement_academy_id ON position_skill_requirement(academy_id);
