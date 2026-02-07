-- V5: Create reporting tables
-- Reports tables for training, match, skill and trial
-- Daily stats
-- Final reports with approvals and delivery logs

-- Training report
CREATE TABLE training_report (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    player_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    report_data JSONB NOT NULL,
    overall_rating DECIMAL(3, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_training_report_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_training_report_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE,
    CONSTRAINT fk_training_report_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_training_report_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_training_report_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_training_report_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_training_report_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT uk_training_report_session_player UNIQUE (session_id, player_id),
    CONSTRAINT chk_training_report_rating CHECK (overall_rating IS NULL OR (overall_rating >= 0 AND overall_rating <= 10))
);

CREATE INDEX idx_training_report_event_id ON training_report(event_id);
CREATE INDEX idx_training_report_event_unique_number ON training_report(event_unique_number);
CREATE INDEX idx_training_report_session_id ON training_report(session_id);
CREATE INDEX idx_training_report_academy_id ON training_report(academy_id);
CREATE INDEX idx_training_report_sport_id ON training_report(sport_id);
CREATE INDEX idx_training_report_team_id ON training_report(team_id);
CREATE INDEX idx_training_report_player_id ON training_report(player_id);
CREATE INDEX idx_training_report_creator_id ON training_report(created_by_user_id);
CREATE INDEX idx_training_report_created_at ON training_report(created_at);

-- Match report
CREATE TABLE match_report (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    player_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    report_data JSONB NOT NULL,
    overall_rating DECIMAL(3, 2),
    minutes_played INTEGER,
    goals_scored INTEGER,
    assists INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_report_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_report_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_report_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_report_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_report_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_match_report_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_report_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT uk_match_report_session_player UNIQUE (session_id, player_id),
    CONSTRAINT chk_match_report_rating CHECK (overall_rating IS NULL OR (overall_rating >= 0 AND overall_rating <= 10)),
    CONSTRAINT chk_match_report_minutes CHECK (minutes_played IS NULL OR minutes_played >= 0),
    CONSTRAINT chk_match_report_goals CHECK (goals_scored IS NULL OR goals_scored >= 0),
    CONSTRAINT chk_match_report_assists CHECK (assists IS NULL OR assists >= 0)
);

CREATE INDEX idx_match_report_event_id ON match_report(event_id);
CREATE INDEX idx_match_report_event_unique_number ON match_report(event_unique_number);
CREATE INDEX idx_match_report_session_id ON match_report(session_id);
CREATE INDEX idx_match_report_academy_id ON match_report(academy_id);
CREATE INDEX idx_match_report_sport_id ON match_report(sport_id);
CREATE INDEX idx_match_report_team_id ON match_report(team_id);
CREATE INDEX idx_match_report_player_id ON match_report(player_id);
CREATE INDEX idx_match_report_creator_id ON match_report(created_by_user_id);
CREATE INDEX idx_match_report_created_at ON match_report(created_at);

-- Skill session report
CREATE TABLE skill_session_report (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    player_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    report_data JSONB NOT NULL,
    skill_assessments JSONB,
    overall_rating DECIMAL(3, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_skill_session_report_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_skill_session_report_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE,
    CONSTRAINT fk_skill_session_report_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_skill_session_report_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_skill_session_report_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_skill_session_report_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_skill_session_report_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT uk_skill_session_report_session_player UNIQUE (session_id, player_id),
    CONSTRAINT chk_skill_session_report_rating CHECK (overall_rating IS NULL OR (overall_rating >= 0 AND overall_rating <= 10))
);

CREATE INDEX idx_skill_session_report_event_id ON skill_session_report(event_id);
CREATE INDEX idx_skill_session_report_event_unique_number ON skill_session_report(event_unique_number);
CREATE INDEX idx_skill_session_report_session_id ON skill_session_report(session_id);
CREATE INDEX idx_skill_session_report_academy_id ON skill_session_report(academy_id);
CREATE INDEX idx_skill_session_report_sport_id ON skill_session_report(sport_id);
CREATE INDEX idx_skill_session_report_team_id ON skill_session_report(team_id);
CREATE INDEX idx_skill_session_report_player_id ON skill_session_report(player_id);
CREATE INDEX idx_skill_session_report_creator_id ON skill_session_report(created_by_user_id);
CREATE INDEX idx_skill_session_report_created_at ON skill_session_report(created_at);

-- Trial session report
CREATE TABLE trial_session_report (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    player_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    report_data JSONB NOT NULL,
    overall_rating DECIMAL(3, 2),
    recommendation VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trial_session_report_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_trial_session_report_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE,
    CONSTRAINT fk_trial_session_report_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_trial_session_report_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_trial_session_report_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_trial_session_report_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_trial_session_report_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT uk_trial_session_report_session_player UNIQUE (session_id, player_id),
    CONSTRAINT chk_trial_session_report_rating CHECK (overall_rating IS NULL OR (overall_rating >= 0 AND overall_rating <= 10))
);

CREATE INDEX idx_trial_session_report_event_id ON trial_session_report(event_id);
CREATE INDEX idx_trial_session_report_event_unique_number ON trial_session_report(event_unique_number);
CREATE INDEX idx_trial_session_report_session_id ON trial_session_report(session_id);
CREATE INDEX idx_trial_session_report_academy_id ON trial_session_report(academy_id);
CREATE INDEX idx_trial_session_report_sport_id ON trial_session_report(sport_id);
CREATE INDEX idx_trial_session_report_team_id ON trial_session_report(team_id);
CREATE INDEX idx_trial_session_report_player_id ON trial_session_report(player_id);
CREATE INDEX idx_trial_session_report_creator_id ON trial_session_report(created_by_user_id);
CREATE INDEX idx_trial_session_report_created_at ON trial_session_report(created_at);

-- Daily stats
CREATE TABLE daily_stats (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    player_id BIGINT NOT NULL,
    stats_date DATE NOT NULL,
    stats_data JSONB NOT NULL,
    total_sessions INTEGER NOT NULL DEFAULT 0,
    total_training_sessions INTEGER NOT NULL DEFAULT 0,
    total_match_sessions INTEGER NOT NULL DEFAULT 0,
    total_skill_sessions INTEGER NOT NULL DEFAULT 0,
    total_trial_sessions INTEGER NOT NULL DEFAULT 0,
    average_rating DECIMAL(3, 2),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_daily_stats_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_daily_stats_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_daily_stats_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_daily_stats_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_daily_stats_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT uk_daily_stats_event_player_date UNIQUE (event_id, player_id, stats_date),
    CONSTRAINT chk_daily_stats_sessions CHECK (total_sessions >= 0 AND total_training_sessions >= 0 AND total_match_sessions >= 0 AND total_skill_sessions >= 0 AND total_trial_sessions >= 0),
    CONSTRAINT chk_daily_stats_rating CHECK (average_rating IS NULL OR (average_rating >= 0 AND average_rating <= 10))
);

CREATE INDEX idx_daily_stats_event_id ON daily_stats(event_id);
CREATE INDEX idx_daily_stats_event_unique_number ON daily_stats(event_unique_number);
CREATE INDEX idx_daily_stats_academy_id ON daily_stats(academy_id);
CREATE INDEX idx_daily_stats_sport_id ON daily_stats(sport_id);
CREATE INDEX idx_daily_stats_team_id ON daily_stats(team_id);
CREATE INDEX idx_daily_stats_player_id ON daily_stats(player_id);
CREATE INDEX idx_daily_stats_date ON daily_stats(stats_date);
CREATE INDEX idx_daily_stats_event_player_date ON daily_stats(event_id, player_id, stats_date);

-- Final reports
CREATE TABLE final_report (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    team_id BIGINT,
    player_id BIGINT NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    report_data JSONB NOT NULL,
    summary_text TEXT,
    overall_rating DECIMAL(3, 2),
    status VARCHAR(50) NOT NULL DEFAULT 'Draft',
    created_by_user_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_final_report_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_final_report_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_final_report_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_final_report_team FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL,
    CONSTRAINT fk_final_report_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_final_report_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT uk_final_report_event_player_type UNIQUE (event_id, player_id, report_type),
    CONSTRAINT chk_final_report_rating CHECK (overall_rating IS NULL OR (overall_rating >= 0 AND overall_rating <= 10)),
    CONSTRAINT chk_final_report_status CHECK (status IN ('Draft', 'Pending Approval', 'Approved', 'Rejected', 'Delivered'))
);

CREATE INDEX idx_final_report_event_id ON final_report(event_id);
CREATE INDEX idx_final_report_event_unique_number ON final_report(event_unique_number);
CREATE INDEX idx_final_report_academy_id ON final_report(academy_id);
CREATE INDEX idx_final_report_sport_id ON final_report(sport_id);
CREATE INDEX idx_final_report_team_id ON final_report(team_id);
CREATE INDEX idx_final_report_player_id ON final_report(player_id);
CREATE INDEX idx_final_report_creator_id ON final_report(created_by_user_id);
CREATE INDEX idx_final_report_status ON final_report(status);
CREATE INDEX idx_final_report_created_at ON final_report(created_at);

-- Report approvals
CREATE TABLE report_approval (
    id BIGSERIAL PRIMARY KEY,
    final_report_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    approved_by_user_id BIGINT NOT NULL,
    approval_status VARCHAR(50) NOT NULL,
    approval_notes TEXT,
    approved_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_report_approval_final_report FOREIGN KEY (final_report_id) REFERENCES final_report(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_approval_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_approval_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_approval_approver FOREIGN KEY (approved_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT,
    CONSTRAINT chk_report_approval_status CHECK (approval_status IN ('Approved', 'Rejected', 'Pending'))
);

CREATE INDEX idx_report_approval_final_report_id ON report_approval(final_report_id);
CREATE INDEX idx_report_approval_event_id ON report_approval(event_id);
CREATE INDEX idx_report_approval_event_unique_number ON report_approval(event_unique_number);
CREATE INDEX idx_report_approval_academy_id ON report_approval(academy_id);
CREATE INDEX idx_report_approval_approver_id ON report_approval(approved_by_user_id);
CREATE INDEX idx_report_approval_status ON report_approval(approval_status);
CREATE INDEX idx_report_approval_approved_at ON report_approval(approved_at);

-- Report delivery logs
CREATE TABLE report_delivery_log (
    id BIGSERIAL PRIMARY KEY,
    final_report_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    delivery_method VARCHAR(50) NOT NULL,
    delivery_status VARCHAR(50) NOT NULL,
    delivery_recipient VARCHAR(255),
    delivery_metadata JSONB,
    delivered_by_user_id BIGINT,
    delivered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    error_message TEXT,
    CONSTRAINT fk_report_delivery_log_final_report FOREIGN KEY (final_report_id) REFERENCES final_report(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_delivery_log_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_delivery_log_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_delivery_log_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_delivery_log_deliverer FOREIGN KEY (delivered_by_user_id) REFERENCES app_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_report_delivery_log_status CHECK (delivery_status IN ('Pending', 'Delivered', 'Failed', 'Bounced'))
);

CREATE INDEX idx_report_delivery_log_final_report_id ON report_delivery_log(final_report_id);
CREATE INDEX idx_report_delivery_log_event_id ON report_delivery_log(event_id);
CREATE INDEX idx_report_delivery_log_event_unique_number ON report_delivery_log(event_unique_number);
CREATE INDEX idx_report_delivery_log_academy_id ON report_delivery_log(academy_id);
CREATE INDEX idx_report_delivery_log_player_id ON report_delivery_log(player_id);
CREATE INDEX idx_report_delivery_log_status ON report_delivery_log(delivery_status);
CREATE INDEX idx_report_delivery_log_delivered_at ON report_delivery_log(delivered_at);
