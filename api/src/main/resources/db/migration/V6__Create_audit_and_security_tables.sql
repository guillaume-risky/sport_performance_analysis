-- V6: Create audit and security tables
-- OTP logs
-- Audit logs
-- Blocked access attempts logs

-- OTP logs
CREATE TABLE otp_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    email VARCHAR(255) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    otp_type VARCHAR(50) NOT NULL,
    purpose VARCHAR(100),
    is_used BOOLEAN NOT NULL DEFAULT false,
    is_expired BOOLEAN NOT NULL DEFAULT false,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_otp_log_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_otp_log_code CHECK (LENGTH(otp_code) >= 4 AND LENGTH(otp_code) <= 10)
);

CREATE INDEX idx_otp_log_user_id ON otp_log(user_id);
CREATE INDEX idx_otp_log_email ON otp_log(email);
CREATE INDEX idx_otp_log_code ON otp_log(otp_code);
CREATE INDEX idx_otp_log_type ON otp_log(otp_type);
CREATE INDEX idx_otp_log_used ON otp_log(is_used);
CREATE INDEX idx_otp_log_expires_at ON otp_log(expires_at);
CREATE INDEX idx_otp_log_created_at ON otp_log(created_at);

-- Audit logs for tracking all critical data changes
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    academy_id BIGINT,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT,
    entity_number BIGINT,
    old_values JSONB,
    new_values JSONB,
    change_description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    request_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_log_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE SET NULL,
    CONSTRAINT fk_audit_log_academy FOREIGN KEY (academy_id) REFERENCES academy(id) ON DELETE SET NULL
);

CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX idx_audit_log_academy_id ON audit_log(academy_id);
CREATE INDEX idx_audit_log_action_type ON audit_log(action_type);
CREATE INDEX idx_audit_log_entity_type ON audit_log(entity_type);
CREATE INDEX idx_audit_log_entity_id ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_entity_number ON audit_log(entity_type, entity_number);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at);

-- Blocked access attempts logs
CREATE TABLE blocked_access_attempt (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    email VARCHAR(255),
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    attempt_type VARCHAR(50) NOT NULL,
    reason VARCHAR(255),
    blocked_until TIMESTAMP WITH TIME ZONE,
    is_permanent BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_blocked_access_attempt_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_blocked_access_attempt_identifier CHECK (
        user_id IS NOT NULL OR email IS NOT NULL OR ip_address IS NOT NULL
    )
);

CREATE INDEX idx_blocked_access_attempt_user_id ON blocked_access_attempt(user_id);
CREATE INDEX idx_blocked_access_attempt_email ON blocked_access_attempt(email);
CREATE INDEX idx_blocked_access_attempt_ip_address ON blocked_access_attempt(ip_address);
CREATE INDEX idx_blocked_access_attempt_type ON blocked_access_attempt(attempt_type);
CREATE INDEX idx_blocked_access_attempt_blocked_until ON blocked_access_attempt(blocked_until);
CREATE INDEX idx_blocked_access_attempt_permanent ON blocked_access_attempt(is_permanent);
CREATE INDEX idx_blocked_access_attempt_created_at ON blocked_access_attempt(created_at);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at columns on key tables
CREATE TRIGGER update_academy_updated_at BEFORE UPDATE ON academy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_academy_branding_updated_at BEFORE UPDATE ON academy_branding
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sport_updated_at BEFORE UPDATE ON sport
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_team_updated_at BEFORE UPDATE ON team
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_app_user_updated_at BEFORE UPDATE ON app_user
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_updated_at BEFORE UPDATE ON player
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_position_updated_at BEFORE UPDATE ON position
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_updated_at BEFORE UPDATE ON skill
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_set_updated_at BEFORE UPDATE ON skill_set
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_updated_at BEFORE UPDATE ON event
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_session_updated_at BEFORE UPDATE ON session
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reporting_day_control_updated_at BEFORE UPDATE ON reporting_day_control
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feedback_note_updated_at BEFORE UPDATE ON feedback_note
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_voice_note_metadata_updated_at BEFORE UPDATE ON voice_note_metadata
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_voice_note_transcript_updated_at BEFORE UPDATE ON voice_note_transcript
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consolidated_insight_updated_at BEFORE UPDATE ON consolidated_insight
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_report_updated_at BEFORE UPDATE ON training_report
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_report_updated_at BEFORE UPDATE ON match_report
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_session_report_updated_at BEFORE UPDATE ON skill_session_report
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trial_session_report_updated_at BEFORE UPDATE ON trial_session_report
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_stats_updated_at BEFORE UPDATE ON daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_final_report_updated_at BEFORE UPDATE ON final_report
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
