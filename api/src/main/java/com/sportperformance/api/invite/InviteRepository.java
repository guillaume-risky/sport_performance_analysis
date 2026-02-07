package com.sportperformance.api.invite;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public class InviteRepository {

    private final JdbcTemplate jdbcTemplate;

    public InviteRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<InviteToken> ROW_MAPPER = (rs, rowNum) -> new InviteToken(
        UUID.fromString(rs.getString("id")),
        rs.getString("token"),
        rs.getString("academy_number"),
        rs.getString("email"),
        rs.getString("role"),
        rs.getObject("expires_at", OffsetDateTime.class),
        rs.getObject("used_at", OffsetDateTime.class),
        rs.getObject("created_at", OffsetDateTime.class)
    );

    public InviteToken save(InviteToken inviteToken) {
        String sql = """
            INSERT INTO invite_token (id, token, academy_number, email, role, expires_at, used_at, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            RETURNING id, token, academy_number, email, role, expires_at, used_at, created_at
            """;
        
        return jdbcTemplate.queryForObject(sql, ROW_MAPPER,
            inviteToken.id(),
            inviteToken.token(),
            inviteToken.academyNumber(),
            inviteToken.email(),
            inviteToken.role(),
            inviteToken.expiresAt(),
            inviteToken.usedAt(),
            inviteToken.createdAt()
        );
    }

    public Optional<InviteToken> findByToken(String token) {
        String sql = """
            SELECT id, token, academy_number, email, role, expires_at, used_at, created_at
            FROM invite_token
            WHERE token = ?
            """;
        
        try {
            InviteToken inviteToken = jdbcTemplate.queryForObject(sql, ROW_MAPPER, token);
            return Optional.ofNullable(inviteToken);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public void markAsUsed(UUID id, OffsetDateTime usedAt) {
        String sql = "UPDATE invite_token SET used_at = ? WHERE id = ?";
        jdbcTemplate.update(sql, usedAt, id);
    }
}
