-- V3: Create events and sessions tables
-- Events with event unique number and event admin, types Normal and VIP Selection
-- Sessions under events, can span multiple dates, types Training, Match, Skill Session, Trial Session
-- Event invited contributors table and invite links
-- Reporting day open close controls

-- Events table with event unique number
CREATE TABLE event (
    id BIGSERIAL PRIMARY KEY,
    event_unique_number BIGINT NOT NULL UNIQUE,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    event_admin_user_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('Normal', 'VIP Selection')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Draft',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_event_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_event_admin_user FOREIGN KEY (event_admin_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT chk_event_dates CHECK (end_date >= start_date),
    CONSTRAINT event_unique_number_immutable CHECK (event_unique_number > 0)
);

CREATE INDEX idx_event_unique_number ON event(event_unique_number);
CREATE INDEX idx_event_academy_id ON event(academy_id);
CREATE INDEX idx_event_sport_id ON event(sport_id);
CREATE INDEX idx_event_team_id ON event(team_id);
CREATE INDEX idx_event_admin_user_id ON event(event_admin_user_id);
CREATE INDEX idx_event_type ON event(event_type);
CREATE INDEX idx_event_dates ON event(start_date, end_date);
CREATE INDEX idx_event_status ON event(status);

-- Sessions under events, can span multiple dates
CREATE TABLE session (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    session_number INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    session_type VARCHAR(50) NOT NULL CHECK (session_type IN ('Training', 'Match', 'Skill Session', 'Trial Session')),
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'Scheduled',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_session_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_session_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_session_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT uk_session_event_number UNIQUE (event_id, session_number),
    CONSTRAINT chk_session_datetimes CHECK (end_datetime > start_datetime)
);

CREATE INDEX idx_session_event_id ON session(event_id);
CREATE INDEX idx_session_event_unique_number ON session(event_unique_number);
CREATE INDEX idx_session_academy_id ON session(academy_id);
CREATE INDEX idx_session_sport_id ON session(sport_id);
CREATE INDEX idx_session_type ON session(session_type);
CREATE INDEX idx_session_datetimes ON session(start_datetime, end_datetime);
CREATE INDEX idx_session_status ON session(status);

-- Event invited contributors
CREATE TABLE event_invited_contributor (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    role VARCHAR(100) NOT NULL,
    invited_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP WITH TIME ZONE,
    declined_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_event_invited_contributor_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_invited_contributor_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_invited_contributor_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT uk_event_invited_contributor UNIQUE (event_id, user_id),
    CONSTRAINT chk_event_invited_contributor_status CHECK (status IN ('Pending', 'Accepted', 'Declined'))
);

CREATE INDEX idx_event_invited_contributor_event_id ON event_invited_contributor(event_id);
CREATE INDEX idx_event_invited_contributor_event_unique_number ON event_invited_contributor(event_unique_number);
CREATE INDEX idx_event_invited_contributor_user_id ON event_invited_contributor(user_id);
CREATE INDEX idx_event_invited_contributor_academy_id ON event_invited_contributor(academy_id);
CREATE INDEX idx_event_invited_contributor_status ON event_invited_contributor(status);

-- Event invite links
CREATE TABLE event_invite_link (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    invite_token VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(100) NOT NULL,
    max_uses INTEGER,
    current_uses INTEGER NOT NULL DEFAULT 0,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by_user_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_event_invite_link_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_invite_link_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_invite_link_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT chk_event_invite_link_uses CHECK (current_uses >= 0 AND (max_uses IS NULL OR current_uses <= max_uses))
);

CREATE INDEX idx_event_invite_link_event_id ON event_invite_link(event_id);
CREATE INDEX idx_event_invite_link_event_unique_number ON event_invite_link(event_unique_number);
CREATE INDEX idx_event_invite_link_academy_id ON event_invite_link(academy_id);
CREATE INDEX idx_event_invite_link_token ON event_invite_link(invite_token);
CREATE INDEX idx_event_invite_link_active ON event_invite_link(is_active);
CREATE INDEX idx_event_invite_link_expires_at ON event_invite_link(expires_at);

-- Reporting day open close controls
CREATE TABLE reporting_day_control (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    reporting_date DATE NOT NULL,
    opens_at TIMESTAMP WITH TIME ZONE NOT NULL,
    closes_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT true,
    controlled_by_user_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reporting_day_control_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_reporting_day_control_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_reporting_day_control_user FOREIGN KEY (controlled_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT uk_reporting_day_control_event_date UNIQUE (event_id, reporting_date),
    CONSTRAINT chk_reporting_day_control_times CHECK (closes_at > opens_at)
);

CREATE INDEX idx_reporting_day_control_event_id ON reporting_day_control(event_id);
CREATE INDEX idx_reporting_day_control_event_unique_number ON reporting_day_control(event_unique_number);
CREATE INDEX idx_reporting_day_control_academy_id ON reporting_day_control(academy_id);
CREATE INDEX idx_reporting_day_control_date ON reporting_day_control(reporting_date);
CREATE INDEX idx_reporting_day_control_open ON reporting_day_control(is_open);
