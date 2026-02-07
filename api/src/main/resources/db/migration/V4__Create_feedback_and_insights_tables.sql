-- V4: Create feedback, insights, and transcripts tables
-- Feedback notes and voice notes metadata linked by event unique number
-- Consolidated insights table, must not store coach attribution for player facing outputs

-- Feedback notes linked by event unique number
CREATE TABLE feedback_note (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    note_text TEXT NOT NULL,
    note_type VARCHAR(50),
    is_player_facing BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_note_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_note_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE SET NULL,
    CONSTRAINT fk_feedback_note_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_note_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_note_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_note_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT
);

CREATE INDEX idx_feedback_note_event_id ON feedback_note(event_id);
CREATE INDEX idx_feedback_note_event_unique_number ON feedback_note(event_unique_number);
CREATE INDEX idx_feedback_note_session_id ON feedback_note(session_id);
CREATE INDEX idx_feedback_note_academy_id ON feedback_note(academy_id);
CREATE INDEX idx_feedback_note_sport_id ON feedback_note(sport_id);
CREATE INDEX idx_feedback_note_player_id ON feedback_note(player_id);
CREATE INDEX idx_feedback_note_creator_id ON feedback_note(created_by_user_id);
CREATE INDEX idx_feedback_note_player_facing ON feedback_note(is_player_facing);
CREATE INDEX idx_feedback_note_created_at ON feedback_note(created_at);

-- Voice notes metadata linked by event unique number
CREATE TABLE voice_note_metadata (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size_bytes BIGINT,
    duration_seconds INTEGER,
    mime_type VARCHAR(100),
    storage_location VARCHAR(255),
    is_player_facing BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_voice_note_metadata_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_metadata_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE SET NULL,
    CONSTRAINT fk_voice_note_metadata_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_metadata_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_metadata_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_metadata_creator FOREIGN KEY (created_by_user_id) REFERENCES app_user(id) ON DELETE RESTRICT
);

CREATE INDEX idx_voice_note_metadata_event_id ON voice_note_metadata(event_id);
CREATE INDEX idx_voice_note_metadata_event_unique_number ON voice_note_metadata(event_unique_number);
CREATE INDEX idx_voice_note_metadata_session_id ON voice_note_metadata(session_id);
CREATE INDEX idx_voice_note_metadata_academy_id ON voice_note_metadata(academy_id);
CREATE INDEX idx_voice_note_metadata_sport_id ON voice_note_metadata(sport_id);
CREATE INDEX idx_voice_note_metadata_player_id ON voice_note_metadata(player_id);
CREATE INDEX idx_voice_note_metadata_creator_id ON voice_note_metadata(created_by_user_id);
CREATE INDEX idx_voice_note_metadata_player_facing ON voice_note_metadata(is_player_facing);
CREATE INDEX idx_voice_note_metadata_created_at ON voice_note_metadata(created_at);

-- Transcript table for voice notes
CREATE TABLE voice_note_transcript (
    id BIGSERIAL PRIMARY KEY,
    voice_note_metadata_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    transcript_text TEXT NOT NULL,
    language_code VARCHAR(10) DEFAULT 'en',
    confidence_score DECIMAL(5, 4),
    transcribed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_voice_note_transcript_metadata FOREIGN KEY (voice_note_metadata_id) REFERENCES voice_note_metadata(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_transcript_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_transcript_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_voice_note_transcript_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    CONSTRAINT uk_voice_note_transcript_metadata UNIQUE (voice_note_metadata_id),
    CONSTRAINT chk_voice_note_transcript_confidence CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1))
);

CREATE INDEX idx_voice_note_transcript_metadata_id ON voice_note_transcript(voice_note_metadata_id);
CREATE INDEX idx_voice_note_transcript_event_id ON voice_note_transcript(event_id);
CREATE INDEX idx_voice_note_transcript_event_unique_number ON voice_note_transcript(event_unique_number);
CREATE INDEX idx_voice_note_transcript_academy_id ON voice_note_transcript(academy_id);
CREATE INDEX idx_voice_note_transcript_player_id ON voice_note_transcript(player_id);

-- Consolidated insights table
-- Must not store coach attribution for player facing outputs
CREATE TABLE consolidated_insight (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL,
    event_unique_number BIGINT NOT NULL,
    session_id BIGINT,
    academy_id BIGINT NOT NULL,
    sport_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    insight_type VARCHAR(100) NOT NULL,
    insight_category VARCHAR(100),
    insight_text TEXT NOT NULL,
    is_player_facing BOOLEAN NOT NULL DEFAULT false,
    -- Note: No created_by_user_id field for player-facing insights to avoid coach attribution
    -- For internal insights, coach attribution can be tracked via audit logs if needed
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consolidated_insight_event FOREIGN KEY (event_id) REFERENCES event(id) ON DELETE CASCADE,
    CONSTRAINT fk_consolidated_insight_session FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE SET NULL,
    CONSTRAINT fk_consolidated_insight_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE CASCADE,
    CONSTRAINT fk_consolidated_insight_sport FOREIGN KEY (sport_id) REFERENCES sport(id) ON DELETE CASCADE,
    CONSTRAINT fk_consolidated_insight_player FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
);

CREATE INDEX idx_consolidated_insight_event_id ON consolidated_insight(event_id);
CREATE INDEX idx_consolidated_insight_event_unique_number ON consolidated_insight(event_unique_number);
CREATE INDEX idx_consolidated_insight_session_id ON consolidated_insight(session_id);
CREATE INDEX idx_consolidated_insight_academy_id ON consolidated_insight(academy_id);
CREATE INDEX idx_consolidated_insight_sport_id ON consolidated_insight(sport_id);
CREATE INDEX idx_consolidated_insight_player_id ON consolidated_insight(player_id);
CREATE INDEX idx_consolidated_insight_type ON consolidated_insight(insight_type);
CREATE INDEX idx_consolidated_insight_player_facing ON consolidated_insight(is_player_facing);
CREATE INDEX idx_consolidated_insight_created_at ON consolidated_insight(created_at);
